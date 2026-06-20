# covers: python_ontology.validation_strategy.turtle_parse_gate python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_after_graph_build python_ontology.validation_strategy.no_validation_by_execution python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Validator do
  @moduledoc """
  Public validation entrypoints for authored ontologies and generated graphs.
  """

  alias PythonOntology.SHACL
  alias PythonOntology.Validator.Turtle

  @doc """
  Validates authored ontology Turtle files.
  """
  def validate_authored_ontologies(opts \\ []) when is_list(opts) do
    opts
    |> Keyword.get(:ontology_dir, Turtle.ontology_dir())
    |> Turtle.validate_directory(Keyword.get(opts, :turtle_options, []))
  end

  @doc """
  Validates generated RDF graph triples after RDF building.
  """
  def validate_graph(data_graph, opts \\ []) when is_list(opts) do
    SHACL.Validator.validate(data_graph, opts)
  end
end
