# covers: python_ontology.project_analysis_scope.include_python_sources python_ontology.project_analysis_scope.include_stub_files python_ontology.project_analysis_scope.exclude_environment_dirs python_ontology.project_analysis_scope.configurable_globs python_ontology.project_analysis_scope.no_dependency_traversal_default python_ontology.project_analysis_scope.deterministic_order
defmodule PythonOntology.Project.SelectionPolicy do
  @moduledoc """
  File selection policy for project discovery.
  """

  @default_include_globs ["**/*.py", "**/*.pyi"]
  @default_excluded_directories [
    ".git",
    ".venv",
    "venv",
    "env",
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
    ".tox",
    ".nox",
    "build",
    "dist",
    "site-packages",
    "node_modules"
  ]

  @enforce_keys [
    :root_path,
    :include_globs,
    :exclude_globs,
    :generated_dirs,
    :include_paths,
    :exclude_paths
  ]
  defstruct [
    :root_path,
    :include_globs,
    :exclude_globs,
    :generated_dirs,
    :include_paths,
    :exclude_paths
  ]

  @type file_decision :: {:select, :include_glob} | {:skip, :exclude_glob | :not_included}
  @type directory_decision ::
          :traverse | {:skip, :default_excluded_directory | :generated_directory}
  @type t :: %__MODULE__{
          root_path: Path.t(),
          include_globs: [String.t()],
          exclude_globs: [String.t()],
          generated_dirs: [String.t()],
          include_paths: MapSet.t(Path.t()),
          exclude_paths: MapSet.t(Path.t())
        }

  @doc """
  Builds a selection policy from discovery options.
  """
  @spec from_options(Path.t(), keyword()) :: t()
  def from_options(root_path, opts) do
    root_path = Path.expand(root_path)
    include_globs = option_globs(opts, :include_globs, @default_include_globs)
    exclude_globs = option_globs(opts, :exclude_globs, [])
    generated_dirs = opts |> Keyword.get(:generated_dirs, []) |> configured_list()

    %__MODULE__{
      root_path: root_path,
      include_globs: include_globs,
      exclude_globs: exclude_globs,
      generated_dirs: Enum.map(generated_dirs, &normalize_relative_path/1),
      include_paths: glob_paths(root_path, include_globs),
      exclude_paths: glob_paths(root_path, exclude_globs)
    }
  end

  @doc """
  Returns whether a directory should be traversed.
  """
  @spec directory_decision(t(), Path.t()) :: directory_decision()
  def directory_decision(%__MODULE__{} = policy, path) do
    cond do
      Path.basename(path) in @default_excluded_directories ->
        {:skip, :default_excluded_directory}

      generated_directory?(policy, path) ->
        {:skip, :generated_directory}

      true ->
        :traverse
    end
  end

  @doc """
  Returns whether a file should be selected.
  """
  @spec file_decision(t(), Path.t()) :: file_decision()
  def file_decision(%__MODULE__{} = policy, path) do
    path = Path.expand(path)

    cond do
      MapSet.member?(policy.exclude_paths, path) ->
        {:skip, :exclude_glob}

      MapSet.member?(policy.include_paths, path) ->
        {:select, :include_glob}

      true ->
        {:skip, :not_included}
    end
  end

  defp option_globs(opts, key, default) do
    case Keyword.fetch(opts, key) do
      {:ok, nil} -> default
      {:ok, value} -> configured_list(value)
      :error -> default
    end
  end

  defp configured_list(value) when is_binary(value), do: [value]
  defp configured_list(value) when is_list(value), do: Enum.filter(value, &is_binary/1)
  defp configured_list(_value), do: []

  defp glob_paths(root_path, globs) do
    globs
    |> Enum.flat_map(fn glob -> Path.wildcard(Path.join(root_path, glob)) end)
    |> Enum.map(&Path.expand/1)
    |> MapSet.new()
  end

  defp generated_directory?(policy, path) do
    relative_path = relative_path(policy, path)
    basename = Path.basename(path)

    Enum.any?(policy.generated_dirs, fn generated_dir ->
      if String.contains?(generated_dir, "/") do
        relative_path == generated_dir
      else
        basename == generated_dir
      end
    end)
  end

  defp relative_path(policy, path) do
    path
    |> Path.relative_to(policy.root_path)
    |> normalize_relative_path()
  end

  defp normalize_relative_path(path), do: String.replace(path, "\\", "/")
end
