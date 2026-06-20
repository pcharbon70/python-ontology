# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.TypedNodesTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Syntax

  test "constructs representative structural syntax nodes" do
    info = node_info("class_definition")

    parameter = %Syntax.Parameter{
      info: node_info("identifier"),
      name: "value",
      annotation: %Syntax.Annotation{info: node_info("type"), raw_text: "int"}
    }

    function = %Syntax.Function{
      info: node_info("function_definition"),
      name: "method",
      method_candidate?: true,
      parameters: [parameter],
      decorators: [%Syntax.Decorator{info: node_info("decorator"), raw_text: "@decorator"}],
      return_annotation: %Syntax.Annotation{info: node_info("type"), raw_text: "str"}
    }

    class = %Syntax.Class{
      info: info,
      name: "Example",
      bases: [%Syntax.BaseClass{info: node_info("argument_list"), raw_text: "Base"}],
      body: [function]
    }

    module = %Syntax.ModuleNode{info: node_info("module"), body: [class]}

    assert module.body == [class]
    assert class.name == "Example"
    assert function.method_candidate?
    assert parameter.annotation.raw_text == "int"
  end

  test "constructs representative expression and preservation nodes" do
    identifier = %Syntax.Identifier{info: node_info("identifier"), name: "value"}

    attribute = %Syntax.Attribute{
      info: node_info("attribute"),
      object: identifier,
      attribute: "name"
    }

    call = %Syntax.Call{
      info: node_info("call"),
      function: attribute,
      arguments: [
        %Syntax.Literal{info: node_info("integer"), kind: :number, value: 1, raw_text: "1"}
      ]
    }

    subscript = %Syntax.Subscript{info: node_info("subscript"), object: identifier, index: call}

    control = %Syntax.ControlFlow{
      info: node_info("if_statement"),
      kind: :if,
      children: [subscript]
    }

    comprehension = %Syntax.Comprehension{
      info: node_info("list_comprehension"),
      kind: :list,
      children: [identifier]
    }

    generic = %Syntax.Generic{
      info: node_info("match_statement"),
      raw_type: "match_statement",
      children: [control, comprehension]
    }

    assert call.function == attribute
    assert subscript.index == call
    assert generic.raw_type == "match_statement"
  end

  defp node_info(raw_type) do
    source = %Syntax.Source{id: "memory://typed.py"}

    provenance = %Syntax.Provenance{
      raw_type: raw_type,
      named: true,
      field_name: nil,
      child_index: 0,
      parent_path: ["module"],
      child_order: []
    }

    %Syntax.NodeInfo{
      id: Syntax.NodeId.build(source, raw_type, provenance.parent_path, provenance.child_index),
      source: source,
      span: Syntax.Span.unavailable(),
      provenance: provenance
    }
  end
end
