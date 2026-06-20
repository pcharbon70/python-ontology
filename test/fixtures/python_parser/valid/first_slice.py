# covers: python_ontology.parser.tree_sitter_python_authority python_ontology.parser.concrete_syntax_tree_output python_ontology.parser.source_locations python_ontology.initial_analysis_slice.tests_for_slice
import os
import sys as system
from pathlib import Path as FilePath


@decorator("value")
class Example(Base):
    class_attr: int = 1

    def method(self, name: str, *args, enabled: bool = True, **kwargs) -> str:
        result = helper(name, *args, **kwargs)
        return result.value
