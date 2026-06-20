# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator.Violation do
  @moduledoc """
  Structured validation violation emitted by closed-world graph checks.
  """

  @enforce_keys [:target_node, :shape, :path, :message]
  defstruct [
    :target_node,
    :shape,
    :path,
    :message,
    :source,
    severity: :violation,
    stage: :shacl_validation,
    source_context: %{}
  ]

  @type t :: %__MODULE__{
          severity: :violation,
          stage: atom(),
          target_node: String.t(),
          shape: String.t(),
          path: String.t(),
          message: String.t(),
          source: String.t() | nil,
          source_context: map()
        }

  @doc """
  Returns a deterministic map representation.
  """
  @spec to_map(t()) :: map()
  def to_map(%__MODULE__{} = violation) do
    %{
      severity: violation.severity,
      stage: violation.stage,
      target_node: violation.target_node,
      shape: violation.shape,
      path: violation.path,
      message: violation.message,
      source: violation.source,
      source_context: Map.new(violation.source_context)
    }
  end
end
