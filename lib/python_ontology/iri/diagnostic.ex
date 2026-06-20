# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output
defmodule PythonOntology.IRI.Diagnostic do
  @moduledoc """
  Structured diagnostic for IRI identity generation.
  """

  @enforce_keys [:stage, :severity, :message]
  defstruct [:stage, :severity, :message, :input, details: %{}]

  @type t :: %__MODULE__{
          stage: atom(),
          severity: :error | :warning,
          message: String.t(),
          input: term(),
          details: map()
        }
end
