# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Confidence.Category do
  @moduledoc """
  Confidence categories for generated Python facts.
  """

  @categories [
    :source_declared,
    :statically_inferred,
    :unresolved,
    :runtime_dependent
  ]

  @direct_syntax_default :source_declared

  @type t :: :source_declared | :statically_inferred | :unresolved | :runtime_dependent

  @doc """
  Returns the finite category set.
  """
  @spec all() :: [t()]
  def all, do: @categories

  @doc """
  Returns the default category for facts extracted directly from parsed syntax.
  """
  @spec direct_syntax_default() :: t()
  def direct_syntax_default, do: @direct_syntax_default

  @doc """
  Normalizes and validates a confidence category.
  """
  @spec validate(atom() | String.t()) :: {:ok, t()} | {:error, String.t()}
  def validate(category) when category in @categories, do: {:ok, category}

  def validate(category) when is_binary(category) do
    category
    |> String.to_existing_atom()
    |> validate()
  rescue
    ArgumentError -> {:error, "unknown confidence category #{inspect(category)}"}
  end

  def validate(category), do: {:error, "unknown confidence category #{inspect(category)}"}
end
