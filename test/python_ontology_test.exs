# covers: package.python_ontology.test_baseline
defmodule PythonOntologyTest do
  use ExUnit.Case

  test "exposes the OTP application name" do
    assert PythonOntology.app_name() == :python_ontology
  end
end
