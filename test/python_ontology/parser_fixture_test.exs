# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.ParserFixtureTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Parser.Result

  @fixture_root Path.expand("../fixtures/python_parser", __DIR__)

  test "valid parser fixtures produce stable root and child node shapes" do
    first_slice = parse_valid!("valid/first_slice.py")
    first_slice_kinds = flatten_kinds(first_slice.root)

    assert first_slice.root.kind == "module"
    assert "import_statement" in first_slice_kinds
    assert "import_from_statement" in first_slice_kinds
    assert "decorated_definition" in first_slice_kinds
    assert "class_definition" in first_slice_kinds
    assert "function_definition" in first_slice_kinds
    assert "typed_parameter" in first_slice_kinds
    assert "typed_default_parameter" in first_slice_kinds
    assert "call" in first_slice_kinds
    assert "attribute" in first_slice_kinds

    preservation = parse_valid!("valid/preservation_cases.py")
    preservation_kinds = flatten_kinds(preservation.root)

    assert preservation.root.kind == "module"
    assert "async" in preservation_kinds
    assert "with_statement" in preservation_kinds
    assert "try_statement" in preservation_kinds
    assert "list_comprehension" in preservation_kinds
    assert "raise_statement" in preservation_kinds
  end

  test "invalid parser fixtures produce diagnostics with spans and partial trees" do
    for fixture <- [
          "invalid/incomplete_function.py",
          "invalid/invalid_indentation.py",
          "invalid/malformed_expression.py"
        ] do
      path = Path.join(@fixture_root, fixture)

      assert {:ok, %Result{} = result} = Parser.parse_file(path)
      assert result.root.kind == "module"
      assert result.has_error
      assert [%Diagnostic{} | _] = result.diagnostics
      assert Enum.all?(result.diagnostics, & &1.span)
      assert Enum.all?(result.diagnostics, &(&1.stage == :parser))
    end
  end

  defp parse_valid!(fixture) do
    path = Path.join(@fixture_root, fixture)
    assert {:ok, %Result{} = result} = Parser.parse_file(path)
    refute result.has_error
    assert result.diagnostics == []
    result
  end

  defp flatten_kinds(node) do
    [node.kind | Enum.flat_map(node.children, &flatten_kinds/1)]
  end
end
