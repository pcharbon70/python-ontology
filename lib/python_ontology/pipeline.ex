# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.extractor_builder_boundary.validation_after_build python_ontology.fact_confidence_model.builder_propagation python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Pipeline do
  @moduledoc """
  Composes parsing, normalization, extraction, and RDF building.
  """

  alias PythonOntology.Builders.Context, as: BuilderContext
  alias PythonOntology.Builders.RDF
  alias PythonOntology.Extractors
  alias PythonOntology.Extractors.Context, as: ExtractorContext
  alias PythonOntology.Parser
  alias PythonOntology.Pipeline.Result
  alias PythonOntology.Syntax

  @doc """
  Runs the single-file pipeline from a filesystem path.
  """
  @spec run_file(Path.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  def run_file(path, opts \\ []) when is_binary(path) and is_list(opts) do
    with {:ok, parser_result} <- Parser.parse_file(path, parser_opts(opts)) do
      run_parser_result(parser_result, opts)
    end
  end

  @doc """
  Runs the pipeline from an existing parser result.
  """
  @spec run_parser_result(Parser.Result.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  def run_parser_result(%Parser.Result{} = parser_result, opts \\ []) when is_list(opts) do
    with {:ok, syntax_root} <- Syntax.normalize(parser_result, normalize_opts(opts)) do
      run_syntax(syntax_root, Keyword.put(opts, :parser_result, parser_result))
    end
  end

  @doc """
  Runs extraction and building from an existing normalized syntax root.
  """
  @spec run_syntax(Syntax.ModuleNode.t(), keyword()) :: {:ok, Result.t()} | {:error, term()}
  def run_syntax(%Syntax.ModuleNode{} = syntax_root, opts \\ []) when is_list(opts) do
    parser_result = opts[:parser_result]

    with {:ok, extractor_context} <- extractor_context(parser_result, syntax_root, opts),
         extraction_result = Extractors.extract(syntax_root, extractor_context),
         {:ok, builder_context} <- builder_context(opts, extractor_context),
         build_result = RDF.build(extraction_result.facts, builder_context) do
      {:ok,
       %Result{
         parser_result: parser_result,
         syntax_root: syntax_root,
         extraction_result: extraction_result,
         build_result: build_result,
         facts: extraction_result.facts,
         triples: build_result.triples,
         diagnostics:
           extractor_context.diagnostics ++
             extraction_result.diagnostics ++
             builder_context.diagnostics ++ build_result.diagnostics,
         metadata: %{
           fact_count: length(extraction_result.facts),
           triple_count: length(build_result.triples)
         }
       }}
    end
  end

  defp extractor_context(%Parser.Result{} = parser_result, syntax_root, opts) do
    ExtractorContext.from_parser_result(parser_result, syntax_root, context_opts(opts))
  end

  defp extractor_context(nil, syntax_root, opts) do
    opts
    |> context_opts()
    |> Keyword.put(:syntax_root, syntax_root)
    |> ExtractorContext.new()
  end

  defp builder_context(opts, %ExtractorContext{} = extractor_context) do
    BuilderContext.new(
      iri_context: extractor_context.iri_context,
      namespaces: Keyword.get(opts, :namespaces, %{}),
      confidence_options: Keyword.get(opts, :confidence_options, []),
      options: Keyword.get(opts, :builder_options, [])
    )
  end

  defp context_opts(opts) do
    opts
    |> Keyword.take([
      :project_root,
      :source_file,
      :source_id,
      :source_path,
      :parser_metadata,
      :module_name,
      :base_iri,
      :iri_context,
      :namespaces,
      :diagnostics
    ])
    |> Keyword.put(:options, Keyword.get(opts, :analysis_options, []))
  end

  defp parser_opts(opts), do: Keyword.get(opts, :parser_options, [])
  defp normalize_opts(opts), do: Keyword.get(opts, :normalize_options, [])
end
