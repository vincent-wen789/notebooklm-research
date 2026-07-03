# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**让 NotebookLM 抓住它自己的幻觉：凭空捏造的引用、悄悄漂移的数字、时间错乱的"目前"结论。** 一套 4 段式调研工作流——可以纯手动贴 prompt 用，也可以装成 agent skill。每份报告自带结构化 verdict，不是凭感觉过 review。

> **诚实说**：如果你用 ChatGPT Deep Research 或 Perplexity Pro 已经够爽，你大概不需要这个。那些工具看起来很稳，是因为失败模式不会大声坏掉——你不会看到"这段引用的论文我编的"警告。这个 skill 是给被这种悄悄出错坑过的人用的。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.3-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/装-Claude_Code_%7C_Codex_%7C_Cursor_%7C_Windsurf_%7C_Copilot_%7C_Gemini-7C3AED)](#安装--原生-skill-hostclaude-code--codex)

**你需要什么**：[NotebookLM](https://notebooklm.google.com)（Google 账号免费用）。零安装路线只需要这一个。完整 4 段式工作流额外需要一个 AI coding agent——[Claude Code](https://claude.com/claude-code)、Codex、Cursor 等（数量级大约 $20/月起，各工具不同）——外加一个终端（terminal）来装。

## 痛点

NotebookLM 本身是好工具。但裸跑 NotebookLM 有 3 个系统性失真，**人读报告校对抓不住**——人会漏：

1. **数字幻觉**：source A 的"310 万"被算到 source B；转述里漂成"350 万"
2. **事实-观点混淆**：source 作者的主观判断（"市场过热"）被当成事实写
3. **时效漂移**：source 是 2024 年的"目前"，NotebookLM 也写成"目前"

ChatGPT Deep Research 和 Perplexity 是同一类失败，只是被更漂亮的 UI 藏起来了。市面上其他自动化 wrapper（LangChain / GPT Researcher / 通用 agent）大多没有 verification 层——综合完直接 ship。看起来稳，是因为没东西大声坏掉。坏掉是悄悄的：你正要基于做决策的那份报告里有微妙错的数字。

这个项目不试图修好所有工具。它让 NotebookLM 这一个工具，抓住自己的失败。

## 不想装？先尝一下 301 字符 Magic Prompt

打开 [NotebookLM](https://notebooklm.google.com)，进你的笔记本，找到 **Notebook Settings → Custom Instructions**，把这段粘进去，零安装尝鲜：

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

**不懂技术？这个粘贴步骤对你就是全部——下面的安装全跳过。** 嫌上面 6 条太硬核，用这个大白话 4 条版（没有 `[#N]` 记号、没有术语），直接粘这个：

```
你在这个笔记本里写的每一句话：
1. 每个事实、数字、引述后面加 [1]、[2]、[3]……，并在最末尾列出对应来源（标题 + 链接）。
2. 如果某句是观点或你自己的推测，句首写"观点："或"推测："——不要当成事实写。
3. 日期写全，比如"截至 2025 年 3 月……"，不要写"目前""最近"。
4. 如果一个说法只有一个来源支撑，加"（单一来源）"，让我知道它没被交叉验证。
```

中文 / 日本語同款：[`templates/simple-prompt.md`](./templates/simple-prompt.md)。完整 6 条版有 EN / ZH / JA 三版，在 [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md)。

**贴了能得到什么**：citation 和标签纪律——NotebookLM 输出质量立刻上一档。**贴了得不到什么**：Stage 4 那套自动反查（抓捏造论文、抓漂移数字）——那部分需要一个跑 skill 的 agent（安装见下）。两个版本怎么选：4 条大白话版保留同样的核心保护（来源、观点标注、日期写全、单源标记）；6 条版多的是更严格的记号体系，自动核对读的就是它。这段贴的内容是完整 4 段式工作流里 Stage 3 的核心规则。

效果对比：

- **前**：NotebookLM 输出"目前业内主流方案是 XYZ"，引用糊在一起，事实观点混杂，数字幻觉
- **后**：每条 claim 带 `[#N]` · 标 `[事实]`/`[作者观点]`/`[推论]` · `截至 YYYY-MM-DD（[#N] 发布日期）` · 三档置信度

## 差异化在哪

- **不是又一个 deep research wrapper**。重活 NotebookLM 干（15-30 信源长 context 综合，长 context 是它的核心强项）。这个 skill 包一层 301 字符 Custom Instructions，强制 NotebookLM 每条 claim 自带 inline citation + 事实/观点/推论标签 + 三档置信度。
- **数字是被反查的，不是靠眼睛扫的**。你把成稿交回，Stage 4 跑 Tier A/B/C 分级核对：决策数字逐个 WebFetch 反查原文、时间节点抽样核对、命名实体 grep 对照来源表。paywall 失败显式标 `unverifiable`，不假装 verified。诚实地说清边界：整个流程是人在环里的 paste-and-handback 循环，自动的是反查这步。
- **防御是真实事故炼出来的**。vault 真实捕获（[原始记录在这](./examples/fabricated-source-catch.md)）：NotebookLM 捏造的 "Talos: Anatomy of Bitcoin ETF" / "Amberdata: Microstructure of Taker BSR" 论文（两篇都 404 不存在，但看起来像真 paper 还配作者和机构）、"310 万"在转述里悄悄漂成"350 万"、2024 年的"目前"被当成今天的"目前"——这些 skill 全部标出来。
- **装进你的整套栈**。原生 `SKILL.md` host（Claude Code · Codex · Agents SDK · Hermes）走自动检测安装脚本；规则文件型 agent（Cursor · Windsurf · Copilot · Gemini · Aider）贴一行 pointer。source-of-truth 一处，`git pull` 一次更新所有地方。
- **事故驱动迭代，不是白板设计**。Personal vault 方法论 v1 → v2.3，每个 patch 都能追溯到一次真实失败——收据在 [CHANGELOG](./CHANGELOG.md)。

## 安装 · 原生 skill host（Claude Code · Codex）

`SKILL.md` 现在是跨 agent 的开放标准。安装脚本自动检测原生读它的 host，symlink 进每个。这条命令**在终端（terminal）里跑**（macOS / Linux；Windows 用 WSL 或 Git Bash）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
```

- `~/.claude/skills/` · **Claude Code CLI**
- `~/.codex/skills/` · **OpenAI Codex CLI** — 2025 年 12 月起原生读 `SKILL.md`
- `~/.agents/skills/` · Anthropic Agents SDK
- `~/.hermes/skills/` · Hermes *（作者私有的自主 agent runtime——你不跑就忽略）*

Source-of-truth 在 `~/.local/share/notebooklm-research/`，`git pull` 一次更新所有 host，`./install.sh --uninstall` 干净撤回。

参数：`--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force` · `--print-agents-snippet`

**验证装好了**：打开你的 agent 输入 `/notebooklm-research "test"`——应该看到 Stage 1 的变体/规模提问。

## 安装 · 其他 agent（Cursor · Windsurf · Copilot · Gemini · Aider …）

这些 agent **没有 skill 概念**——只读一个常驻的指令文件，symlink 一个 `SKILL.md` 进去没用。改成往那个文件里贴一段简短的 *pointer*（agent 按需再读完整 workflow，几乎不占 context）。

**第 0 步 · 先把文件弄到本地。** pointer 引用的是 skill 的文件，所以先拉一次（同样在终端里跑）。在没有原生 skill host 的机器上，安装脚本只是把源码 clone 到 `~/.local/share/notebooklm-research/`，然后把你指到这一节：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
# 或者不用脚本：git clone https://github.com/vincent-wen789/notebooklm-research ~/.local/share/notebooklm-research
```

**第 1 步 · 把 pointer 追加到项目的指令文件：**

```bash
# 在你的项目里——把 pointer 追加到 AGENTS.md
sed -n '/^## Deep research/,/Emit all output/p' ~/.local/share/notebooklm-research/templates/agents-md-snippet.md >> ./AGENTS.md
```

| Agent | 它读的文件 |
|-------|-----------|
| Cursor · Windsurf · Aider · Zed · Jules · Amp · Devin · JetBrains Junie · VS Code | 项目 `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md`（或 `AGENTS.md`） |
| Gemini CLI | `GEMINI.md` |

`AGENTS.md` 是 [Linux 基金会托管的开放标准](https://agents.md/)，大多数 agent 都读它——贴一次基本覆盖全栈。完整说明 + 原始 block：[`templates/agents-md-snippet.md`](./templates/agents-md-snippet.md)（或跑 `install.sh --print-agents-snippet`）。

**这里实际跑得起来的部分。** Stage 1-3（喂给 NotebookLM 的 prompt）在任何 agent 上都能用——这是大头价值。Stage 4 的自动数字反查需要一个联网抓取工具：有的 agent（Cursor、Codex 等）自带、就能跑；没有的话你照样拿到带 citation 纪律的报告，被标出的数字手动核一下。Stage 1 的交互式选变体在没有原生提问 UI 的 agent 上退化成一段纯文字 prompt。

## 用一句

装好后，在你的 agent 里说（不是在 NotebookLM 里）：

```
/notebooklm-research "<你的调研主题>"
```

或者直接自然语言："帮我做个 crypto+AI 招聘 mapping" · "梳理 X 这个赛道弹药库" · "compliance scan 一下进口 X 到日本"——这些 intent skill 都自动触发，**不需要你提 NotebookLM**。

## 用起来什么感觉

先说清循环的形状：**你的 agent 和 NotebookLM 之间不直接通信**——每个 stage skill 吐一个产物，你贴进 NotebookLM，再把 NotebookLM 的输出带回来。自动化的是核对运算，不是来回搬运。

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
【Tier B 时间节点】 总 9 / 抽样 3 / 通过 3
【Tier C 命名实体】 报告 23 / 对照表 21 / 0-命中 2
                   (待核实: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【整体】 ⚠ 修后 ship
```

外加 5 类异常自动检测：fetch 成功率 <50% / 核对耗时超规模预估 2 倍 / CI 被 NotebookLM 截断或无视 / 数字幻觉 / 自检 4 块缺 ≥ 2 块——任一命中就 log 一条供你追踪 NotebookLM 的行为变化。

**时间账，诚实版**：一轮完整循环 = NotebookLM 自己的 Deep Research 跑一遍 + 你审一遍来源 + Stage 4 核对。光核对这步：S 规模约 15-30 分钟、M 约 30-60 分钟、L 按小时算（规模分档就是为这个）。

## 跟其他工具对比

| 工具 | 深度 | Citation 纪律 | 数字 cross-ref | 成本 |
|------|------|---------------|----------------|------|
| ChatGPT Deep Research | 中 | 弱（有 citation 但仍幻觉） | ❌ | $20/月 |
| Perplexity Deep Research | 中 | 弱 | ❌ | $20/月 |
| GPT Researcher · 类似 wrapper | 低（综合浅） | 无 | ❌ | self-host |
| 你的 agent 裸跑（Claude / GPT + 联网搜索） | 中低（单轮信源少） | 中（fetch 到的会引） | ❌ | 你已经在付的 |
| 裸 NotebookLM | 高（长 context 综合） | 无（3 大失真未防） | ❌ | 免费（Plus 可选） |
| **NotebookLM + 本 skill** | **高** | **强制：inline `[#N]` + 事实/观点/推论标签 + 截至日期 + 置信度分档** | **✅ Tier A/B/C 自动** | **skill 免费（MIT）** |

成本的小字：NotebookLM 免费层对 Deep Research 有每日次数限制（额度会变，以官方为准），S/M 规模够用。Stage 4 跑在你自己 agent 的额度上——那部分你本来就在付。

这个 skill 不是替代 deep research 工具。是让 NotebookLM 这一个工具抓住自己的失败。

## 12 个变体框架（A1 · B1 有完整模板 · 其余 10 个待补）

| 系列 | Codes | 用途 |
|------|-------|------|
| A · 认知扩展 | A1 领域 mapping · A2 概念深研 · A3 趋势调研 · A4 法规变化追踪 | "帮我 map 一下 X 行业" · "搞懂 Y 的全貌" |
| B · 叙事/创作 | B1 narrative 弹药 · B2 历史复盘 | 题材创作调研 · "1929 对今天的启示" |
| C · 决策辅助 | C1 竞品分析 · C2 技术选型 · C3 面试公司情报 | "X vs Y" · "选哪个栈" · 面试前情报 |
| D · 市场/用户调研 | D1 用户画像 + 触达 | 产品 launch 用户调研 |
| E · 合规/法规扫盲 | E1 跨法域合规 | "在 Y 市场做 X 合法吗" |
| F · 事件/时间线 | F1 事件 timeline 还原 | "X 到底发生了什么" |

完整模板 A1 · B1 · 硬骨架 · verdict · anomaly-log 在 [`templates/`](./templates/)。其余 10 个框架定义在 [PLAYBOOK § 4](./PLAYBOOK.md)（SKILL.md 里内嵌了同一张表的英文版），可以 fork 改或开 PR 补模板。

## 仓库结构

```
notebooklm-research/
├── SKILL.md              ← skill 本体（host 读这个 · 英文）
├── install.sh            ← cross-host 安装脚本
├── README.md             ← 英文主页
├── README.zh.md          ← 你正在读
├── README.ja.md          ← 日本語
├── PLAYBOOK.md           ← 完整 spec（深度参考 · 目前仅中文）
├── CHANGELOG.md          ← v1 → v2.3
├── templates/            ← 模板（CI · verdict · anomaly-log 即贴即用）
├── examples/             ← 真实捕获记录（假论文抓捕现场 · 原始笔记）
└── LICENSE               ← MIT
```

## 维护节奏

Personal vault workflow · 半月维护一次 · share as-is。Issue 响应不保证 · PR 欢迎但 merge 看 owner 节奏。

## 相关项目

[ORP (Obsidian RAG Protocol)](https://github.com/vincent-wen789/obsidian-rag-protocol) · ORP 是 vault → AI agent 的 state/memory 协议。本 skill 是 research handoff workflow spec。相邻但解耦。

## License

MIT
