# covers: python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Builders.RDFTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Builders.Context
  alias PythonOntology.Builders.RDF
  alias PythonOntology.Extractors
  alias PythonOntology.Extractors.Context, as: ExtractorContext
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @source """
  class Example:
      def method(self, name: str):
          return helper(name).value
  """

  test "builds RDF triples for first-slice facts with source locations and confidence evidence" do
    assert {:ok, parsed} = Parser.parse_string(@source, source_id: "src/pkg/example.py")
    assert {:ok, syntax_root} = Syntax.normalize(parsed, source: @source)

    assert {:ok, extractor_context} =
             ExtractorContext.from_parser_result(parsed, syntax_root, module_name: "pkg.example")

    facts = Extractors.extract(syntax_root, extractor_context).facts

    assert {:ok, builder_context} = Context.new(base_iri: "https://analysis.example/python/")
    result = RDF.build(facts, builder_context)

    module_iri = result.resources["module:pkg.example"]

    class_iri =
      Enum.find_value(result.resources, fn {id, iri} ->
        if String.starts_with?(id, "class:"), do: iri
      end)

    method_iri =
      Enum.find_value(result.resources, fn {id, iri} ->
        if String.starts_with?(id, "method:"), do: iri
      end)

    assert {module_iri, Context.vocabulary(builder_context, :structure, :moduleName),
            "pkg.example"} in result.triples

    assert {module_iri, Context.vocabulary(builder_context, :structure, :definesClass), class_iri} in result.triples

    assert {module_iri, Context.vocabulary(builder_context, :structure, :definesFunction),
            method_iri} in result.triples

    assert Enum.any?(result.triples, fn {_s, p, o} ->
             p == Context.vocabulary(builder_context, :core, :hasLocation) and
               String.contains?(o, "/location/")
           end)

    assert Enum.any?(result.triples, fn {_s, p, o} ->
             p == Context.vocabulary(builder_context, :core, :confidenceCategory) and
               o == "source_declared"
           end)

    assert result.diagnostics == []
  end

  test "builder modules do not parse source or hard-code ontology resource roots" do
    for file <- Path.wildcard("lib/python_ontology/builders/**/*.ex") do
      source = File.read!(file)

      refute source =~ "Parser.parse"
      refute source =~ "Syntax.normalize"
      refute source =~ "https://w3id.org/python-code/"
      refute source =~ "base_iri <>"
    end
  end
end
