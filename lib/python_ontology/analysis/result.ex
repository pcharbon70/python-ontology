# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Analysis.Result do
  @moduledoc """
  Project-level result returned by public analysis entrypoints.
  """

  alias PythonOntology.Builders
  alias PythonOntology.Pipeline
  alias PythonOntology.Project
  alias PythonOntology.SHACL
  alias PythonOntology.Validator

  @type validation_status :: :pass | :fail | :not_run

  @type t :: %__MODULE__{
          mode: :file | :project,
          input_path: Path.t(),
          project: Project.Result.t(),
          files: [Project.SourceFile.t()],
          pipeline_results: [Pipeline.Result.t()],
          triples: [Builders.Result.triple()],
          diagnostics: [term()],
          options: map(),
          validation_status: validation_status(),
          validation_result: SHACL.Result.t() | nil,
          validation_report: Validator.Report.t() | nil,
          metadata: map()
        }

  @enforce_keys [:mode, :input_path, :project]
  defstruct [
    :mode,
    :input_path,
    :project,
    :validation_result,
    :validation_report,
    files: [],
    pipeline_results: [],
    triples: [],
    diagnostics: [],
    options: %{},
    validation_status: :not_run,
    metadata: %{}
  ]
end
