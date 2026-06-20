# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.extractor_builder_boundary.validation_after_build python_ontology.fact_confidence_model.builder_propagation python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.PipelineTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Pipeline

  @source """
  import importlib

  class Example:
      def method(self, name: str):
          dynamic = importlib.import_module(name)
          return helper(name).value
  """

  test "runs parser result through normalization extraction and RDF building" do
    assert {:ok, parsed} =
             PythonOntology.Parser.parse_string(@source, source_id: "src/pkg/example.py")

    assert {:ok, result} =
             Pipeline.run_parser_result(parsed,
               normalize_options: [source: @source],
               module_name: "pkg.example",
               base_iri: "https://analysis.example/python/"
             )

    assert result.parser_result == parsed
    assert result.syntax_root.info.source.id == "src/pkg/example.py"
    assert result.metadata.fact_count == length(result.facts)
    assert result.metadata.triple_count == length(result.triples)
    assert Enum.any?(result.facts, &(&1.kind == :class and &1.name == "Example"))

    assert Enum.any?(
             result.facts,
             &(&1.kind == :call and &1.target_text == "importlib.import_module")
           )

    assert Enum.any?(result.triples, fn {_s, _p, o} -> o == "source_declared" end)
    assert Enum.any?(result.triples, fn {_s, _p, o} -> o == "runtime_dependent" end)
    assert Enum.any?(result.diagnostics, &(&1.message == "runtime-dependent dynamic import call"))
  end
end
