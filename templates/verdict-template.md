# 收尾核对 Verdict 模板

**这是什么**：Claude 拿到 NotebookLM 报告后，按 PLAYBOOK § 5 阶段三 3a 跑完分级核对（Step 1-6）后，输出的结构化 verdict block。

**怎么用**：Claude（或任何 agent）在跑完 7 步收尾流程后，按下面格式填入数字 + 结论。owner 看一眼就知道这份报告 ship / 修后 ship / 退回重生成。

**跟其他模板关系**：是 [ci-hard-skeleton.md](./ci-hard-skeleton.md) 在 NotebookLM 端"自检 section"的镜像 — 一个是 NotebookLM 自报，一个是 Claude 外部核对。两边数据应该 cross-check。

---

## Verdict block 模板

```
NotebookLM 报告核对 verdict（v2.2）
═══════════════════════════════════════
【规模档】 S 小 / M 中 / L 大
【结构】 来源对照表 ✅/❌  自检 section ✅/❌
【citation 密度】 每千字 N 处（基线 ≥ 10）

【Tier A 决策数字】
  总 N 个 / 成功 cross-ref X 个 / 待修正 Y 个 / fetch 失败 Z 个

【Tier B 时间节点】
  总 N 个 / 抽样 M 个 / 通过 X 个 / 待修正 Y 个

【Tier C 命名实体】
  报告 N 个 / 对照表 M 个 / 0-命中 K 个 (待核实)

【事实/观点】 抽检通过 X/8
【时效】 通过 X / 异常 Y

【自检 4 块处理建议】
  未满足 CI: ...
  未找到答案: ...
  引用频次 top 3: ...
  内部矛盾: ...

【整体】 ✅ ship / ⚠️ 修后 ship / ❌ 退回 NotebookLM 重生成
```

---

## 字段说明

### 规模档

按 PLAYBOOK § 3 规模分级表分档：

- **S 小**：10-15 信源 / 3000-5000 字 / 数字 < 20
- **M 中**：15-30 信源 / 5000-10000 字 / 数字 20-50
- **L 大**：> 30 信源 / > 10000 字 / 数字 > 50

### 结构

- **来源对照表**：必填 7 字段（#、标题、URL、发布日期、类型、权威度、引用位置）齐全为 ✅
- **自检 section**：必填 4 块（未满足 CI / 未找到答案 / 引用频次 top 3 / 内部矛盾）齐全为 ✅

### citation 密度

```bash
# 统计
grep -oE '\[#[0-9]+\]' 报告.md | wc -l
wc -m 报告.md

# 密度 = [#N] 总数 / (总字数 / 1000)
```

基线 ≥ 10 每千字 · < 10 flag "可能有未标注的推论"。

### Tier A · 决策关键数字

定义：金额（¥/$/€）/ 百分比 / 利益分配比例 / 市场规模 / 融资金额 / 关键 KPI 数字

- **总 N 个**：grep 报告里所有 Tier A 数字
- **成功 cross-ref X 个**：WebFetch 拿到原文 + 误差 < 5%
- **待修正 Y 个**：WebFetch 拿到原文 + 误差 ≥ 5%
- **fetch 失败 Z 个**：paywall / JS 渲染 / 反爬 / 404 · 不算误差，但要 report

### Tier B · 时间节点

定义：日期 / 年份 / 时间戳 / 版本号 / 时长

- **总 N 个**：grep 全部时间节点
- **抽样 M 个**：随机抽 30% · WebFetch cross-ref
- **通过 X 个**：误差 < 1 个时间单位（年/月/日）
- **待修正 Y 个**：误差 ≥ 1 个时间单位

### Tier C · 命名实体

定义：人名 / 公司名 / 项目名 / 地点 / 机构名

- **报告 N 个**：grep 报告里所有专有名词
- **对照表 M 个**：来源对照表"标题"字段里出现的实体数
- **0 命中 K 个**：报告里出现但对照表 0 命中 · flag "可能是 NotebookLM 推断或编造"

### 事实/观点

抽样 5 条 `[事实]` + 3 条 `[作者观点]` cross-ref source。通过 = 与 source 原文一致。

### 时效

grep "截至 YYYY-MM-DD" → 每个日期 ≤ 对应 `[#N]` source 发布日期？通过 / 异常。

### 整体判定

| 判定 | 触发线 |
|---|---|
| ✅ ship | 结构齐 + citation 密度过线 + Tier A 待修正 0 + 抽检通过 ≥ 7/8 |
| ⚠️ 修后 ship | Tier A 待修正 1-2 / 自检某块缺 / 抽检通过 5-6/8 |
| ❌ 退回 NotebookLM 重生成 | 结构缺 ≥ 2 项 / Tier A 待修正 ≥ 3 / 抽检通过 < 5/8 |

---

## 使用注意

- **fetch 失败 ≠ 待修正**：paywall 命中无法验证，不算误差，但 verdict 要单独列 Z 数让 owner 心里有数
- **Tier B 30% 抽样**：不是漏检，是 calibrated trade-off — 日期幻觉率本来就比金额低
- **Tier C 不 fetch**：grep 对照表足够 catch 编造，省 WebFetch 配额
