# covers: python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.source_span_preservation python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Syntax.Span do
  @moduledoc """
  Combined byte and row/column range for normalized syntax nodes.
  """

  alias PythonOntology.Parser
  alias PythonOntology.Syntax.ByteSpan
  alias PythonOntology.Syntax.Point
  alias PythonOntology.Syntax.PointSpan

  @type t :: %__MODULE__{
          byte: ByteSpan.t(),
          point: PointSpan.t()
        }

  @enforce_keys [:byte, :point]
  defstruct [:byte, :point]

  @doc """
  Builds a normalized span from a parser span.
  """
  def from_parser(%Parser.Span{} = span) do
    %__MODULE__{
      byte: ByteSpan.new(span.start_byte, span.end_byte),
      point:
        PointSpan.new(
          Point.new(span.start_line, span.start_column),
          Point.new(span.end_line, span.end_column)
        )
    }
  end

  @doc """
  Returns an unavailable normalized span.
  """
  def unavailable do
    %__MODULE__{byte: ByteSpan.unavailable(), point: PointSpan.unavailable()}
  end
end
