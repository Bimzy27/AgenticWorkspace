---
name: release
description: Promote the development branch into the release branch (e.g. develop into master) to trigger a production deployment. Use when asked to release, promote develop, or merge develop into master.
---

# Release

Promote proven work into the branch that production deploys from.
A release is outward-facing and hard to reverse, so this skill is deliberate where /commit is quick.

## Resolve the branch model

- Release branch: the repo default (master or main).
- Development branch: `develop` or `dev` if one exists.
- If the repo has no development branch, it does not use the promote flow; say so and suggest /ship or /commit instead.

## Steps

1. Preflight on the development branch: working tree clean, branch pushed, and /patrol green.
   Commit or shelve stray changes first via /commit; never release a dirty tree.
2. Show what would be released: `git log <release>..<develop> --oneline`, summarized in one or two sentences.
   If the user has not already asked for this specific release in this conversation, stop here and confirm before merging.
3. Merge: check out the release branch, pull it fresh, merge the development branch, push.
   A merge conflict stops the release; resolve it on the development branch, re-run preflight, and start again.
4. Watch the deploy when it is observable: a CI run, a Vercel or Railway deployment, a webhook.
   Confirm it started, and when the platform exposes status, confirm it finished green.
5. Return to the development branch so the next work does not land on the release branch by accident.

## Report

The commit range released, the deploy status with a link when available, and anything that should be smoke-tested in production.
