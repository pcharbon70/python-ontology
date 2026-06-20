# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.SharedFieldsTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Syntax.ByteSpan
  alias PythonOntology.Syntax.NodeId
  alias PythonOntology.Syntax.NodeInfo
  alias PythonOntology.Syntax.Point
  alias PythonOntology.Syntax.PointSpan
  alias PythonOntology.Syntax.Provenance
  alias PythonOntology.Syntax.Source
  alias PythonOntology.Syntax.Span

  test "builds source identity and parser metadata from parser results" do
    assert {:ok, parsed} = Parser.parse_string("x = 1\n", source_id: "memory://shared.py")

    source = Source.from_parser_result(parsed)

    assert source.id == "memory://shared.py"
    assert source.path == nil
    assert source.parser_metadata.language == "python"
  end

  test "builds available and unavailable spans" do
    span =
      Span.from_parser(%Parser.Span{
        start_byte: 1,
        end_byte: 4,
        start_line: 2,
        start_column: 3,
        end_line: 2,
        end_column: 6
      })

    assert span.byte == %ByteSpan{start: 1, end: 4}

    assert span.point == %PointSpan{
             start: %Point{row: 2, column: 3},
             end: %Point{row: 2, column: 6}
           }

    assert Span.unavailable().byte == %ByteSpan{start: nil, end: nil}
  end

  test "builds deterministic node IDs scoped to source identity and parser path" do
    source = %Source{id: "memory://ids.py"}
    parent_path = ["module", 0, "function_definition"]

    id = NodeId.build(source, "identifier", parent_path, 1)

    assert id == NodeId.build(source, "identifier", parent_path, 1)
    refute id == NodeId.build(source, "identifier", parent_path, 2)
  end

  test "groups shared node fields in NodeInfo" do
    source = %Source{id: "memory://node-info.py"}

    provenance = %Provenance{
      raw_type: "identifier",
      named: true,
      field_name: "name",
      child_index: 0,
      parent_path: ["module", 0],
      child_order: []
    }

    info = %NodeInfo{
      id: NodeId.build(source, "identifier", provenance.parent_path, provenance.child_index),
      source: source,
      span: Span.unavailable(),
      provenance: provenance
    }

    assert info.provenance.raw_type == "identifier"
    assert info.provenance.field_name == "name"
  end
end
