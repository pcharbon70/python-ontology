# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.Point do
  @moduledoc """
  Zero-based row and column point for normalized syntax nodes.
  """

  @type t :: %__MODULE__{
          row: non_neg_integer() | nil,
          column: non_neg_integer() | nil
        }

  @enforce_keys [:row, :column]
  defstruct [:row, :column]

  @doc """
  Builds an available source point.
  """
  def new(row, column) when is_integer(row) and row >= 0 and is_integer(column) and column >= 0 do
    %__MODULE__{row: row, column: column}
  end

  @doc """
  Returns an unavailable source point.
  """
  def unavailable do
    %__MODULE__{row: nil, column: nil}
  end
end
