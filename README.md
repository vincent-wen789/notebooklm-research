# NotebookLM Handoff Playbook

> Claude × NotebookLM 协作 SOP · 把"扫源 + 综合"外包给 NotebookLM · 把"判断 + 应用 + 核对"留给 Claude · 防幻觉 CI 硬骨架 + Tier A/B/C 分级核对

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.1-blue)](./CHANGELOG.md)

## Quickstart · 301 字符 Magic Prompt

把下面这段粘到 NotebookLM 的 **Notebook Settings → Custom Instructions**（永久预设），任何 deep research 任务的输出都会自带 inline citation + 事实/观点/推论标签 + 三档置信度 + 自检 section：

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

效果差异：

- **前**：NotebookLM 输出"目前业内主流方案是 XYZ"，引用糊成一团，事实和观点混杂，数字幻觉
- **后**：每条 claim 带 `[#N]` · 标 `[事实]`/`[作者观点]`/`[推论]` · `截至 YYYY-MM-DD（[#N] 发布日期）` · `[高 多源 ≥ 2]`/`[中 单源]`/`[低 推论或冲突]`

完整 SOP 看 [PLAYBOOK.md](./PLAYBOOK.md)。

## 痛点

NotebookLM 是好工具，但裸跑有 3 个系统性失真：

1. **数字幻觉**：source A 的数字算到 source B / 转述时改写
2. **事实-观点混淆**：source 作者的主观判断被当事实写
3. **时效模糊**：source 是 2024 年的"目前"，NotebookLM 也写成"目前"

owner 跑完报告人脑校对 = 漏。

## 方案 · 四段式架构

1. **搜索大纲**（Deep Research · NotebookLM 端）→ 不设 CI，只要来源列表
2. **Custom Instructions**（永久预设）→ 变体专属框架 + §10.0 硬骨架
3. **报告 prompt** → 按 CI 框架走 + 末尾两表（来源对照表 + 自检 section）
4. **Claude 收尾核对 SOP** → 按 PLAYBOOK § 5 阶段三 3a 跑分级核对

分级核对：

- **Tier A 决策数字**（金额/比例/KPI）：100% 尝试 cross-ref，paywall 失败显式 reporting
- **Tier B 时间节点**：抽样 30% cross-ref
- **Tier C 命名实体**：grep 对照来源表，0 命中标"可能编造"

## 模板库

每个模板独立可用，开头自带使用说明。

- [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md) · 301 字符硬骨架（推荐起点 · 粘到任何 CI 末尾）
- [`templates/ci-A1-mapping.md`](./templates/ci-A1-mapping.md) · A1 求职/竞品 mapping 完整 CI
- [`templates/ci-B1-narrative.md`](./templates/ci-B1-narrative.md) · B1 narrative 弹药 CI
- [`templates/verdict-template.md`](./templates/verdict-template.md) · § 5 3a 收尾核对 verdict 结构
- [`templates/anomaly-log-entry.md`](./templates/anomaly-log-entry.md) · 5 类异常上报模板

## 完整 spec

[PLAYBOOK.md](./PLAYBOOK.md) · v2.1 · 三轮 patch · 11 变体 CI + Tier A/B/C 分级核对 + 5 类异常上报机制

## 维护节奏

Half-monthly maintenance. Personal vault workflow shared as-is. Issue 响应不保证 · PR 欢迎但 merge 看 owner 节奏。

## Related Projects

[ORP (Obsidian RAG Protocol)](https://github.com/wjameswen888/obsidian-rag-protocol) · ORP 是 vault → AI agent 的 state/memory 协议；本 playbook 是 research handoff workflow spec。相邻但解耦。

## License

MIT
