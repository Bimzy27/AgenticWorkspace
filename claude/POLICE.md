# Global police rules

Fallback behaviour rules enforced by the /police skill in repos that have no POLICE.md of their own.
This file lives in the AgenticWorkspace repo as `claude/POLICE.md` and is symlinked to `~/.claude/POLICE.md`; edit it in the repo, never via the symlink.
A repo's own POLICE.md replaces these rules entirely, so repo files should carry over any of these rules that still apply.

Format: each `##` heading is one rule, named in kebab-case.
Optional fields on the first lines under the heading:

- `Scope:` glob(s) limiting which changed files trigger the rule (default: all changes; `repo` means judge the whole repository).
- `Command:` a shell command; a non-zero exit means the rule is violated.

Everything else under the heading is the rule statement, judged by the agent against the diff.

## no-em-dash

No change may introduce an em dash (U+2014) in any file; use a plain dash instead.
Box-drawing characters in script banners are not em dashes and are fine.

## markdown-sentence-per-line

Scope: **/*.md
New or substantially edited Markdown puts each full sentence on its own physical line.

## no-agent-coauthor

Commits in the changeset must not carry an agent name as co-author.

## no-secrets

No credentials, API keys, tokens, or connection strings may appear anywhere in the diff, including test fixtures and comments.

## no-manual-changelog-edits

Scope: **/CHANGELOG.md
Auto-generated files such as CHANGELOG.md are never edited by hand; changes to them must come from the generating tool.
