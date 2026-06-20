# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Project.SourceFile do
  @moduledoc """
  Python source file selected for project analysis.
  """

  @enforce_keys [:path, :relative_path, :extension]
  defstruct [:path, :relative_path, :extension]

  @type t :: %__MODULE__{
          path: Path.t(),
          relative_path: String.t(),
          extension: String.t()
        }
end
