# covers: python_ontology.fact_confidence_model.static_inference_evidence python_ontology.fact_confidence_model.unresolved_queryable python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.dynamic_construct_marking python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.EvidenceTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Evidence
  alias PythonOntology.Parser
  alias PythonOntology.Syntax

  @fixture Path.expand("../../fixtures/python_parser/valid/first_slice.py", __DIR__)

  test "builds source file and span evidence references" do
    span = %{start_byte: 10, end_byte: 20}

    assert %Evidence{kind: :source, source_id: "memory://example.py", span: ^span} =
             Confidence.source_evidence(source_id: "memory://example.py", span: span)
  end

  test "builds syntax node evidence references from normalized node info" do
    assert {:ok, parsed} = Parser.parse_file(@fixture)
    assert {:ok, module} = Syntax.normalize(parsed)

    import = Enum.find(module.body, &match?(%Syntax.Import{}, &1))

    assert %Evidence{
             kind: :syntax_node,
             source_id: @fixture,
             syntax_node_id: syntax_node_id,
             raw_node_type: "import_statement"
           } = Confidence.syntax_evidence(import.info)

    assert is_binary(syntax_node_id)
  end

  test "builds evidence lists and static inference evidence from inputs" do
    source =
      Confidence.source_evidence(
        source_id: "memory://example.py",
        span: %{start_byte: 0, end_byte: 8}
      )

    syntax =
      Confidence.syntax_evidence(syntax_node_id: "syntax:1", raw_node_type: "import_statement")

    assert {:ok, [^source, ^syntax]} = Confidence.evidence_list([source, syntax])

    assert %Evidence{
             kind: :static_inference,
             reason: :alias_resolution,
             inputs: [^source, ^syntax],
             details: %{name: "Path"}
           } =
             Confidence.static_inference_evidence(:alias_resolution, [source, syntax],
               details: [name: "Path"]
             )
  end

  test "builds unresolved evidence with supported reasons" do
    assert :unknown_name in Evidence.unresolved_reasons()
    assert :dynamic_target in Evidence.unresolved_reasons()

    assert {:ok, %Evidence{kind: :unresolved, reason: :unknown_name, details: %{name: "target"}}} =
             Confidence.unresolved_evidence(:unknown_name, details: [name: "target"])

    assert {:error, message} = Confidence.unresolved_evidence(:maybe_later)
    assert message =~ "unknown unresolved evidence reason"
  end

  test "builds runtime-dependent evidence for dynamic Python boundaries" do
    for reason <- [:dynamic_import, :decorator, :metaclass, :monkey_patching, :reflection] do
      assert {:ok, %Evidence{kind: :runtime_dependent, reason: ^reason}} =
               Confidence.runtime_evidence(reason)
    end

    assert {:error, message} = Confidence.runtime_evidence(:static_alias)
    assert message =~ "unknown runtime-dependent evidence reason"
  end
end
