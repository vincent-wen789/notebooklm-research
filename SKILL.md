---
name: notebooklm-research
description: Run a 4-stage Claude × NotebookLM deep-research workflow with anti-hallucination guardrails. Use whenever the user wants deep research, competitor mapping, narrative ammunition, compliance scoping, industry decode, user-segment profile, trend study, or a research dossier with citations. Trigger on phrases like "深度调研", "做 mapping", "梳理 X", "弹药库", "竞品分析", "用户画像", "面试情报", "industry decode", "compliance scan", or "comprehensive write-up on X", even without explicit NotebookLM mention. Stages, (1) Deep Research search outline, (2) hard-skeleton Custom Instructions forcing inline [#N] citations + fact/opinion/inference tags + recency markers + 3-tier confidence + self-check, (3) variant-specific full CI to paste into Notebook Settings, (4) Tier A/B/C verification on returned report plus structured verdict. Guards against NotebookLM's three systemic failures, number hallucination, fact-opinion conflation, time-recency drift.
license: MIT
version: 2.3
---

# NotebookLM Research

A structured Claude × NotebookLM deep-research workflow. Walk the user through 4 stages and emit precise artifacts at each: search outline, NotebookLM Custom Instructions, variant-specific CI, and a structured verdict on the returned report.

The user typically wants this when they say "deep research on X", "mapping of crypto+AI hiring", "narrative ammunition for a script", "compliance scoping for importing X", or any "comprehensive write-up with sources I can trust" request — even when they do not name NotebookLM.

Full spec lives in [PLAYBOOK.md](./PLAYBOOK.md). Reusable building blocks live in [templates/](./templates/). This file is the executable workflow that wraps them.

---

## Output language · match the user (non-negotiable)

**Detect the user's language from their request and emit every artifact in it** — search outline, Custom Instructions, verdict, all of it. The templates in this repo are written in Chinese as the *canonical reference copy*; they are not a language mandate. When you emit:

1. Translate the human-readable scaffolding (section headers, instructions, field names) into the user's language.
2. Set the report's output language to **match the user**, not the template. The hard-skeleton ships in EN / ZH / JA at [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md) — pick the user's language; for any other language, translate it.
3. Keep the machinery markers (`[#N]`, the fact/opinion/inference tags, confidence tiers) but render the tag *words* in the user's language — e.g. `[fact]/[opinion]/[inference]` for English, `[事实]/[作者观点]/[推论]` for Chinese, `[事実]/[見解]/[推論]` for Japanese. Your Stage 4 grep then matches the same language.

Default to the user's language. Only fall back to Chinese if the user is clearly writing in Chinese or gives no signal.

## Two modes · full vs simple

This skill defaults to the **full 4-stage workflow** below (expert mode). If the user is clearly a non-power-user — they just want "better NotebookLM research," don't mention variants/verification/citations, or ask for "a simple version" — **skip straight to [`templates/simple-prompt.md`](./templates/simple-prompt.md)**: one plain-language prompt they paste into NotebookLM, no install, no variant selection, no Tier A/B/C. Emit it in their language. Offer the full workflow only if they want more.

---

## The Why · Three NotebookLM Failure Modes

Before starting, remember **why** this workflow exists. NotebookLM (and any LLM-driven research tool) has 3 systemic failures the SOP defends against:

1. **Number hallucination** — source A's number gets attributed to source B; "3.1 million" rewritten to "3.5 million" in synthesis
2. **Fact/opinion conflation** — the source author's subjective judgment gets written as fact
3. **Time-recency drift** — a 2024 source's "currently" passes through as today's "currently"

These can't be caught by "reading the report carefully" — humans miss things at scale. This workflow engineers the defense into the prompt (hard-skeleton CI) and into the SOP (Tier A/B/C verification on the returned report).

---

## Stage 1 · Pick variant and scale

Ask the user which variant and scale they want. Use the host's native question mechanism (AskUserQuestion in Claude Code, plain text prompt in Codex / other hosts).

**Variants** — codes aligned with [PLAYBOOK § 4](./PLAYBOOK.md) (Chinese; the framework column below inlines the same content so you don't need it at runtime). Full templates exist for **A1** and **B1** at [templates/](./templates/):

| Code | Use case | Output framework |
|------|----------|------------------|
| **A1** | Domain mapping — industry / company / tool / people scan. Default for "mapping of X" | entity map + 4-dimension scoring + priority ranking |
| A2 | Concept deep-dive — "help me really understand X" | 5W1H + evolution path + common misconceptions |
| A3 | Trend scan — "what happened in X these 6 months" | phenomenon + data + drivers + impact + outlook |
| A4 | Regulation-change tracking · policy environment | timeline + key changes + impact surface + response options |
| **B1** | Narrative ammunition — story/article research (adapt framing for counter-narrative / steelman) | archetypes + decision chains + psychology arcs + jargon + audience hooks |
| B2 | Historical retrospective — "what does 1929 teach us about Y" | timeline + key actors + turning points + lessons + modern mapping |
| C1 | Competitor analysis — "X vs Y" product scan | scored dimension matrix + differentiation + fit-by-scenario + takeaway |
| C2 | Tech / tool selection — "which X should I use" | performance + usability + ecosystem + trend + team fit |
| C3 | Pre-interview company intel | fundamentals + culture + interview patterns + salary range + verdict |
| D1 | User persona & reach — marketing · product fit | segments + pain points + preferences + channels + conversion path |
| E1 | Compliance scoping — "can I do X legally", incl. cross-jurisdiction | law-layer structure (statute / rules / directives) + liability + risk levels + practical path |
| F1 | Event timeline reconstruction — "what happened with X" | trigger + timeline + multi-party views + impact spread + follow-ups |

**Scale** (affects Stage 4 verification depth):

| Scale | Sources | Words | Numbers | Verification | Wall clock |
|-------|---------|-------|---------|--------------|------------|
| S | 10-15 | 3000-5000 | < 20 | Tier A 100% cross-ref · full | 15-30 min |
| **M** | 15-30 | 5000-10000 | 20-50 | Tier A 100% + Tier B 30% sample | 30-60 min |
| L | > 30 | > 10000 | > 50 | Split into multiple NotebookLM passes | 1-3 h |

Default: **M / A1**. Only ask the user explicitly if their request is clearly S or L, or if variant is ambiguous.

---

## Stage 2 · Emit the Deep Research search outline

Generate the search outline to paste into NotebookLM's **Deep Research** mode. This is **not** the Custom Instructions — Deep Research mode has no CI; it just collects sources.

Output structure (emit the whole block in the user's language):

```
NotebookLM Deep Research · search outline

[Topic + framing in 1-2 sentences]

Suggested keywords (bilingual if the user's context is multilingual):
  - [primary keywords]
  - [secondary keywords]
  - [adversarial keywords for triangulation]

Focus on:
  - [list of focal points specific to variant]

Scope limits:
  - Time window: [e.g., 2023-2026 if recency matters]
  - Source-type preference: primary > secondary > tertiary
  - Exclude: [e.g., re-posted commentary / known paywall-heavy domains]

Output requirement (paste at the end of the Deep Research prompt):
  "Return the source list with title + URL + publish date + type (primary/secondary/tertiary) + authority (high/mid/low)"
```

Tell the user: "Take this to NotebookLM Deep Research mode. When sources come back, audit them (drop low-quality / off-topic), then come back here for the Custom Instructions."

---

## Stage 3 · Emit the Custom Instructions

After the user audits sources, generate the variant-specific full CI for them to paste into **NotebookLM Notebook Settings → Custom Instructions** (permanent preset).

For variants A1 and B1, the full templates are ready at [`templates/ci-A1-mapping.md`](./templates/ci-A1-mapping.md) and [`templates/ci-B1-narrative.md`](./templates/ci-B1-narrative.md). Read the relevant file and emit the codeblock contents to the user — **translating the whole codeblock (role, output framing, tag words, hard requirements) into the user's language as you emit it**, per the Output-language rule above. The template files are the Chinese reference copy; do not paste Chinese CI to a non-Chinese user.

For the other 10 variants (A2-F1) no full template exists yet — build the CI ad-hoc (backfill policy: [PLAYBOOK § 10.3](./PLAYBOOK.md), Chinese):
1. Take the A1 template as base.
2. Adapt the "core framework" section to the variant's output framework from the Stage 1 table (e.g., for E1 compliance: replace the company matrix with a regulatory matrix — law source / regulator / violation consequences).
3. **Always** append the hard-skeleton from [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md) at the end. This is non-negotiable.

Emit:

```
NotebookLM Custom Instructions · [Variant code]

Paste this into Notebook Settings → Custom Instructions:

---8<--- begin CI ---8<---
[full CI here · including hard-skeleton at end]
---8<--- end CI ---8<---

Then run your research prompt as normal. NotebookLM will follow this CI as a permanent preset.

[Field definitions for the source table + self-check section · paste at the end of each report prompt as needed]
```

Field definitions for the source table and self-check section are in [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md). Reference them in your output.

Tell the user: "Paste this into Notebook Settings, run your research prompt, and bring the report back here for verification."

---

## Stage 4 · Verification + verdict

When the user returns with the NotebookLM report, run Tier A/B/C verification per [PLAYBOOK § 5 阶段三 3a](./PLAYBOOK.md). This is the **value layer** of this skill — where the 3 NotebookLM failure modes get caught.

### Step 1 · Parse the report structure

Verify presence of:
- Inline `[#N]` citations on facts/numbers/quotes
- Source reference table at the end (来源对照表 in Chinese reports)
- Self-check section, 4 blocks (自检 in Chinese reports)

If any are missing, **send the report back to the user**: "Ask NotebookLM to regenerate following the CI — it skipped the citation / source table / self-check." Do not proceed to verification.

### Step 2 · Tier A · Numbers (100% cross-ref)

Identify every decision-grade number (amounts / percentages / KPIs / version numbers / key dates). For each:
1. Find its `[#N]` reference.
2. Find the source in the source table.
3. **WebFetch the source URL** and grep for the exact number (or its quoted context, the ≤ 50-word source quote).
4. Mark:
   - ✅ cross-ref OK · number matches source
   - ⚠ cross-ref partial · close but not exact (e.g., "3.1M" vs "3.12M")
   - ❌ cross-ref FAIL · number not found in source
   - 🔒 paywall / 404 · source not accessible · mark `unverifiable`, do NOT pass it through as ✅

If WebFetch isn't available on the current host, tell the user: "Tier A automation needs WebFetch. Paste sources back manually or run this skill in Claude Code / Codex which both have it."

### Step 3 · Tier B · Time/dates (30% sample)

Sample 30% of the time markers (`as of YYYY-MM-DD`; `截至 YYYY-MM-DD` in Chinese reports). For each sampled, WebFetch the source and verify the date is consistent.

### Step 4 · Tier C · Named entities (grep)

Extract all named entities (people, companies, products, regulations, paper titles, institutions). For each:
1. Grep the source table for the entity.
2. If 0 hits → mark "potentially fabricated · needs manual check".
3. This catches the "NotebookLM gave me a paper called X by Y from Z institution" hallucination — see [PLAYBOOK § 8 Failure Mode 1](./PLAYBOOK.md) and [templates/ci-hard-skeleton.md](./templates/ci-hard-skeleton.md).

### Step 5 · Emit structured verdict

Use the template at [`templates/verdict-template.md`](./templates/verdict-template.md) (Chinese reference copy). Emit the verdict in the user's language:

```
NotebookLM report verification verdict (v2.3)

【scale】 S / M / L
【structure】 source table ✅/❌  self-check section ✅/❌
【citation density】 N per 1000 words (baseline ≥ 10)

【Tier A · decision numbers】
  total N / cross-ref OK X / needs fix Y / fetch failed Z

【Tier B · time markers】
  total N / sampled M / pass X / needs fix Y

【Tier C · named entities】
  in report N / in source table M / zero-hit K (needs manual check)

【self-check 4 blocks】
  unmet CI: ...
  no answer found: ...
  top-3 citation frequency: ...
  internal contradictions: ...

【overall】 ✅ ship / ⚠ ship after fixes / ❌ send back to NotebookLM to regenerate
```

### Step 6 · Anomaly detection (5 types)

After verdict, check whether any of these 5 anomalies fired. If yes, prompt the user to log it to their local research-anomaly log (or vault `log.md` if they use that style):

| Anomaly | Threshold | Why log |
|---------|-----------|---------|
| `fetch_low` | Tier A WebFetch success < 50% | Paywall / source quality signal |
| `wall_clock_2x` | Total verification > 2× scale estimate | Process complexity signal |
| `ci_blown` | CI was truncated or rejected by NotebookLM | Hard-skeleton size signal |
| `number_hallucination` | Tier A ❌ count > 0 with verifiable sources | NotebookLM defect |
| `selfcheck_missing` | ≥ 2 of 4 self-check blocks empty/skipped | NotebookLM defect |

Use [`templates/anomaly-log-entry.md`](./templates/anomaly-log-entry.md) as the entry template. Aggregation rule: ≥ 3 same-type entries → worth reviewing the workflow itself; isolated 1-2 → just log and move on.

---

## Cross-host notes

`SKILL.md` is a cross-agent open standard. **Native skill hosts** load this file directly:
- **Claude Code CLI** (`~/.claude/skills/notebooklm-research/`) — use AskUserQuestion for Stage 1 and TodoWrite to track stages
- **OpenAI Codex CLI** (`~/.codex/skills/notebooklm-research/`) — reads SKILL.md natively (since Dec 2025); no AskUserQuestion, use plain-text prompts; has WebFetch
- **Anthropic Agents SDK** (`~/.agents/skills/notebooklm-research/`) — plain-text prompts
- **Hermes** (`~/.hermes/skills/notebooklm-research/`) — autonomous mode: use defaults (M scale, A1 variant) unless the calling cron job overrides

**Rules-based agents** (Cursor / Windsurf / GitHub Copilot / Gemini CLI / Aider / Zed …) have no skill loader — they reach this workflow via a pointer in their `AGENTS.md` / `GEMINI.md` (see [`templates/agents-md-snippet.md`](./templates/agents-md-snippet.md)). When invoked that way you'll already be reading this file; just run the workflow. If the agent lacks WebFetch, do Stage 4 with whatever fetch tool it has, or hand verification back to the user.

When the host doesn't have a native question-asking tool, emit a plain text prompt in the user's language, e.g.:
```
Pick a variant (A1-F1) and a scale (S/M/L). Default: A1 / M.
```

When the host doesn't have WebFetch (Stage 4 Tier A), tell the user: "Paste sources back here for manual verification, or run this skill in Claude Code / Codex which both support WebFetch."

---

## When NOT to invoke this skill

- Vague requests like "tell me about X" → use plain web search / WebFetch instead
- Single-source short answers → direct lookup is faster
- Personal decisions (offer comparison / career choice) → owner brain dump beats research
- Already-known information from owner's vault / memory → check vault first

---

## See also

- [PLAYBOOK.md](./PLAYBOOK.md) — full spec (Chinese-only for now) · 12 variants · S/M/L scale matrix · 5-anomaly mechanism
- [templates/](./templates/) — copy-paste-ready blocks
- [CHANGELOG.md](./CHANGELOG.md) — version history (v1 → v2.3)
