# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.deterministic_order python_ontology.initial_analysis_slice.source_locations
defmodule PythonOntology.Project.SourceFile do
  @moduledoc """
  Python source file selected for project analysis.
  """

  @enforce_keys [:path, :relative_path, :extension, :role, :test?, :stub?, :module_name]
  defstruct [
    :path,
    :relative_path,
    :extension,
    :role,
    :test?,
    :stub?,
    :package_kind,
    :package_root,
    :package_name,
    :module_name
  ]

  @type t :: %__MODULE__{
          path: Path.t(),
          relative_path: String.t(),
          extension: String.t(),
          role: :source | :test,
          test?: boolean(),
          stub?: boolean(),
          package_kind: :regular | :namespace | nil,
          package_root: String.t() | nil,
          package_name: String.t() | nil,
          module_name: String.t()
        }
end
