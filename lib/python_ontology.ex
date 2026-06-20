# covers: package.python_ontology.public_namespace package.python_ontology.public_analysis_api python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology do
  @moduledoc """
  Core namespace for the PythonOntology project.
  """

  @doc """
  Returns the application name used by Mix and OTP.
  """
  def app_name do
    :python_ontology
  end

  @doc """
  Analyzes one Python source file and returns graph, diagnostics, selected options,
  and validation status.
  """
  defdelegate analyze_file(path, opts \\ []), to: PythonOntology.Analysis

  @doc """
  Analyzes a Python project directory and returns a merged graph, diagnostics, selected options,
  and validation status.
  """
  defdelegate analyze_project(path, opts \\ []), to: PythonOntology.Analysis
end
