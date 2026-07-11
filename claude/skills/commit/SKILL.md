---
name: commit
description: Commit and push the current changes with a conventional message and a quick sanity pass. Use when asked to commit, commit and push, or save progress; for PR-based delivery use /ship instead.
---

# Commit

The quick delivery path for direct-push repos and work-in-progress branches.
/ship owns the full gate and PR flow; this skill is for "commit and push this" moments.

## Steps

1. Review `git status` and the diff.
   Group related changes into logical commits; leave unrelated work uncommitted and say so.
2. OpenSpec check: if the repo has an `openspec/` directory, run `openspec list --json`.
   For any active change whose tasks are all complete, its specs should be synced and the change archived (/opsx:archive) before committing, so the spec sync and archive land in the same delivery as the implementation.
   If archiving is not appropriate yet (e.g. verification is still pending), leave the change active and name it in the report as pending archive.
3. Sanity pass on the diff before anything is committed: no secrets or credentials, no debug output, no conflict markers, no auto-generated files edited by hand, no accidental large or binary files.
   A finding here stops the commit and gets reported instead.
4. Write the message: conventional commit format, a lowercase type (`feat`, `fix`, `chore`, `refactor`, `docs`, `test`), a colon, then an imperative subject of 72 characters or less.
   Add a body explaining why when the change is not self-evident.
   Never add an agent name as co-author.
5. Commit and push to the current branch's upstream, setting upstream on first push.
   Never force-push.
6. Report: each commit hash and subject, the branch pushed, and anything deliberately left uncommitted with the reason.

## Judgement

- In a repo that delivers through pull requests, committing on the default branch is wrong; stop and suggest /ship.
- This skill does not run the quality gate.
  When the changes include non-trivial code and /patrol has not run this session, say so in the report and recommend it.
