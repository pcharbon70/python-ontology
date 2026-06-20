# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project.Discovery do
  @moduledoc """
  Discovers Python project roots and selected source files.
  """

  alias PythonOntology.IRI.Path, as: IRIPath
  alias PythonOntology.Project.Diagnostic
  alias PythonOntology.Project.Input
  alias PythonOntology.Project.Result
  alias PythonOntology.Project.SourceFile

  @supported_file_extensions [".py", ".pyi"]
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
         {:ok, files, diagnostics} <- selected_files(input, root_path) do
      {:ok,
       %Result{
         mode: input.mode,
         input_path: input.path,
         root_path: root_path,
         root_marker: root_marker,
         files: files,
         diagnostics: diagnostics,
         metadata: %{file_count: length(files)}
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

  defp selected_files(%Input{mode: :file, path: path}, root_path) do
    with {:ok, file} <- source_file(path, root_path) do
      {:ok, [file], []}
    end
  end

  defp selected_files(%Input{mode: :project}, root_path) do
    {paths, diagnostics} = traverse(root_path)

    files =
      paths
      |> Enum.sort_by(&source_sort_key(&1, root_path))
      |> Enum.map(&source_file!(&1, root_path))

    {:ok, files, diagnostics}
  end

  defp traverse(root_path), do: traverse_directory(root_path)

  defp traverse_directory(directory) do
    case File.ls(directory) do
      {:ok, entries} ->
        entries
        |> Enum.map(&Path.join(directory, &1))
        |> Enum.reduce({[], []}, fn path, {files, diagnostics} ->
          {nested_files, nested_diagnostics} = traverse_path(path)
          {files ++ nested_files, diagnostics ++ nested_diagnostics}
        end)

      {:error, reason} ->
        {[], [traversal_diagnostic(directory, reason)]}
    end
  end

  defp traverse_path(path) do
    case File.lstat(path) do
      {:ok, %File.Stat{type: :regular}} ->
        if supported_file?(path), do: {[path], []}, else: {[], []}

      {:ok, %File.Stat{type: :directory}} ->
        traverse_directory(path)

      {:ok, _stat} ->
        {[], []}

      {:error, reason} ->
        {[], [traversal_diagnostic(path, reason)]}
    end
  end

  defp supported_file?(path), do: Path.extname(path) in @supported_file_extensions

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
      {:ok,
       %SourceFile{
         path: path,
         relative_path: relative_path,
         extension: Path.extname(path)
       }}
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
end
