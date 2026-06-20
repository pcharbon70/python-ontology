# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Parser.Native do
  @moduledoc false

  use Rustler,
    otp_app: :python_ontology,
    crate: :python_ontology_parser

  def parser_info, do: :erlang.nif_error(:nif_not_loaded)

  def parse_string(_source), do: :erlang.nif_error(:nif_not_loaded)
end
