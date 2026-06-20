# covers: python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.builders_emit_rdf python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.extractor_builder_boundary.validation_after_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Pipeline.Result do
  @moduledoc """
  Result returned by the composed analysis pipeline.
  """

  alias PythonOntology.Builders
  alias PythonOntology.Facts
  alias PythonOntology.Parser
  alias PythonOntology.Pipeline.Diagnostic
  alias PythonOntology.Syntax

  @type t :: %__MODULE__{
          parser_result: Parser.Result.t() | nil,
          syntax_root: Syntax.ModuleNode.t(),
          facts: [Facts.Fact.t()],
          triples: [Builders.Result.triple()],
          diagnostics: [Diagnostic.t()],
          extraction_result: Facts.Result.t(),
          build_result: Builders.Result.t(),
          metadata: map()
        }

  @enforce_keys [:syntax_root, :facts, :triples, :extraction_result, :build_result]
  defstruct [
    :parser_result,
    :syntax_root,
    :extraction_result,
    :build_result,
    facts: [],
    triples: [],
    diagnostics: [],
    metadata: %{}
  ]
end
