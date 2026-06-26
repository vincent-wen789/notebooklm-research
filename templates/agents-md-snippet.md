# Install on rules-based agents (Cursor · Windsurf · Copilot · Gemini · Aider …)

Codex and Claude Code read `SKILL.md` natively — the `install.sh` script handles those. But many agents have **no skill concept**; they only read an always-on instructions file. For those, paste the short pointer below into that file. It's a *pointer*, not the whole workflow — the agent reads the full `SKILL.md` on demand, so it costs almost no context.

## The pointer block

```md
## Deep research (NotebookLM workflow)
When the user wants deep research, an industry/competitor mapping, narrative ammunition, a compliance scan, a user-persona profile, or "a write-up with sources I can trust" — read and follow `~/.local/share/notebooklm-research/SKILL.md` (the full 4-stage workflow). For a quick no-setup version, hand them `~/.local/share/notebooklm-research/templates/simple-prompt.md`. Emit all output in the user's language.
```

> Adjust the path if you cloned the repo somewhere else. `~/.local/share/notebooklm-research` is where `install.sh` puts the source-of-truth.

## Where each agent reads it

| Agent | Paste the block into | Scope |
|-------|----------------------|-------|
| **Cursor** | project `AGENTS.md` *(or `.cursor/rules/notebooklm.md`)* | per-project |
| **Windsurf** | project `AGENTS.md` *(or `.windsurfrules`)* | per-project |
| **GitHub Copilot** | `.github/copilot-instructions.md` *(or `AGENTS.md`)* | per-project |
| **Aider** | `AGENTS.md` *(or `CONVENTIONS.md`)* | per-project |
| **Zed · Jules · Amp · Devin · JetBrains Junie · VS Code** | project `AGENTS.md` | per-project |
| **Gemini CLI** | `GEMINI.md` | project / global |

`AGENTS.md` is the [Linux-Foundation-stewarded open standard](https://agents.md/) most of these read natively, so one paste usually covers your whole stack. Gemini is the main exception — it wants `GEMINI.md`.

## One-liner

From inside a project, append the pointer to its `AGENTS.md`:

```bash
sed -n '/^## Deep research/,/Emit all output/p' ~/.local/share/notebooklm-research/templates/agents-md-snippet.md >> ./AGENTS.md
```

(`install.sh --print-agents-snippet` prints just the block to stdout if you'd rather pipe it yourself.)
