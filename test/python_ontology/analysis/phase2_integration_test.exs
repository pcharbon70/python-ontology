# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Analysis.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  @base_iri "https://analysis.example/python/"
  @fixture_project Path.expand("../../fixtures/python_initial_slice/project", __DIR__)
  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"

  test "first-slice fixture project covers structural and expression graph requirements" do
    assert {:ok, result} = PythonOntology.analyze_project(@fixture_project, base_iri: @base_iri)

    facts = Enum.flat_map(result.pipeline_results, & &1.facts)
    triples = result.triples

    for kind <- [
          :source_file,
          :package,
          :module,
          :import,
          :import_alias,
          :class,
          :method,
          :parameter,
          :decorator,
          :annotation,
          :base_class,
          :call,
          :attribute,
          :subscript
        ] do
      assert Enum.any?(facts, &(&1.kind == kind)), "expected #{kind} fact"
    end

    assert result.validation_status == :pass
    assert Enum.any?(facts, &(&1.kind == :parameter and &1.attributes.kind == :vararg))
    assert Enum.any?(facts, &(&1.kind == :parameter and &1.attributes.kind == :keyword_only))
    assert Enum.any?(facts, &(&1.kind == :parameter and &1.attributes.kind == :kwarg))
    assert Enum.any?(facts, &(&1.kind == :annotation and &1.raw_text == "int"))
    assert Enum.any?(facts, &(&1.kind == :annotation and &1.raw_text == "str"))

    for class_iri <- [
          @pycore <> "SourceFile",
          @pycore <> "SourceLocation",
          @pycore <> "ImportStatement",
          @pycore <> "ImportAlias",
          @pycore <> "CallExpression",
          @pycore <> "AttributeExpression",
          @pycore <> "SubscriptExpression",
          @pystruct <> "Package",
          @pystruct <> "Module",
          @pystruct <> "Class",
          @pystruct <> "Method",
          @pystruct <> "Parameter",
          @pystruct <> "Decorator",
          @pystruct <> "Annotation",
          @pystruct <> "BaseClass"
        ] do
      assert typed?(triples, class_iri), "expected #{class_iri}"
    end

    assert predicate_object?(triples, @pycore <> "aliasName", "system")
    assert predicate_object?(triples, @pycore <> "aliasName", "FilePath")
    assert predicate_object?(triples, @pystruct <> "parameterKind", "keyword_only")
    assert predicate_object?(triples, @pystruct <> "defaultText", "True")
    assert predicate_object?(triples, @pycore <> "confidenceCategory", "runtime_dependent")
    assert predicate_object?(triples, @pycore <> "confidenceCategory", "unresolved")

    assert Enum.any?(result.diagnostics, &(&1.message == "runtime-dependent dynamic import call"))
    assert Enum.any?(result.diagnostics, &(&1.message == "unresolved dynamic call target"))
  end

  defp typed?(triples, class_iri) do
    Enum.any?(triples, &match?({_subject, @rdf_type, ^class_iri}, &1))
  end

  defp predicate_object?(triples, predicate, object) do
    Enum.any?(triples, &match?({_subject, ^predicate, ^object}, &1))
  end
end
