# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.BaseIRITest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic

  test "builds a default generated-resource context for local analysis" do
    assert {:ok, %Context{} = context} = IRI.context()

    assert context.base_iri == "https://example.invalid/python-ontology/resources/"
    assert context.repository_root == nil
  end

  test "accepts safe configured generated-resource base IRIs" do
    assert {:ok, %Context{base_iri: "https://analysis.example/resources/"}} =
             IRI.context(base_iri: "https://analysis.example/resources/")
  end

  test "rejects missing malformed or unsafe generated-resource base IRIs" do
    for base_iri <- [
          nil,
          "",
          "not a uri",
          "urn:python:",
          "https://example.org/resources",
          "https://example.org/resources/?q=1",
          "https://example.org/has space/"
        ] do
      assert {:error, %Diagnostic{stage: :base_iri, severity: :error}} =
               IRI.validate_base_iri(base_iri)
    end
  end

  test "keeps ontology vocabulary IRIs separate from generated resource bases" do
    assert IRI.ontology_iri(:core) == "https://w3id.org/python-code/core"

    assert IRI.vocabulary_iri(:core, :SourceFile) ==
             "https://w3id.org/python-code/core#SourceFile"

    refute String.starts_with?(IRI.vocabulary_iri(:core, :SourceFile), IRI.default_base_iri())
  end
end
