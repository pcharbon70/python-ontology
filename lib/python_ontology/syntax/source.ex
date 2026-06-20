# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.Source do
  @moduledoc """
  Source identity and parser metadata shared by normalized syntax nodes.
  """

  alias PythonOntology.Parser

  @type t :: %__MODULE__{
          id: String.t(),
          path: Path.t() | nil,
          parser_metadata: Parser.Metadata.t() | map() | nil
        }

  @enforce_keys [:id]
  defstruct [:id, :path, :parser_metadata]

  @doc """
  Builds source identity from a parser result.
  """
  def from_parser_result(%Parser.Result{} = result) do
    %__MODULE__{
      id: result.source_id,
      path: result.path,
      parser_metadata: result.metadata
    }
  end
end
