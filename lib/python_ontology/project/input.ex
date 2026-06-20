# covers: python_ontology.project_analysis_scope.single_file_and_project_modes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Project.Input do
  @moduledoc """
  Caller input classification for project discovery.
  """

  alias PythonOntology.Project.Diagnostic

  @supported_file_extensions [".py", ".pyi"]

  @enforce_keys [:mode, :path]
  defstruct [:mode, :path, :extension]

  @type mode :: :file | :project
  @type t :: %__MODULE__{mode: mode(), path: Path.t(), extension: String.t() | nil}

  @doc """
  Classifies a caller-provided path as a Python source file or project directory.
  """
  @spec classify(Path.t()) :: {:ok, t()} | {:error, Diagnostic.t()}
  def classify(path) when is_binary(path) and path != "" do
    expanded = Path.expand(path)

    case File.stat(expanded) do
      {:ok, %File.Stat{type: :regular}} ->
        classify_file(expanded)

      {:ok, %File.Stat{type: :directory}} ->
        {:ok, %__MODULE__{mode: :project, path: expanded}}

      {:ok, %File.Stat{type: type}} ->
        error(expanded, "unsupported analysis path type #{inspect(type)}", type: type)

      {:error, reason} ->
        error(expanded, "analysis path is not available: #{:file.format_error(reason)}",
          reason: reason
        )
    end
  end

  def classify(path), do: error(path, "analysis path must be a non-empty string")

  defp classify_file(path) do
    extension = Path.extname(path)

    if extension in @supported_file_extensions do
      {:ok, %__MODULE__{mode: :file, path: path, extension: extension}}
    else
      error(path, "unsupported analysis file extension #{inspect(extension)}",
        extension: extension,
        supported_extensions: @supported_file_extensions
      )
    end
  end

  defp error(path, message, details \\ []) do
    {:error,
     %Diagnostic{
       stage: :input,
       severity: :error,
       message: message,
       path: path,
       details: Map.new(details)
     }}
  end
end
