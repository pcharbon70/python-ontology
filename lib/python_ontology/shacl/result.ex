# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.SHACL.Result do
  @moduledoc """
  Result returned by generated graph SHACL validation.
  """

  alias PythonOntology.Validator.Diagnostic
  alias PythonOntology.Validator.Violation

  @type triple :: {String.t(), String.t(), String.t()}
  @type t :: %__MODULE__{
          conforms?: boolean(),
          data_graph: [triple()],
          shapes_graph: term(),
          violations: [Violation.t()],
          diagnostics: [Diagnostic.t()],
          metadata: map()
        }

  @enforce_keys [:conforms?, :data_graph]
  defstruct conforms?: true,
            data_graph: [],
            shapes_graph: nil,
            violations: [],
            diagnostics: [],
            metadata: %{}
end
