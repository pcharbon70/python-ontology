# covers: python_ontology.extractor_builder_boundary.shared_context python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Pipeline.Diagnostic do
  @moduledoc """
  Structured diagnostic shared by extraction, building, and pipeline stages.
  """

  @enforce_keys [:stage, :severity, :message]
  defstruct [
    :stage,
    :severity,
    :message,
    :source_id,
    :path,
    :span,
    :node_id,
    details: %{}
  ]

  @type severity :: :error | :warning | :info
  @type t :: %__MODULE__{
          stage: atom(),
          severity: severity(),
          message: String.t(),
          source_id: String.t() | nil,
          path: Path.t() | nil,
          span: term(),
          node_id: String.t() | nil,
          details: map()
        }
end
