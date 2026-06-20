# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Syntax do
  @moduledoc """
  Normalized syntax model facade.
  """

  alias PythonOntology.Parser
  alias PythonOntology.Syntax.Normalizer

  @doc """
  Normalizes parser output into stable syntax structs.
  """
  def normalize(%Parser.Result{} = result, opts \\ []) when is_list(opts) do
    Normalizer.normalize(result, opts)
  end
end
