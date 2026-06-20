# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Builders.ConfidenceTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Builders.Confidence, as: ConfidenceBuilder
  alias PythonOntology.Confidence
  alias PythonOntology.IRI
  alias PythonOntology.IRI.Diagnostic

  setup do
    {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")
    %{context: context, fact_iri: "https://analysis.example/python/fact/source-declared/h-1"}
  end

  test "emits confidence class and category triples", %{context: context, fact_iri: fact_iri} do
    evidence = [
      Confidence.source_evidence(
        source_id: "memory://example.py",
        span: %{start_byte: 0, end_byte: 8}
      )
    ]

    assert {:ok, triples} =
             ConfidenceBuilder.triples(context,
               fact_iri: fact_iri,
               category: :source_declared,
               evidence: evidence
             )

    assert {fact_iri, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "https://w3id.org/python-code/core#SourceDeclaredFact"} in triples

    assert {fact_iri, "https://w3id.org/python-code/core#confidenceCategory", "source_declared"} in triples

    assert Enum.any?(
             triples,
             &match?({^fact_iri, "https://w3id.org/python-code/core#hasEvidence", _}, &1)
           )

    assert Enum.any?(
             triples,
             &match?({_, "https://w3id.org/python-code/core#evidenceKind", "source"}, &1)
           )
  end

  test "emits evidence triples for unresolved and runtime-dependent facts", %{
    context: context,
    fact_iri: fact_iri
  } do
    assert {:ok, unresolved} =
             Confidence.unresolved_evidence(:unknown_name, details: [name: "target"])

    assert {:ok, runtime} = Confidence.runtime_evidence(:dynamic_import)

    assert {:ok, triples} =
             ConfidenceBuilder.triples(context,
               fact_iri: fact_iri,
               category: :runtime_dependent,
               evidence: [unresolved, runtime]
             )

    assert {fact_iri, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "https://w3id.org/python-code/core#RuntimeDependentFact"} in triples

    assert Enum.any?(
             triples,
             &match?({_, "https://w3id.org/python-code/core#evidenceReason", "unknown_name"}, &1)
           )

    assert Enum.any?(
             triples,
             &match?(
               {_, "https://w3id.org/python-code/core#evidenceReason", "dynamic_import"},
               &1
             )
           )
  end

  test "diagnoses missing confidence metadata", %{context: context, fact_iri: fact_iri} do
    assert {:error, %Diagnostic{stage: :confidence_builder, details: %{field: :category}}} =
             ConfidenceBuilder.triples(context, fact_iri: fact_iri, evidence: [])

    assert {:error, %Diagnostic{stage: :confidence_builder, details: %{field: :evidence}}} =
             ConfidenceBuilder.triples(context, fact_iri: fact_iri, category: :source_declared)
  end
end
