# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.UnknownPreservationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Syntax

  @preservation_fixture Path.expand(
                          "../../fixtures/python_parser/valid/preservation_cases.py",
                          __DIR__
                        )

  test "preserves unsupported extra and named nodes as generic syntax in relative order" do
    assert {:ok, parsed} = Parser.parse_file(@preservation_fixture)
    assert {:ok, %Syntax.ModuleNode{} = module} = Syntax.normalize(parsed)

    assert [
             %Syntax.Generic{raw_type: "comment"} = comment,
             %Syntax.Function{name: "fetch", async?: true} = function
           ] = module.body

    assert comment.info.provenance.named
    assert comment.info.provenance.child_index == 0
    assert comment.info.span.point.start.row == 0

    assert [%Syntax.Generic{raw_type: "with_statement"} = with_statement] = function.body
    assert with_statement.info.provenance.child_index == 0

    assert Enum.any?(descendants(with_statement), &generic_type?(&1, "try_statement"))
    assert Enum.any?(descendants(with_statement), &generic_type?(&1, "raise_statement"))
    assert Enum.any?(descendants(with_statement), &generic_type?(&1, "list_comprehension"))
  end

  test "attaches parser diagnostics and preserves partial error syntax" do
    source = "value = (1 + )\n"

    assert {:ok, parsed} = Parser.parse_string(source, source_id: "memory://malformed.py")
    assert {:ok, %Syntax.ModuleNode{} = module} = Syntax.normalize(parsed, source: source)

    assert [%Diagnostic{stage: :parser, raw_node_type: "ERROR"}] = module.diagnostics
    assert [%Syntax.Assignment{}] = module.body
    assert Enum.any?(descendants(module), &generic_type?(&1, "ERROR"))
  end

  defp generic_type?(%Syntax.Generic{raw_type: raw_type}, raw_type), do: true
  defp generic_type?(_node, _raw_type), do: false

  defp descendants(node), do: [node | Enum.flat_map(syntax_children(node), &descendants/1)]

  defp syntax_children(%Syntax.ModuleNode{body: body}), do: body
  defp syntax_children(%Syntax.Import{children: children}), do: children
  defp syntax_children(%Syntax.Alias{children: children}), do: children

  defp syntax_children(%Syntax.Class{decorators: decorators, bases: bases, body: body}),
    do: decorators ++ bases ++ body

  defp syntax_children(%Syntax.Function{
         decorators: decorators,
         parameters: parameters,
         body: body
       }),
       do: decorators ++ parameters ++ body

  defp syntax_children(%Syntax.Parameter{annotation: annotation, default: default}),
    do: present([annotation, default])

  defp syntax_children(%Syntax.Decorator{expression: expression}), do: present([expression])
  defp syntax_children(%Syntax.Annotation{expression: expression}), do: present([expression])
  defp syntax_children(%Syntax.BaseClass{expression: expression}), do: present([expression])
  defp syntax_children(%Syntax.Docstring{}), do: []

  defp syntax_children(%Syntax.Assignment{targets: targets, value: value, annotation: annotation}),
    do: targets ++ present([annotation, value])

  defp syntax_children(%Syntax.Identifier{}), do: []

  defp syntax_children(%Syntax.Call{function: function, arguments: arguments}),
    do: present([function]) ++ arguments

  defp syntax_children(%Syntax.Attribute{object: object, attribute: attribute}),
    do: present([object, attribute])

  defp syntax_children(%Syntax.Subscript{object: object, index: index}),
    do: present([object, index])

  defp syntax_children(%Syntax.Literal{children: children}), do: children
  defp syntax_children(%Syntax.ControlFlow{children: children}), do: children
  defp syntax_children(%Syntax.Comprehension{children: children}), do: children
  defp syntax_children(%Syntax.Generic{children: children}), do: children

  defp present(nodes), do: Enum.reject(nodes, &is_nil/1)
end
