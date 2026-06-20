# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.ByteSpan do
  @moduledoc """
  Zero-based byte range for normalized syntax nodes.
  """

  @type t :: %__MODULE__{
          start: non_neg_integer() | nil,
          end: non_neg_integer() | nil
        }

  @enforce_keys [:start, :end]
  defstruct [:start, :end]

  @doc """
  Builds an available byte span.
  """
  def new(start, finish)
      when is_integer(start) and start >= 0 and is_integer(finish) and finish >= start do
    %__MODULE__{start: start, end: finish}
  end

  @doc """
  Returns an unavailable byte span.
  """
  def unavailable do
    %__MODULE__{start: nil, end: nil}
  end
end
