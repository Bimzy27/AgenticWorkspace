---
name: equip
description: Set up missing quality-gate tooling (type checker, linter, audit scanners, POLICE.md, test runner) in a repo. Use when a gate stage reports nothing configured, when starting work in an under-tooled repo, or when asked to bootstrap quality checks.
---

# Equip

Give a repo the tooling the quality gate expects, so /patrol stages stop reporting SKIPPED.
The stage skills (typecheck, lint, audit, police, tests via patrol) send work here when they find nothing configured; equip installs the community-standard tool with the smallest viable config and hands back.

## Principles

- Community standard over clever niche: pick the tool the ecosystem has converged on.
- Smallest viable config: the tool's recommended defaults plus strictness; no hand-tuned rule zoos on day one.
- Strict from the start: warnings are errors wherever the ecosystem supports it, because a gate that tolerates warnings decays.
- Equipping includes getting the repo green under the new check via the stage skill's fix loop, not just adding a config file.
- Own repos get equipped directly; third-party repos (open-source contributions, codebases with their own governance) get a proposal instead of imposed tooling.
- Idempotent: re-running equip on a fully equipped repo changes nothing.

## Steps

1. Inventory: detect the repo's stacks by marker files and source extensions, then check each gate stage against the resolution tables in the sibling stage skills.
2. For each gap, set up the tool from the tables below: install it, write the minimal config, and add a task entry (package.json script, Makefile target) when the repo already uses a task runner.
3. Run the corresponding stage skill end to end so the new tool is proven green, fixing findings per that skill's fix loop.
4. Record permanent gaps (stages with no viable tool for the stack) in the repo's AGENTS.md or CLAUDE.md so later sessions inherit the decision instead of re-deriving it.
5. Report the stage-to-tool matrix, then deliver the new files as their own `chore:` commit; never bundle them with feature work.

## Setup tables

### Typecheck

| Stack | Setup |
|---|---|
| TypeScript | `tsconfig.json` with `"strict": true`; command `tsc --noEmit` |
| Python | `[tool.pyright]` in pyproject.toml (or pyrightconfig.json) |
| Rust, Go, .NET, JVM | the compiler already type-checks; nothing to add |
| Plain JS, Lua, PowerShell, shell | no viable standalone type checker; record the stage as not applicable |

### Lint

| Stack | Setup |
|---|---|
| JS/TS | biome (`biome.json`, lint and format in one tool); if the repo already carries eslint or prettier config, complete that setup instead of switching |
| Python | ruff (`[tool.ruff]` in pyproject.toml) for both lint and format |
| Rust | clippy with `-D warnings` plus `cargo fmt`; built in, no config needed |
| Go | golangci-lint with its default linter set (`.golangci.yml`) |
| Lua | stylua (`stylua.toml`) |
| PowerShell | PSScriptAnalyzer module plus `PSScriptAnalyzerSettings.psd1` |
| Markdown-only repos | markdownlint-cli2 when prose is the product; otherwise not applicable |

### Audit

| Gap | Setup |
|---|---|
| No secrets scanner | install gitleaks machine-wide (winget, brew, or pacman) |
| No dependency scanner for the ecosystem | install the tool from the audit skill's table (pip-audit, cargo-audit, govulncheck, osv-scanner) |

These are machine-level installs, not repo files; name them in the report so other machines know to install them too.

### Police

Repos without their own police file are already covered by the global fallback at `~/.claude/POLICE.md`, so a missing `POLICE.md` is a gap only when the project needs rules of its own.
When it does, bootstrap `POLICE.md` from `POLICE.template.md` in the police skill's directory.
Seed it with the global fallback rules that still apply (a repo file replaces the fallback, it does not extend it), plus rules evidenced by the repo itself (conventions in its AGENTS.md or README, patterns the code already follows), and delete template examples that do not apply.
Police rules are law once committed, so present the seeded rules for approval before enforcing them.

### Tests

| Stack | Setup |
|---|---|
| JS/TS | vitest |
| Python | pytest |
| Rust, Go, .NET | built-in test runner; just add the first test |
| PowerShell | Pester |

Seed with one real end-to-end smoke test of the repo's main flow; a placeholder assert-true test is worse than no stage.

## Judgement

- Proportionality: equip stacks with real code.
  Vendored code, generated files, and one-off scripts do not justify tooling; a pure-config repo may honestly support only a subset of stages.
- Not applicable is a recorded state, not silence: write it down (step 4) so future patrols stop re-litigating the same gaps.
- Existing decisions win: if the repo's docs already say a check is deliberately absent, respect that and surface disagreement in the report instead of overriding it.
