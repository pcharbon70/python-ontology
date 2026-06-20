# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.ontology_turtle_files.bootstrap_validity python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Validation.ShaclShapeValidationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"

  @module "https://analysis.example/python/module/sample"
  @function "https://analysis.example/python/function/sample/build"
  @parameter "https://analysis.example/python/parameter/sample/build/name"
  @location "https://analysis.example/python/location/sample"

  test "accepts first-slice modules functions parameters and source locations" do
    assert {:ok, %Result{} = result} = Validator.validate_graph(valid_graph())

    assert result.conforms?
    assert result.violations == []
  end

  test "reports missing required first-slice properties" do
    triples = [
      {@module, @rdf_type, iri(:structure, "Module")},
      {@function, @rdf_type, iri(:structure, "Function")},
      {@function, iri(:structure, "hasParameter"), @parameter},
      {@location, @rdf_type, iri(:core, "SourceLocation")},
      {@location, iri(:core, "line"), "not-an-integer"}
    ]

    assert {:ok, %Result{} = result} = Validator.validate_graph(triples)

    refute result.conforms?

    assert violation?(result, @module, "ModuleShape", iri(:structure, "moduleName"))
    assert violation?(result, @module, "ModuleShape", iri(:core, "hasLocation"))
    assert violation?(result, @function, "FunctionShape", iri(:structure, "qualifiedName"))
    assert violation?(result, @parameter, "FunctionShape", iri(:structure, "hasParameter"))
    assert violation?(result, @parameter, "ParameterShape", iri(:structure, "name"))
    assert violation?(result, @location, "SourceLocationShape", iri(:core, "line"))
    assert violation?(result, @location, "SourceLocationShape", iri(:core, "column"))
  end

  defp valid_graph do
    [
      {@module, @rdf_type, iri(:structure, "Module")},
      {@module, iri(:structure, "moduleName"), "sample"},
      {@module, iri(:core, "hasLocation"), @location},
      {@function, @rdf_type, iri(:structure, "Function")},
      {@function, iri(:structure, "qualifiedName"), "sample.build"},
      {@function, iri(:structure, "hasParameter"), @parameter},
      {@parameter, @rdf_type, iri(:structure, "Parameter")},
      {@parameter, iri(:structure, "name"), "name"},
      {@location, @rdf_type, iri(:core, "SourceLocation")},
      {@location, iri(:core, "line"), "1"},
      {@location, iri(:core, "column"), "0"}
    ]
  end

  defp violation?(%Result{} = result, target_node, shape, path) do
    Enum.any?(result.violations, fn violation ->
      violation.target_node == target_node and
        violation.shape == shape and
        violation.path == path
    end)
  end

  defp iri(:core, term), do: @pycore <> term
  defp iri(:structure, term), do: @pystruct <> term
end
