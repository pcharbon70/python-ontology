# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.Phase3IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Pipeline
  alias PythonOntology.Validator.Command
  alias PythonOntology.Validator.Turtle

  @source """
  import importlib

  class Example:
      def method(self, name: str):
          dynamic = importlib.import_module(name)
          return helper(name).value
  """

  @module_name_predicate "https://w3id.org/python-code/structure#moduleName"

  test "validation command reports are stable for generated pipeline graphs" do
    assert {:ok, pipeline_result} = run_pipeline()
    assert Enum.any?(pipeline_result.diagnostics, &(&1.stage == :extractor))

    assert {:ok, first} = Command.validate_graph(pipeline_result, format: :json)
    assert {:ok, second} = Command.validate_graph(pipeline_result, format: :json)

    assert first.exit_status == 0
    assert first.report.status == :pass
    assert first.report.diagnostics == []
    assert first.output == second.output
  end

  test "validation violations stay separate from parser and extractor diagnostics" do
    assert {:ok, pipeline_result} = run_pipeline()

    malformed =
      Enum.reject(pipeline_result.triples, fn {_subject, predicate, _object} ->
        predicate == @module_name_predicate
      end)

    assert {:error, result} = Command.validate_graph(malformed, format: :text)

    assert result.exit_status == 1
    assert result.report.status == :fail
    assert result.report.diagnostics == []
    assert Enum.all?(result.report.violations, &(&1.stage == :shacl_validation))
    assert result.output =~ "status: fail"
    assert result.output =~ "ModuleShape"
  end

  test "authored Turtle parse gate remains available in final acceptance" do
    assert {:ok, results} = Turtle.validate_directory()
    assert Enum.any?(results, &String.ends_with?(&1.path, "python-shapes.ttl"))
  end

  defp run_pipeline do
    with {:ok, parsed} <-
           PythonOntology.Parser.parse_string(@source, source_id: "src/pkg/example.py") do
      Pipeline.run_parser_result(parsed,
        normalize_options: [source: @source],
        module_name: "pkg.example",
        base_iri: "https://analysis.example/python/"
      )
    end
  end
end
