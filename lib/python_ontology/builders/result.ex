# covers: python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.no_parsing_in_builders python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Builders.Result do
  @moduledoc """
  Result returned by RDF builder stages.
  """

  alias PythonOntology.Pipeline.Diagnostic

  @type triple :: {String.t(), String.t(), String.t()}
  @type t :: %__MODULE__{
          triples: [triple()],
          diagnostics: [Diagnostic.t()],
          resources: map(),
          metadata: map()
        }

  @enforce_keys [:triples]
  defstruct triples: [], diagnostics: [], resources: %{}, metadata: %{}
end
