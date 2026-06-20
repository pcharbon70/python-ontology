# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.configurable_globs python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.SelectionPolicyTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @tmp_root Path.join(System.tmp_dir!(), "python_ontology_project_selection_policy_test")

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "excludes dependency, cache, build, distribution, generated, and VCS directories by default" do
    repo = Path.join(@tmp_root, "defaults")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"defaults\"\n")
    write_project_file(repo, "src/pkg/app.py", "x = 1\n")
    write_project_file(repo, ".venv/lib/site-packages/dep.py", "x = 1\n")
    write_project_file(repo, "venv/lib/python/site.py", "x = 1\n")
    write_project_file(repo, "env/lib/python/site.py", "x = 1\n")
    write_project_file(repo, "src/pkg/__pycache__/app.py", "x = 1\n")
    write_project_file(repo, ".mypy_cache/module.py", "x = 1\n")
    write_project_file(repo, ".pytest_cache/module.py", "x = 1\n")
    write_project_file(repo, ".tox/py/module.py", "x = 1\n")
    write_project_file(repo, ".nox/session/module.py", "x = 1\n")
    write_project_file(repo, "build/generated.py", "x = 1\n")
    write_project_file(repo, "dist/generated.py", "x = 1\n")
    write_project_file(repo, "vendor/site-packages/dep.py", "x = 1\n")
    write_project_file(repo, "node_modules/tool.py", "x = 1\n")
    File.mkdir_p!(Path.join(repo, ".git"))
    File.write!(Path.join(repo, ".git/hook.py"), "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(repo)

    assert Enum.map(result.files, & &1.relative_path) == ["src/pkg/app.py"]
    assert result.metadata.selected_count == 1
    assert result.metadata.file_count == 1
    assert result.metadata.skipped_directory_count == 13
    assert result.metadata.skipped_reasons.default_excluded_directory == 13
  end

  test "applies include globs, generated directories, and exclude precedence" do
    repo = Path.join(@tmp_root, "configured")
    write_project_file(repo, "pyproject.toml", "[project]\nname = \"configured\"\n")
    write_project_file(repo, "src/pkg/app.py", "x = 1\n")
    write_project_file(repo, "src/pkg/api.pyi", "name: str\n")
    write_project_file(repo, "src/pkg/generated/auto.py", "x = 1\n")
    write_project_file(repo, "tests/test_app.py", "def test_app(): pass\n")
    write_project_file(repo, "tools/script.py", "x = 1\n")

    assert {:ok, %Result{} = result} =
             Project.discover(repo,
               include_globs: ["src/**/*.py", "src/**/*.pyi", "tests/**/*.py"],
               exclude_globs: ["tests/**"],
               generated_dirs: ["src/pkg/generated"]
             )

    assert Enum.map(result.files, & &1.relative_path) == ["src/pkg/api.pyi", "src/pkg/app.py"]
    assert result.metadata.selected_count == 2
    assert result.metadata.skipped_directory_count == 1
    assert result.metadata.skipped_reasons.generated_directory == 1
    assert result.metadata.skipped_reasons.exclude_glob == 1
    assert result.metadata.skipped_reasons.not_included >= 2
  end

  defp write_project_file(repo, relative_path, contents) do
    path = Path.join(repo, relative_path)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end
end
