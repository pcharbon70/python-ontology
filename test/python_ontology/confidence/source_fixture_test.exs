# covers: python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.SourceFixtureTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture_dir Path.expand("../../fixtures/python_confidence", __DIR__)

  test "direct and inferred fixture yields source-declared syntax evidence" do
    path = Path.join(@fixture_dir, "direct_and_inferred.py")

    assert {:ok, parsed} = Parser.parse_file(path)
    assert {:ok, module} = Syntax.normalize(parsed)

    assert Confidence.direct_syntax_default() == :source_declared

    import = Enum.find(module.body, &match?(%Syntax.Import{}, &1))
    class = Enum.find(module.body, &match?(%Syntax.Class{name: "DirectExample"}, &1))

    import_evidence = Confidence.syntax_evidence(import.info)
    class_evidence = Confidence.syntax_evidence(class.info)

    assert %Evidence{kind: :syntax_node, source_id: ^path, raw_node_type: "import_statement"} =
             import_evidence

    assert %Evidence{kind: :syntax_node, source_id: ^path, raw_node_type: "class_definition"} =
             class_evidence

    inferred =
      Confidence.static_inference_evidence(:alias_resolution, [import_evidence],
        details: [alias: "AliasPath"]
      )

    assert inferred.inputs == [import_evidence]
  end

  test "dynamic fixture leaves runtime and unresolved boundaries queryable" do
    path = Path.join(@fixture_dir, "dynamic_boundaries.py")

    assert {:ok, parsed} = Parser.parse_file(path)
    assert {:ok, module} = Syntax.normalize(parsed)

    calls = module |> Syntax.descendants() |> Enum.filter(&match?(%Syntax.Call{}, &1))
    assert Enum.any?(calls, &call_named?(&1, "getattr"))
    assert Enum.any?(calls, &call_named?(&1, "setattr"))
    assert Enum.any?(calls, &attribute_call?(&1, "importlib", "import_module"))

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :dynamic_import}} =
             Confidence.runtime_evidence(:dynamic_import)

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :reflection}} =
             Confidence.runtime_evidence(:reflection)

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :decorator}} =
             Confidence.runtime_evidence(:decorator)

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :metaclass}} =
             Confidence.runtime_evidence(:metaclass)

    assert {:ok, %Evidence{kind: :runtime_dependent, reason: :monkey_patching}} =
             Confidence.runtime_evidence(:monkey_patching)

    assert {:ok, %Evidence{kind: :unresolved, reason: :dynamic_target}} =
             Confidence.unresolved_evidence(:dynamic_target, details: [target: "name"])
  end

  defp call_named?(%Syntax.Call{function: %Syntax.Identifier{name: name}}, name), do: true
  defp call_named?(_call, _name), do: false

  defp attribute_call?(
         %Syntax.Call{
           function: %Syntax.Attribute{
             object: %Syntax.Identifier{name: object},
             attribute: %Syntax.Identifier{name: attribute}
           }
         },
         object,
         attribute
       ),
       do: true

  defp attribute_call?(_call, _object, _attribute), do: false
end
