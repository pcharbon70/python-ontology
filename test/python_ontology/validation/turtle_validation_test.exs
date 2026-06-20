# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.owl_open_world python_ontology.validation_strategy.no_validation_by_execution python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.TurtleValidationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Validator.Diagnostic
  alias PythonOntology.Validator.Turtle

  @ontology_dir Path.expand("../../../priv/ontologies", __DIR__)

  test "parses authored ontology turtle files deterministically" do
    files = Turtle.ontology_files(@ontology_dir)

    assert Enum.map(files, &Path.basename/1) == [
             "python-core.ttl",
             "python-evolution.ttl",
             "python-runtime.ttl",
             "python-shapes.ttl",
             "python-structure.ttl",
             "python-typing.ttl"
           ]

    assert {:ok, results} = Turtle.validate_files(files)
    assert Enum.map(results, &Path.basename(&1.path)) == Enum.map(files, &Path.basename/1)
    assert Enum.all?(results, &(&1.metadata.triple_count > 0))
  end

  test "returns file path and parse details for malformed Turtle" do
    path = Path.join(System.tmp_dir!(), "python-ontology-invalid-#{System.unique_integer()}.ttl")
    on_exit(fn -> File.rm(path) end)

    File.write!(path, "@prefix : <https://example.invalid/> .\n:broken a .\n")

    assert {:error, [%Diagnostic{} = diagnostic]} = Turtle.validate_files([path])
    assert diagnostic.stage == :turtle_parse
    assert diagnostic.severity == :error
    assert diagnostic.path == Path.expand(path)
    assert diagnostic.message =~ "Turtle parse failed"
    assert is_binary(diagnostic.details.reason)
  end
end
