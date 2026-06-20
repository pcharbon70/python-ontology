# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.TraversalTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "facade traversal returns normalized children and descendants" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    assert [%Syntax.Generic{raw_type: "comment"} | _rest] = Syntax.children(module)

    descendants = Syntax.descendants(module)
    assert Enum.any?(descendants, &match?(%Syntax.Call{}, &1))
    assert Enum.any?(descendants, &match?(%Syntax.Attribute{}, &1))
    refute Enum.any?(descendants, &match?(%Parser.Node{}, &1))
  end

  test "facade returns source slices by normalized spans" do
    source = File.read!(@fixture)

    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    function =
      module
      |> Syntax.descendants()
      |> Enum.find(&match?(%Syntax.Function{name: "method"}, &1))

    assert Syntax.source_slice(function, source) =~ "def method"
    assert Syntax.source_slice(function, source) =~ "return result.value"
  end

  test "facade documents stable node types for extractor work" do
    stable_node_types = Syntax.stable_node_types()

    assert Syntax.ModuleNode in stable_node_types
    assert Syntax.Function in stable_node_types
    assert Syntax.Call in stable_node_types
    assert Syntax.Generic in stable_node_types
    refute Parser.Node in stable_node_types
  end
end
