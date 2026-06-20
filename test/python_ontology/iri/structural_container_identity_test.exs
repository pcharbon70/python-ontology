# covers: python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.module_package_identity python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.StructuralContainerIdentityTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI

  setup do
    {:ok, context} = IRI.context(base_iri: "https://analysis.example/python/")
    %{context: context}
  end

  test "generates regular package IRIs from package names and __init__.py paths", %{
    context: context
  } do
    assert {:ok, iri} =
             IRI.package(context,
               kind: :regular,
               name: "pkg.subpkg",
               source_path: "src/pkg/subpkg/__init__.py"
             )

    assert iri ==
             "https://analysis.example/python/package/regular/pkg.subpkg/source/src/pkg/subpkg/__init__.py"
  end

  test "generates namespace package IRIs from discovered namespace roots", %{context: context} do
    assert {:ok, iri} =
             IRI.package(context,
               kind: :namespace,
               name: "pkg.plugins",
               root_path: "src/pkg/plugins"
             )

    assert iri ==
             "https://analysis.example/python/package/namespace/pkg.plugins/root/src/pkg/plugins"
  end

  test "generates ordinary and stub module IRIs from dotted names and source files", %{
    context: context
  } do
    assert {:ok, ordinary} =
             IRI.module(context,
               name: "pkg.module",
               source_path: "src/pkg/module.py"
             )

    assert {:ok, stub} =
             IRI.module(context,
               name: "pkg.module",
               source_path: "src/pkg/module.pyi"
             )

    assert ordinary ==
             "https://analysis.example/python/module/source/pkg.module/source/src/pkg/module.py"

    assert stub ==
             "https://analysis.example/python/module/stub/pkg.module/source/src/pkg/module.pyi"
  end

  test "uses source path fallback to disambiguate duplicate package and module names", %{
    context: context
  } do
    assert {:ok, first_package} =
             IRI.package(context,
               kind: :regular,
               name: "plugins",
               source_path: "src/plugins/__init__.py"
             )

    assert {:ok, second_package} =
             IRI.package(context,
               kind: :regular,
               name: "plugins",
               source_path: "vendor/plugins/__init__.py"
             )

    assert {:ok, first_module} =
             IRI.module(context, name: "plugins.auth", source_path: "src/plugins/auth.py")

    assert {:ok, second_module} =
             IRI.module(context, name: "plugins.auth", source_path: "vendor/plugins/auth.py")

    assert first_package != second_package
    assert first_module != second_module
  end
end
