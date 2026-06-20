# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.no_validation_by_execution python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.Diagnostic do
  @moduledoc """
  Structured diagnostic emitted by validation stages.
  """

  @enforce_keys [:stage, :severity, :message]
  defstruct [:stage, :severity, :message, :path, details: %{}]

  @type severity :: :info | :warning | :error

  @type t :: %__MODULE__{
          stage: atom(),
          severity: severity(),
          message: String.t(),
          path: Path.t() | nil,
          details: map()
        }
end
