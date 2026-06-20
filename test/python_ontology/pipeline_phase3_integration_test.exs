# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.extractor_builder_boundary.validation_after_build python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.PipelinePhase3IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Facts.Fact
  alias PythonOntology.Pipeline

  @base_iri "https://analysis.example/python/"
  @vocabulary_iri "https://w3id.org/python-code/"
  @fixture Path.expand("../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "pipeline produces RDF from extracted first-slice facts while preserving stage boundaries" do
    assert {:ok, result} =
             Pipeline.run_file(@fixture,
               parser_options: [source_id: "src/sample_pkg/first_slice.py"],
               module_name: "sample_pkg.first_slice",
               base_iri: @base_iri
             )

    assert result.metadata.fact_count == length(result.facts)
    assert result.metadata.triple_count == length(result.triples)
    assert Enum.all?(result.facts, &match?(%Fact{}, &1))
    assert Enum.all?(result.triples, &triple?/1)

    for kind <- [
          :source_file,
          :module,
          :import,
          :import_alias,
          :class,
          :method,
          :parameter,
          :decorator,
          :annotation,
          :base_class,
          :call,
          :attribute
        ] do
      assert Enum.any?(result.facts, &(&1.kind == kind)), "expected #{kind} fact"
    end

    assert Enum.any?(result.triples, &generated_resource_triple?/1)
    assert Enum.any?(result.triples, &vocabulary_predicate_triple?/1)
    assert Enum.any?(result.triples, &confidence_category_triple?(&1, "source_declared"))
    assert Enum.any?(result.triples, &has_evidence_triple?/1)

    refute Enum.any?(result.facts, &triple?/1)
    refute Enum.any?(result.diagnostics, &(&1.stage == :builder))
  end

  defp triple?({subject, predicate, object})
       when is_binary(subject) and is_binary(predicate) and is_binary(object),
       do: true

  defp triple?(_term), do: false

  defp generated_resource_triple?({subject, _predicate, object}) do
    String.starts_with?(subject, @base_iri) or String.starts_with?(object, @base_iri)
  end

  defp vocabulary_predicate_triple?({_subject, predicate, _object}) do
    String.starts_with?(predicate, @vocabulary_iri)
  end

  defp confidence_category_triple?({_subject, predicate, object}, expected) do
    String.ends_with?(predicate, "#confidenceCategory") and object == expected
  end

  defp has_evidence_triple?({_subject, predicate, object}) do
    String.ends_with?(predicate, "#hasEvidence") and String.starts_with?(object, @base_iri)
  end
end
