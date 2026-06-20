# covers: python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Facts do
  @moduledoc """
  Public fact contract facade for extractor output.
  """

  alias PythonOntology.Facts.Fact
  alias PythonOntology.Facts.Result

  @doc """
  Returns supported fact kinds.
  """
  defdelegate kinds(), to: Fact

  @doc """
  Returns supported structural fact kinds.
  """
  defdelegate structural_kinds(), to: Fact

  @doc """
  Returns supported expression fact kinds.
  """
  defdelegate expression_kinds(), to: Fact

  @doc """
  Builds a typed fact.
  """
  defdelegate new(kind, attrs), to: Fact

  @doc """
  Builds an extractor result.
  """
  defdelegate result(facts, opts \\ []), to: Result, as: :new
end
