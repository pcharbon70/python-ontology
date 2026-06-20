# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.configurable_globs python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project.Discovery do
  @moduledoc """
  Discovers Python project roots and selected source files.
  """

  alias PythonOntology.IRI.Path, as: IRIPath
  alias PythonOntology.Project.Classifier
  alias PythonOntology.Project.Diagnostic
  alias PythonOntology.Project.Input
  alias PythonOntology.Project.Result
  alias PythonOntology.Project.SelectionPolicy
  alias PythonOntology.Project.SourceFile

  @root_markers [
    {"pyproject.toml", :pyproject, :file},
    {"setup.cfg", :setup_cfg, :file},
    {"setup.py", :setup_py, :file},
    {".git", :git, :any}
  ]

  @doc """
  Classifies the input path, detects its project root, and selects Python source files.
  """
  @spec discover(Path.t(), keyword()) :: {:ok, Result.t()} | {:error, Diagnostic.t()}
  def discover(path, opts \\ []) when is_list(opts) do
    with {:ok, input} <- Input.classify(path),
         {:ok, root_path, root_marker} <- detect_root(input),
         policy = SelectionPolicy.from_options(root_path, opts),
         {:ok, files, diagnostics, selection_metadata} <- selected_files(input, root_path, policy) do
      {:ok,
       %Result{
         mode: input.mode,
         input_path: input.path,
         root_path: root_path,
         root_marker: root_marker,
         files: files,
         diagnostics: diagnostics,
         metadata: Map.put(selection_metadata, :file_count, length(files))
       }}
    end
  end

  defp detect_root(%Input{mode: :file, path: path}) do
    start_dir = Path.dirname(path)
    root_from_ancestors(start_dir, start_dir)
  end

  defp detect_root(%Input{mode: :project, path: path}) do
    root_from_ancestors(path, path)
  end

  defp root_from_ancestors(directory, fallback_root) do
    case find_root_marker(directory) do
      {:ok, root_path, root_marker} -> {:ok, root_path, root_marker}
      :not_found -> {:ok, fallback_root, %{type: :explicit}}
    end
  end

  defp find_root_marker(directory) do
    directory
    |> ancestors()
    |> Enum.find_value(:not_found, fn candidate ->
      Enum.find_value(@root_markers, fn {marker_name, type, expected_kind} ->
        marker_path = Path.join(candidate, marker_name)

        if marker_exists?(marker_path, expected_kind) do
          {:ok, candidate, %{type: type, path: marker_path}}
        end
      end)
    end)
  end

  defp ancestors(directory) do
    directory
    |> Stream.unfold(fn
      nil ->
        nil

      current ->
        parent = Path.dirname(current)
        next = if parent == current, do: nil, else: parent
        {current, next}
    end)
  end

  defp marker_exists?(path, :file), do: File.regular?(path)
  defp marker_exists?(path, :any), do: File.exists?(path)

  defp selected_files(%Input{mode: :file, path: path}, root_path, policy) do
    case SelectionPolicy.file_decision(policy, path) do
      {:select, _reason} ->
        with {:ok, file} <- source_file(path, root_path) do
          {:ok, [file], [], count(empty_selection_metadata(), :selected_file)}
        end

      {:skip, reason} ->
        {:ok, [], [], count(empty_selection_metadata(), {:skipped_file, reason})}
    end
  end

  defp selected_files(%Input{mode: :project}, root_path, policy) do
    {paths, diagnostics, selection_metadata} = traverse(root_path, policy)

    files =
      paths
      |> Enum.sort_by(&source_sort_key(&1, root_path))
      |> Enum.map(&source_file!(&1, root_path))

    {:ok, files, diagnostics, selection_metadata}
  end

  defp traverse(root_path, policy), do: traverse_directory(root_path, policy)

  defp traverse_directory(directory, policy) do
    case File.ls(directory) do
      {:ok, entries} ->
        entries
        |> Enum.map(&Path.join(directory, &1))
        |> Enum.reduce({[], [], empty_selection_metadata()}, fn path,
                                                                {files, diagnostics, metadata} ->
          {nested_files, nested_diagnostics, nested_metadata} = traverse_path(path, policy)

          {files ++ nested_files, diagnostics ++ nested_diagnostics,
           merge_selection_metadata(metadata, nested_metadata)}
        end)

      {:error, reason} ->
        {[], [traversal_diagnostic(directory, reason)], empty_selection_metadata()}
    end
  end

  defp traverse_path(path, policy) do
    case File.lstat(path) do
      {:ok, %File.Stat{type: :regular}} ->
        case SelectionPolicy.file_decision(policy, path) do
          {:select, _reason} ->
            {[path], [], count(empty_selection_metadata(), :selected_file)}

          {:skip, reason} ->
            {[], [], count(empty_selection_metadata(), {:skipped_file, reason})}
        end

      {:ok, %File.Stat{type: :directory}} ->
        case SelectionPolicy.directory_decision(policy, path) do
          :traverse ->
            traverse_directory(path, policy)

          {:skip, reason} ->
            {[], [], count(empty_selection_metadata(), {:skipped_directory, reason})}
        end

      {:ok, _stat} ->
        {[], [], empty_selection_metadata()}

      {:error, reason} ->
        {[], [traversal_diagnostic(path, reason)], empty_selection_metadata()}
    end
  end

  defp source_sort_key(path, root_path) do
    case IRIPath.canonicalize(path, repository_root: root_path) do
      {:ok, relative_path} -> relative_path
      {:error, _diagnostic} -> path
    end
  end

  defp source_file!(path, root_path) do
    {:ok, file} = source_file(path, root_path)
    file
  end

  defp source_file(path, root_path) do
    with {:ok, relative_path} <- IRIPath.canonicalize(path, repository_root: root_path) do
      classification = Classifier.classify(path, relative_path, root_path)

      {:ok,
       struct!(
         SourceFile,
         Map.merge(classification, %{
           path: path,
           relative_path: relative_path,
           extension: Path.extname(path)
         })
       )}
    end
  end

  defp traversal_diagnostic(path, reason) do
    %Diagnostic{
      stage: :traversal,
      severity: :warning,
      message: "could not traverse project path: #{:file.format_error(reason)}",
      path: path,
      details: %{reason: reason}
    }
  end

  defp empty_selection_metadata do
    %{
      selected_count: 0,
      skipped_count: 0,
      skipped_file_count: 0,
      skipped_directory_count: 0,
      skipped_reasons: %{}
    }
  end

  defp count(metadata, :selected_file) do
    Map.update!(metadata, :selected_count, &(&1 + 1))
  end

  defp count(metadata, {:skipped_file, reason}) do
    metadata
    |> Map.update!(:skipped_count, &(&1 + 1))
    |> Map.update!(:skipped_file_count, &(&1 + 1))
    |> count_skip_reason(reason)
  end

  defp count(metadata, {:skipped_directory, reason}) do
    metadata
    |> Map.update!(:skipped_count, &(&1 + 1))
    |> Map.update!(:skipped_directory_count, &(&1 + 1))
    |> count_skip_reason(reason)
  end

  defp count_skip_reason(metadata, reason) do
    Map.update!(metadata, :skipped_reasons, fn reasons ->
      Map.update(reasons, reason, 1, &(&1 + 1))
    end)
  end

  defp merge_selection_metadata(left, right) do
    %{
      selected_count: left.selected_count + right.selected_count,
      skipped_count: left.skipped_count + right.skipped_count,
      skipped_file_count: left.skipped_file_count + right.skipped_file_count,
      skipped_directory_count: left.skipped_directory_count + right.skipped_directory_count,
      skipped_reasons:
        Map.merge(left.skipped_reasons, right.skipped_reasons, fn _key, a, b -> a + b end)
    }
  end
end
