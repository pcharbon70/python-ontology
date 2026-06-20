# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.elixir_owned_adapter python_ontology.parser.no_python_runtime_dependency python_ontology.parser.no_project_code_execution python_ontology.parser.adapter_boundary python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.parser.error_contract python_ontology.parser.parser_version_reporting python_ontology.parser.no_direct_rdf_output python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Parser.TreeSitter do
  @moduledoc """
  Project-local Tree-sitter adapter for Python source parsing.
  """

  alias PythonOntology.Parser.Native

  @doc """
  Returns static metadata for the compiled parser adapter.
  """
  def parser_info do
    Native.parser_info()
  end

  @doc """
  Parses Python source text into normalized Elixir data.
  """
  def parse_string(source) when is_binary(source) do
    Native.parse_string(source)
  end
end
