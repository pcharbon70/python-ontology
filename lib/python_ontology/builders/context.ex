# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.fact_confidence_model.builder_propagation python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Builders.Context do
  @moduledoc """
  Explicit context passed to RDF builders.
  """

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context, as: IRIContext
  alias PythonOntology.Pipeline.Diagnostic

  @enforce_keys [:iri_context]
  defstruct [
    :iri_context,
    namespaces: %{},
    confidence_options: %{},
    options: %{},
    diagnostics: []
  ]

  @type t :: %__MODULE__{
          iri_context: IRIContext.t(),
          namespaces: map(),
          confidence_options: map(),
          options: map(),
          diagnostics: [Diagnostic.t()]
        }

  @doc """
  Builds a builder context from IRI, namespace, and confidence options.
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, term()}
  def new(opts \\ []) when is_list(opts) do
    with {:ok, iri_context} <- iri_context(opts) do
      {:ok,
       %__MODULE__{
         iri_context: iri_context,
         namespaces: Map.new(Keyword.get(opts, :namespaces, %{})),
         confidence_options: Map.new(Keyword.get(opts, :confidence_options, [])),
         options: Map.new(Keyword.get(opts, :options, [])),
         diagnostics: List.wrap(Keyword.get(opts, :diagnostics, []))
       }}
    end
  end

  @doc """
  Returns a vocabulary IRI through the shared IRI helper.
  """
  def vocabulary(_context, layer, term), do: IRI.builder_vocabulary(layer, term)

  @doc """
  Builds a generated resource IRI through the shared IRI helper.
  """
  def resource(%__MODULE__{iri_context: iri_context}, segments),
    do: IRI.resource(iri_context, segments)

  @doc """
  Builds a fact assertion IRI through the shared IRI helper.
  """
  def fact_iri(%__MODULE__{iri_context: iri_context}, opts), do: IRI.fact(iri_context, opts)

  @doc """
  Adds a diagnostic to the context.
  """
  @spec add_diagnostic(t(), Diagnostic.t()) :: t()
  def add_diagnostic(%__MODULE__{} = context, %Diagnostic{} = diagnostic) do
    %{context | diagnostics: context.diagnostics ++ [diagnostic]}
  end

  defp iri_context(opts) do
    case Keyword.fetch(opts, :iri_context) do
      {:ok, %IRIContext{} = context} ->
        {:ok, context}

      _missing ->
        IRI.context(
          base_iri: Keyword.get(opts, :base_iri, IRI.default_base_iri()),
          repository_root: Keyword.get(opts, :repository_root)
        )
    end
  end
end
