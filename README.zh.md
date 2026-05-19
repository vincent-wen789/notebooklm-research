# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**一个跨 host 的 Claude × NotebookLM 深度调研 skill · 专门拦截 NotebookLM 自己藏起来的 3 类 AI 幻觉：凭空捏造引用 · 悄悄篡改数字 · 时间错乱的"当前"结论。** 4 段式拆解 · 每份报告自带结构化 verdict · 不是凭感觉过 review。

> **诚实说**：如果你用 ChatGPT Deep Research 或 Perplexity Pro 已经够爽，你大概不需要这个。那些工具看起来很稳，是因为失败模式不会大声坏掉——你不会看到"这段引用的论文我编的"警告。这个 skill 是给被这种悄悄出错坑过的人用的。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.1-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/装-Claude_Code_%7C_Codex_CLI_%7C_Agents_SDK_%7C_Hermes-7C3AED)](#一次装-四个-host-用)

### 差异化在哪

- **不是又一个 deep research wrapper**。重活 NotebookLM 干（15-30 信源长 context 综合 · 长 context 是它的核心强项）。这个 skill 包一层 301 字符 Custom Instructions，强制 NotebookLM 每条 claim 自带 inline citation + 事实/观点/推论标签 + 三档置信度。
- **数字自动 cross-ref**。Tier A/B/C 分级核对：决策数字 100% WebFetch 反查 · 时间节点抽样 30% · 命名实体 grep 对照来源表 · paywall 失败显式标 `unverifiable`，不假装 verified。
- **抓 ChatGPT/Perplexity 漏的**。比如：vault 真实捕获 NotebookLM 报告里捏造的 "Talos: Anatomy of Bitcoin ETF" / "Amberdata: Microstructure of Taker BSR" 论文（两篇都 404 不存在 · 看起来像真 paper 还配作者和机构）· "310 万"在转述里悄悄漂成"350 万"· 2024 年的"目前"被当成今天的"目前"——这些 skill 全部标出来。
- **一次装 · 四个 host 用**。Claude Code / Codex CLI / Anthropic Agents SDK / Hermes · source-of-truth 一处 · symlink 到各 host · `git pull` 一次更新所有地方。
- **半月维护节奏 · 跑了 1 年的真实 SOP**。Personal vault 方法论迭代 v1 → v2.0 → v2.1 + 三轮 patch。不是 startup wrapper。5 类异常分类是真实事故炼出来的，不是白板想的。

---

## 痛点

NotebookLM 本身是好工具。但裸跑 NotebookLM 有 3 个系统性失真，**人读报告校对抓不住**——人会漏：

1. **数字幻觉**：source A 的"310 万"被算到 source B；转述里漂成"350 万"
2. **事实-观点混淆**：source 作者的主观判断（"市场过热"）被当成事实写
3. **时效漂移**：source 是 2024 年的"目前"，NotebookLM 也写成"目前"

ChatGPT Deep Research 和 Perplexity 有同样的问题，只是被更漂亮的 UI 藏起来了。市面上其他自动化 wrapper（LangChain / GPT Researcher / 通用 agent）大多没有 verification 层——综合完直接 ship。看起来稳，是因为没东西大声坏掉。坏掉是悄悄的：你正要基于做决策的那份报告里有微妙错的数字。

## 不想装？先尝一下 301 字符 Magic Prompt

把这段粘到 NotebookLM Notebook Settings → Custom Instructions，零安装尝鲜：

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

效果对比：

- **前**：NotebookLM 输出"目前业内主流方案是 XYZ"，引用糊在一起，事实观点混杂，数字幻觉
- **后**：每条 claim 带 `[#N]` · 标 `[事实]`/`[作者观点]`/`[推论]` · `截至 YYYY-MM-DD（[#N] 发布日期）` · 三档置信度

这只是 skill 内置 4-stage 工作流的 Stage 2 片段——独立用就能立刻提升 NotebookLM 输出质量。装上 skill 还能拿到：Stage 1 自动选变体（A1 mapping / B1 narrative / C1 compliance 等 11 种）· Stage 4 自动跑 Tier A/B/C 数字反查 · 抓出编造的论文（详情看下面"用起来什么感觉"）。

## 一次装 · 四个 host 用

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wjameswen888/notebooklm-research/main/install.sh)
```

安装脚本自动检测你机器上的 AI host 路径，把 skill 装进每个找到的：

- `~/.claude/skills/` · Claude Code CLI
- `~/.agents/skills/` · Anthropic Agents SDK · OpenAI Codex CLI
- `~/.codex/skills/` · Codex CLI 备用路径
- `~/.hermes/skills/` · Hermes

Source-of-truth 在 `~/.local/share/notebooklm-research/` · `git pull` 一次更新所有 host · `./install.sh --uninstall` 干净撤回。

参数：`--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force`

## 用一句

任何 host 装上后：

```
/notebooklm-research "<你的调研主题>"
```

或者直接自然语言："帮我做个 crypto+AI 招聘 mapping" · "梳理 X 这个赛道弹药库" · "compliance scan 一下进口 X 到日本"——这些 intent skill 都自动触发，**不需要你提 NotebookLM**。

## 用起来什么感觉

你装一次。然后说：

```
/notebooklm-research "Crypto+AI 创业公司 2026 hiring mapping"
```

Skill 走 4 个 stage：

**Stage 1 · 变体 + 规模**。默认 A1（mapping）+ M 规模（15-30 信源）。只有你的需求明显是 S 或 L 才问。

**Stage 2 · 搜索大纲**。skill 吐一段搜索大纲给你贴到 NotebookLM **Deep Research mode**：

```
NotebookLM Deep Research · 搜索大纲
[主题 + 双语关键词 + 范围限制 + 来源类型偏好 + 输出要求]
```

NotebookLM 跑完返回来源列表，你过一遍砍掉低质量/跑题的。

**Stage 3 · Custom Instructions**。来源审完，skill 吐变体专属 CI（含 301 字符硬骨架）：

```
## 来源与可核对性（硬要求）
1. 事实/数字/引述句末必带 [#N]
2. 数字独立 [#N · 原文引述≤50 字]，不许多条共用
3. 每条陈述前缀 [事实]/[作者观点]/[推论] 三选一
...
```

贴到 NotebookLM **Notebook Settings → Custom Instructions**（永久预设）。这个 notebook 之后所有报告都按这个规矩走。

**Stage 4 · 收尾核对**。报告拿回来贴给 skill。skill 跑 Tier A/B/C verification 输出结构化 verdict：

```
【Tier A 决策数字】 总 12 / 成功 cross-ref 9 / 待修正 1 / fetch 失败 2 (paywall)
【Tier C 命名实体】 报告 23 / 对照表 21 / 0-命中 2
                   (待核实: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【整体】 ⚠ 修后 ship
```

外加 5 类异常自动检测：fetch <50% / 墙钟超 2× / CI 爆 / 数字幻觉 / 自检缺 ≥ 2 块——任一命中就 log 一条供你追踪 NotebookLM 的行为变化。

## 跟其他工具对比

| 工具 | 深度 | Citation 纪律 | 数字 cross-ref | 成本 |
|------|------|---------------|----------------|------|
| ChatGPT Deep Research | 中 | 弱（有 citation 但仍幻觉） | ❌ | $20/月 |
| Perplexity Deep Research | 中 | 弱 | ❌ | $20/月 |
| GPT Researcher · 类似 wrapper | 低（综合浅） | 无 | ❌ | self-host |
| 裸 NotebookLM | 高（长 context 综合） | 无（3 大失真未防） | ❌ | 免费（Plus $20/月可选） |
| **NotebookLM + 本 skill** | **高** | **强制 4 层防御** | **✅ Tier A/B/C 自动** | **免费**（skill 免费 + NotebookLM 免费层够用） |

这个 skill 不是替代 deep research 工具。是让 NotebookLM 这一个工具抓住自己的失败。

## 11 个变体覆盖

| 系列 | Codes | 用途 |
|------|-------|------|
| A · Mapping | A1, A2, A3, A4 | 行业 · 工具 · 区域 · 人物 mapping |
| B · Narrative | B1, B2 | 故事弹药 · 反向叙事 |
| C · Compliance | C1, C2, C3 | 法规 · 标准 · 政策扫盲 |
| D · Timeline | D1 | 事件时间线 |
| E · 跨法域 | E1 | 多地区合规 |
| F · 用户群 | F1 | 用户画像 · marketing |

完整模板 A1 · B1 · 硬骨架 · verdict · anomaly-log 在 [`templates/`](./templates/)。其他变体框架在 [PLAYBOOK § 10.3+](./PLAYBOOK.md)，可以 fork 改或开 PR 补。

## 仓库结构

```
notebooklm-research/
├── SKILL.md              ← skill 本体（host 读这个）
├── install.sh            ← cross-host 安装脚本
├── README.md             ← 英文主页
├── README.zh.md          ← 你正在读
├── README.ja.md          ← 日本語
├── PLAYBOOK.md           ← v2.1 完整 spec（深度参考 · 624 行）
├── CHANGELOG.md          ← v1 → v2.0 → v2.1 → 三轮 patch
├── templates/            ← 模板（CI · verdict · anomaly-log 即贴即用）
└── LICENSE               ← MIT
```

## 维护节奏

Personal vault workflow · 半月维护一次 · share as-is。Issue 响应不保证 · PR 欢迎但 merge 看 owner 节奏。

## 相关项目

[ORP (Obsidian RAG Protocol)](https://github.com/wjameswen888/obsidian-rag-protocol) · ORP 是 vault → AI agent 的 state/memory 协议。本 skill 是 research handoff workflow spec。相邻但解耦。

## License

MIT
