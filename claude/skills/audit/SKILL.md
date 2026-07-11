---
name: audit
description: Scan dependencies for known vulnerabilities and the changeset for secrets. Use before shipping, when asked to audit or check dependencies, or as a stage of /patrol.
---

# Audit

Judge what the project depends on and what the changeset leaks, not the code's logic.
Code-level security review of the diff belongs to the harness's built-in /security-review, not this skill.

## Part 1: dependency vulnerabilities

Resolve the scanner by ecosystem and use the first match:

| Marker | Command |
|---|---|
| package-lock.json | `npm audit --audit-level=high` |
| pnpm-lock.yaml | `pnpm audit --audit-level high` |
| yarn.lock | `yarn npm audit --severity high` |
| pyproject.toml or requirements*.txt | `pip-audit` |
| Cargo.lock | `cargo audit` |
| go.mod | `govulncheck ./...` |
| *.sln or *.csproj | `dotnet list package --vulnerable --include-transitive` |
| any of the above, when `osv-scanner` is installed | `osv-scanner -r .` is an acceptable substitute |

If the matching tool is not installed, do not silently pass: report the stage as SKIPPED, name the tool to install, and continue.

Severity policy: high and critical findings fail the audit; moderate and low are reported but do not fail.

Fixing: prefer the smallest version bump that clears the finding, update the lockfile, and let the patrol test stage prove nothing broke.
Never jump a major version to clear a finding without flagging it; if the only fix is a major upgrade or there is no fixed release, report it for a human decision instead of forcing it.

## Part 2: secrets in the changeset

Scope: uncommitted changes plus commits on the current branch since merge-base with the default branch.

1. If `gitleaks` is installed, run it over that range (`gitleaks detect` with the appropriate range flags, plus `--no-git` staging scan for uncommitted work).
2. Otherwise, read the diff hunks yourself and look for credential patterns: private key blocks, cloud provider key formats, bearer tokens, connection strings with passwords, and high-entropy literals assigned to names like key, token, secret, or password.

Any hit fails the audit.
Remediation is removal plus a rotation warning to the user; moving a secret to .gitignore or an env file does not un-leak something already committed, so say so explicitly when history contains it.

## Report

List findings grouped by part, each with severity, package or file:line, and the fix applied or recommended.
Finish with a verdict line: `AUDIT: PASS`, `AUDIT: FAIL (N findings)`, or `AUDIT: SKIPPED (<missing tool>)`.
