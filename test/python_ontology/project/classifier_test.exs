# covers: python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.include_stub_files python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.ClassifierTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @tmp_root Path.join(System.tmp_dir!(), "python_ontology_project_classifier_test")

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "classifies regular packages, module names, stubs, and tests" do
    repo = Path.join(@tmp_root, "regular")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"regular\"\n")
    write_project_file(repo, "src/pkg/__init__.py", "")
    write_project_file(repo, "src/pkg/core.py", "x = 1\n")
    write_project_file(repo, "src/pkg/api.pyi", "name: str\n")
    write_project_file(repo, "tests/test_core.py", "def test_core(): pass\n")
    write_project_file(repo, "src/pkg/core_test.py", "def test_core(): pass\n")

    assert {:ok, %Result{} = result} = Project.discover(repo)

    init = file!(result, "src/pkg/__init__.py")
    core = file!(result, "src/pkg/core.py")
    api = file!(result, "src/pkg/api.pyi")
    tests = file!(result, "tests/test_core.py")
    pattern_test = file!(result, "src/pkg/core_test.py")

    assert init.package_kind == :regular
    assert init.package_root == "src"
    assert init.package_name == "pkg"
    assert init.module_name == "pkg"

    assert core.package_kind == :regular
    assert core.package_root == "src"
    assert core.package_name == "pkg"
    assert core.module_name == "pkg.core"
    refute core.stub?
    refute core.test?
    assert core.role == :source

    assert api.package_kind == :regular
    assert api.package_name == "pkg"
    assert api.module_name == "pkg.api"
    assert api.stub?

    assert tests.role == :test
    assert tests.test?
    assert tests.package_kind == nil
    assert tests.module_name == "tests.test_core"

    assert pattern_test.role == :test
    assert pattern_test.test?
    assert pattern_test.package_kind == :regular
    assert pattern_test.module_name == "pkg.core_test"
  end

  test "classifies namespace package candidates without __init__ files" do
    repo = Path.join(@tmp_root, "namespace")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"namespace\"\n")
    write_project_file(repo, "src/acme/plugins/plugin.py", "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(repo)

    plugin = file!(result, "src/acme/plugins/plugin.py")

    assert plugin.package_kind == :namespace
    assert plugin.package_root == "src"
    assert plugin.package_name == "acme.plugins"
    assert plugin.module_name == "acme.plugins.plugin"
    assert plugin.role == :source
  end

  defp write_project_file(repo, relative_path, contents) do
    path = Path.join(repo, relative_path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end

  defp file!(result, relative_path) do
    Enum.find(result.files, &(&1.relative_path == relative_path)) ||
      flunk("missing discovered file #{relative_path}")
  end
end
