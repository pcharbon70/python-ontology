# covers: python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.CommandResult do
  @moduledoc """
  Result returned by validation command adapters.
  """

  alias PythonOntology.Validator.Report

  @type t :: %__MODULE__{
          exit_status: non_neg_integer(),
          format: atom(),
          output: String.t(),
          report: Report.t()
        }

  @enforce_keys [:exit_status, :format, :output, :report]
  defstruct [:exit_status, :format, :output, :report]
end
