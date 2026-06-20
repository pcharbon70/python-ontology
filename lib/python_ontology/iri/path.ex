# covers: python_ontology.iri_identity_strategy.stable_path_normalization python_ontology.iri_identity_strategy.shared_iri_helper python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.first_cli_output
defmodule PythonOntology.IRI.Path do
  @moduledoc """
  Canonical source path handling for generated resource identity.
  """

  alias PythonOntology.IRI.Context
  alias PythonOntology.IRI.Diagnostic

  @doc """
  Converts a source path to a repository-relative POSIX path.
  """
  @spec canonicalize(Path.t(), keyword() | Context.t()) ::
          {:ok, String.t()} | {:error, Diagnostic.t()}
  def canonicalize(path, opts \\ [])

  def canonicalize(path, %Context{} = context),
    do: canonicalize(path, repository_root: context.repository_root)

  def canonicalize(path, opts) when is_binary(path) and is_list(opts) do
    repository_root = normalize_root(opts[:repository_root])
    posix_path = to_posix(path)

    cond do
      posix_path == "" ->
        path_error(path, "source path is required")

      absolute_path?(posix_path) and is_nil(repository_root) ->
        path_error(path, "absolute source paths require a repository root")

      absolute_path?(posix_path) ->
        canonicalize_absolute_path(posix_path, repository_root, path)

      true ->
        canonicalize_relative_path(posix_path, path)
    end
  end

  def canonicalize(path, _opts), do: path_error(path, "source path must be a string")

  defp canonicalize_absolute_path(posix_path, repository_root, input) do
    expanded_path = posix_path |> Elixir.Path.expand() |> to_posix()

    cond do
      expanded_path == repository_root ->
        path_error(input, "source path must identify a file inside the repository root")

      not under_root?(expanded_path, repository_root) ->
        path_error(input, "source path escapes the repository root",
          repository_root: repository_root,
          expanded_path: expanded_path
        )

      true ->
        expanded_path
        |> String.replace_prefix(repository_root <> "/", "")
        |> canonicalize_relative_path(input)
    end
  end

  defp canonicalize_relative_path(posix_path, input) do
    case normalize_relative_segments(posix_path) do
      {:ok, ""} -> path_error(input, "source path is required")
      {:ok, normalized} -> {:ok, normalized}
      {:error, :escaped_root} -> path_error(input, "source path escapes the repository root")
    end
  end

  defp normalize_relative_segments(path) do
    path
    |> String.split("/")
    |> Enum.reduce_while({:ok, []}, fn
      segment, {:ok, segments} when segment in ["", "."] ->
        {:cont, {:ok, segments}}

      "..", {:ok, []} ->
        {:halt, {:error, :escaped_root}}

      "..", {:ok, [_last | rest]} ->
        {:cont, {:ok, rest}}

      segment, {:ok, segments} ->
        {:cont, {:ok, [segment | segments]}}
    end)
    |> case do
      {:ok, segments} -> {:ok, segments |> Enum.reverse() |> Enum.join("/")}
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_root(nil), do: nil
  defp normalize_root(root), do: root |> to_posix() |> Elixir.Path.expand() |> to_posix()

  defp under_root?(path, root), do: String.starts_with?(path, root <> "/")

  defp absolute_path?(path),
    do: String.starts_with?(path, "/") or String.match?(path, ~r/^[A-Za-z]:\//)

  defp to_posix(path) when is_binary(path), do: String.replace(path, "\\", "/")

  defp path_error(input, message, details \\ []) do
    {:error,
     %Diagnostic{
       stage: :source_path,
       severity: :error,
       message: message,
       input: input,
       details: Map.new(details)
     }}
  end
end
