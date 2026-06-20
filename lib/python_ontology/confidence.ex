# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Confidence do
  @moduledoc """
  Confidence and evidence helpers for extracted Python facts.
  """

  alias PythonOntology.Confidence.Category
  alias PythonOntology.Confidence.Evidence

  @doc """
  Returns all supported confidence categories.
  """
  defdelegate categories(), to: Category, as: :all

  @doc """
  Returns the default category for direct syntax extraction.
  """
  defdelegate direct_syntax_default(), to: Category

  @doc """
  Validates a confidence category.
  """
  defdelegate validate_category(category), to: Category, as: :validate

  @doc """
  Builds source file/span evidence.
  """
  defdelegate source_evidence(opts), to: Evidence, as: :source

  @doc """
  Builds normalized syntax node evidence.
  """
  defdelegate syntax_evidence(input), to: Evidence, as: :syntax_node

  @doc """
  Builds static inference evidence.
  """
  defdelegate static_inference_evidence(reason, inputs, opts \\ []),
    to: Evidence,
    as: :static_inference

  @doc """
  Builds unresolved evidence.
  """
  defdelegate unresolved_evidence(reason, opts \\ []), to: Evidence, as: :unresolved

  @doc """
  Builds runtime-dependent evidence.
  """
  defdelegate runtime_evidence(reason, opts \\ []), to: Evidence, as: :runtime_dependent

  @doc """
  Validates an evidence list.
  """
  defdelegate evidence_list(evidence), to: Evidence, as: :list
end
