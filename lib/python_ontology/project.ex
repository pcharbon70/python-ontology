# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project do
  @moduledoc """
  Project discovery and source selection facade.
  """

  alias PythonOntology.Project.Input

  @doc """
  Classifies a caller-provided path as single-file or project analysis input.
  """
  defdelegate classify_input(path), to: Input, as: :classify
end
