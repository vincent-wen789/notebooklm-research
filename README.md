# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**A cross-host Claude × NotebookLM deep-research skill that catches the 3 AI hallucinations NotebookLM hides from you: fabricated citations · silent number drift · time-confused "currently" conclusions.** 4-stage workflow · every report ships with a structured verdict · not pass-by-vibes.

> **Brutally honest**: if ChatGPT Deep Research or Perplexity Pro already work for you, you probably don't need this. Those tools look stable because their failure modes don't break loudly · you don't see a "I made this citation up" warning. This skill is for people who've been burned by that kind of silent error.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.1-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/install-Claude_Code_%7C_Codex_CLI_%7C_Agents_SDK_%7C_Hermes-7C3AED)](#install-once-use-on-four-hosts)

### Key differentiators

- **Not another deep-research wrapper**. NotebookLM does the heavy lifting (15-30 sources, long-context synthesis · that's its core strength). This skill wraps a 301-character Custom Instructions block around it, forcing NotebookLM to put inline citations on every claim, label fact / opinion / inference, and tag a three-tier confidence score.
- **Numbers get cross-referenced automatically**. Tier A / B / C verification: 100% WebFetch reverse-check on decision numbers · 30% sample on time markers · grep cross-check on named entities against the source list · paywall failures get marked `unverifiable` instead of being faked as verified.
- **Catches what ChatGPT / Perplexity miss**. From actual vault captures: NotebookLM-fabricated papers like "Talos: Anatomy of Bitcoin ETF" and "Amberdata: Microstructure of Taker BSR" (both 404 · look like real papers with author and institution attached) · a "3.1 million" silently drifted to "3.5 million" in paraphrase · a 2024 "currently" treated as today's "currently" · this skill flags all of them.
- **Install once · run on four hosts**. Claude Code / Codex CLI / Anthropic Agents SDK / Hermes · single source-of-truth · symlinked into each host · `git pull` updates everywhere.
- **Bi-weekly maintenance · 1-year-old SOP in production**. Personal vault methodology iterated v1 → v2.0 → v2.1 plus three rounds of patches. Not a startup wrapper. The 5 anomaly categories are forged from real incidents, not whiteboarded.

---

## The problem

NotebookLM is a good tool on its own. But bare NotebookLM has 3 systematic distortions that **a human reading the report cannot reliably catch**:

1. **Number hallucinations**: source A's "3.1 million" gets attributed to source B; paraphrase drifts it to "3.5 million"
2. **Fact / opinion conflation**: a source author's judgment call ("market is overheated") gets written as a fact
3. **Temporal drift**: the source says "currently" about 2024, NotebookLM also writes "currently"

ChatGPT Deep Research and Perplexity have the same problems, just hidden behind nicer UI. Most automation wrappers on the market (LangChain · GPT Researcher · generic agents) skip the verification layer entirely · they synthesize and ship. They look stable because nothing breaks loudly. The breakage is silent: the report you're about to make a decision from has subtly wrong numbers.

## Don't want to install? Try the 301-character magic prompt first

Paste this into NotebookLM Notebook Settings → Custom Instructions, zero install:

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

Before vs after:

- **Before**: NotebookLM outputs "the mainstream solution in the industry currently is XYZ", citations smashed together, facts and opinions mixed, hallucinated numbers
- **After**: every claim carries `[#N]` · labeled `[事实]` / `[作者观点]` / `[推论]` · `截至 YYYY-MM-DD（[#N] 发布日期）` · three-tier confidence

This is just a fragment of Stage 2 from the skill's full 4-stage workflow · use it standalone and NotebookLM's output quality jumps immediately. Install the skill and you also get: Stage 1 auto-variant selection (11 types · A1 mapping / B1 narrative / C1 compliance etc.) · Stage 4 automatic Tier A/B/C number cross-check · fabricated-paper detection (see "What it feels like" below).

## Install once · use on four hosts

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wjameswen888/notebooklm-research/main/install.sh)
```

The installer auto-detects which AI hosts you have installed and drops the skill into each one it finds:

- `~/.claude/skills/` · Claude Code CLI
- `~/.agents/skills/` · Anthropic Agents SDK · OpenAI Codex CLI
- `~/.codex/skills/` · Codex CLI fallback path
- `~/.hermes/skills/` · Hermes

Source-of-truth lives at `~/.local/share/notebooklm-research/` · one `git pull` updates every host · `./install.sh --uninstall` removes everything cleanly.

Flags: `--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force`

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
NotebookLM Deep Research · 搜索大纲
[topic + bilingual keywords + scope limits + source-type preferences + output requirements]
```

NotebookLM runs and returns its source list. You scan it and cut low-quality or off-topic ones.

**Stage 3 · Custom Instructions**. Once the source list is approved, the skill emits the variant-specific CI (including the 301-char hard skeleton):

```
## 来源与可核对性（硬要求）
1. 事实/数字/引述句末必带 [#N]
2. 数字独立 [#N · 原文引述≤50 字]，不许多条共用
3. 每条陈述前缀 [事实]/[作者观点]/[推论] 三选一
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

## 11 variants covered

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
├── PLAYBOOK.md           ← v2.1 full spec (deep reference · 624 lines)
├── CHANGELOG.md          ← v1 → v2.0 → v2.1 → three patches
├── templates/            ← templates (CI · verdict · anomaly-log · paste-ready)
└── LICENSE               ← MIT
```

## Maintenance cadence

Personal vault workflow · bi-weekly maintenance · shared as-is. Issue response not guaranteed · PRs welcome but merge cadence depends on owner.

## Related projects

[ORP (Obsidian RAG Protocol)](https://github.com/wjameswen888/obsidian-rag-protocol) · ORP is the vault → AI agent state/memory protocol. This skill is the research handoff workflow spec. Adjacent but decoupled.

## License

MIT
