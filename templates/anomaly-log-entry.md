# 异常上报模板 · 5 类异常 + log append 格式

**这是什么**：v2.1 三轮 patch 后的轻量级异常上报机制。常态跑 NotebookLM 不记 metric，仅遇下面 5 类异常时去本地 log（如 `log.md` / project journal）append 一行结构化条目，攒 ≥ 3 条同模式信号才 retreat 调 SOP。

**怎么用**：跑完 NotebookLM case 后，如果遇到下表任一异常，按格式 append 一行（≤30 秒搞定）。零散一两条不动 SOP，攒 ≥ 3 条同模式才考虑修 PLAYBOOK § 5 或 § 11。

**为什么不记 metric**：NotebookLM case 半月一次，ledger + 5 字段收集 + retreat 聚合 = 维护成本 > 收益。预估数字不准 = 可接受；架构层出问题 = 才值得调。

---

## 5 类异常表

| 异常类型 | 触发线 | log 记什么 |
|---|---|---|
| **fetch 大面积失败** | Tier A WebFetch 成功率 < 50% | 失败信源域名 + paywall 还是 404 |
| **墙钟严重超预估** | 实际核对 > 2× 预估（M 档 > 2h） | 卡哪一步、为什么 |
| **CI 字符爆** | NotebookLM 截断 § 10.0 硬骨架或拒收 CI | 截断点 + 现场 CI 实际字符数 |
| **数字幻觉漏检** | 收尾发现 NotebookLM 编造数字/URL | 编造内容 + 触发场景 |
| **自检 4 块缺失 ≥ 2** | NotebookLM 默默跳过 ≥ 2 块自检 | 跳过哪几块 + 推测原因 |

---

## log entry 格式

```
[YYYY-MM-DD HH:MM] [notebooklm 异常] [类型]
  case: {简短描述 · 变体 · 规模档}
  细节: {按上表"log 记什么"列填}
  影响: ship blocker / 修后 ship / 接受不动
```

---

## 示例 entry

```
[2026-05-18 14:32] [notebooklm 异常] [fetch 大面积失败]
  case: A1 求职 mapping 跨境 fintech 公司 · M 档 · 18 信源
  细节: Tier A 共 12 个数字 · WebFetch 成功 4 个 / paywall 6 个 (bloomberg, theinformation, ft) / 404 2 个
  影响: 修后 ship · 6 个 Tier A 数字标"无法验证 · 待 owner 直接联系信源核实"
```

---

## 聚合规则

```bash
# 周末 / 月末 grep 一次
grep "notebooklm.*异常" log.md | wc -l

# 同模式分组
grep "notebooklm 异常.*fetch 大面积失败" log.md
grep "notebooklm 异常.*墙钟严重超预估" log.md
```

- < 3 条同模式：不动，继续跑 v2.1
- ≥ 3 条同模式：retreat 调 PLAYBOOK § 5 SOP 或 § 11 预估
- **v2.2 触发条件**：本节预估出现**结构性错误**（不是数字偏差），如 Tier A 100% cross-ref 在 paywall 重灾区彻底跑不动 / 规模档 M/L 边界完全画错

---

## 跟其他模板关系

- 异常发现：[verdict-template.md](./verdict-template.md) 跑完 verdict，看到 Z（fetch 失败）/ 待修正 Y / 自检缺失 ≥ 2 → 触发异常 log
- SOP 修订：log 聚合 ≥ 3 条同模式 → 回头看 PLAYBOOK § 5 阶段三 3a 该 step 要不要调
