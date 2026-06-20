# covers: python_ontology.project_analysis_scope.package_detection python_ontology.project_analysis_scope.namespace_package_detection python_ontology.project_analysis_scope.test_scope_marking python_ontology.project_analysis_scope.include_stub_files
defmodule PythonOntology.Project.Classifier do
  @moduledoc """
  Classifies selected Python source files for package and scope metadata.
  """

  @source_root_names ["src", "lib"]
  @test_directory_names ["test", "tests"]
  @init_names ["__init__.py", "__init__.pyi"]

  @type classification :: %{
          required(:role) => :source | :test,
          required(:test?) => boolean(),
          required(:stub?) => boolean(),
          required(:package_kind) => :regular | :namespace | nil,
          required(:package_root) => String.t() | nil,
          required(:package_name) => String.t() | nil,
          required(:module_name) => String.t()
        }

  @doc """
  Classifies a selected file relative to its detected project root.
  """
  @spec classify(Path.t(), String.t(), Path.t()) :: classification()
  def classify(path, relative_path, root_path) do
    role = role(relative_path)
    stub? = Path.extname(relative_path) == ".pyi"
    package = package_info(path, relative_path, root_path, role)

    package
    |> Map.merge(%{
      role: role,
      test?: role == :test,
      stub?: stub?,
      module_name: module_name(relative_path, package)
    })
  end

  defp role(relative_path) do
    segments = path_segments(relative_path)
    basename = List.last(segments) || relative_path

    if test_path?(segments, basename), do: :test, else: :source
  end

  defp test_path?([first | _rest], _basename) when first in @test_directory_names, do: true

  defp test_path?(_segments, basename) do
    String.starts_with?(basename, "test_") or
      String.ends_with?(basename, "_test.py") or
      String.ends_with?(basename, "_test.pyi")
  end

  defp package_info(_path, relative_path, root_path, role) do
    cond do
      regular_package_info(relative_path, root_path) ->
        regular_package_info(relative_path, root_path)

      role != :test and namespace_package_info(relative_path) ->
        namespace_package_info(relative_path)

      true ->
        %{package_kind: nil, package_root: nil, package_name: nil}
    end
  end

  defp regular_package_info(relative_path, root_path) do
    relative_path
    |> package_directory()
    |> ancestor_dirs()
    |> Enum.find(&regular_package_dir?(root_path, &1))
    |> case do
      nil -> nil
      package_dir -> regular_package_identity(package_dir, root_path)
    end
  end

  defp package_directory(relative_path) do
    if Path.basename(relative_path) in @init_names do
      relative_path |> Path.dirname() |> normalize_directory()
    else
      relative_path |> Path.dirname() |> normalize_directory()
    end
  end

  defp regular_package_identity(package_dir, root_path) do
    segments = path_segments(package_dir)
    start_index = regular_package_start_index(segments, root_path)

    package_root =
      segments
      |> Enum.take(start_index)
      |> Enum.join("/")

    package_name =
      segments
      |> Enum.drop(start_index)
      |> Enum.join(".")

    %{package_kind: :regular, package_root: package_root, package_name: package_name}
  end

  defp regular_package_start_index(segments, root_path) do
    last_index = length(segments) - 1

    Enum.find(0..last_index, last_index, fn start_index ->
      start_index..last_index
      |> Enum.all?(fn index ->
        segments
        |> Enum.take(index + 1)
        |> Enum.join("/")
        |> then(&regular_package_dir?(root_path, &1))
      end)
    end)
  end

  defp regular_package_dir?(root_path, relative_dir) do
    Enum.any?(@init_names, fn init_name ->
      root_path
      |> Path.join(relative_dir)
      |> Path.join(init_name)
      |> File.regular?()
    end)
  end

  defp namespace_package_info(relative_path) do
    directory_segments =
      relative_path
      |> Path.dirname()
      |> normalize_directory()
      |> path_segments()

    case namespace_identity(directory_segments) do
      nil ->
        nil

      {package_root, package_segments} ->
        %{
          package_kind: :namespace,
          package_root: package_root,
          package_name: Enum.join(package_segments, ".")
        }
    end
  end

  defp namespace_identity([]), do: nil

  defp namespace_identity([source_root | package_segments])
       when source_root in @source_root_names and package_segments != [] do
    {source_root, package_segments}
  end

  defp namespace_identity(package_segments), do: {"", package_segments}

  defp module_name(relative_path, package) do
    module_parts = module_path_parts(relative_path, package.package_root)

    case package.package_name do
      nil ->
        Enum.join(module_parts, ".")

      package_name ->
        package_tail_parts = path_segments(String.replace(package_name, ".", "/"))

        module_parts
        |> Enum.drop(length(package_tail_parts))
        |> then(fn
          [] -> package_name
          tail -> Enum.join([package_name | tail], ".")
        end)
    end
  end

  defp module_path_parts(relative_path, nil), do: module_path_parts(relative_path, "")

  defp module_path_parts(relative_path, package_root) do
    relative_path
    |> strip_package_root(package_root)
    |> strip_python_extension()
    |> path_segments()
    |> drop_init_name()
  end

  defp strip_package_root(relative_path, ""), do: relative_path

  defp strip_package_root(relative_path, package_root) do
    String.replace_prefix(relative_path, package_root <> "/", "")
  end

  defp strip_python_extension(path) do
    path
    |> String.replace_suffix(".pyi", "")
    |> String.replace_suffix(".py", "")
  end

  defp drop_init_name(parts) do
    case Enum.reverse(parts) do
      ["__init__" | rest] -> Enum.reverse(rest)
      _other -> parts
    end
  end

  defp ancestor_dirs(""), do: []

  defp ancestor_dirs(relative_dir) do
    relative_dir
    |> path_segments()
    |> then(fn
      [] ->
        []

      segments ->
        for length <- length(segments)..1//-1 do
          segments
          |> Enum.take(length)
          |> Enum.join("/")
        end
    end)
  end

  defp normalize_directory("."), do: ""
  defp normalize_directory(directory), do: String.replace(directory, "\\", "/")

  defp path_segments(""), do: []
  defp path_segments(path), do: path |> String.replace("\\", "/") |> String.split("/", trim: true)
end
