# covers: python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.NoExecutionTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_confidence/side_effect_guard.py", __DIR__)

  test "parsing and confidence handling do not execute top-level Python side effects" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    assert Enum.any?(module.body, &match?(%Syntax.Generic{raw_type: "raise_statement"}, &1))
    assert Enum.any?(module.body, &match?(%Syntax.Function{name: "still_parseable"}, &1))

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :module_side_effect}} =
             Confidence.runtime_evidence(:module_side_effect)
  end
end
