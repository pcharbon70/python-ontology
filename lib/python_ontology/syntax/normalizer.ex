# covers: python_ontology.normalized_syntax_model.tree_sitter_not_internal_model python_ontology.normalized_syntax_model.elixir_struct_boundary python_ontology.normalized_syntax_model.raw_cst_provenance python_ontology.normalized_syntax_model.typed_core_nodes python_ontology.normalized_syntax_model.unknown_node_preservation python_ontology.normalized_syntax_model.deterministic_normalization python_ontology.normalized_syntax_model.no_code_execution python_ontology.normalized_syntax_model.no_rdf_generation python_ontology.normalized_syntax_model.source_span_preservation python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Syntax.Normalizer do
  @moduledoc false

  alias PythonOntology.Parser
  alias PythonOntology.Syntax
  alias PythonOntology.Syntax.NodeId
  alias PythonOntology.Syntax.NodeInfo
  alias PythonOntology.Syntax.Provenance
  alias PythonOntology.Syntax.Source
  alias PythonOntology.Syntax.Span

  @literal_types ~w(string integer float true false none list tuple dictionary set)

  @type context :: %{
          source: Source.t(),
          source_text: String.t() | nil,
          parent_path: list(),
          child_index: non_neg_integer() | nil,
          decorators: list(),
          method_scope?: boolean()
        }

  @doc false
  def normalize(%Parser.Result{} = result, opts) do
    source = Source.from_parser_result(result)
    source_text = Keyword.get(opts, :source) || source_from_path(result.path)

    context = %{
      source: source,
      source_text: source_text,
      parent_path: [],
      child_index: nil,
      decorators: [],
      method_scope?: false
    }

    {:ok, map_node(result.root, context) |> attach_root_diagnostics(result.diagnostics)}
  end

  defp map_node(%Parser.Node{kind: "module"} = node, context) do
    children = map_children(node, context)

    %Syntax.ModuleNode{
      info: info(node, context),
      body: children
    }
  end

  defp map_node(%Parser.Node{kind: "import_statement"} = node, context) do
    aliases =
      node
      |> named_children()
      |> Enum.map(&alias_node(&1, child_context(node, context, child_index(node, &1))))

    %Syntax.Import{
      info: info(node, context),
      names: aliases,
      children: aliases
    }
  end

  defp map_node(%Parser.Node{kind: "import_from_statement"} = node, context) do
    module_name = node |> child_by_field("module_name") |> raw_text(context)

    aliases =
      node
      |> named_children()
      |> Enum.filter(&(&1.field_name == "name"))
      |> Enum.map(&alias_node(&1, child_context(node, context, child_index(node, &1))))

    %Syntax.Import{
      info: info(node, context),
      module: module_name,
      names: aliases,
      relative_level: relative_level(node, context),
      children: aliases
    }
  end

  defp map_node(%Parser.Node{kind: "decorated_definition"} = node, context) do
    decorators =
      node
      |> named_children("decorator")
      |> Enum.map(&decorator_node(&1, child_context(node, context, child_index(node, &1))))

    definition =
      node.children
      |> Enum.find(&(&1.kind in ["class_definition", "function_definition"]))

    if definition do
      map_node(definition, %{
        child_context(node, context, child_index(node, definition))
        | decorators: decorators
      })
    else
      generic_node(node, context)
    end
  end

  defp map_node(%Parser.Node{kind: "class_definition"} = node, context) do
    body_node = child_by_field(node, "body")

    body_context =
      if body_node, do: child_context(node, context, child_index(node, body_node)), else: context

    body =
      if body_node,
        do: map_block_children(body_node, %{body_context | method_scope?: true}),
        else: []

    %Syntax.Class{
      info: info(node, context),
      name: node |> child_by_field("name") |> raw_text(context),
      bases: base_class_nodes(node, context),
      decorators: context.decorators,
      body: body,
      children: context.decorators ++ body
    }
  end

  defp map_node(%Parser.Node{kind: "function_definition"} = node, context) do
    parameters_node = child_by_field(node, "parameters")
    body_node = child_by_field(node, "body")

    parameters =
      if parameters_node do
        parameter_nodes(
          parameters_node,
          child_context(node, context, child_index(node, parameters_node))
        )
      else
        []
      end

    body =
      if body_node do
        map_block_children(body_node, child_context(node, context, child_index(node, body_node)))
      else
        []
      end

    %Syntax.Function{
      info: info(node, context),
      name: node |> child_by_field("name") |> raw_text(context),
      async?: has_child_kind?(node, "async"),
      method_candidate?: context.method_scope?,
      parameters: parameters,
      decorators: context.decorators,
      return_annotation: annotation_node(child_by_field(node, "return_type"), context),
      body: body,
      children: context.decorators ++ parameters ++ body
    }
  end

  defp map_node(%Parser.Node{kind: "expression_statement"} = node, context) do
    case named_children(node) do
      [child] ->
        map_node(child, child_context(node, context, child_index(node, child)))

      _children ->
        generic_node(node, context)
    end
  end

  defp map_node(%Parser.Node{kind: "assignment"} = node, context) do
    targets = map_field_children(node, context, "left")
    value = map_optional_child(node, child_by_field(node, "right"), context)
    annotation = annotation_node(child_by_field(node, "type"), context)

    %Syntax.Assignment{
      info: info(node, context),
      targets: targets,
      value: value,
      annotation: annotation,
      children: targets ++ Enum.reject([annotation, value], &is_nil/1)
    }
  end

  defp map_node(%Parser.Node{kind: kind} = node, context)
       when kind in ["identifier", "dotted_name"] do
    %Syntax.Identifier{
      info: info(node, context),
      name: raw_text(node, context)
    }
  end

  defp map_node(%Parser.Node{kind: "call"} = node, context) do
    function_node = child_by_field(node, "function")
    arguments_node = child_by_field(node, "arguments")

    function = map_optional_child(node, function_node, context)

    arguments =
      if arguments_node, do: map_argument_children(node, arguments_node, context), else: []

    %Syntax.Call{
      info: info(node, context),
      function: function,
      arguments: arguments,
      children: Enum.reject([function], &is_nil/1) ++ arguments
    }
  end

  defp map_node(%Parser.Node{kind: "attribute"} = node, context) do
    object_node = child_by_field(node, "object")
    attribute_node = child_by_field(node, "attribute")

    object = map_optional_child(node, object_node, context)
    attribute = map_optional_child(node, attribute_node, context)

    %Syntax.Attribute{
      info: info(node, context),
      object: object,
      attribute: attribute,
      children: Enum.reject([object, attribute], &is_nil/1)
    }
  end

  defp map_node(%Parser.Node{kind: "subscript"} = node, context) do
    object_node = child_by_field(node, "value")
    index_node = child_by_field(node, "subscript")

    object = map_optional_child(node, object_node, context)
    index = map_optional_child(node, index_node, context)

    %Syntax.Subscript{
      info: info(node, context),
      object: object,
      index: index,
      children: Enum.reject([object, index], &is_nil/1)
    }
  end

  defp map_node(%Parser.Node{kind: kind} = node, context) when kind in @literal_types do
    raw_text = raw_text(node, context)
    literal_kind = literal_kind(kind)

    %Syntax.Literal{
      info: info(node, context),
      kind: literal_kind,
      value: literal_value(literal_kind, raw_text),
      raw_text: raw_text,
      children: map_named_children(node, context)
    }
  end

  defp map_node(node, context), do: generic_node(node, context)

  defp map_children(node, context) do
    node.children
    |> Enum.with_index()
    |> Enum.reject(fn {child, _index} -> child.extra end)
    |> Enum.map(fn {child, index} -> map_node(child, child_context(node, context, index)) end)
  end

  defp map_block_children(node, context) do
    node.children
    |> Enum.with_index()
    |> Enum.reject(fn {child, _index} -> child.extra end)
    |> Enum.map(fn {child, index} -> map_node(child, child_context(node, context, index)) end)
  end

  defp map_named_children(node, context) do
    node.children
    |> Enum.with_index()
    |> Enum.filter(fn {child, _index} -> child.named end)
    |> Enum.map(fn {child, index} -> map_node(child, child_context(node, context, index)) end)
  end

  defp alias_node(%Parser.Node{kind: "aliased_import"} = node, context) do
    %Syntax.Alias{
      info: info(node, context),
      name: node |> child_by_field("name") |> raw_text(context),
      as: node |> child_by_field("alias") |> raw_text(context)
    }
  end

  defp alias_node(node, context) do
    %Syntax.Alias{
      info: info(node, context),
      name: raw_text(node, context)
    }
  end

  defp decorator_node(node, context) do
    expression =
      node
      |> named_children()
      |> List.first()

    %Syntax.Decorator{
      info: info(node, context),
      expression:
        if(expression,
          do: map_node(expression, child_context(node, context, child_index(node, expression)))
        ),
      raw_text: raw_text(node, context)
    }
  end

  defp base_class_nodes(%Parser.Node{kind: "class_definition"} = node, context) do
    node.children
    |> Enum.find(&(&1.kind == "argument_list"))
    |> case do
      nil ->
        []

      argument_list ->
        argument_list
        |> named_children()
        |> Enum.map(fn child ->
          child_context =
            child_context(
              argument_list,
              child_context(node, context, child_index(node, argument_list)),
              child_index(argument_list, child)
            )

          %Syntax.BaseClass{
            info: info(child, child_context),
            expression: map_node(child, child_context),
            raw_text: raw_text(child, child_context)
          }
        end)
    end
  end

  defp parameter_nodes(node, context) do
    node
    |> named_children()
    |> Enum.map(fn child ->
      parameter_node(child, child_context(node, context, child_index(node, child)))
    end)
  end

  defp parameter_node(%Parser.Node{kind: "typed_parameter"} = node, context) do
    %Syntax.Parameter{
      info: info(node, context),
      name: node |> parameter_name_node() |> raw_text(context),
      kind: :positional,
      annotation: annotation_node(child_by_field(node, "type"), context)
    }
  end

  defp parameter_node(%Parser.Node{kind: "typed_default_parameter"} = node, context) do
    %Syntax.Parameter{
      info: info(node, context),
      name: node |> child_by_field("name") |> raw_text(context),
      kind: :positional,
      annotation: annotation_node(child_by_field(node, "type"), context),
      default: child_by_field(node, "value") && map_node(child_by_field(node, "value"), context)
    }
  end

  defp parameter_node(%Parser.Node{kind: "default_parameter"} = node, context) do
    %Syntax.Parameter{
      info: info(node, context),
      name: node |> parameter_name_node() |> raw_text(context),
      kind: :positional,
      default: child_by_field(node, "value") && map_node(child_by_field(node, "value"), context)
    }
  end

  defp parameter_node(%Parser.Node{kind: kind} = node, context)
       when kind in ["list_splat", "list_splat_pattern"] do
    value = first_named_child(node)
    %Syntax.Parameter{info: info(node, context), name: raw_text(value, context), kind: :vararg}
  end

  defp parameter_node(%Parser.Node{kind: kind} = node, context)
       when kind in ["dictionary_splat", "dictionary_splat_pattern"] do
    value = first_named_child(node)
    %Syntax.Parameter{info: info(node, context), name: raw_text(value, context), kind: :kwarg}
  end

  defp parameter_node(node, context) do
    %Syntax.Parameter{info: info(node, context), name: raw_text(node, context), kind: :positional}
  end

  defp annotation_node(nil, _context), do: nil

  defp annotation_node(node, context) do
    %Syntax.Annotation{
      info: info(node, context),
      expression: generic_node(node, context),
      raw_text: raw_text(node, context)
    }
  end

  defp generic_node(node, context) do
    %Syntax.Generic{
      info: info(node, context),
      raw_type: node.kind,
      children: map_children(node, context),
      raw_text: raw_text(node, context)
    }
  end

  defp attach_root_diagnostics(%Syntax.ModuleNode{} = module, diagnostics) do
    %{module | diagnostics: diagnostics}
  end

  defp attach_root_diagnostics(node, _diagnostics), do: node

  defp info(node, context) do
    %NodeInfo{
      id: NodeId.build(context.source, node.kind, context.parent_path, context.child_index),
      source: context.source,
      span: Span.from_parser(node.span),
      provenance: provenance(node, context)
    }
  end

  defp provenance(node, context) do
    %Provenance{
      raw_type: node.kind,
      named: node.named,
      field_name: node.field_name,
      child_index: context.child_index,
      parent_path: context.parent_path,
      child_order: Enum.map(node.children, & &1.kind)
    }
  end

  defp child_context(parent, context, child_index) do
    %{
      context
      | parent_path: context.parent_path ++ [parent.kind, child_index || 0],
        child_index: child_index,
        decorators: []
    }
  end

  defp named_children(node) do
    Enum.filter(node.children, & &1.named)
  end

  defp named_children(node, kind) do
    Enum.filter(node.children, &(&1.named and &1.kind == kind))
  end

  defp child_by_field(node, field) do
    Enum.find(node.children, &(&1.field_name == field))
  end

  defp children_by_field(node, field) do
    Enum.filter(node.children, &(&1.field_name == field))
  end

  defp map_field_children(node, context, field) do
    node
    |> children_by_field(field)
    |> Enum.map(&map_optional_child(node, &1, context))
  end

  defp map_argument_children(call_node, arguments_node, context) do
    argument_context = child_context(call_node, context, child_index(call_node, arguments_node))

    arguments_node
    |> named_children()
    |> Enum.map(&map_optional_child(arguments_node, &1, argument_context))
  end

  defp map_optional_child(_parent, nil, _context), do: nil

  defp map_optional_child(parent, child, context) do
    map_node(child, child_context(parent, context, child_index(parent, child)))
  end

  defp first_named_child(node) do
    Enum.find(node.children, & &1.named)
  end

  defp parameter_name_node(node) do
    child_by_field(node, "name") || Enum.find(node.children, &(&1.kind == "identifier"))
  end

  defp child_index(parent, child) do
    Enum.find_index(parent.children, &(&1 == child))
  end

  defp has_child_kind?(node, kind) do
    Enum.any?(node.children, &(&1.kind == kind))
  end

  defp raw_text(nil, _context), do: nil

  defp raw_text(node, %{source_text: source_text}) when is_binary(source_text) do
    binary_part(source_text, node.span.start_byte, node.span.end_byte - node.span.start_byte)
  end

  defp raw_text(_node, _context), do: nil

  defp relative_level(node, context) do
    node
    |> raw_text(context)
    |> case do
      nil ->
        0

      text ->
        text
        |> String.trim_leading("from ")
        |> String.graphemes()
        |> Enum.take_while(&(&1 == "."))
        |> length()
    end
  end

  defp source_from_path(nil), do: nil

  defp source_from_path(path) do
    case File.read(path) do
      {:ok, source} -> source
      {:error, _reason} -> nil
    end
  end

  defp literal_kind(kind) when kind in ["integer", "float"], do: :number
  defp literal_kind("string"), do: :string
  defp literal_kind(kind) when kind in ["true", "false"], do: :boolean
  defp literal_kind("none"), do: :none
  defp literal_kind("list"), do: :list
  defp literal_kind("tuple"), do: :tuple
  defp literal_kind("dictionary"), do: :dict
  defp literal_kind("set"), do: :set

  defp literal_value(:number, raw_text) do
    case Integer.parse(raw_text || "") do
      {integer, ""} ->
        integer

      _other ->
        case Float.parse(raw_text || "") do
          {float, ""} -> float
          _other -> nil
        end
    end
  end

  defp literal_value(:boolean, "True"), do: true
  defp literal_value(:boolean, "False"), do: false
  defp literal_value(:none, _raw_text), do: nil
  defp literal_value(:string, raw_text), do: raw_text
  defp literal_value(_kind, _raw_text), do: nil
end
