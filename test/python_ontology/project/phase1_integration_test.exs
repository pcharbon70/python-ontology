# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Project.Phase1IntegrationTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Project
  alias PythonOntology.Project.Result

  @tmp_root Path.join(System.tmp_dir!(), "python_ontology_project_phase1_integration_test")

  setup do
    File.rm_rf!(@tmp_root)
    File.mkdir_p!(@tmp_root)

    on_exit(fn -> File.rm_rf!(@tmp_root) end)
  end

  test "discovers explicit file and explicit directory analysis inputs" do
    file_root = Path.join(@tmp_root, "single_file")
    File.mkdir_p!(file_root)
    file = Path.join(file_root, "module.py")
    File.write!(file, "x = 1\n")

    assert {:ok, %Result{} = file_result} = Project.discover(file)
    assert file_result.mode == :file
    assert file_result.root_path == file_root
    assert Enum.map(file_result.files, & &1.relative_path) == ["module.py"]

    directory_root = Path.join(@tmp_root, "directory")
    File.mkdir_p!(Path.join(directory_root, "pkg"))
    File.write!(Path.join(directory_root, "pkg/__init__.py"), "")
    File.write!(Path.join(directory_root, "pkg/core.pyi"), "NAME: str\n")

    assert {:ok, %Result{} = directory_result} = Project.discover(directory_root)
    assert directory_result.mode == :project
    assert directory_result.root_path == directory_root

    assert Enum.map(directory_result.files, & &1.relative_path) == [
             "pkg/__init__.py",
             "pkg/core.pyi"
           ]
  end

  test "discovers metadata roots, git fallback roots, and deterministic file order" do
    metadata_repo = Path.join(@tmp_root, "metadata")
    File.mkdir_p!(Path.join(metadata_repo, "src/pkg/nested"))
    File.write!(Path.join(metadata_repo, "pyproject.toml"), "[project]\nname = \"metadata\"\n")
    File.write!(Path.join(metadata_repo, "src/pkg/z.py"), "z = 1\n")
    File.write!(Path.join(metadata_repo, "src/pkg/a.py"), "a = 1\n")
    File.write!(Path.join(metadata_repo, "src/pkg/nested/b.pyi"), "b: int\n")
    File.write!(Path.join(metadata_repo, "notes.txt"), "ignored\n")

    assert {:ok, %Result{} = metadata_result} =
             Project.discover(Path.join(metadata_repo, "src/pkg"))

    assert metadata_result.root_path == metadata_repo
    assert metadata_result.root_marker.type == :pyproject

    assert Enum.map(metadata_result.files, & &1.relative_path) == [
             "src/pkg/a.py",
             "src/pkg/nested/b.pyi",
             "src/pkg/z.py"
           ]

    git_repo = Path.join(@tmp_root, "git")
    File.mkdir_p!(Path.join(git_repo, ".git"))
    File.mkdir_p!(Path.join(git_repo, "lib"))
    File.write!(Path.join(git_repo, "lib/module.py"), "x = 1\n")

    assert {:ok, %Result{} = git_result} = Project.discover(Path.join(git_repo, "lib"))
    assert git_result.root_path == git_repo
    assert git_result.root_marker.type == :git
    assert Enum.map(git_result.files, & &1.relative_path) == ["lib/module.py"]
  end
end
