# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Builders.Confidence do
  @moduledoc """
  Builder helper for confidence and evidence triples.
  """

  alias PythonOntology.Confidence.Category
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Fragment

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"

  @category_classes %{
    source_declared: "SourceDeclaredFact",
    statically_inferred: "StaticallyInferredFact",
    unresolved: "UnresolvedFact",
    runtime_dependent: "RuntimeDependentFact"
  }

  @evidence_classes %{
    source: "SourceEvidence",
    syntax_node: "SourceEvidence",
    static_inference: "InferenceEvidence",
    unresolved: "UnresolvedEvidence",
    runtime_dependent: "RuntimeEvidence"
  }

  @type triple :: {String.t(), String.t(), String.t()}

  @doc """
  Builds triples that make confidence category and evidence queryable.
  """
  @spec triples(Context.t(), keyword()) :: {:ok, [triple()]} | {:error, Diagnostic.t()}
  def triples(%Context{} = context, opts) when is_list(opts) do
    with {:ok, fact_iri} <- required_string(opts, :fact_iri),
         {:ok, category} <- required_category(opts[:category]),
         {:ok, evidence} <- required_evidence(opts[:evidence]) do
      triples =
        [
          {fact_iri, @rdf_type, category_class_iri(category)},
          {fact_iri, IRI.vocabulary_iri(:core, :confidenceCategory), Atom.to_string(category)}
        ] ++ evidence_triples(context, fact_iri, evidence)

      {:ok, triples}
    end
  end

  @doc """
  Returns the ontology class IRI for a confidence category.
  """
  @spec category_class_iri(Category.t()) :: String.t()
  def category_class_iri(category),
    do: IRI.vocabulary_iri(:core, Map.fetch!(@category_classes, category))

  defp evidence_triples(context, fact_iri, evidence_records) do
    Enum.flat_map(evidence_records, fn evidence ->
      evidence_iri = evidence_iri(context, fact_iri, evidence)

      [
        {fact_iri, IRI.vocabulary_iri(:core, :hasEvidence), evidence_iri},
        {evidence_iri, @rdf_type, evidence_class_iri(evidence.kind)},
        {evidence_iri, IRI.vocabulary_iri(:core, :evidenceKind), Atom.to_string(evidence.kind)}
      ]
      |> append_optional(evidence.reason, fn reason ->
        {evidence_iri, IRI.vocabulary_iri(:core, :evidenceReason), Atom.to_string(reason)}
      end)
      |> append_optional(
        evidence.syntax_node_id || evidence.source_id || evidence.path,
        fn source ->
          {evidence_iri, IRI.vocabulary_iri(:core, :evidenceSource), to_string(source)}
        end
      )
    end)
  end

  defp evidence_iri(%Context{} = context, fact_iri, %Evidence{} = evidence) do
    canonical_input =
      [
        "python_ontology_evidence:v1",
        "fact=#{fact_iri}",
        "kind=#{evidence.kind}",
        "reason=#{evidence.reason}",
        "source_id=#{evidence.source_id}",
        "path=#{evidence.path}",
        "syntax_node_id=#{evidence.syntax_node_id}",
        "raw_node_type=#{evidence.raw_node_type}",
        "details=#{inspect(evidence.details)}"
      ]
      |> Enum.join("\n")

    {:ok, iri} = IRI.resource(context, ["evidence", "h-" <> Fragment.hash(canonical_input)])
    iri
  end

  defp evidence_class_iri(kind),
    do: IRI.vocabulary_iri(:core, Map.fetch!(@evidence_classes, kind))

  defp append_optional(triples, nil, _fun), do: triples
  defp append_optional(triples, value, fun), do: triples ++ [fun.(value)]

  defp required_string(opts, key) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_binary(value) and value != "" ->
        {:ok, value}

      {:ok, value} ->
        builder_error(key, value, "#{key} must be a non-empty string")

      :error ->
        builder_error(key, nil, "#{key} is required")
    end
  end

  defp required_category(nil), do: builder_error(:category, nil, "category is required")

  defp required_category(category) do
    case Category.validate(category) do
      {:ok, category} -> {:ok, category}
      {:error, message} -> builder_error(:category, category, message)
    end
  end

  defp required_evidence(nil), do: builder_error(:evidence, nil, "evidence is required")

  defp required_evidence(evidence) do
    case Evidence.list(evidence) do
      {:ok, evidence} -> {:ok, evidence}
      {:error, message} -> builder_error(:evidence, evidence, message)
    end
  end

  defp builder_error(field, input, message) do
    {:error,
     %Diagnostic{
       stage: :confidence_builder,
       severity: :error,
       message: message,
       input: input,
       details: %{field: field}
     }}
  end
end
