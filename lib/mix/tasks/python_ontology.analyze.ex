# covers: python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule Mix.Tasks.PythonOntology.Analyze do
  @moduledoc """
  Analyzes a Python file or project and writes generated graph output.
  """

  use Mix.Task

  alias PythonOntology.Analysis.Result
  alias PythonOntology.Output.Turtle
  alias PythonOntology.Project

  @shortdoc "Analyze a Python file or project"

  @switches [
    output: :string,
    base_iri: :string,
    include: :keep,
    include_glob: :keep,
    exclude: :keep,
    exclude_glob: :keep,
    generated_dir: :keep,
    validate: :boolean,
    shapes_path: :string
  ]
  @aliases [o: :output]

  @impl Mix.Task
  def run(args) do
    case parse_args(args) do
      {:ok, path, switches} ->
        path
        |> analyze(switches)
        |> write_output(switches)
        |> enforce_validation()

      {:error, message} ->
        Mix.raise(message)
    end
  end

  defp parse_args(args) do
    case OptionParser.parse(args, strict: @switches, aliases: @aliases) do
      {switches, [path], []} ->
        {:ok, path, switches}

      {_switches, [], []} ->
        {:error, "mix python_ontology.analyze requires a file or project path"}

      {_switches, paths, []} ->
        {:error, "mix python_ontology.analyze accepts one path, got #{length(paths)}"}

      {_switches, _paths, invalid} ->
        {:error, "invalid option #{format_invalid_option(List.first(invalid))}"}
    end
  end

  defp analyze(path, switches) do
    with {:ok, input} <- Project.classify_input(path),
         {:ok, %Result{} = result} <- run_analysis(input.mode, path, analysis_options(switches)) do
      result
    else
      {:error, diagnostic} ->
        Mix.raise(format_diagnostic(diagnostic))
    end
  end

  defp run_analysis(:file, path, opts), do: PythonOntology.analyze_file(path, opts)
  defp run_analysis(:project, path, opts), do: PythonOntology.analyze_project(path, opts)

  defp analysis_options(switches) do
    [
      base_iri: switches[:base_iri],
      validate?: Keyword.get(switches, :validate, true),
      include_globs: glob_options(switches, :include, :include_glob),
      exclude_globs: glob_options(switches, :exclude, :exclude_glob),
      generated_dirs: Keyword.get_values(switches, :generated_dir),
      validation_options: validation_options(switches)
    ]
    |> Enum.reject(fn {_key, value} -> value in [nil, []] end)
  end

  defp validation_options(switches) do
    []
    |> maybe_put(:shapes_path, switches[:shapes_path])
  end

  defp glob_options(switches, primary, alias_key) do
    Keyword.get_values(switches, primary) ++ Keyword.get_values(switches, alias_key)
  end

  defp write_output(%Result{} = result, switches) do
    case switches[:output] do
      nil ->
        IO.write(Turtle.to_string(result))

      path ->
        path
        |> Path.expand()
        |> write_file(result)
    end

    result
  end

  defp write_file(path, result) do
    case Turtle.write_file(result, path) do
      :ok ->
        :ok

      {:error, reason} ->
        Mix.raise("could not write output #{path}: #{:file.format_error(reason)}")
    end
  end

  defp enforce_validation(%Result{validation_status: :fail}) do
    Mix.raise("PythonOntology analysis validation failed")
  end

  defp enforce_validation(%Result{} = result), do: result

  defp format_invalid_option({switch, nil}), do: to_string(switch)
  defp format_invalid_option({switch, value}), do: "#{switch}=#{value}"

  defp format_diagnostic(%{message: message, path: nil}), do: message

  defp format_diagnostic(%{message: message, path: path}) when is_binary(path) do
    "#{message}: #{path}"
  end

  defp format_diagnostic(diagnostic), do: inspect(diagnostic)

  defp maybe_put(opts, _key, nil), do: opts
  defp maybe_put(opts, key, value), do: Keyword.put(opts, key, value)
end
