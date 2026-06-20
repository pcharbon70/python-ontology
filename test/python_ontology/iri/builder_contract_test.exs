# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.hash_canonicalization python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.shared_iri_helper python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.BuilderContractTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Builder
  alias PythonOntology.IRI.Diagnostic
  alias PythonOntology.IRI.Fragment

  test "builder helper separates vocabulary and generated resource IRIs" do
    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    assert Builder.vocabulary(:core, :SourceFile) ==
             "https://w3id.org/python-code/core#SourceFile"

    assert IRI.builder_vocabulary(:structure, :Class) ==
             "https://w3id.org/python-code/structure#Class"

    assert {:ok, resource_iri} = Builder.resource(context, ["module", "pkg.module"])
    assert resource_iri == "https://analysis.example/python/module/pkg.module"

    refute String.starts_with?(Builder.vocabulary(:core, :SourceFile), context.base_iri)
  end

  test "builder helper generates deterministic fact resource IRIs" do
    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    opts = [
      kind: "source-declared",
      subject: "https://analysis.example/python/module/pkg",
      predicate: "https://w3id.org/python-code/structure#definesClass",
      object: "https://analysis.example/python/module/pkg/class/Example",
      source: "https://analysis.example/python/module/pkg/location/b10-20"
    ]

    canonical_input = Builder.canonical_fact_input(opts)

    expected =
      "https://analysis.example/python/fact/source-declared/h-" <> Fragment.hash(canonical_input)

    assert {:ok, ^expected} = Builder.fact(context, opts)
    assert {:ok, ^expected} = IRI.fact(context, opts)
  end

  test "builder helper diagnoses missing fact inputs" do
    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    assert {:error, %Diagnostic{stage: :builder_iri, details: %{field: :predicate}}} =
             Builder.fact(context, kind: "source-declared", subject: "s")
  end

  test "future builders must not hard-code ontology or resource IRI strings" do
    for file <- Path.wildcard("lib/python_ontology/builders/**/*.ex") do
      source = File.read!(file)

      refute source =~ "https://w3id.org/python-code/"
      refute source =~ "base_iri <>"
    end
  end
end
