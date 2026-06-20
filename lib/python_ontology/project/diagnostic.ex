# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project.Diagnostic do
  @moduledoc """
  Structured diagnostic for project discovery and file selection.
  """

  @enforce_keys [:stage, :severity, :message]
  defstruct [:stage, :severity, :message, :path, details: %{}]

  @type t :: %__MODULE__{
          stage: atom(),
          severity: :error | :warning,
          message: String.t(),
          path: Path.t() | nil,
          details: map()
        }
end
