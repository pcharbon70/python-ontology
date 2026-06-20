# covers: python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.tests_for_slice
from initial_slice_pkg.complete import Example as Subject


def test_method():
    assert Subject().method("path")
