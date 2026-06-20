# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.Phase1IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Diagnostic

  test "base IRI context and path canonicalization produce deterministic identity inputs" do
    repository_root = Path.expand("tmp/integration_project")
    absolute_source = Path.join([repository_root, "pkg", "subpkg", "..", "module.py"])

    assert {:ok, first_context} =
             IRI.context(
               base_iri: "https://analysis.example/python/",
               repository_root: repository_root
             )

    assert {:ok, second_context} =
             IRI.context(
               base_iri: "https://analysis.example/python/",
               repository_root: repository_root
             )

    assert first_context == second_context
    assert {:ok, "pkg/module.py"} = IRI.source_path(absolute_source, first_context)
    assert {:ok, "pkg/module.py"} = IRI.source_path("pkg/subpkg/../module.py")
  end

  test "invalid base and out-of-root paths fail before resource identity is built" do
    assert {:error, %Diagnostic{stage: :base_iri}} = IRI.context(base_iri: "relative/base/")

    assert {:error,
            %Diagnostic{stage: :source_path, message: "source path escapes the repository root"}} =
             IRI.source_path("../module.py")
  end

  test "ontology vocabulary IRIs remain outside generated-resource base IRIs" do
    assert {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")

    vocabulary_iri = IRI.vocabulary_iri(:structure, :Module)

    assert vocabulary_iri == "https://w3id.org/python-code/structure#Module"
    refute String.starts_with?(vocabulary_iri, context.base_iri)
  end
end
