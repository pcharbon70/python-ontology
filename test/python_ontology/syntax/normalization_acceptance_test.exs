# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.NormalizationAcceptanceTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Syntax

  @preservation_fixture Path.expand(
                          "../../fixtures/python_parser/valid/preservation_cases.py",
                          __DIR__
                        )

  @invalid_fixtures [
                      "malformed_expression.py",
                      "incomplete_function.py",
                      "invalid_indentation.py"
                    ]
                    |> Enum.map(
                      &Path.expand("../../fixtures/python_parser/invalid/#{&1}", __DIR__)
                    )

  test "preserves unsupported syntax categories needed for future refinement" do
    assert {:ok, parsed} = Parser.parse_file(@preservation_fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    generic_types =
      module
      |> Syntax.descendants()
      |> Enum.filter(&match?(%Syntax.Generic{}, &1))
      |> Enum.map(& &1.raw_type)

    assert "comment" in generic_types
    assert "with_statement" in generic_types
    assert "try_statement" in generic_types
    assert "list_comprehension" in generic_types
    assert "raise_statement" in generic_types
  end

  test "normalizes invalid parser fixtures with parser diagnostics and partial syntax" do
    for path <- @invalid_fixtures do
      assert {:ok, parsed} = Parser.parse_file(path)
      assert {:ok, %Syntax.ModuleNode{} = module} = Syntax.normalize(parsed)

      assert [%Diagnostic{} | _rest] = module.diagnostics
      assert Enum.all?(module.diagnostics, &(&1.stage == :parser))
      assert Enum.all?(module.diagnostics, & &1.span)
      assert module.body != []
    end
  end
end
