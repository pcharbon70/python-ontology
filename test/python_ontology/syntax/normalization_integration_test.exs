# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.NormalizationIntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "normalizes the first-slice fixture into deterministic typed syntax" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, first} = Syntax.normalize(parsed)
    assert {:ok, second} = Syntax.normalize(parsed)

    assert first == second

    assert %Syntax.ModuleNode{} = first
    assert Enum.count(first.body, &match?(%Syntax.Import{}, &1)) == 3

    assert %Syntax.Class{name: "Example"} =
             class = Enum.find(first.body, &match?(%Syntax.Class{}, &1))

    assert [
             %Syntax.Decorator{
               expression: %Syntax.Call{
                 function: %Syntax.Identifier{name: "decorator"},
                 arguments: [%Syntax.Literal{kind: :string, raw_text: "\"value\""}]
               }
             }
           ] = class.decorators

    assert [%Syntax.BaseClass{expression: %Syntax.Identifier{name: "Base"}}] = class.bases

    assert %Syntax.Assignment{
             targets: [%Syntax.Identifier{name: "class_attr"}],
             annotation: %Syntax.Annotation{raw_text: "int"},
             value: %Syntax.Literal{kind: :number, raw_text: "1", value: 1}
           } = assignment(class.body, "class_attr")

    assert %Syntax.Function{name: "method", method_candidate?: true} =
             function = Enum.find(class.body, &match?(%Syntax.Function{}, &1))

    assert Enum.map(function.parameters, &{&1.name, &1.kind}) == [
             {"self", :positional},
             {"name", :positional},
             {"args", :vararg},
             {"enabled", :keyword_only},
             {"kwargs", :kwarg}
           ]

    assert Enum.find(function.parameters, &(&1.name == "name")).annotation.raw_text == "str"
    assert Enum.find(function.parameters, &(&1.name == "enabled")).default.value == true
    assert function.return_annotation.raw_text == "str"

    assert %Syntax.Assignment{
             targets: [%Syntax.Identifier{name: "result"}],
             value: %Syntax.Call{
               function: %Syntax.Identifier{name: "helper"},
               arguments: [
                 %Syntax.Identifier{name: "name"},
                 %Syntax.Generic{raw_type: "list_splat"},
                 %Syntax.Generic{raw_type: "dictionary_splat"}
               ]
             }
           } = assignment(function.body, "result")

    assert Enum.any?(descendants(function), fn
             %Syntax.Attribute{
               object: %Syntax.Identifier{name: "result"},
               attribute: %Syntax.Identifier{name: "value"}
             } ->
               true

             _other ->
               false
           end)
  end

  defp assignment(nodes, target_name) do
    Enum.find(nodes, fn
      %Syntax.Assignment{targets: [%Syntax.Identifier{name: ^target_name} | _rest]} -> true
      _other -> false
    end)
  end

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
