# Phase 2 - Ontology Alignment and Builder Propagation

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces

- `.spec/decisions/python_ontology.decision.fact_confidence_model.md`
- `.spec/specs/fact_confidence_model.spec.md`
- `priv/ontologies/python-core.ttl`
- `priv/ontologies/python-runtime.ttl`
- `lib/python_ontology/builders/**/*.ex`

## Relevant Assumptions / Defaults

- Confidence categories must be queryable in RDF.
- The ontology already contains starter confidence classes.
- Builders are responsible for RDF propagation.

[x] 2 Phase 2 - Ontology Alignment and Builder Propagation
  Align confidence vocabulary with RDF builder behavior.

  [x] 2.1 Section - Turtle Vocabulary Review
    Ensure authored ontologies can represent confidence categories and evidence.

    [x] 2.1.1 Task - Review `python-core.ttl`
      Confirm and refine fact confidence vocabulary.

      [x] 2.1.1.1 Subtask - Confirm classes for source-declared, statically-inferred, unresolved, and runtime-dependent facts.
      [x] 2.1.1.2 Subtask - Add object/datatype properties for confidence category and evidence references if needed.
      [x] 2.1.1.3 Subtask - Add comments that distinguish static source facts from runtime-dependent facts.

    [x] 2.1.2 Task - Align runtime ontology
      Keep dynamic boundaries consistent across core and runtime layers.

      [x] 2.1.2.1 Subtask - Connect dynamic import, monkey patching, and runtime boundary concepts to confidence categories.
      [x] 2.1.2.2 Subtask - Keep runtime-dependent facts queryable without asserting runtime truth.
      [x] 2.1.2.3 Subtask - Parse all Turtle files after edits.

  [x] 2.2 Section - Builder Propagation Helpers
    Prepare builders to emit confidence triples consistently.

    [x] 2.2.1 Task - Implement confidence RDF helpers
      Centralize confidence triple generation.

      [x] 2.2.1.1 Subtask - Add helper for confidence class or property triples.
      [x] 2.2.1.2 Subtask - Add helper for evidence resource links or literals.
      [x] 2.2.1.3 Subtask - Add diagnostics for missing confidence metadata.

  [x] 2.3 Section - Phase 2 Integration Tests
    Prove ontology and builder helpers can represent queryable confidence.

    [x] 2.3.1 Task - Run confidence RDF checks
      Validate Turtle vocabulary and helper output.

      [x] 2.3.1.1 Subtask - Add tests that confidence helper emits expected triples.
      [x] 2.3.1.2 Subtask - Run Turtle parse validation for all ontology files.
      [x] 2.3.1.3 Subtask - Run focused confidence RDF tests, full `mix test`, and `mix spec.check`.
