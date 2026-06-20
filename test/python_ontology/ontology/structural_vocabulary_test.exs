# covers: python_ontology.ontology_turtle_files.python_native_boundaries python_ontology.ontology_turtle_files.bootstrap_validity python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Ontology.StructuralVocabularyTest do
  use ExUnit.Case, async: true

  @ontology_dir Path.expand("../../../priv/ontologies", __DIR__)

  test "core and structure ontologies declare first-slice structural graph terms" do
    core = File.read!(Path.join(@ontology_dir, "python-core.ttl"))
    structure = File.read!(Path.join(@ontology_dir, "python-structure.ttl"))

    for term <- [":ImportAlias", ":hasImportAlias", ":importName", ":aliasName"] do
      assert core =~ term
    end

    for term <- [
          ":BaseClass",
          ":Annotation",
          ":parameterKind",
          ":defaultText",
          ":hasBaseClass",
          ":hasAnnotation"
        ] do
      assert structure =~ term
    end

    assert structure =~ "does not imply resolved type semantics"
  end
end
