---
name: notebooklm-research
description: Run a 4-stage Claude × NotebookLM deep-research workflow with anti-hallucination guardrails. Use whenever the user wants deep research, competitor mapping, narrative ammunition, compliance scoping, industry decode, user-segment profile, trend study, or a research dossier with trustworthy citations. Trigger on phrases like "深度调研", "做 mapping", "梳理 X", "弹药库", "竞品分析", "用户画像", "面试情报", "industry decode", "compliance scan", or "comprehensive write-up on X", even without explicit NotebookLM mention. Stages, (1) Deep Research search outline, (2) 301-char hard-skeleton Custom Instructions forcing inline [#N] citations + fact/opinion/inference tags + recency markers + 3-tier confidence + self-check, (3) variant-specific full CI to paste into Notebook Settings, (4) Tier A/B/C verification on returned report (numbers 100% cross-ref, dates 30% sample, entities grep, paywall failures flagged) plus structured verdict. Guards against NotebookLM's three systemic failures, number hallucination, fact-opinion conflation, time-recency drift.
license: MIT
version: 2.1
---

# NotebookLM Research

A structured Claude × NotebookLM deep-research workflow. Walk the user through 4 stages and emit precise artifacts at each: search outline, NotebookLM Custom Instructions, variant-specific CI, and a structured verdict on the returned report.

The user typically wants this when they say "deep research on X", "mapping of crypto+AI hiring", "narrative ammunition for a script", "compliance scoping for importing X", or any "comprehensive write-up with sources I can trust" request — even when they do not name NotebookLM.

Full spec lives in [PLAYBOOK.md](./PLAYBOOK.md). Reusable building blocks live in [templates/](./templates/). This file is the executable workflow that wraps them.

---

## The Why · Three NotebookLM Failure Modes

Before starting, remember **why** this workflow exists. NotebookLM (and any LLM-driven research tool) has 3 systemic failures the SOP defends against:

1. **Number hallucination** — source A's number gets attributed to source B; "3.1 million" rewritten to "3.5 million" in synthesis
2. **Fact/opinion conflation** — the source author's subjective judgment gets written as fact
3. **Time-recency drift** — a 2024 source's "currently" passes through as today's "currently"

These can't be caught by "reading the report carefully" — humans miss things at scale. This workflow engineers the defense into the prompt (301-char hard-skeleton CI) and into the SOP (Tier A/B/C verification on the returned report).

---

## Stage 1 · Pick variant and scale

Ask the user which variant and scale they want. Use the host's native question mechanism (AskUserQuestion in Claude Code, plain text prompt in Codex / other hosts).

**Variants** (full templates at [templates/](./templates/) and [PLAYBOOK § 10](./PLAYBOOK.md)):

| Code | Use case | When to pick |
|------|----------|--------------|
| **A1** | Industry/company mapping · job search · competitor scan | Most common · default for "mapping of X" |
| A2 | Tool selection · stack comparison | "which X should I use" |
| A3 | Region/market mapping | "what's the X scene in Japan" |
| A4 | People mapping · who's who | "who are the key players in X" |
| **B1** | Narrative ammunition · story/article research | Creative · narrative-driven |
| B2 | Counter-narrative · steelman | Debate prep · adversarial framing |
| **C1** | Compliance scoping · regulation scan | "can I do X legally" |
| C2 | Standards/spec scoping | Technical compliance |
| C3 | Policy environment scoping | Political/regulatory context |
| D1 | Event timeline reconstruction | "what happened with X" · chronological |
| E1 | Cross-jurisdiction compliance | Multi-region legal scoping |
| F1 | User segment profile · persona research | Marketing · product fit |

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

Output structure:

```
NotebookLM Deep Research · 搜索大纲

[Topic + framing in 1-2 sentences]

关键词建议 (bilingual if user context is multilingual):
  - [primary keywords]
  - [secondary keywords]
  - [adversarial keywords for triangulation]

重点关注:
  - [list of focal points specific to variant]

范围限制:
  - 时间窗口: [e.g., 2023-2026 if recency matters]
  - 信源类型偏好: 一手 > 二手 > 三手
  - 排除: [e.g., 自媒体复述 / 已知 paywall 重灾区]

输出要求 (paste into Deep Research prompt末尾):
  "返回来源列表 · 含标题 + URL + 发布日期 + 类型 (一手/二手/三手) + 权威度 (高/中/低)"
```

Tell the user: "Take this to NotebookLM Deep Research mode. When sources come back, audit them (drop low-quality / off-topic), then come back here for the Custom Instructions."

---

## Stage 3 · Emit the Custom Instructions

After the user audits sources, generate the variant-specific full CI for them to paste into **NotebookLM Notebook Settings → Custom Instructions** (permanent preset).

For variants A1 and B1, the full templates are ready at [`templates/ci-A1-mapping.md`](./templates/ci-A1-mapping.md) and [`templates/ci-B1-narrative.md`](./templates/ci-B1-narrative.md). Read the relevant file and emit the codeblock contents to the user.

For other variants (A2-F1), the framework is in [PLAYBOOK § 10.3+](./PLAYBOOK.md). If the template is still a stub, do this:
1. Take the A1 template as base.
2. Adapt the "core framework" section to the variant (e.g., for C1 compliance: replace "competitor matrix" with "regulatory matrix · 法源 / 主管 / 违反后果").
3. **Always** append the 301-char hard-skeleton from [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md) at the end. This is non-negotiable.

Emit:

```
NotebookLM Custom Instructions · [Variant code]

Paste this into Notebook Settings → Custom Instructions:

---8<--- begin CI ---8<---
[full CI here · including 301-char hard-skeleton at end]
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
- Source reference table (来源对照表) at the end
- Self-check section (自检 section · 4 blocks)

If any are missing, **send the report back to the user**: "Ask NotebookLM to regenerate following the CI — it skipped the citation / source table / self-check." Do not proceed to verification.

### Step 2 · Tier A · Numbers (100% cross-ref)

Identify every decision-grade number (金额 / 比例 / KPI / 版本号 / 关键日期). For each:
1. Find its `[#N]` reference.
2. Find the source in the source table.
3. **WebFetch the source URL** and grep for the exact number (or its quoted context · 原文引述 ≤ 50 字).
4. Mark:
   - ✅ cross-ref OK · number matches source
   - ⚠ cross-ref partial · close but not exact (e.g., "3.1M" vs "3.12M")
   - ❌ cross-ref FAIL · number not found in source
   - 🔒 paywall / 404 · source not accessible · mark `unverifiable`, do NOT pass it through as ✅

If WebFetch isn't available on the current host, tell the user: "Tier A automation needs WebFetch. Paste sources back manually or run this skill in Claude Code / Codex which both have it."

### Step 3 · Tier B · Time/dates (30% sample)

Sample 30% of the time markers (`截至 YYYY-MM-DD`). For each sampled, WebFetch the source and verify the date is consistent.

### Step 4 · Tier C · Named entities (grep)

Extract all named entities (people, companies, products, regulations, paper titles, institutions). For each:
1. Grep the source table for the entity.
2. If 0 hits → mark "potentially fabricated · 待核实".
3. This catches the "NotebookLM gave me a paper called X by Y from Z institution" hallucination — see [PLAYBOOK § 8 Failure Mode 1](./PLAYBOOK.md) and [templates/ci-hard-skeleton.md](./templates/ci-hard-skeleton.md).

### Step 5 · Emit structured verdict

Use the template at [`templates/verdict-template.md`](./templates/verdict-template.md). Output:

```
NotebookLM 报告核对 verdict (v2.1)

【规模档】 S / M / L
【结构】 来源对照表 ✅/❌  自检 section ✅/❌
【citation 密度】 每千字 N 处 (baseline ≥ 10)

【Tier A 决策数字】
  总 N 个 / 成功 cross-ref X / 待修正 Y / fetch 失败 Z

【Tier B 时间节点】
  总 N / 抽样 M / 通过 X / 待修正 Y

【Tier C 命名实体】
  报告 N / 对照表 M / 0-命中 K (待核实)

【自检 4 块解读】
  未满足 CI: ...
  未找到答案: ...
  引用频次 top 3: ...
  内部矛盾: ...

【整体】 ✅ ship / ⚠ 修后 ship / ❌ 退回 NotebookLM 重生成
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

Portable across:
- **Claude Code CLI** (`~/.claude/skills/notebooklm-research/`) — use AskUserQuestion for Stage 1 and TodoWrite to track stages
- **Anthropic Agents SDK · OpenAI Codex CLI** (`~/.agents/skills/notebooklm-research/`) — fall back to plain text prompts (no AskUserQuestion); Codex has WebFetch
- **Codex CLI alt path** (`~/.codex/skills/notebooklm-research/`)
- **Hermes** (`~/.hermes/skills/notebooklm-research/`) — autonomous mode: use defaults (M scale, A1 variant) unless the calling cron job overrides

When the host doesn't have a native question-asking tool, emit a plain text prompt:
```
请选择变体 (A1-F1) 和规模档 (S/M/L)。默认: A1 / M。
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

- [PLAYBOOK.md](./PLAYBOOK.md) — full v2.1 spec · 11 variants · S/M/L scale matrix · 5-anomaly mechanism
- [templates/](./templates/) — copy-paste-ready blocks
- [CHANGELOG.md](./CHANGELOG.md) — version history (v1 → v2.0 → v2.1 → 三轮 patch)
