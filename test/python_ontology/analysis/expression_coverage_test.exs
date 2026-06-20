# covers: python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Analysis.ExpressionCoverageTest do
  use ExUnit.Case, async: false

  @base_iri "https://analysis.example/python/"
  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"

  @source """
  import importlib

  class Example:
      def method(self, data, name):
          item = data["items"][0]
          dynamic = importlib.import_module(name)
          return factory()[name](item).value
  """

  setup do
    tmp_dir =
      Path.join(
        System.tmp_dir!(),
        "python_ontology_expression_coverage_#{System.unique_integer()}"
      )

    File.rm_rf!(tmp_dir)
    File.mkdir_p!(tmp_dir)
    path = Path.join(tmp_dir, "example.py")
    File.write!(path, @source)

    on_exit(fn -> File.rm_rf!(tmp_dir) end)

    {:ok, path: path}
  end

  test "file analysis graph contains expression resources and confidence boundaries", %{
    path: path
  } do
    assert {:ok, result} = PythonOntology.analyze_file(path, base_iri: @base_iri)
    triples = result.triples

    calls = typed_subjects(triples, @pycore <> "CallExpression")
    attributes = typed_subjects(triples, @pycore <> "AttributeExpression")
    subscripts = typed_subjects(triples, @pycore <> "SubscriptExpression")

    assert calls != []
    assert attributes != []
    assert subscripts != []

    assert resource_with_target?(triples, calls, "importlib.import_module")
    assert resource_with_target?(triples, calls, "factory(...)[name]")
    assert resource_with_target?(triples, attributes, "factory(...)[name](...).value")
    assert resource_with_target?(triples, subscripts, "data[\"items\"]")
    assert resource_with_target?(triples, subscripts, "factory(...)[name]")

    assert resource_with_confidence?(triples, calls, "runtime_dependent")
    assert resource_with_confidence?(triples, calls, "unresolved")
    assert resource_with_confidence?(triples, calls, "source_declared")

    assert Enum.any?(result.diagnostics, &(&1.message == "runtime-dependent dynamic import call"))
    assert Enum.any?(result.diagnostics, &(&1.message == "unresolved dynamic call target"))
  end

  defp typed_subjects(triples, class_iri) do
    for {subject, @rdf_type, ^class_iri} <- triples, do: subject
  end

  defp resource_with_target?(triples, resources, target_text) do
    Enum.any?(resources, fn resource ->
      {resource, @pycore <> "targetText", target_text} in triples or
        {resource, "https://w3id.org/python-code/structure#targetText", target_text} in triples
    end)
  end

  defp resource_with_confidence?(triples, resources, category) do
    resources
    |> Enum.any?(fn resource ->
      triples
      |> assertion_subjects(resource)
      |> Enum.any?(&({&1, @pycore <> "confidenceCategory", category} in triples))
    end)
  end

  defp assertion_subjects(triples, resource) do
    for {assertion, @pycore <> "assertsSubject", ^resource} <- triples, do: assertion
  end
end
