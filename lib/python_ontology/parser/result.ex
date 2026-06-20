# covers: python_ontology.parser.normalized_output python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output
defmodule PythonOntology.Parser.Result do
  @moduledoc """
  Successful parser result returned by the public parser API.
  """

  alias PythonOntology.Parser.Diagnostic
  alias PythonOntology.Parser.Metadata
  alias PythonOntology.Parser.Node

  @type t :: %__MODULE__{
          source_id: String.t(),
          path: Path.t() | nil,
          root: Node.t(),
          metadata: Metadata.t(),
          diagnostics: [Diagnostic.t()],
          has_error: boolean()
        }

  @enforce_keys [:source_id, :root, :metadata]
  defstruct [:source_id, :path, :root, :metadata, diagnostics: [], has_error: false]
end
