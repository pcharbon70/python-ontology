# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Syntax.ExpressionMappingTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @source """
  call_result = helper(name, *args, **kwargs)
  attr_result = result.value
  item = data[0]
  text = "hello"
  count = 42
  flag = True
  missing = None
  items = [1, 2]
  pair = (1, 2)
  mapping = {"a": 1}
  unique = {1, 2}
  """

  test "normalizes assignments, calls, arguments, attributes, and subscripts" do
    module = normalize!()

    assert %Syntax.Assignment{
             targets: [%Syntax.Identifier{name: "call_result"}],
             value: %Syntax.Call{
               function: %Syntax.Identifier{name: "helper"},
               arguments: [
                 %Syntax.Identifier{name: "name"},
                 %Syntax.Generic{raw_type: "list_splat"},
                 %Syntax.Generic{raw_type: "dictionary_splat"}
               ]
             }
           } = assignment(module, "call_result")

    assert %Syntax.Assignment{
             value: %Syntax.Attribute{
               object: %Syntax.Identifier{name: "result"},
               attribute: %Syntax.Identifier{name: "value"}
             }
           } = assignment(module, "attr_result")

    assert %Syntax.Assignment{
             value: %Syntax.Subscript{
               object: %Syntax.Identifier{name: "data"},
               index: %Syntax.Literal{kind: :number, raw_text: "0", value: 0}
             }
           } = assignment(module, "item")
  end

  test "normalizes basic literal leaves and container literal children" do
    module = normalize!()

    assert %Syntax.Literal{kind: :string, raw_text: "\"hello\"", value: "\"hello\""} =
             assignment(module, "text").value

    assert %Syntax.Literal{kind: :number, raw_text: "42", value: 42} =
             assignment(module, "count").value

    assert %Syntax.Literal{kind: :boolean, raw_text: "True", value: true} =
             assignment(module, "flag").value

    assert %Syntax.Literal{kind: :none, raw_text: "None", value: nil} =
             assignment(module, "missing").value

    assert %Syntax.Literal{kind: :list, raw_text: "[1, 2]", children: [_, _]} =
             assignment(module, "items").value

    assert %Syntax.Literal{kind: :tuple, raw_text: "(1, 2)", children: [_, _]} =
             assignment(module, "pair").value

    assert %Syntax.Literal{kind: :dict, raw_text: "{\"a\": 1}", children: [_]} =
             assignment(module, "mapping").value

    assert %Syntax.Literal{kind: :set, raw_text: "{1, 2}", children: [_, _]} =
             assignment(module, "unique").value
  end

  defp normalize! do
    assert {:ok, parsed} = Parser.parse_string(@source, source_id: "memory://expressions.py")
    assert {:ok, %Syntax.ModuleNode{} = module} = Syntax.normalize(parsed, source: @source)
    module
  end

  defp assignment(module, target_name) do
    Enum.find(module.body, fn
      %Syntax.Assignment{targets: [%Syntax.Identifier{name: ^target_name} | _rest]} -> true
      _other -> false
    end)
  end
end
