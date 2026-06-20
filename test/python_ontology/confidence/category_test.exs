# covers: python_ontology.fact_confidence_model.categories python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.no_execution_for_confidence python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
defmodule PythonOntology.Confidence.CategoryTest do
  use ExUnit.Case, async: true

  alias PythonOntology.Confidence
  alias PythonOntology.Confidence.Category

  test "defines the finite confidence category set" do
    assert Category.all() == [
             :source_declared,
             :statically_inferred,
             :unresolved,
             :runtime_dependent
           ]

    assert Confidence.categories() == Category.all()
  end

  test "validates known confidence categories" do
    for category <- Category.all() do
      assert {:ok, ^category} = Category.validate(category)
      assert {:ok, ^category} = Confidence.validate_category(Atom.to_string(category))
    end
  end

  test "rejects unknown confidence categories" do
    assert {:error, message} = Category.validate(:optimistic)
    assert message =~ "unknown confidence category"

    assert {:error, message} = Confidence.validate_category("optimistic")
    assert message =~ "unknown confidence category"
  end

  test "defaults direct syntax facts to source declared" do
    assert Category.direct_syntax_default() == :source_declared
    assert Confidence.direct_syntax_default() == :source_declared
  end
end
