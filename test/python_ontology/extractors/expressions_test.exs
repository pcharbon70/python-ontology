# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Extractors.ExpressionsTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Extractors.Context
  alias PythonOntology.Extractors.Expressions
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @source """
  import importlib

  call_result = helper(name, *args)
  attr_result = result.value
  item = data[0]
  dynamic_module = importlib.import_module(module_name)
  computed = registry[name]()
  """

  test "extracts calls, attributes, subscripts, literals, and structured diagnostics" do
    assert {:ok, parsed} = Parser.parse_string(@source, source_id: "memory://expressions.py")
    assert {:ok, syntax_root} = Syntax.normalize(parsed, source: @source)

    assert {:ok, context} =
             Context.from_parser_result(parsed, syntax_root, module_name: "expressions")

    result = Expressions.extract(syntax_root, context)
    facts = result.facts

    calls = Enum.filter(facts, &(&1.kind == :call))
    assert Enum.any?(calls, &(&1.target_text == "helper" and &1.confidence == :source_declared))

    assert Enum.any?(
             calls,
             &(&1.target_text == "importlib.import_module" and
                 &1.confidence == :runtime_dependent and
                 &1.attributes.runtime_boundary == :dynamic_import)
           )

    assert Enum.any?(
             calls,
             &(&1.target_text == "registry[name]" and &1.confidence == :unresolved)
           )

    assert Enum.any?(facts, &(&1.kind == :attribute and &1.target_text == "result.value"))
    assert Enum.any?(facts, &(&1.kind == :subscript and &1.target_text == "data[0]"))
    assert Enum.any?(facts, &(&1.kind == :literal and &1.raw_text == "0"))

    assert Enum.any?(result.diagnostics, &(&1.message =~ "unsupported normalized syntax node"))
    assert Enum.any?(result.diagnostics, &(&1.message == "runtime-dependent dynamic import call"))
    assert Enum.any?(result.diagnostics, &(&1.message == "unresolved dynamic call target"))

    assert Enum.all?(facts, &match?(%Fact{}, &1))
    refute Enum.any?(facts, &match?({_, _, _}, &1))
  end
end
