# covers: python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Output.TurtleTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Output.Turtle
  alias PythonOntology.Validator

  @base_iri "https://analysis.example/python/"
  @fixture Path.expand(
             "../../fixtures/python_initial_slice/project/src/initial_slice_pkg/complete.py",
             __DIR__
           )

  test "serializes generated graphs with stable prefixes and deterministic triples" do
    assert {:ok, result} = PythonOntology.analyze_file(@fixture, base_iri: @base_iri)

    first = Turtle.to_string(result)
    second = Turtle.to_string(%{triples: Enum.reverse(result.triples)})

    assert first == second
    assert first =~ "@prefix rdf:"
    assert first =~ "@prefix pycore:"
    assert first =~ "@prefix pystruct:"
    assert first =~ "@prefix pytyping:"
    assert first =~ @base_iri
    assert first =~ "runtime_dependent"
    assert first =~ "unresolved"
  end

  test "writes generated Turtle that parses back through the Turtle gate" do
    tmp_dir =
      Path.join(System.tmp_dir!(), "python_ontology_turtle_output_#{System.unique_integer()}")

    path = Path.join(tmp_dir, "analysis.ttl")
    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    assert {:ok, result} = PythonOntology.analyze_file(@fixture, base_iri: @base_iri)
    assert :ok = Turtle.write_file(result, path)

    assert {:ok, parsed} = Validator.Turtle.validate_file(path)
    assert parsed.metadata.triple_count == length(result.triples)
  end
end
