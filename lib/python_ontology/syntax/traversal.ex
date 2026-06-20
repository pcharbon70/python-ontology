# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Syntax.Traversal do
  @moduledoc false

  alias PythonOntology.Syntax

  @doc false
  def children(%Syntax.ModuleNode{body: body}), do: body

  def children(%Syntax.Import{children: children}), do: children
  def children(%Syntax.Alias{children: children}), do: children

  def children(%Syntax.Class{decorators: decorators, bases: bases, body: body}) do
    decorators ++ bases ++ body
  end

  def children(%Syntax.Function{decorators: decorators, parameters: parameters, body: body}) do
    decorators ++ parameters ++ body
  end

  def children(%Syntax.Parameter{annotation: annotation, default: default}) do
    present([annotation, default])
  end

  def children(%Syntax.Decorator{expression: expression}), do: present([expression])
  def children(%Syntax.Annotation{expression: expression}), do: present([expression])
  def children(%Syntax.BaseClass{expression: expression}), do: present([expression])
  def children(%Syntax.Docstring{}), do: []

  def children(%Syntax.Assignment{targets: targets, value: value, annotation: annotation}) do
    targets ++ present([annotation, value])
  end

  def children(%Syntax.Identifier{}), do: []

  def children(%Syntax.Call{function: function, arguments: arguments}),
    do: present([function]) ++ arguments

  def children(%Syntax.Attribute{object: object, attribute: attribute}),
    do: present([object, attribute])

  def children(%Syntax.Subscript{object: object, index: index}), do: present([object, index])
  def children(%Syntax.Literal{children: children}), do: children
  def children(%Syntax.ControlFlow{children: children}), do: children
  def children(%Syntax.Comprehension{children: children}), do: children
  def children(%Syntax.Generic{children: children}), do: children
  def children(_node), do: []

  @doc false
  def descendants(node) do
    node
    |> children()
    |> Enum.flat_map(fn child -> [child | descendants(child)] end)
  end

  @doc false
  def source_slice(%{info: %{span: %{byte: %{start: start_byte, end: end_byte}}}}, source_text)
      when is_binary(source_text) and is_integer(start_byte) and is_integer(end_byte) and
             start_byte <= end_byte and start_byte >= 0 and end_byte <= byte_size(source_text) do
    binary_part(source_text, start_byte, end_byte - start_byte)
  end

  def source_slice(_node, _source_text), do: nil

  defp present(nodes), do: Enum.reject(nodes, &is_nil/1)
end
