# covers: python_ontology.parser.error_contract python_ontology.parser.source_locations python_ontology.parser.no_direct_rdf_output
defmodule PythonOntology.Parser.Diagnostic do
  @moduledoc """
  Structured parser-layer diagnostic.
  """

  @type severity :: :error | :warning | :info
  @type stage :: :source_identity | :file_read | :parser

  @type t :: %__MODULE__{
          stage: stage(),
          severity: severity(),
          message: String.t(),
          source_id: String.t() | nil,
          path: Path.t() | nil,
          span: map() | nil,
          raw_node_type: String.t() | nil,
          field_name: String.t() | nil,
          raw: term()
        }

  @enforce_keys [:stage, :severity, :message]
  defstruct [
    :stage,
    :severity,
    :message,
    :source_id,
    :path,
    :span,
    :raw_node_type,
    :field_name,
    :raw
  ]
end
