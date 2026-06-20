# covers: python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.normalized_output python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.ParserTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Parser.Metadata
  alias PythonOntology.Parser.Node
  alias PythonOntology.Parser.Result
  alias PythonOntology.Parser.Span

  test "parse_string/2 returns a tagged parser result with source identity" do
    assert {:ok, %Result{} = result} =
             Parser.parse_string("import os\n", source_id: "memory://entry_points.py")

    assert result.source_id == "memory://entry_points.py"
    assert result.path == nil
    assert result.diagnostics == []
    refute result.has_error
    assert result.root.kind == "module"
    assert %Node{} = result.root
    assert %Span{} = result.root.span
    assert %Metadata{} = result.metadata
    assert result.metadata.adapter == "PythonOntology.Parser.TreeSitter"
    assert result.metadata.options.source_id == "memory://entry_points.py"
  end

  test "parse_string/2 requires explicit source identity" do
    assert {:error, %Diagnostic{} = diagnostic} = Parser.parse_string("x = 1\n", [])

    assert diagnostic.stage == :source_identity
    assert diagnostic.severity == :error
    assert diagnostic.message =~ ":source_id"
  end

  test "parse_file/2 normalizes path identity on success" do
    path = fixture_path("entry_points_success.py")
    File.write!(path, "value = call()\n")

    assert {:ok, %Result{} = result} = Parser.parse_file(path)

    assert result.path == Path.expand(path)
    assert result.source_id == Path.expand(path)
    assert result.metadata.options.path == Path.expand(path)
    assert result.root.kind == "module"
  after
    cleanup_fixture("entry_points_success.py")
  end

  test "parse_file/2 returns file-read diagnostics" do
    path = fixture_path("missing_entry_points.py")

    assert {:error, %Diagnostic{} = diagnostic} = Parser.parse_file(path)

    assert diagnostic.stage == :file_read
    assert diagnostic.severity == :error
    assert diagnostic.path == Path.expand(path)
    assert diagnostic.source_id == Path.expand(path)
    assert diagnostic.raw == :enoent
  end

  test "parse_string/2 preserves metadata, spans, child order, and field names" do
    source = """
    class Example:
        def method(self, value):
            return value.call()
    """

    assert {:ok, %Result{} = result} = Parser.parse_string(source, source_id: "memory://shape.py")

    assert result.metadata.language == "python"
    assert result.metadata.grammar == "tree-sitter-python"
    assert result.metadata.grammar_abi_version in 13..result.metadata.tree_sitter_language_version

    source_bytes = byte_size(source)

    assert %Span{
             start_byte: 0,
             end_byte: ^source_bytes,
             start_line: 0,
             start_column: 0,
             end_line: 3,
             end_column: 0
           } = result.root.span

    assert ["class_definition"] = Enum.map(result.root.children, & &1.kind)

    class_definition = hd(result.root.children)
    assert class_definition.span.start_line == 0
    assert class_definition.span.end_line == 2

    assert ["class", "identifier", ":", "block"] =
             Enum.map(class_definition.children, & &1.kind)

    assert Enum.find(class_definition.children, &(&1.field_name == "name")).kind == "identifier"

    class_body = Enum.find(class_definition.children, &(&1.field_name == "body"))
    function_definition = hd(class_body.children)

    assert Enum.find(function_definition.children, &(&1.field_name == "parameters")).kind ==
             "parameters"

    assert Enum.find(function_definition.children, &(&1.field_name == "body")).kind == "block"
  end

  defp fixture_path(name) do
    Path.join([System.tmp_dir!(), "python_ontology_parser_test", name])
    |> tap(&File.mkdir_p!(Path.dirname(&1)))
  end

  defp cleanup_fixture(name) do
    fixture_path(name)
    |> Path.dirname()
    |> File.rm_rf()
  end
end
