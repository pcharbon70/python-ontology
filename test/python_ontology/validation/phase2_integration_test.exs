# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Pipeline
  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @module_name "sample_pkg.first_slice"
  @source_id "src/sample_pkg/first_slice.py"
  @base_iri "https://analysis.example/python/"
  @module_name_predicate "https://w3id.org/python-code/structure#moduleName"

  test "validates generated pipeline RDF graph for the first slice" do
    assert {:ok, pipeline_result} = run_pipeline()
    assert {:ok, %Result{} = validation_result} = Validator.validate_graph(pipeline_result)

    assert validation_result.conforms?
    assert validation_result.violations == []
    assert validation_result.metadata.data_triple_count == length(pipeline_result.triples)
  end

  test "rejects a generated graph fixture with missing required properties" do
    assert {:ok, pipeline_result} = run_pipeline()

    malformed_triples =
      Enum.reject(pipeline_result.triples, fn {_subject, predicate, _object} ->
        predicate == @module_name_predicate
      end)

    assert {:ok, %Result{} = validation_result} = Validator.validate_graph(malformed_triples)

    refute validation_result.conforms?

    assert Enum.any?(validation_result.violations, fn violation ->
             violation.shape == "ModuleShape" and
               violation.path == @module_name_predicate and
               violation.message =~ "moduleName"
           end)
  end

  defp run_pipeline do
    Pipeline.run_file(@fixture,
      parser_options: [source_id: @source_id],
      module_name: @module_name,
      base_iri: @base_iri
    )
  end
end
