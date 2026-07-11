# Inactive skills

Skills staged here are version-controlled but not loaded, because only `claude/skills/` is symlinked to `~/.claude/skills`.

To activate one:

```powershell
git mv claude/skills-inactive/<name> claude/skills/<name>
```

New Claude Code sessions pick it up automatically.

Currently staged:

- `next/` - autonomous-loop work intake (next, work, patrol, ship). Activate once the pipeline is ready for unattended operation.
