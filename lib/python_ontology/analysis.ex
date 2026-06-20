# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Analysis do
  @moduledoc """
  Public file and project analysis facade.
  """

  alias PythonOntology.Pipeline
  alias PythonOntology.Pipeline.Diagnostic, as: PipelineDiagnostic
  alias PythonOntology.Project
  alias PythonOntology.Project.Diagnostic, as: ProjectDiagnostic
  alias PythonOntology.Project.Result, as: ProjectResult
  alias PythonOntology.Validator
  alias PythonOntology.Validator.Report

  alias __MODULE__.Result

  @project_option_keys [:include_globs, :exclude_globs, :generated_dirs]
  @pipeline_option_keys [
    :analysis_options,
    :builder_options,
    :confidence_options,
    :diagnostics,
    :iri_context,
    :namespaces,
    :normalize_options
  ]

  @doc """
  Analyzes one Python source or stub file through discovery, parsing, extraction, RDF building,
  and optional validation.
  """
  @spec analyze_file(Path.t(), keyword()) :: {:ok, Result.t()} | {:error, ProjectDiagnostic.t()}
  def analyze_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    analyze(path, :file, opts)
  end

  @doc """
  Analyzes a Python project directory through discovery, parsing, extraction, RDF building,
  and optional validation.
  """
  @spec analyze_project(Path.t(), keyword()) ::
          {:ok, Result.t()} | {:error, ProjectDiagnostic.t()}
  def analyze_project(path, opts \\ []) when is_binary(path) and is_list(opts) do
    analyze(path, :project, opts)
  end

  defp analyze(path, expected_mode, opts) do
    with {:ok, %ProjectResult{} = project} <- Project.discover(path, project_options(opts)),
         :ok <- require_mode(project, expected_mode) do
      {:ok, run_project(project, opts)}
    end
  end

  defp run_project(%ProjectResult{} = project, opts) do
    {pipeline_results, pipeline_diagnostics} =
      project
      |> Project.parser_inputs()
      |> Enum.map(&run_input(&1, project, opts))
      |> split_pipeline_results()

    triples = merged_triples(pipeline_results)

    diagnostics =
      project.diagnostics ++ pipeline_diagnostics ++ pipeline_diagnostics(pipeline_results)

    validation = validate(triples, opts)
    all_diagnostics = diagnostics ++ validation.diagnostics

    %Result{
      mode: project.mode,
      input_path: project.input_path,
      project: project,
      files: project.files,
      pipeline_results: pipeline_results,
      triples: triples,
      diagnostics: all_diagnostics,
      options: selected_options(opts),
      validation_status: validation.status,
      validation_result: validation.result,
      validation_report: validation.report,
      metadata: metadata(project, pipeline_results, triples, all_diagnostics, validation.status)
    }
  end

  defp require_mode(%ProjectResult{mode: expected}, expected), do: :ok

  defp require_mode(%ProjectResult{} = project, expected_mode) do
    {:error,
     %ProjectDiagnostic{
       stage: :analysis_input,
       severity: :error,
       message: "expected #{expected_mode} analysis input, got #{project.mode}",
       path: project.input_path,
       details: %{expected_mode: expected_mode, actual_mode: project.mode}
     }}
  end

  defp run_input(input, %ProjectResult{} = project, opts) do
    pipeline_opts =
      opts
      |> Keyword.take(@pipeline_option_keys)
      |> Keyword.merge(
        project_root: project.root_path,
        source_file: input.source_file,
        source_id: input.source_id,
        source_path: input.path,
        module_name: input.module_name,
        parser_options: parser_options(opts, input)
      )
      |> maybe_put(:base_iri, Keyword.get(opts, :base_iri))

    case Pipeline.run_file(input.path, pipeline_opts) do
      {:ok, %Pipeline.Result{} = result} ->
        {:ok, result}

      {:error, diagnostic} ->
        {:error, pipeline_error(input, diagnostic)}
    end
  end

  defp parser_options(opts, input) do
    opts
    |> Keyword.get(:parser_options, [])
    |> Keyword.put(:source_id, input.source_id)
  end

  defp split_pipeline_results(results) do
    Enum.reduce(results, {[], []}, fn
      {:ok, result}, {pipeline_results, diagnostics} ->
        {pipeline_results ++ [result], diagnostics}

      {:error, diagnostic}, {pipeline_results, diagnostics} ->
        {pipeline_results, diagnostics ++ [diagnostic]}
    end)
  end

  defp pipeline_error(input, %PipelineDiagnostic{} = diagnostic) do
    %{
      diagnostic
      | source_id: diagnostic.source_id || input.source_id,
        path: diagnostic.path || input.path
    }
  end

  defp pipeline_error(input, diagnostic) do
    %PipelineDiagnostic{
      stage: :analysis,
      severity: :error,
      message: "analysis pipeline failed for #{input.relative_path}",
      source_id: input.source_id,
      path: input.path,
      details: %{reason: inspect(diagnostic)}
    }
  end

  defp merged_triples(pipeline_results) do
    pipeline_results
    |> Enum.flat_map(& &1.triples)
    |> Enum.uniq()
  end

  defp pipeline_diagnostics(pipeline_results) do
    Enum.flat_map(pipeline_results, & &1.diagnostics)
  end

  defp validate(triples, opts) do
    if validate?(opts) do
      case Validator.validate_graph(triples, Keyword.get(opts, :validation_options, [])) do
        {:ok, validation_result} ->
          report = Report.from_shacl_result(validation_result)

          %{
            status: report.status,
            result: validation_result,
            report: report,
            diagnostics: report.diagnostics
          }

        {:error, diagnostics} ->
          report = Report.from_diagnostics(diagnostics, %{data_triple_count: length(triples)})

          %{status: :fail, result: nil, report: report, diagnostics: diagnostics}
      end
    else
      %{status: :not_run, result: nil, report: nil, diagnostics: []}
    end
  end

  defp validate?(opts), do: Keyword.get(opts, :validate?, true)

  defp selected_options(opts) do
    %{
      base_iri: Keyword.get(opts, :base_iri),
      validate?: validate?(opts),
      project_options: Map.new(project_options(opts)),
      validation_options: Map.new(Keyword.get(opts, :validation_options, [])),
      parser_options: Map.new(Keyword.get(opts, :parser_options, [])),
      normalize_options: Map.new(Keyword.get(opts, :normalize_options, [])),
      analysis_options: Map.new(Keyword.get(opts, :analysis_options, [])),
      builder_options: Map.new(Keyword.get(opts, :builder_options, []))
    }
  end

  defp project_options(opts), do: Keyword.take(opts, @project_option_keys)

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)

  defp metadata(project, pipeline_results, triples, diagnostics, validation_status) do
    project.metadata
    |> Map.merge(%{
      analyzed_file_count: length(pipeline_results),
      diagnostic_count: length(diagnostics),
      fact_count: Enum.reduce(pipeline_results, 0, &(&2 + Map.get(&1.metadata, :fact_count, 0))),
      triple_count: length(triples),
      validation_status: validation_status
    })
  end
end
