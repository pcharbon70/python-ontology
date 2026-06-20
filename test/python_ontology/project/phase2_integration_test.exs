# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.configurable_globs python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.Phase2IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @tmp_root Path.join(System.tmp_dir!(), "python_ontology_project_phase2_integration_test")

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "applies default exclusions while preserving package, namespace, test, and stub metadata" do
    repo = Path.join(@tmp_root, "default")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"default\"\n")
    write_project_file(repo, "src/pkg/__init__.py", "")
    write_project_file(repo, "src/pkg/app.py", "x = 1\n")
    write_project_file(repo, "src/pkg/api.pyi", "name: str\n")
    write_project_file(repo, "src/acme/plugins/plugin.py", "x = 1\n")
    write_project_file(repo, "tests/test_app.py", "def test_app(): pass\n")
    write_project_file(repo, ".venv/lib/site-packages/dep.py", "x = 1\n")
    write_project_file(repo, "build/generated.py", "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(repo)

    assert Enum.map(result.files, & &1.relative_path) == [
             "src/acme/plugins/plugin.py",
             "src/pkg/__init__.py",
             "src/pkg/api.pyi",
             "src/pkg/app.py",
             "tests/test_app.py"
           ]

    app = file!(result, "src/pkg/app.py")
    api = file!(result, "src/pkg/api.pyi")
    plugin = file!(result, "src/acme/plugins/plugin.py")
    test_file = file!(result, "tests/test_app.py")

    assert app.package_kind == :regular
    assert app.package_name == "pkg"
    assert app.module_name == "pkg.app"
    assert api.stub?
    assert plugin.package_kind == :namespace
    assert plugin.package_name == "acme.plugins"
    assert test_file.role == :test
    assert result.metadata.selected_count == 5
    assert result.metadata.skipped_reasons.default_excluded_directory == 2
  end

  test "applies configured include, exclude, and generated directory rules before classification" do
    repo = Path.join(@tmp_root, "configured")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"configured\"\n")
    write_project_file(repo, "src/pkg/__init__.py", "")
    write_project_file(repo, "src/pkg/app.py", "x = 1\n")
    write_project_file(repo, "src/pkg/internal/hidden.py", "x = 1\n")
    write_project_file(repo, "src/pkg/generated/auto.py", "x = 1\n")
    write_project_file(repo, "tests/test_app.py", "def test_app(): pass\n")

    assert {:ok, %Result{} = result} =
             Project.discover(repo,
               include_globs: ["src/**/*.py"],
               exclude_globs: ["src/pkg/internal/**"],
               generated_dirs: ["generated"]
             )

    assert Enum.map(result.files, & &1.relative_path) == [
             "src/pkg/__init__.py",
             "src/pkg/app.py"
           ]

    assert file!(result, "src/pkg/app.py").package_kind == :regular
    assert result.metadata.selected_count == 2
    assert result.metadata.skipped_reasons.exclude_glob == 1
    assert result.metadata.skipped_reasons.generated_directory == 1
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
