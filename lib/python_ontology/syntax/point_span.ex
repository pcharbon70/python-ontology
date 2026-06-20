# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.PointSpan do
  @moduledoc """
  Zero-based row/column source range for normalized syntax nodes.
  """

  alias PythonOntology.Syntax.Point

  @type t :: %__MODULE__{
          start: Point.t(),
          end: Point.t()
        }

  @enforce_keys [:start, :end]
  defstruct [:start, :end]

  @doc """
  Builds an available row/column span.
  """
  def new(%Point{} = start_point, %Point{} = end_point) do
    %__MODULE__{start: start_point, end: end_point}
  end

  @doc """
  Returns an unavailable row/column span.
  """
  def unavailable do
    %__MODULE__{start: Point.unavailable(), end: Point.unavailable()}
  end
end
