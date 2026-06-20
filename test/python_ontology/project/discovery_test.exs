# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.DiscoveryTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @tmp_root Path.join(System.tmp_dir!(), "python_ontology_project_discovery_test")

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "detects pyproject root from a nested source file" do
    repo = Path.join(@tmp_root, "pyproject_repo")
    File.mkdir_p!(Path.join(repo, "src/pkg"))
    File.write!(Path.join(repo, "pyproject.toml"), "[project]\nname = \"sample\"\n")
    source = Path.join(repo, "src/pkg/module.py")
    File.write!(source, "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(source)

    assert result.mode == :file
    assert result.root_path == repo
    assert result.root_marker == %{type: :pyproject, path: Path.join(repo, "pyproject.toml")}
    assert Enum.map(result.files, & &1.relative_path) == ["src/pkg/module.py"]
  end

  test "detects setup and git roots from nested project directories" do
    assert_marker_root("setup_cfg_repo", "setup.cfg", :setup_cfg)
    assert_marker_root("setup_py_repo", "setup.py", :setup_py)

    repo = Path.join(@tmp_root, "git_repo")
    nested = Path.join(repo, "pkg")
    File.mkdir_p!(nested)
    File.mkdir_p!(Path.join(repo, ".git"))
    File.write!(Path.join(nested, "module.py"), "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(nested)
    assert result.root_path == repo
    assert result.root_marker == %{type: :git, path: Path.join(repo, ".git")}
  end

  test "falls back to an explicit directory root when metadata is absent" do
    repo = Path.join(@tmp_root, "plain")
    File.mkdir_p!(Path.join(repo, "pkg"))
    File.write!(Path.join(repo, "pkg/module.py"), "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(repo)

    assert result.mode == :project
    assert result.root_path == repo
    assert result.root_marker == %{type: :explicit}
    assert Enum.map(result.files, & &1.relative_path) == ["pkg/module.py"]
  end

  test "walks Python files and stubs in deterministic relative POSIX order" do
    repo = Path.join(@tmp_root, "ordered")
    File.mkdir_p!(Path.join(repo, "pkg/nested"))
    File.write!(Path.join(repo, "pyproject.toml"), "[project]\nname = \"ordered\"\n")
    File.write!(Path.join(repo, "z.py"), "z = 1\n")
    File.write!(Path.join(repo, "README.md"), "# ignored\n")
    File.write!(Path.join(repo, "pkg/nested/b.pyi"), "b: int\n")
    File.write!(Path.join(repo, "pkg/a.py"), "a = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(Path.join(repo, "pkg"))

    assert Enum.map(result.files, & &1.relative_path) == [
             "pkg/a.py",
             "pkg/nested/b.pyi",
             "z.py"
           ]

    assert Enum.map(result.files, & &1.extension) == [".py", ".pyi", ".py"]
    assert result.metadata.file_count == 3
  end

  defp assert_marker_root(repo_name, marker_name, marker_type) do
    repo = Path.join(@tmp_root, repo_name)
    nested = Path.join(repo, "pkg")
    File.mkdir_p!(nested)
    File.write!(Path.join(repo, marker_name), "")
    File.write!(Path.join(nested, "module.py"), "x = 1\n")

    assert {:ok, %Result{} = result} = Project.discover(nested)
    assert result.root_path == repo
    assert result.root_marker == %{type: marker_type, path: Path.join(repo, marker_name)}
  end
end
