---
name: police
description: Check a set of changes against the project's POLICE.md behaviour rules. Use before committing, when asked to police or audit changes, or as a stage of /patrol.
---

# Police

Enforce the project's checked-in behaviour rules against a changeset.
These are human-written rules that linters and type checkers cannot express: architectural boundaries, testing discipline, security posture, product conventions.

## Locate the police file

Look in order: `POLICE.md` at the repo root, `.claude/POLICE.md`, `docs/POLICE.md`.
If the repo has none of these, fall back to the global rules at `~/.claude/POLICE.md` and name the fallback in the report.
A repo file replaces the global fallback entirely; never merge the two.
If the global file does not exist either, bootstrap a repo file from `POLICE.template.md` in this skill's directory by following the sibling `equip` skill, and get the seeded rules approved before enforcing them.
Never invent rules that are not written down.

## Determine the changeset

- If the invocation names commits, branches, or files, police exactly those.
- Otherwise: all uncommitted changes plus the commits on the current branch since its merge-base with the default branch.
- On the default branch with a clean tree there is nothing to police; say so and stop.

## Enforce

For each rule in the police file:

1. If the rule has a `Scope:` glob and no changed file matches it, skip the rule.
2. If the rule has a `Command:`, run it; a non-zero exit is a violation.
3. Otherwise, read the relevant diff hunks and changed files and judge the rule exactly as written.

Judge only the changeset, not the whole repository, unless a rule declares `Scope: repo`.
Rules are law: do not water them down, reinterpret them, or grant exceptions.
If a change is genuinely ambiguous under a rule, report it as a warning with your reasoning rather than silently passing it.

## Report

For each violation: the rule id, `file:line`, and one sentence on what breaks the rule.
Finish with a verdict line: `POLICE: PASS` or `POLICE: FAIL (N violations, M warnings)`.

If invoked with `--fix`, first report all violations, then fix them and re-run the enforcement pass until clean or blocked.
