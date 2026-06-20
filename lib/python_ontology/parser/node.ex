# covers: python_ontology.parser.normalized_output python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Parser.Node do
  @moduledoc """
  Normalized Tree-sitter concrete syntax node.
  """

  alias PythonOntology.Parser.Span

  @type t :: %__MODULE__{
          kind: String.t(),
          field_name: String.t() | nil,
          named: boolean(),
          extra: boolean(),
          error: boolean(),
          missing: boolean(),
          has_error: boolean(),
          span: Span.t(),
          child_count: non_neg_integer(),
          named_child_count: non_neg_integer(),
          children: [t()]
        }

  @enforce_keys [
    :kind,
    :named,
    :extra,
    :error,
    :missing,
    :has_error,
    :span,
    :child_count,
    :named_child_count,
    :children
  ]
  defstruct [
    :kind,
    :field_name,
    :named,
    :extra,
    :error,
    :missing,
    :has_error,
    :span,
    :child_count,
    :named_child_count,
    children: []
  ]

  @doc false
  def from_native(native_node) do
    %__MODULE__{
      kind: native_node.kind,
      field_name: native_node.field_name,
      named: native_node.named,
      extra: native_node.extra,
      error: native_node.error,
      missing: native_node.missing,
      has_error: native_node.has_error,
      span: Span.from_native(native_node),
      child_count: native_node.child_count,
      named_child_count: native_node.named_child_count,
      children: Enum.map(native_node.children, &from_native/1)
    }
  end
end
