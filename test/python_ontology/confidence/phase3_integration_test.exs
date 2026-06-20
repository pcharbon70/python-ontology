# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.Phase3IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Builders.Confidence, as: ConfidenceBuilder
  alias PythonOntology.Confidence
  alias PythonOntology.IRI
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture_dir Path.expand("../../fixtures/python_confidence", __DIR__)

  test "dynamic boundary fixture remains queryable as unresolved and runtime dependent" do
    path = Path.join(@fixture_dir, "dynamic_boundaries.py")

    assert {:ok, parsed} = Parser.parse_file(path)
    assert {:ok, module} = Syntax.normalize(parsed)

    dynamic_call =
      module
      |> Syntax.descendants()
      |> Enum.find(&match?(%Syntax.Call{function: %Syntax.Attribute{}}, &1))

    source_evidence = Confidence.syntax_evidence(dynamic_call.info)

    assert {:ok, unresolved} =
             Confidence.unresolved_evidence(:dynamic_target, inputs: [source_evidence])

    assert {:ok, runtime} =
             Confidence.runtime_evidence(:dynamic_import, inputs: [source_evidence])

    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    assert {:ok, fact_iri} =
             IRI.fact(context,
               kind: "runtime-dependent",
               subject: path,
               predicate: "dynamicImport"
             )

    assert {:ok, triples} =
             ConfidenceBuilder.triples(context,
               fact_iri: fact_iri,
               category: :runtime_dependent,
               evidence: [source_evidence, unresolved, runtime]
             )

    assert {fact_iri, "https://w3id.org/python-code/core#confidenceCategory", "runtime_dependent"} in triples

    assert Enum.any?(
             triples,
             &match?(
               {_, "https://w3id.org/python-code/core#evidenceReason", "dynamic_target"},
               &1
             )
           )

    assert Enum.any?(
             triples,
             &match?(
               {_, "https://w3id.org/python-code/core#evidenceReason", "dynamic_import"},
               &1
             )
           )
  end

  test "direct source fixture keeps source-declared default and inferred evidence available" do
    path = Path.join(@fixture_dir, "direct_and_inferred.py")

    assert {:ok, parsed} = Parser.parse_file(path)
    assert {:ok, module} = Syntax.normalize(parsed)

    import = Enum.find(module.body, &match?(%Syntax.Import{}, &1))
    source_evidence = Confidence.syntax_evidence(import.info)
    inferred = Confidence.static_inference_evidence(:alias_resolution, [source_evidence])

    assert Confidence.direct_syntax_default() == :source_declared
    assert inferred.inputs == [source_evidence]
  end
end
