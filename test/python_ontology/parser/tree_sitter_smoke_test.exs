# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Parser.TreeSitterSmokeTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser.TreeSitter

  test "loads the project adapter and Python grammar" do
    info = TreeSitter.parser_info()

    assert info.adapter == "PythonOntology.Parser.TreeSitter"
    assert info.language == "python"
    assert info.grammar == "tree-sitter-python"
    assert info.tree_sitter_python_crate_version == "0.25.0"

    assert info.grammar_abi_version in info.tree_sitter_min_compatible_language_version..info.tree_sitter_language_version
  end

  test "parses a one-line Python module through Tree-sitter" do
    assert {:ok, parsed} = TreeSitter.parse_string("x = 1\n")

    assert parsed.adapter == "PythonOntology.Parser.TreeSitter"
    assert parsed.language == "python"
    assert parsed.grammar == "tree-sitter-python"
    refute parsed.has_error

    assert parsed.root.kind == "module"
    assert parsed.root.start_byte == 0
    assert parsed.root.end_byte == 6
    assert parsed.root.start_point == %{row: 0, column: 0}
    assert parsed.root.end_point == %{row: 1, column: 0}
    assert Enum.map(parsed.root.children, & &1.kind) == ["expression_statement"]
  end
end
