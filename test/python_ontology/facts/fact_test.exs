# covers: python_ontology.extractor_builder_boundary.extractors_emit_facts python_ontology.extractor_builder_boundary.no_rdf_in_extractors python_ontology.extractor_builder_boundary.source_evidence_required python_ontology.extractor_builder_boundary.diagnostic_accumulation python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.runtime_dependent_boundary python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Facts.FactTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Facts
  alias PythonOntology.Facts.Fact
  alias PythonOntology.Pipeline.Diagnostic

  test "builds structural facts with required source evidence and default confidence" do
    evidence = [
      Confidence.source_evidence(source_id: "src/pkg/app.py", path: "/project/src/pkg/app.py")
    ]

    assert {:ok, %Fact{} = fact} =
             Fact.module(
               id: "module:sample_pkg.app",
               name: "sample_pkg.app",
               source_id: "src/pkg/app.py",
               path: "/project/src/pkg/app.py",
               identity: %{module_name: "sample_pkg.app"},
               evidence: evidence
             )

    assert fact.kind == :module
    assert fact.confidence == :source_declared
    assert fact.evidence == evidence
    assert fact.identity.module_name == "sample_pkg.app"
    assert Facts.structural_kinds() |> Enum.member?(:module)
  end

  test "builds expression facts with unresolved or runtime confidence markers" do
    source = Confidence.source_evidence(source_id: "src/pkg/app.py")
    assert {:ok, runtime} = Confidence.runtime_evidence(:dynamic_import, inputs: [source])

    assert {:ok, %Fact{} = fact} =
             Fact.call(
               id: "call:dynamic-import",
               target_text: "importlib.import_module",
               confidence: :runtime_dependent,
               evidence: [source, runtime],
               attributes: %{runtime_boundary: :dynamic_import}
             )

    assert fact.kind == :call
    assert fact.confidence == :runtime_dependent
    assert fact.attributes.runtime_boundary == :dynamic_import
    assert Facts.expression_kinds() |> Enum.member?(:call)
  end

  test "rejects facts without source evidence or valid diagnostics" do
    assert {:error, "facts require source or syntax-node evidence"} =
             Fact.class(id: "class:Example", evidence: [])

    source = Confidence.source_evidence(source_id: "src/pkg/app.py")

    assert {:error, "diagnostics must contain pipeline diagnostic records"} =
             Fact.class(id: "class:Example", evidence: [source], diagnostics: [:not_diagnostic])

    diagnostic = %Diagnostic{stage: :extractor, severity: :warning, message: "kept unresolved"}

    assert {:ok, %Fact{diagnostics: [^diagnostic]}} =
             Fact.class(id: "class:Example", evidence: [source], diagnostics: [diagnostic])
  end

  test "extractor result merges facts and diagnostics without RDF triples" do
    source = Confidence.source_evidence(source_id: "src/pkg/app.py")
    assert {:ok, fact} = Fact.source_file(id: "source:src/pkg/app.py", evidence: [source])
    diagnostic = %Diagnostic{stage: :extractor, severity: :info, message: "noted"}

    result = Facts.result([fact], diagnostics: [diagnostic])
    merged = PythonOntology.Facts.Result.merge([result, Facts.result([])])

    assert result.facts == [fact]
    assert result.diagnostics == [diagnostic]
    refute match?({_, _, _}, fact)
    assert merged.facts == [fact]
    assert merged.diagnostics == [diagnostic]
  end
end
