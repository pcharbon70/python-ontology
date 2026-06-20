# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.ontology_turtle_files.dynamic_fact_boundary python_ontology.ontology_turtle_files.bootstrap_validity python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Builders.Confidence, as: ConfidenceBuilder
  alias PythonOntology.Confidence
  alias PythonOntology.IRI

  @ontology_dir Path.expand("../../../priv/ontologies", __DIR__)

  test "builder confidence triples use authored core ontology vocabulary" do
    core = File.read!(Path.join(@ontology_dir, "python-core.ttl"))

    assert core =~ ":RuntimeDependentFact"
    assert core =~ ":confidenceCategory"
    assert core =~ ":hasEvidence"
    assert core =~ ":evidenceReason"

    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")
    fact_iri = "https://analysis.example/python/fact/runtime/h-1"
    assert {:ok, evidence} = Confidence.runtime_evidence(:dynamic_import)

    assert {:ok, triples} =
             ConfidenceBuilder.triples(context,
               fact_iri: fact_iri,
               category: :runtime_dependent,
               evidence: [evidence]
             )

    assert {fact_iri, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
            "https://w3id.org/python-code/core#RuntimeDependentFact"} in triples

    assert {fact_iri, "https://w3id.org/python-code/core#confidenceCategory", "runtime_dependent"} in triples

    assert Enum.any?(
             triples,
             &match?(
               {_, "https://w3id.org/python-code/core#evidenceReason", "dynamic_import"},
               &1
             )
           )
  end

  test "all authored ontology files expose ontology declarations for confidence checks" do
    ontology_files = Path.wildcard(Path.join(@ontology_dir, "*.ttl"))

    assert Enum.count(ontology_files) == 6

    for path <- ontology_files do
      text = File.read!(path)
      assert text =~ "@prefix"
      assert text =~ "a owl:Ontology"
    end
  end
end
