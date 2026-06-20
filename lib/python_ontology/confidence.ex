# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Confidence do
  @moduledoc """
  Confidence and evidence helpers for extracted Python facts.
  """

  alias PythonOntology.Confidence.Category

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
end
