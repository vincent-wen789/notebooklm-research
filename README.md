# notebooklm-research

> A portable Claude × NotebookLM deep-research skill · 4-stage workflow + anti-hallucination guardrails · works in Claude Code, Codex CLI, Anthropic Agents SDK, Hermes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.1-blue)](./CHANGELOG.md)

## Install · one line

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wjameswen888/notebooklm-research/main/install.sh)
```

The installer detects AI host paths on your machine and symlinks the skill into each:

- `~/.claude/skills/` — Claude Code CLI
- `~/.agents/skills/` — Anthropic Agents SDK, OpenAI Codex CLI
- `~/.codex/skills/` — Codex CLI alt path
- `~/.hermes/skills/` — Hermes

One source of truth at `~/.local/share/notebooklm-research/` · each host reads via symlink · `git pull` propagates everywhere.

Dry-run / specific hosts / uninstall:

```bash
./install.sh --dry-run
./install.sh --hosts claude,codex
./install.sh --uninstall
```

Or clone manually:

```bash
git clone https://github.com/wjameswen888/notebooklm-research ~/.local/share/notebooklm-research
~/.local/share/notebooklm-research/install.sh
```

## Use · one phrase

In any AI host that supports skills:

```
/notebooklm-research "I want a deep research on <topic>"
```

The skill walks 4 stages:

1. **Pick variant + scale** — A1 mapping / B1 narrative / C1 compliance / etc., scale S/M/L
2. **Get the search outline** — paste into NotebookLM Deep Research mode, collect sources
3. **Get the Custom Instructions** — paste into Notebook Settings (permanent preset)
4. **Run NotebookLM, return with report** — skill runs Tier A/B/C verification and emits a structured verdict

## What problems does this solve

NotebookLM is a great research tool, but raw NotebookLM has 3 systemic failure modes:

1. **Number hallucination** — source A's "3.1 million" becomes "3.5 million" in synthesis
2. **Fact/opinion conflation** — author's opinion gets written as fact
3. **Time-recency drift** — 2024's "currently" passes through as today's "currently"

This skill engineers the defense into the prompt (301-char anti-hallucination hard-skeleton in NotebookLM's Custom Instructions) and into the SOP (Tier A/B/C tiered verification on the returned report).

## Quick taste · the 301-char Magic Prompt

Even without installing the skill, you can paste this into NotebookLM Notebook Settings → Custom Instructions for inline citations + fact/opinion tags + 3-tier confidence on every report:

```
## 来源与可核对性（硬要求）
1. 事实/数字/引述句末必带 [#N]（对应文末来源对照表）
2. 数字（金额/比例/日期/人数/版本号）独立 [#N · 原文引述≤50 字]，不许多条共用
3. 每条陈述前缀 [事实]/[作者观点]/[推论] 三选一
4. 时间用"截至 YYYY-MM-DD（[#N] 发布日期）"，不用"目前/最新"
5. 置信度 [高 多源 ≥ 2]/[中 单源]/[低 推论或冲突]
6. 报告末尾必附两表（字段定义见报告 prompt）：
   - 来源对照表
   - 自检 section（4 块：未满足 CI / 未找到答案 / 引用频次 top 3 / 内部矛盾）
```

Effect:

- **Before**: NotebookLM outputs "目前业内主流方案是 XYZ" with tangled references, facts and opinions blurred, numbers drift in synthesis
- **After**: every claim carries `[#N]` · marked `[事实]`/`[作者观点]`/`[推论]` · dates anchored as `截至 YYYY-MM-DD（[#N] 发布日期）` · confidence tagged `[高 多源 ≥ 2]`/`[中 单源]`/`[低 推论或冲突]`

The full skill workflow adds the other 3 stages (search outline → variant-specific CI → Tier A/B/C verification) on top.

## Repo structure

```
notebooklm-research/
├── SKILL.md              ← the skill (Claude/Codex/Agents/Hermes all read this)
├── install.sh            ← cross-host installer
├── README.md             ← you are here
├── PLAYBOOK.md           ← full v2.1 spec (deep-dive reference · 624 lines)
├── CHANGELOG.md          ← version history (v1 → v2.0 → v2.1 → 三轮 patch)
├── templates/            ← copy-paste-ready CI / verdict / anomaly blocks
└── LICENSE               ← MIT
```

## 11 variants supported

| Family | Codes | Use case |
|--------|-------|----------|
| A · Mapping | A1, A2, A3, A4 | Industry / tools / regions / people |
| B · Narrative | B1, B2 | Story ammunition / counter-narrative |
| C · Compliance | C1, C2, C3 | Regulation / standards / policy |
| D · Timeline | D1 | Event chronology |
| E · Cross-jurisdiction | E1 | Multi-region legal scoping |
| F · User segment | F1 | Persona / marketing |

Full templates for A1, B1, hard-skeleton, verdict, and anomaly-log are ready in [`templates/`](./templates/). Other variants follow the same shape — extend or open a PR.

## Maintenance posture

Personal vault workflow shared as-is. Half-monthly maintenance cadence. Issue response not guaranteed; PRs welcome but merge cadence is owner-paced.

## Related Projects

[ORP (Obsidian RAG Protocol)](https://github.com/wjameswen888/obsidian-rag-protocol) · ORP is a state/memory protocol for vault → AI agent. This skill is a research handoff workflow spec. Adjacent but decoupled.

## License

MIT
