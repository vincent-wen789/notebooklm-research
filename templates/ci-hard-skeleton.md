# CI 硬骨架 · 301 字符防幻觉模板

**这是什么**：NotebookLM Custom Instructions（CI）的反幻觉硬骨架。中文版实测 301 字符（含标点换行），能塞进 NotebookLM CI 10k 上限有充裕余量。

**怎么用**：粘到 NotebookLM **Notebook Settings → Custom Instructions**（永久预设）末尾。可以单独用作 minimal CI，也可以叠加在任何变体专属 CI 后面（如 [ci-A1-mapping.md](./ci-A1-mapping.md) / [ci-B1-narrative.md](./ci-B1-narrative.md)）作为统一防幻觉层。

**跟其他模板关系**：A1 / B1 等变体 CI 末尾都会写 `[追加 § 10.0 硬骨架]` — 那个位置就粘这段。

**语言**：下面提供 EN / ZH / JA 三版。**粘跟你研究语言一致的那版**——它决定 NotebookLM 用什么语言输出。其它语言照着翻一版即可（标签词随语言走）。

---

## Template · English (copy-paste)

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

## Template · 日本語（コピペ）

```
## ソースと照合可能性（必須要件）
1. 事実 / 数字 / 引用の文末に必ず [#N]（末尾の出典対照表に対応）
2. 数字（金額 / 比率 / 日付 / 人数 / バージョン）は独立した [#N · 原文引用 50 字以内] · 複数で共用しない
3. 各記述の冒頭に [事実] / [見解] / [推論] のいずれか一つを付ける
4. 時間は「YYYY-MM-DD 時点（[#N] 公開日）」· 「現在 / 最新」は使わない
5. 確信度 [高 · 出典 2 つ以上] / [中 · 出典 1 つ] / [低 · 推論または矛盾]
6. レポート末尾に 2 つの表を付ける（フィールド定義はレポート prompt 参照）：
   - 出典対照表
   - 自己診断 section（4 ブロック：未達 CI / 回答なし / 引用頻度 top 3 / 内部矛盾）
```

## 模板 · 中文（直接复制粘贴）

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

---

## 字段定义（在报告 prompt 里补 · CI 里不放）

CI 字符紧张 · 字段释义全部挪到每次 task 的报告 prompt 里。下面是粘到报告 prompt 末尾的字段定义模板：

### 来源对照表字段

| 字段 | 释义 |
|---|---|
| `#` | 顺序编号，对应正文 `[#N]` |
| `标题` | source 标题（原文 + 译注） |
| `URL` | source 链接 |
| `发布日期` | YYYY-MM-DD · 缺失标 "n/a" |
| `类型` | 一手（原始数据/官方公告/采访/法规原文）/ 二手（媒体报道/专业分析）/ 三手（聚合/转发/UGC） |
| `权威度` | 高（行业最权威/官方/学术）/ 中（专业媒体/资深从业者）/ 低（自媒体/匿名） |
| `报告内引用位置` | 所有引用该来源的章节号 + `[#N]` 出现处，具体到 § / 表 / 附录（不要写"全篇"） |

### 自检 section 4 块

```markdown
## 自检 · 本次报告局限性

### 未满足的 CI 框架要求
[列出未能完全满足的 CI 要求 · 全部满足明示"无未满足项"]

### 未在 source 中找到答案的问题
[CI 要求覆盖但 source 池里没答案的问题]

### 引用频次 top 3 source 及代表段落
[列出报告中被引用次数最多的 3 个 [#N] 及其对应段落，让 owner 判断是不是复读机]

### 内部矛盾或数据冲突
[source 间矛盾，用 [#A] vs [#B] 标注双方观点，不取舍]
```

---

## 效果差异

- **不加硬骨架**：NotebookLM 输出"目前业内主流方案是 XYZ"，引用糊成一团，事实和观点混杂，数字幻觉
- **加硬骨架**：每条 claim 带 `[#N]` · 标 `[事实]`/`[作者观点]`/`[推论]` · `截至 YYYY-MM-DD（[#N] 发布日期）` · `[高 多源 ≥ 2]`/`[中 单源]`/`[低 推论或冲突]`
