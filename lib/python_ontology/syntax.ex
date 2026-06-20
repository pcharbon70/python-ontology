# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Syntax do
  @moduledoc """
  Normalized syntax model facade.

  Extractors should depend on this facade and the normalized syntax structs, not
  raw parser nodes or Tree-sitter cursor APIs.
  """

  alias PythonOntology.Parser
  alias PythonOntology.Syntax.Normalizer
  alias PythonOntology.Syntax.Traversal

  @stable_node_types [
    PythonOntology.Syntax.ModuleNode,
    PythonOntology.Syntax.Import,
    PythonOntology.Syntax.Alias,
    PythonOntology.Syntax.Class,
    PythonOntology.Syntax.Function,
    PythonOntology.Syntax.Parameter,
    PythonOntology.Syntax.Decorator,
    PythonOntology.Syntax.Annotation,
    PythonOntology.Syntax.BaseClass,
    PythonOntology.Syntax.Docstring,
    PythonOntology.Syntax.Assignment,
    PythonOntology.Syntax.Identifier,
    PythonOntology.Syntax.Call,
    PythonOntology.Syntax.Attribute,
    PythonOntology.Syntax.Subscript,
    PythonOntology.Syntax.Literal,
    PythonOntology.Syntax.ControlFlow,
    PythonOntology.Syntax.Comprehension,
    PythonOntology.Syntax.Generic
  ]

  @doc """
  Normalizes parser output into stable syntax structs.
  """
  def normalize(%Parser.Result{} = result, opts \\ []) when is_list(opts) do
    Normalizer.normalize(result, opts)
  end

  @doc """
  Returns direct normalized syntax children for a node.
  """
  defdelegate children(node), to: Traversal

  @doc """
  Returns all normalized syntax descendants for a node in preorder.
  """
  defdelegate descendants(node), to: Traversal

  @doc """
  Returns the source text slice covered by a normalized node when available.
  """
  defdelegate source_slice(node, source_text), to: Traversal

  @doc """
  Returns the normalized syntax node modules considered stable for W6 extractors.
  """
  def stable_node_types, do: @stable_node_types
end
