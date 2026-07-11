# Branden's opinions

Read this when a task involves a judgement call with no objectively right answer.
These opinions decide those calls the way Branden would.
Hard rules and engineering standards live in AGENTS.md; this file covers the longer tail of technical taste.
It grows over time; when Branden states a new opinion in a session, offer to add it here.

## Dependencies: use best-in-class libraries freely

Use the ecosystem.
Pulling a well-maintained, best-in-class library is almost always better than hand-rolling; velocity and correctness beat purity.
In practice: do not reimplement solved problems, and pick the community's standard choice over the clever niche one.

## Abstraction: rule of three

Duplicate first.
Only introduce a shared function, base class, or generic layer once the third usage appears and the real cases have proven the shape.
In practice: two similar blocks of code are fine; a speculative framework for one caller is not.

## Errors: fail fast, crash loudly

Invalid states should throw immediately with rich context.
No fallbacks or silent recovery that mask bugs; a crash in development is a gift.
In practice: assert assumptions, include the offending values in error messages, and never swallow an exception to keep something limping.

## Comments: why-only, sparse

Code should self-document what it does.
Comments exist solely for non-obvious constraints, trade-offs, and gotchas that the code cannot express.
In practice: if a comment restates the line below it, delete it; if a future reader would ask "why is it done this way?", write it.

## Tests: E2E and integration heavy

Most confidence comes from tests that drive the system the way a user would.
Unit tests are for genuinely tricky pure logic, not for coverage theatre.
In practice: prefer one test that exercises the real flow over ten that mock the world, and align with the E2E-first bug rule in AGENTS.md.

## Tech adoption: bleeding edge for tooling, boring for production

Dev tools, editors, terminals, and AI tooling ride the leading edge.
Anything shipped to users sticks to proven, boring technology.
In practice: a nightly build of a terminal is fine; a pre-1.0 database in production is not.

## Refactoring: boy-scout within the diff

Clean up whatever the task already touches: names, dead branches, structure.
Never widen the diff beyond the files the task touches; bigger mess gets surfaced in the report as a proposal instead.
In practice: this is the scope boundary for the "fix what you see" standard in AGENTS.md.

## Performance: readable until measured

Write the clearest version first.
Optimize only with a measurement or profile proving it matters; no speculative micro-optimization.
In practice: choosing an obviously sane data structure is fine, contorting code for an unmeasured hot path is not.
