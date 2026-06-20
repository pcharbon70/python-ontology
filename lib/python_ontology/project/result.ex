# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.project_analysis_scope.root_detection python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project.Result do
  @moduledoc """
  Result of project discovery before parsing selected Python files.
  """

  alias PythonOntology.Project.Diagnostic
  alias PythonOntology.Project.SourceFile

  @type root_marker_type :: :pyproject | :setup_cfg | :setup_py | :git | :explicit
  @type root_marker :: %{
          required(:type) => root_marker_type(),
          optional(:path) => Path.t()
        }

  @enforce_keys [:mode, :input_path, :root_path, :root_marker, :files]
  defstruct [:mode, :input_path, :root_path, :root_marker, :files, diagnostics: [], metadata: %{}]

  @type t :: %__MODULE__{
          mode: :file | :project,
          input_path: Path.t(),
          root_path: Path.t(),
          root_marker: root_marker(),
          files: [SourceFile.t()],
          diagnostics: [Diagnostic.t()],
          metadata: map()
        }
end
