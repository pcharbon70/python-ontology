# covers: python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.IRI.PathTest do
  use ExUnit.Case, async: true

  alias PythonOntology.IRI
  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic

  test "normalizes relative source paths to POSIX form" do
    assert {:ok, "pkg/module.py"} = IRI.source_path("pkg\\module.py")
    assert {:ok, "pkg/module.py"} = IRI.source_path("./pkg/./module.py")
    assert {:ok, "pkg/module.py"} = IRI.source_path("pkg/generated/../module.py")
  end

  test "rejects relative paths that escape the repository root" do
    assert {:error, %Diagnostic{stage: :source_path, severity: :error}} =
             IRI.source_path("../outside.py")
  end

  test "normalizes absolute source paths through a repository root" do
    root = Path.expand("tmp/project")
    path = Path.join([root, "pkg", "..", "pkg", "module.py"])

    assert {:ok, "pkg/module.py"} = IRI.source_path(path, repository_root: root)
  end

  test "rejects absolute source paths without or outside a repository root" do
    outside = Path.expand("tmp/outside.py")

    assert {:error, %Diagnostic{message: "absolute source paths require a repository root"}} =
             IRI.source_path(outside)

    assert {:error, %Diagnostic{message: "source path escapes the repository root"}} =
             IRI.source_path(outside, repository_root: Path.expand("tmp/project"))
  end

  test "accepts an IRI context for source path canonicalization" do
    root = Path.expand("tmp/project")
    path = Path.join([root, "src", "example.py"])

    assert {:ok, context} = IRI.context(repository_root: root)
    assert %Context{} = context
    assert {:ok, "src/example.py"} = IRI.source_path(path, context)
  end
end
