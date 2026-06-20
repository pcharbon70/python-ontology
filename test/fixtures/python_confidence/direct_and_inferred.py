# covers: python_ontology.fact_confidence_model.source_declared_default python_ontology.fact_confidence_model.static_inference_evidence python_ontology.initial_analysis_slice.tests_for_slice
import pathlib
from pathlib import Path as FilePath


AliasPath = FilePath


class DirectExample:
    def build(self, name: str) -> pathlib.Path:
        return AliasPath(name)
