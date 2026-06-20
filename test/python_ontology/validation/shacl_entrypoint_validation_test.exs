# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.ShaclEntrypointValidationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator
  alias PythonOntology.Validator.Diagnostic

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @module "https://analysis.example/python/module/sample"
  @module_class "https://w3id.org/python-code/structure#Module"

  test "validates a generated graph input and loads the default shapes graph" do
    triples = [
      {@module, @rdf_type, @module_class},
      {@module, "https://w3id.org/python-code/structure#moduleName", "sample"}
    ]

    assert {:ok, %Result{} = result} = Validator.validate_graph(%{triples: triples})
    assert result.conforms?
    assert result.data_graph == triples
    assert result.shapes_graph
    assert result.metadata.data_triple_count == 2
    assert String.ends_with?(result.metadata.shapes_path, "python-shapes.ttl")
    assert result.metadata.shapes_triple_count > 0
  end

  test "rejects malformed generated graph triples before loading shapes" do
    assert {:error, [%Diagnostic{} = diagnostic]} =
             Validator.validate_graph([{@module, @rdf_type, :not_a_string}])

    assert diagnostic.stage == :shacl_validation
    assert diagnostic.message =~ "data graph triples"
  end

  test "returns shape parse diagnostics with path details" do
    shapes_path =
      Path.join(
        System.tmp_dir!(),
        "python-ontology-invalid-shapes-#{System.unique_integer()}.ttl"
      )

    on_exit(fn -> File.rm(shapes_path) end)

    File.write!(shapes_path, "@prefix : <https://example.invalid/> .\n:shape a .\n")

    assert {:error, [%Diagnostic{} = diagnostic]} =
             Validator.validate_graph([], shapes_path: shapes_path)

    assert diagnostic.stage == :turtle_parse
    assert diagnostic.path == Path.expand(shapes_path)
  end
end
