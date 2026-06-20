# covers: python_ontology.initial_analysis_slice.modules_packages python_ontology.initial_analysis_slice.imports_aliases python_ontology.initial_analysis_slice.classes_bases python_ontology.initial_analysis_slice.functions_methods python_ontology.initial_analysis_slice.parameters_defaults python_ontology.initial_analysis_slice.decorators_annotations python_ontology.initial_analysis_slice.calls_attributes python_ontology.initial_analysis_slice.source_locations python_ontology.initial_analysis_slice.out_of_scope_runtime python_ontology.initial_analysis_slice.tests_for_slice
import importlib
import sys as system
from pathlib import Path as FilePath


@class_decorator("fixture")
class Example(Base, mixin.Factory()):
    class_attr: int = 1

    @method_decorator
    def method(self, name: str, *args, enabled: bool = True, **kwargs) -> str:
        item = self.items[0]
        module = importlib.import_module(name)
        dynamic = factory()[name](item).value
        return helper(name, *args, **kwargs).result
