# covers: python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Facts.Fact do
  @moduledoc """
  Structured Python fact emitted by extractors and consumed by builders.
  """

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.Pipeline.Diagnostic

  @structural_kinds [
    :source_file,
    :package,
    :module,
    :import,
    :class,
    :function,
    :method,
    :parameter,
    :decorator,
    :annotation,
    :base_class
  ]

  @expression_kinds [
    :call,
    :attribute,
    :subscript,
    :literal,
    :source_location
  ]

  @kinds @structural_kinds ++ @expression_kinds

  @enforce_keys [:kind, :id, :confidence, :evidence]
  defstruct [
    :kind,
    :id,
    :source_id,
    :path,
    :span,
    :node_id,
    :raw_node_type,
    :name,
    :qualified_name,
    :module_name,
    :source_path,
    :parent_id,
    :container_id,
    :role,
    :package_kind,
    :package_root,
    :package_name,
    :target,
    :target_text,
    :value,
    :raw_text,
    aliases: [],
    parameters: [],
    decorators: [],
    annotations: [],
    bases: [],
    arguments: [],
    identity: %{},
    attributes: %{},
    diagnostics: [],
    confidence: :source_declared,
    evidence: []
  ]

  @type kind :: unquote(Enum.reduce(@kinds, &{:|, [], [&1, &2]}))
  @type t :: %__MODULE__{
          kind: kind(),
          id: String.t(),
          source_id: String.t() | nil,
          path: Path.t() | nil,
          span: term(),
          node_id: String.t() | nil,
          raw_node_type: String.t() | nil,
          name: String.t() | nil,
          qualified_name: String.t() | nil,
          module_name: String.t() | nil,
          source_path: String.t() | nil,
          parent_id: String.t() | nil,
          container_id: String.t() | nil,
          role: atom() | nil,
          package_kind: atom() | nil,
          package_root: String.t() | nil,
          package_name: String.t() | nil,
          target: term(),
          target_text: String.t() | nil,
          value: term(),
          raw_text: String.t() | nil,
          aliases: list(),
          parameters: list(),
          decorators: list(),
          annotations: list(),
          bases: list(),
          arguments: list(),
          identity: map(),
          attributes: map(),
          diagnostics: [Diagnostic.t()],
          confidence: Confidence.Category.t(),
          evidence: [Evidence.t()]
        }

  @doc """
  Returns the structural fact kinds.
  """
  def structural_kinds, do: @structural_kinds

  @doc """
  Returns the expression/navigation fact kinds.
  """
  def expression_kinds, do: @expression_kinds

  @doc """
  Returns all supported fact kinds.
  """
  def kinds, do: @kinds

  for kind <- @kinds do
    @doc """
    Builds a #{kind} fact.
    """
    def unquote(kind)(attrs), do: new(unquote(kind), attrs)
  end

  @doc """
  Builds and validates a fact.
  """
  @spec new(kind(), keyword() | map()) :: {:ok, t()} | {:error, String.t()}
  def new(kind, attrs) when kind in @kinds do
    attrs = attrs_map(attrs)

    with {:ok, id} <- required_string(attrs, :id),
         {:ok, confidence} <-
           Confidence.validate_category(Map.get(attrs, :confidence, :source_declared)),
         {:ok, evidence} <- Confidence.evidence_list(Map.get(attrs, :evidence, [])),
         :ok <- require_source_evidence(evidence),
         {:ok, diagnostics} <- diagnostics(Map.get(attrs, :diagnostics, [])) do
      fact_attrs =
        attrs
        |> Map.merge(%{
          kind: kind,
          id: id,
          confidence: confidence,
          evidence: evidence,
          diagnostics: diagnostics,
          identity: Map.new(Map.get(attrs, :identity, %{})),
          attributes: Map.new(Map.get(attrs, :attributes, %{})),
          aliases: List.wrap(Map.get(attrs, :aliases, [])),
          parameters: List.wrap(Map.get(attrs, :parameters, [])),
          decorators: List.wrap(Map.get(attrs, :decorators, [])),
          annotations: List.wrap(Map.get(attrs, :annotations, [])),
          bases: List.wrap(Map.get(attrs, :bases, [])),
          arguments: List.wrap(Map.get(attrs, :arguments, []))
        })

      {:ok, struct!(__MODULE__, fact_attrs)}
    end
  end

  def new(kind, _attrs), do: {:error, "unsupported fact kind #{inspect(kind)}"}

  defp attrs_map(attrs) when is_list(attrs), do: Map.new(attrs)
  defp attrs_map(attrs) when is_map(attrs), do: attrs

  defp required_string(attrs, key) do
    case Map.fetch(attrs, key) do
      {:ok, value} when is_binary(value) and value != "" -> {:ok, value}
      {:ok, value} -> {:error, "#{key} must be a non-empty string, got #{inspect(value)}"}
      :error -> {:error, "#{key} is required"}
    end
  end

  defp require_source_evidence(evidence) do
    if Enum.any?(evidence, &(&1.kind in [:source, :syntax_node])) do
      :ok
    else
      {:error, "facts require source or syntax-node evidence"}
    end
  end

  defp diagnostics(diagnostics) when is_list(diagnostics) do
    if Enum.all?(diagnostics, &match?(%Diagnostic{}, &1)) do
      {:ok, diagnostics}
    else
      {:error, "diagnostics must contain pipeline diagnostic records"}
    end
  end

  defp diagnostics(_diagnostics), do: {:error, "diagnostics must be a list"}
end
