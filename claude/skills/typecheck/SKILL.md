---
name: typecheck
description: Run the project's type checker and fix failures until it passes. Use after making code changes, when asked to typecheck, or as a stage of /patrol.
---

# Typecheck

Leave the project with a passing typecheck.
Fix failures at the root cause; never silence them.

## Resolve the command

Work down this list and use the first match:

1. An explicit typecheck command named in the project's AGENTS.md, CLAUDE.md, or a project-level skill.
2. A task the project defines: a `typecheck` or `check` script in package.json, a Makefile or Justfile target, or an equivalent task-runner entry.
3. An ecosystem default, chosen by marker file:

| Marker | Command |
|---|---|
| tsconfig.json | `tsc --noEmit`, invoked via the package manager the lockfile implies |
| pyrightconfig.json, or pyright section in pyproject.toml | `pyright` |
| mypy.ini, or mypy section in pyproject.toml | `mypy .` |
| Cargo.toml | `cargo check --all-targets` |
| go.mod | `go vet ./...` |
| *.sln or *.csproj | `dotnet build --nologo -warnaserror` |
| build.gradle(.kts) or pom.xml | `./gradlew compileJava compileTestJava` or `mvn -q compile test-compile` |

If nothing matches, follow the sibling `equip` skill to set a type checker up, then run the command it configured.
If equip finds no viable type checker for the stack, report the stage as not applicable.
Never guess at a command that is not evidenced by the repo.

## Fix loop

1. Run the command from the repo root and capture the full output.
2. If it fails, fix the root cause of each error.
   Suppression is not fixing: no `any`, `@ts-ignore`, `# type: ignore`, no loosening compiler options, and no deleting code just to silence an error, unless that is already an established project convention for the exact situation.
3. Re-run.
   Cap at 5 cycles; if errors remain after that, stop and report the remaining output honestly.

Pre-existing failures are in scope.
The goal is a green check, not merely a clean diff.
If a pre-existing error is too large to fix safely inside this task, say so explicitly in the report instead of silently skipping it.

## Report

State the command used, pass or fail, the number of errors fixed, and anything left unresolved with the exact error text.
