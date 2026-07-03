# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**Make NotebookLM catch its own hallucinations: fabricated citations, silent number drift, and time-confused "currently" conclusions.** A 4-stage research workflow you can paste in by hand or install as an agent skill — every report ships with a structured verdict, not pass-by-vibes.

> **Brutally honest**: if ChatGPT Deep Research or Perplexity Pro already work for you, you probably don't need this. Those tools look stable because their failure modes don't break loudly — you never see a "I made this citation up" warning. This skill is for people who've been burned by that kind of silent error.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.3-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/install-Claude_Code_%7C_Codex_%7C_Cursor_%7C_Windsurf_%7C_Copilot_%7C_Gemini-7C3AED)](#install--native-skill-hosts-claude-code--codex)

**What you need:** [NotebookLM](https://notebooklm.google.com) (free with a Google account). That's it for the zero-install path below. The full 4-stage workflow additionally needs an AI coding agent — [Claude Code](https://claude.com/claude-code), Codex, Cursor, etc. (typically from ~$20/mo, varies by tool) — and a terminal to install into it.

## The problem

NotebookLM is a good tool on its own. But bare NotebookLM has 3 systematic distortions that **a human reading the report cannot reliably catch**:

1. **Number hallucinations**: source A's "3.1 million" gets attributed to source B; paraphrase drifts it to "3.5 million"
2. **Fact / opinion conflation**: a source author's judgment call ("market is overheated") gets written as a fact
3. **Temporal drift**: the source says "currently" about 2024, NotebookLM also writes "currently"

ChatGPT Deep Research and Perplexity share the same failure class, just hidden behind nicer UI. Most automation wrappers (LangChain, GPT Researcher, generic agents) skip the verification layer entirely: they synthesize and ship. They look stable because nothing breaks loudly. The breakage is silent — the report you're about to make a decision from has subtly wrong numbers.

This project doesn't try to fix every tool. It makes NotebookLM, one specific tool, catch its own failure modes.

## Don't want to install? Try the magic prompt first

Open [NotebookLM](https://notebooklm.google.com), open your notebook, go to **Notebook Settings → Custom Instructions**, and paste this. Zero install:

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

**What the paste gets you**: citation and labeling discipline — NotebookLM's output quality jumps immediately. **What it can't do alone**: the automated Stage 4 cross-check that catches fabricated papers and drifted numbers. That part needs an agent running the skill (install below). Rule-of-thumb on the two versions: the 4-rule one keeps the same core protections (sources, opinion labels, full dates, single-source flags); the 6-rule one adds the stricter notation that the automated verification reads. This paste is one piece — Stage 3's core rules — of the full 4-stage workflow.

Before vs after:

- **Before**: NotebookLM outputs "the mainstream solution in the industry currently is XYZ", citations smashed together, facts and opinions mixed, hallucinated numbers
- **After**: every claim carries `[#N]`, labeled `[fact]` / `[opinion]` / `[inference]`, dated `as of YYYY-MM-DD ([#N] publish date)`, three-tier confidence

## Key differentiators

- **Not another deep-research wrapper**. NotebookLM does the heavy lifting (15-30 sources, long-context synthesis — that's its core strength). This skill wraps a compact Custom Instructions block around it, forcing inline citations on every claim, fact / opinion / inference labels, and a three-tier confidence score.
- **Numbers get cross-referenced, not eyeballed**. You hand the finished report back and Stage 4 runs Tier A / B / C verification: every decision-grade number reverse-checked against its source by web fetch, time markers sampled, named entities cross-checked against the source list. Paywall failures get marked `unverifiable` instead of being faked as verified. Note the honest scope: the workflow itself is a human-in-the-loop paste-and-hand-back loop; the cross-check is the automated part.
- **Failure modes caught from real incidents**. From actual vault captures ([the receipt, with original notes](./examples/fabricated-source-catch.md)): NotebookLM-fabricated papers like "Talos: Anatomy of Bitcoin ETF" and "Amberdata: Microstructure of Taker BSR" (both 404, but they look like real papers with author and institution attached), a "3.1 million" silently drifted to "3.5 million" in paraphrase, a 2024 "currently" treated as today's "currently". This skill flags all of them.
- **Install across your stack**. Native `SKILL.md` hosts (Claude Code, Codex, Agents SDK, Hermes) get an auto-detecting installer; rules-based agents (Cursor, Windsurf, Copilot, Gemini, Aider) get a one-line paste-in pointer. Single source-of-truth, `git pull` updates everywhere.
- **Incident-driven iteration, not whiteboarding**. Personal vault methodology iterated v1 → v2.3 with every patch traceable to a real failure — the receipts are in the [CHANGELOG](./CHANGELOG.md).

## Install · native skill hosts (Claude Code · Codex)

`SKILL.md` is a cross-agent open standard. The installer auto-detects the hosts that read it natively and symlinks the skill into each. Run this **in your terminal** (macOS / Linux; on Windows use WSL or Git Bash):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
```

- `~/.claude/skills/` · **Claude Code CLI**
- `~/.codex/skills/` · **OpenAI Codex CLI** — reads `SKILL.md` natively since Dec 2025
- `~/.agents/skills/` · Anthropic Agents SDK
- `~/.hermes/skills/` · Hermes *(a personal autonomous-agent runtime — skip if you don't run it)*

Source-of-truth lives at `~/.local/share/notebooklm-research/`; one `git pull` updates every host; `./install.sh --uninstall` removes everything cleanly.

Flags: `--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force` · `--print-agents-snippet`

**Verify it worked**: open your agent and type `/notebooklm-research "test"` — you should get the Stage 1 variant/scale question.

## Install · other agents (Cursor · Windsurf · Copilot · Gemini · Aider …)

These agents have **no skill concept** — they only read an always-on instructions file, so a symlinked `SKILL.md` does nothing. Instead, paste a short *pointer* into that file (the agent then reads the full workflow on demand, near-zero context cost).

**Step 0 · get the files on disk.** The pointer references the skill's files, so fetch them once (also in your terminal). On a machine with no native skill host the installer just clones the source to `~/.local/share/notebooklm-research/` and points you here:

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

After install, in your agent (not in NotebookLM):

```
/notebooklm-research "<your research topic>"
```

Or just natural language: "do a hiring mapping for crypto+AI startups", "build the ammunition for the X vertical", "run a compliance scan for shipping X into Japan" — the skill picks these intents up automatically, **you don't need to mention NotebookLM**.

## What it feels like

Heads-up on the shape of the loop: **your agent and NotebookLM never talk to each other directly** — at each stage the skill emits an artifact, you paste it into NotebookLM, and you bring NotebookLM's output back. The automated part is the verification math, not the ferrying.

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
【Tier B · time markers】    total 9 / sampled 3 / pass 3
【Tier C · named entities】  in report 23 / in source list 21 / zero-hit 2
                             (unverified: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【overall】 ⚠ ship after fixes
```

Plus 5 anomaly auto-detectors: fetch success < 50% · verification taking > 2× the scale estimate · CI truncated or ignored by NotebookLM · number hallucination · self-check missing ≥ 2 blocks. Any hit gets logged so you can track NotebookLM's behavior over time.

**Time budget, honestly**: a full loop = NotebookLM's own Deep Research run + your source audit + Stage 4 verification. Verification alone is roughly 15-30 min at S scale, 30-60 min at M, hours at L (that's what the scale tiers are for).

## How it compares

| Tool | Depth | Citation discipline | Number cross-ref | Cost |
|------|-------|---------------------|------------------|------|
| ChatGPT Deep Research | Mid | Weak (has citations but still hallucinates) | ❌ | $20/mo |
| Perplexity Deep Research | Mid | Weak | ❌ | $20/mo |
| GPT Researcher · similar wrappers | Low (shallow synthesis) | None | ❌ | self-host |
| Your agent alone (Claude / GPT + web search) | Low-mid (handful of sources per run) | Mid (cites what it fetched) | ❌ | what you already pay |
| Bare NotebookLM | High (long-context synthesis) | None (3 distortions undefended) | ❌ | free (Plus optional) |
| **NotebookLM + this skill** | **High** | **Enforced: inline `[#N]` + fact/opinion/inference labels + as-of dates + confidence tiers** | **✅ Tier A/B/C automated** | **skill free (MIT)** |

Cost fine print: NotebookLM's free tier caps Deep Research runs per day (limits change — check current ones); S/M scale fits comfortably. Stage 4 runs on your own agent's usage, which you're already paying for.

This skill is not a replacement for deep-research tools. It makes NotebookLM, one specific tool, catch its own failure modes.

## 12 variant frameworks (A1 · B1 templated · 10 scaffolded)

| Family | Codes | Use case |
|--------|-------|----------|
| A · Cognitive expansion | A1 domain mapping · A2 concept deep-dive · A3 trend scan · A4 regulation-change tracking | "map the X industry" · "the full picture of Y" |
| B · Narrative | B1 narrative ammunition · B2 historical retrospective | story/article research · "what does 1929 teach us about Y" |
| C · Decision support | C1 competitor analysis · C2 tech/tool selection · C3 pre-interview company intel | "X vs Y" · "which stack" · interview prep |
| D · Market research | D1 user persona + reach | product-launch user research |
| E · Compliance | E1 cross-jurisdiction compliance primer | "can I legally do X in market Y" |
| F · Timeline | F1 event timeline reconstruction | "what actually happened with X" |

Full A1 · B1 templates, the hard skeleton, verdict and anomaly-log formats are in [`templates/`](./templates/). The other 10 framework definitions live in [PLAYBOOK § 4](./PLAYBOOK.md) (Chinese — agents translate on the fly; the skill embeds the same table in English). Fork and modify, or open a PR to fill out a template.

## Repo layout

```
notebooklm-research/
├── SKILL.md              ← the skill itself (hosts read this · English)
├── install.sh            ← cross-host install script
├── README.md             ← English (you are here)
├── README.zh.md          ← 中文
├── README.ja.md          ← 日本語
├── PLAYBOOK.md           ← full spec (deep reference · Chinese-only for now)
├── CHANGELOG.md          ← v1 → v2.3
├── templates/            ← templates (CI · verdict · anomaly-log · paste-ready)
├── examples/             ← real captures (fabricated-paper catch, original notes)
└── LICENSE               ← MIT
```

## Maintenance cadence

Personal vault workflow · bi-weekly maintenance · shared as-is. Issue response not guaranteed · PRs welcome but merge cadence depends on owner.

## Related projects

[ORP (Obsidian RAG Protocol)](https://github.com/vincent-wen789/obsidian-rag-protocol) · ORP is the vault → AI agent state/memory protocol. This skill is the research handoff workflow spec. Adjacent but decoupled.

## License

MIT
