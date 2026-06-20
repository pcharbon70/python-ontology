# covers: python_ontology.parser.normalized_output python_ontology.parser.source_locations python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Parser.Span do
  @moduledoc """
  Byte and row/column source range for parser output.
  """

  @type t :: %__MODULE__{
          start_byte: non_neg_integer(),
          end_byte: non_neg_integer(),
          start_line: non_neg_integer(),
          start_column: non_neg_integer(),
          end_line: non_neg_integer(),
          end_column: non_neg_integer()
        }

  @enforce_keys [:start_byte, :end_byte, :start_line, :start_column, :end_line, :end_column]
  defstruct [:start_byte, :end_byte, :start_line, :start_column, :end_line, :end_column]

  @doc false
  def from_native(native_node) do
    %__MODULE__{
      start_byte: native_node.start_byte,
      end_byte: native_node.end_byte,
      start_line: native_node.start_point.row,
      start_column: native_node.start_point.column,
      end_line: native_node.end_point.row,
      end_column: native_node.end_point.column
    }
  end
end
