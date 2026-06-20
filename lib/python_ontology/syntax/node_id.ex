# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.NodeId do
  @moduledoc """
  Deterministic normalized node identifiers scoped to a source file.
  """

  alias PythonOntology.Syntax.Source

  @type t :: String.t()

  @doc """
  Builds a deterministic node ID from source identity and parser path data.
  """
  def build(%Source{} = source, raw_type, parent_path, child_index)
      when is_list(parent_path) and (is_integer(child_index) or is_nil(child_index)) do
    payload =
      :erlang.term_to_binary({
        source.id,
        raw_type,
        parent_path,
        child_index
      })

    digest =
      :crypto.hash(:sha256, payload)
      |> Base.url_encode64(padding: false)
      |> binary_part(0, 18)

    "syntax:" <> digest
  end
end
