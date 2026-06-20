# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.builder_propagation python_ontology.fact_confidence_model.queryable_confidence python_ontology.ontology_turtle_files.dynamic_fact_boundary python_ontology.ontology_turtle_files.bootstrap_validity python_ontology.validation_strategy.command_verification
defmodule PythonOntology.Ontology.ConfidenceVocabularyTest do
  use ExUnit.Case, async: true

  @ontology_dir Path.expand("../../../priv/ontologies", __DIR__)

  test "core ontology exposes queryable confidence categories and evidence vocabulary" do
    core = File.read!(Path.join(@ontology_dir, "python-core.ttl"))

    for term <- [
          ":FactAssertion",
          ":SourceDeclaredFact",
          ":StaticallyInferredFact",
          ":UnresolvedFact",
          ":RuntimeDependentFact",
          ":Evidence",
          ":SourceEvidence",
          ":InferenceEvidence",
          ":UnresolvedEvidence",
          ":RuntimeEvidence",
          ":confidenceCategory",
          ":hasEvidence",
          ":evidenceKind",
          ":evidenceReason",
          ":evidenceSource"
        ] do
      assert core =~ term
    end

    assert core =~ "source_declared, statically_inferred, unresolved, or runtime_dependent"
    assert core =~ "depends on executing Python code"
  end

  test "runtime ontology aligns dynamic constructs with runtime-dependent confidence" do
    runtime = File.read!(Path.join(@ontology_dir, "python-runtime.ttl"))

    for term <- [
          ":DynamicImport",
          ":MonkeyPatch",
          ":RuntimeBoundary",
          ":DynamicAttributeAccess",
          ":DynamicAttributeMutation",
          ":DecoratorRuntimeEffect",
          ":MetaclassRuntimeEffect",
          ":ReflectionBoundary"
        ] do
      assert runtime =~ term
    end

    assert runtime =~ "pycore:RuntimeDependentFact"
    assert runtime =~ "should not promote to static truth"
  end

  test "authored ontology files retain ontology declarations and prefixes" do
    for path <- Path.wildcard(Path.join(@ontology_dir, "*.ttl")) do
      text = File.read!(path)

      assert text =~ "@prefix"
      assert text =~ "a owl:Ontology"
    end
  end
end
