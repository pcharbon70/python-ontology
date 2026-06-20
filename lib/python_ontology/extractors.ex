# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Extractors do
  @moduledoc """
  Public extractor facade for first-slice Python facts.
  """

  alias PythonOntology.Extractors.Context
  alias PythonOntology.Extractors.Expressions
  alias PythonOntology.Extractors.Structural
  alias PythonOntology.Facts.Result
  alias PythonOntology.Syntax

  @doc """
  Runs first-slice extractors over normalized syntax.
  """
  @spec extract(Syntax.ModuleNode.t(), Context.t()) :: Result.t()
  def extract(%Syntax.ModuleNode{} = syntax_root, %Context{} = context) do
    [
      Structural.extract(syntax_root, context),
      Expressions.extract(syntax_root, context)
    ]
    |> Result.merge()
  end
end
