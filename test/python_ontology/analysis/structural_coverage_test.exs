# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Analysis.StructuralCoverageTest do
  use ExUnit.Case, async: true

  @base_iri "https://analysis.example/python/"
  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)
  @project_fixture Path.expand("../../fixtures/python_projects/src_layout", __DIR__)
  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"
  @pytyping "https://w3id.org/python-code/typing#"

  test "file analysis graph contains first-slice structural resources" do
    assert {:ok, result} = PythonOntology.analyze_file(@fixture, base_iri: @base_iri)
    triples = result.triples

    assert typed?(triples, @pycore <> "SourceFile")
    assert typed?(triples, @pycore <> "SourceLocation")
    assert typed?(triples, @pycore <> "ImportStatement")
    assert typed?(triples, @pycore <> "ImportAlias")
    assert typed?(triples, @pystruct <> "Module")
    assert typed?(triples, @pystruct <> "Class")
    assert typed?(triples, @pystruct <> "Method")
    assert typed?(triples, @pystruct <> "Parameter")
    assert typed?(triples, @pystruct <> "BaseClass")
    assert typed?(triples, @pystruct <> "Decorator")
    assert typed?(triples, @pystruct <> "Annotation")

    assert predicate_object?(triples, @pycore <> "hasImportAlias", nil)
    assert predicate_object?(triples, @pycore <> "aliasName", "system")
    assert predicate_object?(triples, @pycore <> "aliasName", "FilePath")
    assert predicate_object?(triples, @pystruct <> "hasBaseClass", nil)
    assert predicate_object?(triples, @pystruct <> "hasDecorator", nil)
    assert predicate_object?(triples, @pystruct <> "hasAnnotation", nil)

    assert predicate_object?(triples, @pystruct <> "parameterKind", "vararg")
    assert predicate_object?(triples, @pystruct <> "parameterKind", "keyword_only")
    assert predicate_object?(triples, @pystruct <> "parameterKind", "kwarg")
    assert predicate_object?(triples, @pystruct <> "defaultText", "True")
    assert predicate_object?(triples, @pytyping <> "annotationText", "str")
    assert predicate_object?(triples, @pytyping <> "annotationText", "int")

    refute Enum.any?(triples, fn {_subject, _predicate, object} ->
             object == "typing.Any" or String.ends_with?(object, "#TypeExpression")
           end)
  end

  test "project analysis graph contains package resources" do
    assert {:ok, result} = PythonOntology.analyze_project(@project_fixture, base_iri: @base_iri)

    assert typed?(result.triples, @pystruct <> "Package")
  end

  defp typed?(triples, class_iri) do
    Enum.any?(triples, &match?({_subject, @rdf_type, ^class_iri}, &1))
  end

  defp predicate_object?(triples, predicate, nil) do
    Enum.any?(triples, &match?({_subject, ^predicate, _object}, &1))
  end

  defp predicate_object?(triples, predicate, object) do
    Enum.any?(triples, &match?({_subject, ^predicate, ^object}, &1))
  end
end
