# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.specled_current_truth python_ontology.validation_strategy.command_verification python_ontology.validation_strategy.no_validation_by_execution python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.Phase1IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Validator.Turtle

  @ontology_dir Path.expand("../../../priv/ontologies", __DIR__)

  test "authored ontology and SpecLed gates are available before generated graph validation" do
    assert {:ok, results} = Turtle.validate_directory(@ontology_dir)

    parsed_files =
      results
      |> Enum.map(&Path.basename(&1.path))
      |> Enum.sort()

    assert parsed_files == [
             "python-core.ttl",
             "python-evolution.ttl",
             "python-runtime.ttl",
             "python-shapes.ttl",
             "python-structure.ttl",
             "python-typing.ttl"
           ]

    assert Mix.Task.get("spec.check")
  end
end
