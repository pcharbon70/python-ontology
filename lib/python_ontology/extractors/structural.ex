# covers: python_ontology.extractor_builder_boundary.parser_syntax_only python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime
defmodule PythonOntology.Extractors.Structural do
  @moduledoc """
  Extracts first-slice structural facts from normalized syntax.
  """

  alias PythonOntology.Confidence
  alias PythonOntology.Extractors.Context
  alias PythonOntology.Facts
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Facts.Result
  alias PythonOntology.Syntax

  @doc """
  Extracts source organization and declaration facts.
  """
  @spec extract(Syntax.ModuleNode.t(), Context.t()) :: Result.t()
  def extract(%Syntax.ModuleNode{} = module, %Context{} = context) do
    facts =
      []
      |> append_fact(source_file_fact(context))
      |> append_fact(package_fact(context))
      |> append_fact(module_fact(module, context))
      |> Kernel.++(declaration_facts(module.body, context, []))

    Facts.result(facts, metadata: %{extractor: __MODULE__, fact_count: length(facts)})
  end

  defp source_file_fact(%Context{} = context) do
    evidence =
      Confidence.source_evidence(
        source_id: context.source_id,
        path: context.source_path,
        details: [relative_path: context.relative_path]
      )

    Fact.source_file(
      id: "source_file:#{context.source_id}",
      source_id: context.source_id,
      path: context.source_path,
      source_path: context.relative_path || context.source_id,
      role: context.source_file && context.source_file.role,
      module_name: module_name(context),
      package_kind: context.package_kind,
      package_root: context.package_root,
      package_name: context.package_name,
      identity: %{source_path: context.relative_path || context.source_id},
      evidence: [evidence]
    )
  end

  defp package_fact(%Context{package_name: nil}), do: nil

  defp package_fact(%Context{} = context) do
    evidence = source_evidence(context)

    Fact.package(
      id: "package:#{context.package_kind}:#{context.package_name}",
      name: context.package_name,
      source_id: context.source_id,
      path: context.source_path,
      package_kind: context.package_kind,
      package_root: context.package_root,
      package_name: context.package_name,
      identity: %{
        kind: context.package_kind,
        name: context.package_name,
        root_path: context.package_root,
        source_path: context.relative_path
      },
      evidence: [evidence]
    )
  end

  defp module_fact(%Syntax.ModuleNode{} = module, %Context{} = context) do
    module_name = module_name(context)

    syntax_fact(:module, module, context,
      id: "module:#{module_name}",
      name: module_name,
      module_name: module_name,
      source_path: context.relative_path || context.source_id,
      package_kind: context.package_kind,
      package_name: context.package_name,
      identity: %{
        name: module_name,
        source_path: context.relative_path || context.source_id,
        stub?: context.source_file && context.source_file.stub?
      }
    )
  end

  defp declaration_facts(nodes, context, lexical_path) do
    Enum.flat_map(nodes, &node_facts(&1, context, lexical_path))
  end

  defp node_facts(%Syntax.Import{} = import, context, _lexical_path) do
    aliases =
      Enum.map(import.names, fn alias_node ->
        %{name: alias_node.name, as: alias_node.as, node_id: alias_node.info.id}
      end)

    [
      syntax_fact(:import, import, context,
        id: "import:#{import.info.id}",
        module_name: module_name(context),
        aliases: aliases,
        attributes: %{
          module: import.module,
          names: Enum.map(aliases, & &1.name),
          relative_level: import.relative_level,
          unresolved_relative?: import.relative_level > 0
        },
        identity: %{container_id: "module:#{module_name(context)}"}
      )
    ]
  end

  defp node_facts(%Syntax.Class{} = class, context, lexical_path) do
    class_path = lexical_path ++ [class.name]
    class_id = "class:#{module_name(context)}:#{Enum.join(class_path, ".")}:#{class.info.id}"

    class_fact =
      syntax_fact(:class, class, context,
        id: class_id,
        name: class.name,
        qualified_name: Enum.join(class_path, "."),
        module_name: module_name(context),
        bases: Enum.map(class.bases, &raw_expression/1),
        decorators: Enum.map(class.decorators, &raw_expression/1),
        identity: %{
          module_name: module_name(context),
          lexical_path: class_path,
          span: class.info.span
        }
      )

    [class_fact] ++
      base_facts(class, context, class_id) ++
      decorator_facts(class.decorators, context, class_id) ++
      declaration_facts(class.body, context, class_path)
  end

  defp node_facts(%Syntax.Function{} = function, context, lexical_path) do
    function_path = lexical_path ++ [function.name]
    kind = if function.method_candidate? or lexical_path != [], do: :method, else: :function

    function_id =
      "#{kind}:#{module_name(context)}:#{Enum.join(function_path, ".")}:#{function.info.id}"

    function_fact =
      syntax_fact(kind, function, context,
        id: function_id,
        name: function.name,
        qualified_name: Enum.join(function_path, "."),
        module_name: module_name(context),
        parameters: Enum.map(function.parameters, & &1.name),
        decorators: Enum.map(function.decorators, &raw_expression/1),
        annotations: annotation_texts(function),
        attributes: %{async?: function.async?, method?: kind == :method},
        identity: %{
          module_name: module_name(context),
          lexical_path: function_path,
          method?: kind == :method,
          span: function.info.span
        }
      )

    [function_fact] ++
      decorator_facts(function.decorators, context, function_id) ++
      parameter_facts(function.parameters, context, function_id) ++
      annotation_facts(function.return_annotation, context, function_id, "return") ++
      declaration_facts(function.body, context, function_path)
  end

  defp node_facts(_node, _context, _lexical_path), do: []

  defp base_facts(%Syntax.Class{} = class, context, class_id) do
    class.bases
    |> Enum.with_index(1)
    |> Enum.map(fn {base, index} ->
      syntax_fact(:base_class, base, context,
        id: "#{class_id}:base:#{index}",
        parent_id: class_id,
        raw_text: raw_expression(base),
        attributes: %{position: index}
      )
    end)
  end

  defp decorator_facts(decorators, context, parent_id) do
    decorators
    |> Enum.with_index(1)
    |> Enum.map(fn {decorator, index} ->
      syntax_fact(:decorator, decorator, context,
        id: "#{parent_id}:decorator:#{index}",
        parent_id: parent_id,
        raw_text: raw_expression(decorator),
        attributes: %{position: index}
      )
    end)
  end

  defp parameter_facts(parameters, context, function_id) do
    parameters
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {parameter, index} ->
      parameter_id = "#{function_id}:parameter:#{index}:#{parameter.name}"

      parameter_fact =
        syntax_fact(:parameter, parameter, context,
          id: parameter_id,
          name: parameter.name,
          parent_id: function_id,
          raw_text: parameter.info.provenance.raw_type,
          attributes: %{
            position: index,
            kind: parameter.kind,
            annotation: raw_expression(parameter.annotation),
            default: raw_expression(parameter.default)
          }
        )

      [parameter_fact] ++
        annotation_facts(parameter.annotation, context, parameter_id, "parameter")
    end)
  end

  defp annotation_facts(nil, _context, _parent_id, _role), do: []

  defp annotation_facts(%Syntax.Annotation{} = annotation, context, parent_id, role) do
    [
      syntax_fact(:annotation, annotation, context,
        id: "#{parent_id}:annotation:#{role}",
        parent_id: parent_id,
        raw_text: raw_expression(annotation),
        attributes: %{role: role}
      )
    ]
  end

  defp annotation_texts(%Syntax.Function{return_annotation: nil}), do: []

  defp annotation_texts(%Syntax.Function{return_annotation: annotation}) do
    [raw_expression(annotation)]
  end

  defp syntax_fact(kind, node, context, attrs) do
    evidence = Confidence.syntax_evidence(node.info)

    {:ok, fact} =
      Fact.new(
        kind,
        attrs
        |> Keyword.put(:source_id, context.source_id)
        |> Keyword.put(:path, context.source_path)
        |> Keyword.put(:span, node.info.span)
        |> Keyword.put(:node_id, node.info.id)
        |> Keyword.put(:raw_node_type, node.info.provenance.raw_type)
        |> Keyword.put(:evidence, [evidence])
      )

    fact
  end

  defp source_evidence(context) do
    Confidence.source_evidence(
      source_id: context.source_id,
      path: context.source_path,
      details: [module_name: module_name(context)]
    )
  end

  defp append_fact(facts, {:ok, fact}), do: facts ++ [fact]
  defp append_fact(facts, %Fact{} = fact), do: facts ++ [fact]
  defp append_fact(facts, nil), do: facts

  defp module_name(%Context{module_name: module_name})
       when is_binary(module_name) and module_name != "",
       do: module_name

  defp module_name(%Context{source_id: source_id}) do
    source_id
    |> String.replace_suffix(".pyi", "")
    |> String.replace_suffix(".py", "")
    |> String.trim_leading("src/")
    |> String.replace("/", ".")
  end

  defp raw_expression(nil), do: nil
  defp raw_expression(%{raw_text: raw_text}) when is_binary(raw_text), do: raw_text
  defp raw_expression(%Syntax.Identifier{name: name}), do: name
  defp raw_expression(%Syntax.Literal{raw_text: raw_text}), do: raw_text
  defp raw_expression(%{info: %{provenance: %{raw_type: raw_type}}}), do: raw_type
  defp raw_expression(value), do: inspect(value)
end
