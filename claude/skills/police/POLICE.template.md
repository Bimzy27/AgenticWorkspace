# Police rules

Behaviour rules enforced by the /police skill against every changeset in this project.

Format: each `##` heading is one rule, named in kebab-case.
Optional fields on the first lines under the heading:

- `Scope:` glob(s) limiting which changed files trigger the rule (default: all changes; `repo` means judge the whole repository).
- `Command:` a shell command; a non-zero exit means the rule is violated.

Everything else under the heading is the rule statement, judged by the agent against the diff.

The rules below are starter examples.
Replace them with what actually matters in this project.

## no-debug-output

Scope: src/**
No change may add debug printing (console.log, print, dbg!, Debug.WriteLine) outside dedicated logging modules.

## tests-accompany-behaviour

Any change that alters runtime behaviour must include or update an automated test that would fail without the change.

## no-secrets

No credentials, API keys, tokens, or connection strings may appear anywhere in the diff, including test fixtures and comments.

## no-silent-error-swallowing

Catch blocks and error branches must handle, propagate, or log the error; an empty catch or a bare `pass` is a violation.

## public-api-documented

Scope: src/**
New exported functions, classes, or endpoints must have doc comments describing purpose, parameters, and failure modes.

## endpoints-require-auth

Scope: src/**
Every new HTTP endpoint or message handler must pass through the project's auth middleware or explicitly document why it is public.
This is OWASP A01 (broken access control) made concrete; name your real middleware here.

## no-raw-sql-outside-repositories

Scope: src/**
Raw SQL strings and query builders are only allowed in the repository/data-access layer; everywhere else must go through it.
This is OWASP A03 (injection) made concrete; adjust the layer name to this project's architecture.

## validate-at-trust-boundaries

Scope: src/**
External input (request bodies, query params, webhook payloads, file uploads) must be validated with the project's schema library at the point of entry, not deep inside business logic.
Name the schema library this project uses here.
