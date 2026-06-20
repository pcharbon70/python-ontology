# covers: python_ontology.iri_identity_strategy.namespace_resource_separation python_ontology.iri_identity_strategy.configurable_base_iri python_ontology.iri_identity_strategy.no_runtime_identity_claims python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.IRI do
  @moduledoc """
  Shared IRI helpers for ontology vocabulary and analyzed-code resources.
  """

  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Identity
  alias PythonOntology.IRI.Path

  @ontology_root "https://w3id.org/python-code/"
  @known_layers ~w(core structure typing runtime evolution shapes)

  @doc """
  Returns the default generated-resource base IRI.
  """
  defdelegate default_base_iri(), to: Context

  @doc """
  Builds a generated-resource IRI context.
  """
  defdelegate context(opts \\ []), to: Context, as: :new

  @doc """
  Validates a generated-resource base IRI.
  """
  defdelegate validate_base_iri(base_iri), to: Context

  @doc """
  Converts a source path to a repository-relative POSIX path.
  """
  defdelegate source_path(path, opts \\ []), to: Path, as: :canonicalize

  @doc """
  Builds a package resource IRI.
  """
  defdelegate package(context, opts), to: Identity

  @doc """
  Builds a module resource IRI.
  """
  defdelegate module(context, opts), to: Identity

  @doc """
  Returns the ontology document IRI for a Python ontology layer.
  """
  @spec ontology_iri(atom() | String.t()) :: String.t()
  def ontology_iri(layer), do: @ontology_root <> layer_name(layer)

  @doc """
  Returns a vocabulary term IRI in the ontology namespace.
  """
  @spec vocabulary_iri(atom() | String.t(), atom() | String.t()) :: String.t()
  def vocabulary_iri(layer, term), do: ontology_iri(layer) <> "#" <> to_string(term)

  @doc """
  Returns known ontology vocabulary layers.
  """
  @spec known_layers() :: [String.t()]
  def known_layers, do: @known_layers

  defp layer_name(layer) when is_atom(layer), do: layer |> Atom.to_string() |> layer_name()

  defp layer_name(layer) when is_binary(layer) do
    if layer in @known_layers do
      layer
    else
      raise ArgumentError, "unknown Python ontology layer #{inspect(layer)}"
    end
  end
end
