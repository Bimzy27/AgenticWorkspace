# Police rules

Behaviour rules enforced by the /police skill against every changeset in this project.

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

## idempotent-setup-scripts

Scope: setup.ps1, bootstrap/**, scripts/install-configs.ps1
Changes to setup scripts must keep them safe to re-run: guard creations, skip what is already installed, and never destroy user state that the script did not create.

## no-agent-coauthor

Commits in the changeset must not carry an agent name as co-author.

## edit-agents-md-not-symlinks

Scope: CLAUDE.md
`CLAUDE.md` is a symlink to `AGENTS.md` and must never be edited directly; the diff should only ever touch `AGENTS.md`.
