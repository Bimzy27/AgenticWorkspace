---
name: lint
description: Run the project's linter and formatter, then fix all findings until clean. Use after making code changes, when asked to lint, or as a stage of /patrol.
---

# Lint

Leave the project lint-clean and consistently formatted.
Auto-fix what the tools can, hand-fix the rest, and never suppress.

## Resolve the command

Work down this list and use the first match:

1. An explicit lint command named in the project's AGENTS.md, CLAUDE.md, or a project-level skill.
2. A task the project defines: a `lint` script in package.json, a Makefile or Justfile target, or an equivalent task-runner entry.
3. An ecosystem default, chosen by marker file:

| Marker | Command |
|---|---|
| eslint.config.* or .eslintrc* | `eslint . --max-warnings=0`, with `--fix` on the first pass |
| biome.json(c) | `biome check --write .`, then `biome check .` to verify |
| ruff.toml, or ruff section in pyproject.toml | `ruff check --fix .` then `ruff format .`, verify with `ruff check .` |
| Cargo.toml | `cargo clippy --all-targets -- -D warnings`, plus `cargo fmt --check` |
| go.mod with .golangci.yml | `golangci-lint run` |
| go.mod otherwise | `gofmt -l .` (empty output is a pass) and `go vet ./...` |
| .editorconfig with a dotnet project | `dotnet format --verify-no-changes`, fix with `dotnet format` |
| stylua.toml (Lua) | `stylua --check .`, fix with `stylua .` |

If nothing matches, report that the project has no linter configured, recommend one for the stack, and stop.

## Fix loop

1. Run the auto-fix variant first, then the verify variant.
2. Hand-fix whatever remains by changing the code, not the rules.
   Do not add inline suppression comments, disable rules, or widen ignore lists unless the project already uses that pattern for the same rule and situation.
3. Re-run the verify command.
   Cap at 5 cycles; if findings remain, stop and report them honestly.

Pre-existing findings are in scope.
The goal is a green check across the project, not merely a clean diff.

## Report

State the command used, pass or fail, a one-line summary of what the auto-fixer changed, what was fixed by hand, and anything left unresolved with the exact finding text.
