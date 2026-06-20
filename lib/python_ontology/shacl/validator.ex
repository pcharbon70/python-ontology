# covers: python_ontology.validation_strategy.shacl_closed_world python_ontology.validation_strategy.validation_reports python_ontology.validation_strategy.no_validation_by_execution python_ontology.validation_strategy.validation_after_graph_build python_ontology.initial_analysis_slice.first_cli_output python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.SHACL.Validator do
  @moduledoc """
  Generated graph validation entrypoint.
  """

  alias PythonOntology.SHACL.Result
  alias PythonOntology.Validator.Diagnostic
  alias PythonOntology.Validator.Turtle
  alias PythonOntology.Validator.Violation

  @type triple :: Result.triple()

  @rdf_type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  @pycore "https://w3id.org/python-code/core#"
  @pystruct "https://w3id.org/python-code/structure#"

  @module_class @pystruct <> "Module"
  @function_class @pystruct <> "Function"
  @method_class @pystruct <> "Method"
  @parameter_class @pystruct <> "Parameter"
  @source_location_class @pycore <> "SourceLocation"

  @module_name @pystruct <> "moduleName"
  @qualified_name @pystruct <> "qualifiedName"
  @has_parameter @pystruct <> "hasParameter"
  @name @pystruct <> "name"
  @has_location @pycore <> "hasLocation"
  @line @pycore <> "line"
  @column @pycore <> "column"

  @doc """
  Validates a generated RDF graph against the authored PythonOntology shapes graph.

  Implements the first-slice closed-world checks declared in
  `priv/ontologies/python-shapes.ttl`.
  """
  @spec validate(term(), keyword()) :: {:ok, Result.t()} | {:error, [Diagnostic.t()]}
  def validate(data_graph, opts \\ []) when is_list(opts) do
    with {:ok, triples} <- normalize_graph(data_graph),
         {:ok, shapes} <- load_shapes(opts) do
      violations = validate_first_slice(triples)

      {:ok,
       %Result{
         conforms?: violations == [],
         data_graph: triples,
         shapes_graph: shapes.graph,
         violations: violations,
         metadata: %{
           data_triple_count: length(triples),
           shapes_path: shapes.path,
           shapes_triple_count: shapes.metadata.triple_count
         }
       }}
    end
  end

  @doc """
  Returns the default shapes graph path.
  """
  @spec default_shapes_path() :: Path.t()
  def default_shapes_path do
    Path.join(Turtle.ontology_dir(), "python-shapes.ttl")
  end

  defp normalize_graph(%{triples: triples}) when is_list(triples), do: normalize_graph(triples)

  defp normalize_graph(triples) when is_list(triples) do
    if Enum.all?(triples, &triple?/1) do
      {:ok, triples}
    else
      {:error, [diagnostic("data graph triples must be {subject, predicate, object} strings")]}
    end
  end

  defp normalize_graph(_data_graph) do
    {:error, [diagnostic("data graph must be a triple list or a struct with triples")]}
  end

  defp triple?({subject, predicate, object})
       when is_binary(subject) and is_binary(predicate) and is_binary(object),
       do: true

  defp triple?(_triple), do: false

  defp load_shapes(opts) do
    opts
    |> Keyword.get(:shapes_path, default_shapes_path())
    |> Turtle.validate_file(Keyword.get(opts, :turtle_options, []))
    |> case do
      {:ok, shapes} -> {:ok, shapes}
      {:error, %Diagnostic{} = diagnostic} -> {:error, [diagnostic]}
    end
  end

  defp diagnostic(message) do
    %Diagnostic{
      stage: :shacl_validation,
      severity: :error,
      message: message
    }
  end

  defp validate_first_slice(triples) do
    index = index(triples)

    module_violations(index) ++
      function_violations(index) ++
      source_location_violations(index)
  end

  defp module_violations(index) do
    index
    |> subjects_of(@module_class)
    |> Enum.flat_map(fn module ->
      required_literal(index, module, "ModuleShape", @module_name, "module requires moduleName") ++
        required_class(
          index,
          module,
          "ModuleShape",
          @has_location,
          @source_location_class,
          "module requires source location"
        )
    end)
  end

  defp function_violations(index) do
    function_subjects =
      index
      |> subjects_of(@function_class)
      |> MapSet.union(subjects_of(index, @method_class))

    Enum.flat_map(function_subjects, fn function ->
      required_literal(
        index,
        function,
        "FunctionShape",
        @qualified_name,
        "function requires qualifiedName"
      ) ++
        class_objects(
          index,
          function,
          "FunctionShape",
          @has_parameter,
          @parameter_class,
          "function parameters must be Parameter resources"
        ) ++
        parameter_violations(index, function)
    end)
  end

  defp parameter_violations(index, function) do
    index
    |> objects(function, @has_parameter)
    |> Enum.flat_map(fn parameter ->
      required_literal(index, parameter, "ParameterShape", @name, "parameter requires name")
    end)
  end

  defp source_location_violations(index) do
    index
    |> subjects_of(@source_location_class)
    |> Enum.flat_map(fn location ->
      required_integer(
        index,
        location,
        "SourceLocationShape",
        @line,
        "source location requires integer line"
      ) ++
        required_integer(
          index,
          location,
          "SourceLocationShape",
          @column,
          "source location requires integer column"
        )
    end)
  end

  defp required_literal(index, subject, shape, path, message) do
    values = objects(index, subject, path)

    cond do
      values == [] ->
        [violation(subject, shape, path, message)]

      Enum.any?(values, &blank?/1) ->
        [violation(subject, shape, path, message)]

      true ->
        []
    end
  end

  defp required_integer(index, subject, shape, path, message) do
    values = objects(index, subject, path)

    cond do
      values == [] ->
        [violation(subject, shape, path, message)]

      Enum.any?(values, &(not integer_literal?(&1))) ->
        [violation(subject, shape, path, message)]

      true ->
        []
    end
  end

  defp required_class(index, subject, shape, path, class_iri, message) do
    values = objects(index, subject, path)

    cond do
      values == [] ->
        [violation(subject, shape, path, message)]

      true ->
        class_objects(index, subject, shape, path, class_iri, message)
    end
  end

  defp class_objects(index, subject, shape, path, class_iri, message) do
    index
    |> objects(subject, path)
    |> Enum.reject(&typed_as?(index, &1, class_iri))
    |> Enum.map(fn object -> violation(object, shape, path, message, source: subject) end)
  end

  defp index(triples) do
    Enum.reduce(triples, %{by_subject: %{}, types: %{}}, fn {subject, predicate, object}, index ->
      by_subject =
        Map.update(index.by_subject, subject, %{predicate => [object]}, fn predicates ->
          Map.update(predicates, predicate, [object], &[object | &1])
        end)

      %{index | by_subject: by_subject}
      |> put_type(subject, predicate, object)
    end)
  end

  defp put_type(index, subject, @rdf_type, object) do
    update_in(index, [:types, object], fn
      nil -> MapSet.new([subject])
      subjects -> MapSet.put(subjects, subject)
    end)
  end

  defp put_type(index, _subject, _predicate, _object), do: index

  defp subjects_of(index, class_iri), do: Map.get(index.types, class_iri, MapSet.new())

  defp objects(index, subject, predicate) do
    index
    |> get_in([:by_subject, subject, predicate])
    |> List.wrap()
    |> Enum.reverse()
  end

  defp typed_as?(index, subject, class_iri), do: subject in subjects_of(index, class_iri)

  defp blank?(value), do: String.trim(value) == ""

  defp integer_literal?(value) do
    case Integer.parse(value) do
      {_, ""} -> true
      _ -> false
    end
  end

  defp violation(target_node, shape, path, message, opts \\ []) do
    source = Keyword.get(opts, :source)

    %Violation{
      target_node: target_node,
      shape: shape,
      path: path,
      message: message,
      source: source,
      source_context: source_context(source)
    }
  end

  defp source_context(nil), do: %{}
  defp source_context(source), do: %{source_node: source}
end
