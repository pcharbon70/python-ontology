# covers: python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Facts.Result do
  @moduledoc """
  Result returned by extractor stages.
  """

  alias PythonOntology.Facts.Fact
  alias PythonOntology.Pipeline.Diagnostic

  @enforce_keys [:facts]
  defstruct facts: [], diagnostics: [], metadata: %{}

  @type t :: %__MODULE__{
          facts: [Fact.t()],
          diagnostics: [Diagnostic.t()],
          metadata: map()
        }

  @doc """
  Builds an extraction result from facts and diagnostics.
  """
  def new(facts, opts \\ []) when is_list(facts) do
    %__MODULE__{
      facts: facts,
      diagnostics: List.wrap(Keyword.get(opts, :diagnostics, [])),
      metadata: Map.new(Keyword.get(opts, :metadata, %{}))
    }
  end

  @doc """
  Merges extractor results in order.
  """
  def merge(results) when is_list(results) do
    %__MODULE__{
      facts: Enum.flat_map(results, & &1.facts),
      diagnostics: Enum.flat_map(results, & &1.diagnostics),
      metadata: %{result_count: length(results)}
    }
  end
end
