# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Extractors.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Extractors
  alias PythonOntology.Extractors.Context
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @source """
  import importlib
  from pathlib import Path as FilePath

  @decorator("value")
  class Example(Base):
      def method(self, name: str, *args, **kwargs) -> str:
          dynamic = importlib.import_module(name)
          return helper(name).value
  """

  test "combined extractors emit first-slice facts and no RDF triples" do
    assert {:ok, parsed} = Parser.parse_string(@source, source_id: "src/pkg/example.py")
    assert {:ok, syntax_root} = Syntax.normalize(parsed, source: @source)

    assert {:ok, context} =
             Context.from_parser_result(parsed, syntax_root, module_name: "pkg.example")

    result = Extractors.extract(syntax_root, context)
    facts = result.facts

    assert Enum.any?(facts, &(&1.kind == :module and &1.name == "pkg.example"))
    assert Enum.count(facts, &(&1.kind == :import)) == 2
    assert Enum.any?(facts, &(&1.kind == :class and &1.name == "Example"))
    assert Enum.any?(facts, &(&1.kind == :method and &1.name == "method"))
    assert Enum.any?(facts, &(&1.kind == :parameter and &1.name == "kwargs"))
    assert Enum.any?(facts, &(&1.kind == :decorator and &1.raw_text == "@decorator(\"value\")"))
    assert Enum.any?(facts, &(&1.kind == :annotation and &1.raw_text == "str"))
    assert Enum.any?(facts, &(&1.kind == :call and &1.target_text == "importlib.import_module"))
    assert Enum.any?(facts, &(&1.kind == :attribute and &1.target_text == "helper(...).value"))

    assert Enum.any?(result.diagnostics, &(&1.message == "runtime-dependent dynamic import call"))
    assert Enum.all?(facts, &match?(%Fact{}, &1))
    refute Enum.any?(facts, &match?({_, _, _}, &1))
  end
end
