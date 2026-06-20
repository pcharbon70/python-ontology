# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Extractors.Context do
  @moduledoc """
  Explicit context passed to fact extractors.
  """

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context, as: IRIContext
  alias PythonOntology.Pipeline.Diagnostic
  alias PythonOntology.Project.SourceFile
  alias PythonOntology.Syntax
  alias PythonOntology.Syntax.ModuleNode

  @enforce_keys [:source_id, :iri_context]
  defstruct [
    :project_root,
    :source_file,
    :source_id,
    :source_path,
    :relative_path,
    :package_kind,
    :package_root,
    :package_name,
    :module_name,
    :parser_metadata,
    :syntax_root,
    :iri_context,
    namespaces: %{},
    options: %{},
    diagnostics: []
  ]

  @type t :: %__MODULE__{
          project_root: Path.t() | nil,
          source_file: SourceFile.t() | nil,
          source_id: String.t(),
          source_path: Path.t() | nil,
          relative_path: String.t() | nil,
          package_kind: atom() | nil,
          package_root: String.t() | nil,
          package_name: String.t() | nil,
          module_name: String.t() | nil,
          parser_metadata: term(),
          syntax_root: ModuleNode.t() | nil,
          iri_context: IRIContext.t(),
          namespaces: map(),
          options: map(),
          diagnostics: [Diagnostic.t()]
        }

  @doc """
  Builds an extractor context from parser, syntax, and project metadata.
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, term()}
  def new(opts) when is_list(opts) do
    source_file = opts[:source_file]
    syntax_root = opts[:syntax_root]
    source = syntax_source(syntax_root)
    project_root = opts[:project_root]

    with {:ok, source_id} <- required_source_id(opts, source, source_file),
         {:ok, iri_context} <- iri_context(opts, project_root) do
      {:ok,
       %__MODULE__{
         project_root: normalize_optional_path(project_root),
         source_file: source_file,
         source_id: source_id,
         source_path: source_path(opts, source, source_file),
         relative_path: source_file && source_file.relative_path,
         package_kind: source_file && source_file.package_kind,
         package_root: source_file && source_file.package_root,
         package_name: source_file && source_file.package_name,
         module_name: module_name(opts, source_file),
         parser_metadata: parser_metadata(opts, source),
         syntax_root: syntax_root,
         iri_context: iri_context,
         namespaces: Map.new(Keyword.get(opts, :namespaces, %{})),
         options: Map.new(Keyword.get(opts, :options, [])),
         diagnostics: List.wrap(Keyword.get(opts, :diagnostics, []))
       }}
    end
  end

  @doc """
  Builds an extractor context from a parser result and normalized syntax root.
  """
  def from_parser_result(parser_result, %ModuleNode{} = syntax_root, opts \\ []) do
    opts =
      opts
      |> Keyword.put_new(:source_id, parser_result.source_id)
      |> Keyword.put_new(:source_path, parser_result.path)
      |> Keyword.put_new(:parser_metadata, parser_result.metadata)
      |> Keyword.put(:syntax_root, syntax_root)

    new(opts)
  end

  @doc """
  Adds a diagnostic to the context.
  """
  @spec add_diagnostic(t(), Diagnostic.t()) :: t()
  def add_diagnostic(%__MODULE__{} = context, %Diagnostic{} = diagnostic) do
    %{context | diagnostics: context.diagnostics ++ [diagnostic]}
  end

  @doc """
  Returns source text for a normalized node when caller options include it.
  """
  def source_slice(%__MODULE__{options: %{source: source}}, node) when is_binary(source) do
    Syntax.source_slice(node, source)
  end

  def source_slice(_context, _node), do: nil

  defp required_source_id(opts, source, source_file) do
    source_id =
      opts[:source_id] || (source && source.id) || (source_file && source_file.relative_path)

    if is_binary(source_id) and source_id != "" do
      {:ok, source_id}
    else
      {:error, "extractor context requires a source id"}
    end
  end

  defp iri_context(opts, project_root) do
    case Keyword.fetch(opts, :iri_context) do
      {:ok, %IRIContext{} = context} ->
        {:ok, context}

      _missing ->
        IRI.context(
          base_iri: Keyword.get(opts, :base_iri, IRI.default_base_iri()),
          repository_root: project_root
        )
    end
  end

  defp syntax_source(%ModuleNode{info: %{source: source}}), do: source
  defp syntax_source(_syntax_root), do: nil

  defp source_path(opts, source, source_file) do
    opts[:source_path] || (source && source.path) || (source_file && source_file.path)
  end

  defp parser_metadata(opts, source),
    do: opts[:parser_metadata] || (source && source.parser_metadata)

  defp module_name(opts, source_file),
    do: opts[:module_name] || (source_file && source_file.module_name)

  defp normalize_optional_path(nil), do: nil
  defp normalize_optional_path(path) when is_binary(path), do: Path.expand(path)
end
