# Branden's agent instructions

These are common instructions for Branden's agents across all scenarios.
This file is the single source of truth.
It lives in the AgenticWorkspace repo as `AGENTS.md` and is symlinked to `~/.claude/CLAUDE.md`, `~/.claude/AGENTS.md`, and the repo's own `CLAUDE.md`.
Edit `AGENTS.md` only; never edit the symlinks.

## Hard rules

Non-negotiable in every project:

- Never use the em dash "—". Use plain dash "-" instead.
- When writing commit messages, NEVER auto-add your agent name as co-author.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When writing or substantially editing Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.

## Engineering standards

- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would trigger it.
  This makes sure you find the real problem so your fix will actually solve it.
  Prove the fix the same way: trigger the original scenario again and observe it passing.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Scope discipline for the two rules above: fix small issues (a lint finding, a flaky test, a misleading log or status line) inline as part of the current task.
  If the fix needs real design work, surface it in your report instead of silently expanding scope.

## Ways of working

- Commit messages follow conventional commits: a lowercase type prefix (`feat`, `fix`, `chore`, `refactor`, `docs`, `test`), a colon, then an imperative subject of 72 characters or less.
  The body explains why, not what.
- Split unrelated changes into separate commits; never bundle them.
- Do not commit or push unless asked, and never force-push.
- When a task is ambiguous, state your interpretation and proceed on the reversible parts; ask only when the answer genuinely changes what you build.
- Report honestly: if a check failed, was skipped, or was not run, say so plainly.
  Never describe unverified work as done.

## Quality Gate

Default skills are installed at `~/.claude/skills` and work in any project: `typecheck`, `lint`, `audit`, `police`, `patrol`, and `ship`.
After completing a set of code changes, run /patrol before committing or reporting the task as done.
Patrol runs typecheck, lint, audit, police, and tests in order, and you must fix failures as they arise until the whole gate is green.
When work is ready to deliver, use /ship so branches, commits, and pull requests follow one standard shape.
If the project has a POLICE.md, its rules are law for every changeset; never water them down or grant exceptions.

## Definition of done

Work is finished only when all of these hold:

1. /patrol passes end to end, and any SKIPPED stage is named in the report.
2. The change has been exercised for real, not only through tests: run the app, reload the config, or drive the flow the way an end user would.
3. Bug fixes carry their E2E reproduction: shown failing before the fix, shown passing after.
4. Docs and comments touched by the change match the new reality.
5. The final report states what was done, what was skipped, and anything left for a human decision.

## This repository (AgenticWorkspace)

Rules scoped to work inside the AgenticWorkspace repo itself:

- This is a dotfiles and agent-instructions repo; configs here are symlinked live into system paths, so edits take effect on the real machine immediately.
- Windows is the primary platform and scripts are PowerShell 7; Linux/Omarchy support is secondary.
- Commit directly to master here; this repo does not use pull requests.
- Setup scripts must stay idempotent; safe to re-run is a requirement.
- WezTerm reads `~/.wezterm.lua` through a symlink, and its file watcher misses edits made to the symlink target; after config changes, reload with Ctrl+Shift+R rather than trusting auto-reload.
- Skill changes under `claude/skills/` are live for new Claude Code sessions with no install step; `claude/skills-inactive/` is staged and not loaded.

## Branden's Opinions

If `~/OPINIONS.md` exists, read it when you are working on something that would benefit from being informed by Branden's viewpoints.

## Voice Profile

If `~/VOICE.md` exists, read it before talking or posting on behalf of Branden using his identity, to see how Branden talks.
