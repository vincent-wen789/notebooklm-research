# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**A cross-host Claude × NotebookLM deep-research skill that catches the 3 AI hallucinations NotebookLM hides from you: fabricated citations · silent number drift · time-confused "currently" conclusions.** 4-stage workflow · every report ships with a structured verdict · not pass-by-vibes.

> **Brutally honest**: if ChatGPT Deep Research or Perplexity Pro already work for you, you probably don't need this. Those tools look stable because their failure modes don't break loudly · you don't see a "I made this citation up" warning. This skill is for people who've been burned by that kind of silent error.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.2-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/install-Claude_Code_%7C_Codex_%7C_Cursor_%7C_Windsurf_%7C_Copilot_%7C_Gemini-7C3AED)](#install--native-skill-hosts-claude-code--codex)

### Key differentiators

- **Not another deep-research wrapper**. NotebookLM does the heavy lifting (15-30 sources, long-context synthesis · that's its core strength). This skill wraps a compact Custom Instructions block around it, forcing NotebookLM to put inline citations on every claim, label fact / opinion / inference, and tag a three-tier confidence score.
- **Numbers get cross-referenced, not eyeballed**. You hand the finished report back and Stage 4 runs Tier A / B / C verification: 100% WebFetch reverse-check on decision numbers · 30% sample on time markers · grep cross-check on named entities against the source list · paywall failures get marked `unverifiable` instead of being faked as verified. (The workflow itself is a human-in-the-loop paste-and-hand-back loop; the cross-check is the automated part.)
- **Catches what ChatGPT / Perplexity miss**. From actual vault captures: NotebookLM-fabricated papers like "Talos: Anatomy of Bitcoin ETF" and "Amberdata: Microstructure of Taker BSR" (both 404 · look like real papers with author and institution attached) · a "3.1 million" silently drifted to "3.5 million" in paraphrase · a 2024 "currently" treated as today's "currently" · this skill flags all of them.
- **Install across your stack**. Native `SKILL.md` hosts (Claude Code · Codex · Agents SDK · Hermes) get an auto-detecting installer; rules-based agents (Cursor · Windsurf · Copilot · Gemini · Aider) get a one-line paste-in pointer. Single source-of-truth · `git pull` updates everywhere.
- **Bi-weekly maintenance · 1-year-old SOP in production**. Personal vault methodology iterated v1 → v2.0 → v2.1 plus three rounds of patches. Not a startup wrapper. The 5 anomaly categories are forged from real incidents, not whiteboarded.

---

## The problem

NotebookLM is a good tool on its own. But bare NotebookLM has 3 systematic distortions that **a human reading the report cannot reliably catch**:

1. **Number hallucinations**: source A's "3.1 million" gets attributed to source B; paraphrase drifts it to "3.5 million"
2. **Fact / opinion conflation**: a source author's judgment call ("market is overheated") gets written as a fact
3. **Temporal drift**: the source says "currently" about 2024, NotebookLM also writes "currently"

ChatGPT Deep Research and Perplexity have the same problems, just hidden behind nicer UI. Most automation wrappers on the market (LangChain · GPT Researcher · generic agents) skip the verification layer entirely · they synthesize and ship. They look stable because nothing breaks loudly. The breakage is silent: the report you're about to make a decision from has subtly wrong numbers.

## Don't want to install? Try the magic prompt first

Paste this into NotebookLM Notebook Settings → Custom Instructions, zero install:

```
## Sourcing & verifiability (hard requirements)
1. End every fact / number / quote with [#N] (maps to the source table at the end)
2. Each number (amount / % / date / count / version) gets its own [#N · source quote ≤ 50 words] — never share one across several
3. Prefix every statement with exactly one of [fact] / [opinion] / [inference]
4. Write time as "as of YYYY-MM-DD ([#N] publish date)" — never "currently / latest"
5. Confidence: [high · 2+ sources] / [mid · single source] / [low · inference or conflict]
6. End the report with two tables (field defs in the report prompt):
   - source table
   - self-check section (4 blocks: unmet CI / no answer found / top-3 citation frequency / internal contradictions)
```

**Not a coder? This paste step is the whole thing for you — skip everything below.** If those 6 rules look like a lot, here's the plain-language 4-rule version (no `[#N]`, no jargon) — paste this instead:

```
For everything you write in this notebook:
1. Put a [1], [2], [3]… after every fact, number, or quote, and list the matching source (title + link) at the very end.
2. If a sentence is someone's opinion or your own guess, start it with "Opinion:" or "Guess:" — never write those as plain fact.
3. Write dates in full, like "as of March 2025…", instead of "currently" or "recently".
4. If only one source backs a claim, add "(single source)" so I know it's not confirmed.
```

Same block in 中文 / 日本語: [`templates/simple-prompt.md`](./templates/simple-prompt.md). The fuller 6-rule version ships in EN / ZH / JA at [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md).

Before vs after:

- **Before**: NotebookLM outputs "the mainstream solution in the industry currently is XYZ", citations smashed together, facts and opinions mixed, hallucinated numbers
- **After**: every claim carries `[#N]` · labeled `[fact]` / `[opinion]` / `[inference]` · `as of YYYY-MM-DD ([#N] publish date)` · three-tier confidence

This is just a fragment of Stage 2 from the skill's full 4-stage workflow · use it standalone and NotebookLM's output quality jumps immediately. Install the skill and you also get: Stage 1 auto-variant selection (11 types · A1 mapping / B1 narrative / C1 compliance etc.) · Stage 4 automatic Tier A/B/C number cross-check · fabricated-paper detection (see "What it feels like" below).

## Install · native skill hosts (Claude Code · Codex)

`SKILL.md` is now a cross-agent open standard. The installer auto-detects the hosts that read it natively and symlinks the skill into each:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
```

- `~/.claude/skills/` · **Claude Code CLI**
- `~/.codex/skills/` · **OpenAI Codex CLI** — reads `SKILL.md` natively since Dec 2025
- `~/.agents/skills/` · Anthropic Agents SDK
- `~/.hermes/skills/` · Hermes *(a personal autonomous-agent runtime — skip if you don't run it)*

Source-of-truth lives at `~/.local/share/notebooklm-research/` · one `git pull` updates every host · `./install.sh --uninstall` removes everything cleanly.

Flags: `--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force` · `--print-agents-snippet`

## Install · other agents (Cursor · Windsurf · Copilot · Gemini · Aider …)

These agents have **no skill concept** — they only read an always-on instructions file, so a symlinked `SKILL.md` does nothing. Instead, paste a short *pointer* into that file (the agent then reads the full workflow on demand, near-zero context cost).

**Step 0 · get the files on disk.** The pointer references the skill's files, so fetch them once. The installer is harmless on a machine with no native skill host — it just clones the source to `~/.local/share/notebooklm-research/`:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
# or, no installer: git clone https://github.com/vincent-wen789/notebooklm-research ~/.local/share/notebooklm-research
```

**Step 1 · append the pointer to your project's instructions file:**

```bash
# from inside your project — appends the pointer to AGENTS.md
sed -n '/^## Deep research/,/Emit all output/p' ~/.local/share/notebooklm-research/templates/agents-md-snippet.md >> ./AGENTS.md
```

| Agent | File it reads |
|-------|---------------|
| Cursor · Windsurf · Aider · Zed · Jules · Amp · Devin · JetBrains Junie · VS Code | project `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` *(or `AGENTS.md`)* |
| Gemini CLI | `GEMINI.md` |

`AGENTS.md` is the [Linux-Foundation open standard](https://agents.md/) most of these read, so one paste usually covers your whole stack. Full details + the raw block: [`templates/agents-md-snippet.md`](./templates/agents-md-snippet.md) (or run `install.sh --print-agents-snippet`).

**What actually runs here.** Stages 1-3 (the prompts NotebookLM uses) work on any agent — that's most of the value. Stage 4's automated number cross-check needs a web-fetch tool: agents that have one (Cursor, Codex, etc.) run it; if yours doesn't, you still get the citation-disciplined report and verify the flagged numbers by hand. The interactive variant pick (Stage 1) falls back to a plain text prompt on agents without a native question UI.

## One-liner

After install, on any host:

```
/notebooklm-research "<your research topic>"
```

Or just natural language: "do a hiring mapping for crypto+AI startups" · "build the ammunition for the X vertical" · "run a compliance scan for shipping X into Japan" · the skill picks these intents up automatically, **you don't need to mention NotebookLM**.

## What it feels like

You install once. Then you say:

```
/notebooklm-research "Crypto+AI startup 2026 hiring mapping"
```

The skill walks through 4 stages:

**Stage 1 · variant + scale**. Default A1 (mapping) + M scale (15-30 sources). Only asks if your topic clearly leans S or L.

**Stage 2 · search outline**. The skill emits a search outline you paste into NotebookLM **Deep Research mode**:

```
NotebookLM Deep Research · search outline
[topic + bilingual keywords + scope limits + source-type preferences + output requirements]
```

NotebookLM runs and returns its source list. You scan it and cut low-quality or off-topic ones.

**Stage 3 · Custom Instructions**. Once the source list is approved, the skill emits the variant-specific CI (including the hard skeleton, in your language):

```
## Sourcing & verifiability (hard requirements)
1. End every fact / number / quote with [#N]
2. Each number gets its own [#N · source quote ≤ 50 words] — never shared
3. Prefix every statement with one of [fact] / [opinion] / [inference]
...
```

Paste it into NotebookLM **Notebook Settings → Custom Instructions** (persistent preset). Every future report from this notebook follows these rules.

**Stage 4 · final cross-check**. You hand the finished report back to the skill. It runs Tier A / B / C verification and emits a structured verdict:

```
【Tier A · decision numbers】 total 12 / cross-ref OK 9 / needs fix 1 / fetch failed 2 (paywall)
【Tier C · named entities】 in report 23 / in source list 21 / zero-hit 2
                            (unverified: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【overall】 ⚠ ship after fixes
```

Plus 5 anomaly auto-detectors: fetch <50% · wall-clock >2× · CI breach · number hallucination · self-check missing ≥ 2 blocks · any hit gets logged so you can track NotebookLM's behavior over time.

## How it compares

| Tool | Depth | Citation discipline | Number cross-ref | Cost |
|------|-------|---------------------|------------------|------|
| ChatGPT Deep Research | Mid | Weak (has citations but still hallucinates) | ❌ | $20/mo |
| Perplexity Deep Research | Mid | Weak | ❌ | $20/mo |
| GPT Researcher · similar wrappers | Low (shallow synthesis) | None | ❌ | self-host |
| Bare NotebookLM | High (long-context synthesis) | None (3 distortions undefended) | ❌ | free (Plus $20/mo optional) |
| **NotebookLM + this skill** | **High** | **4-layer enforced defense** | **✅ Tier A/B/C automated** | **Free** (skill free + NotebookLM free tier is enough) |

This skill is not a replacement for deep-research tools. It makes NotebookLM, one specific tool, catch its own failure modes.

## 11 variant frameworks (A1 · B1 templated · 9 scaffolded)

| Family | Codes | Use case |
|--------|-------|----------|
| A · Mapping | A1, A2, A3, A4 | Industry · tool · region · person mapping |
| B · Narrative | B1, B2 | Story ammunition · counter-narrative |
| C · Compliance | C1, C2, C3 | Regulation · standard · policy primer |
| D · Timeline | D1 | Event timeline |
| E · Cross-jurisdiction | E1 | Multi-region compliance |
| F · User persona | F1 | User persona · marketing |

Full A1 · B1 templates · hard skeleton · verdict · anomaly-log are in [`templates/`](./templates/). The other variant frames live in [PLAYBOOK § 10.3+](./PLAYBOOK.md) · fork and modify, or open a PR to fill them out.

## Repo layout

```
notebooklm-research/
├── SKILL.md              ← the skill itself (hosts read this)
├── install.sh            ← cross-host install script
├── README.md             ← English (you are here)
├── README.zh.md          ← 中文
├── README.ja.md          ← 日本語
├── PLAYBOOK.md           ← v2.2 full spec (deep reference · 624 lines)
├── CHANGELOG.md          ← v1 → v2.0 → v2.1 → v2.2
├── templates/            ← templates (CI · verdict · anomaly-log · paste-ready)
└── LICENSE               ← MIT
```

## Maintenance cadence

Personal vault workflow · bi-weekly maintenance · shared as-is. Issue response not guaranteed · PRs welcome but merge cadence depends on owner.

## Related projects

[ORP (Obsidian RAG Protocol)](https://github.com/vincent-wen789/obsidian-rag-protocol) · ORP is the vault → AI agent state/memory protocol. This skill is the research handoff workflow spec. Adjacent but decoupled.

## License

MIT
