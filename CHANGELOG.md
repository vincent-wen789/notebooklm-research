# Changelog

All notable changes to this playbook will be documented in this file.

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) but adapted for SOP-style content.

---

## [2.1] · 2026-05-18

### 三轮 patch（2026-05-18 · 反过度工程 · v2.1 内修不 bump）

#### Changed

- § 11 "待 v2.1 case 实测回填" dead promise → 改为"接受不回填 · 出异常再 ad-hoc 调"（NotebookLM case 半月一次，ledger + retreat 维护成本 > 收益）
- § 11 "ship 验证 case 建议" 5 字段收集 → 改为"异常上报机制"：常态不记 metric，仅 5 类异常（fetch < 50% / 墙钟超 2× / CI 爆 / 数字幻觉 / 自检 ≥ 2 块缺失）去 log append 一行，攒 ≥ 3 条同模式信号才 retreat

#### Notes

- v2.2 触发条件：仅由**结构性错误**驱动，不由"凑够数据"驱动

---

### 二轮 review patch（v2.1 内修，未 bump 版本号）

#### Fixed

- § 9 "Tier A 100% cross-ref" 措辞 → 改为"100% 尝试 cross-ref · paywall 失败显式 reporting"（消除与 § 11 "paywall 50% 失败" 的自我矛盾 · review B4）
- § 10.3-10.11 回填政策"主动提议" → 硬挂 § 5 3d checklist（review B5 · 防"主动提议"软触发衰退）

---

### 主轮 v2.1（2026-05-15 · 修复对抗性 review 发现的问题）

#### Fixed — P0 阻塞

- §④ 全量 WebFetch → **分级核对** Tier A/B/C（解决"30 数字 × WebFetch + paywall = 墙钟爆炸"）
- § 10.0 硬骨架 → **瘦身到 301 字符**（实测，解决"CI 10k 字符爆"），字段定义挪到 §③ 报告 prompt
- §④ "prompt 模板" → **SOP 重写 + 明确 tool 调度**（Read/Bash grep/WebFetch · 输出结构化 verdict）

#### Fixed — P1 严重

- §2/§5/§6 SOP 三处重复 → 合并到 § 5 阶段三 3a **单一事实源**
- [#N] 共用规则矛盾 → **数字独立 inline `[#N · 原文引述≤50 字]` · 不许共用**
- 复读机硬阈值 > 3 次 → **改为"引用频次 top 3 + 代表段落"**（防 NotebookLM 故意稀释凑数）
- § 11 ROI "校对工时降 75%" → **标"预估 · 待 v2.1 case 验证"**
- § 3 信源门槛 vs case 规模冲突 → **加规模分级表**（S/M/L · 影响核对策略）
- §6 启动姿势 vs §3 拍板冲突 → **取消"混合区拍板"，默认直跑** + Failsafe 兜底

#### Changed — P2 polish

- aliases 精简为 5 个高价值
- Case Study 明标"当时走 v1 ad-hoc · 非 v2 背书"
- § 10.3-10.11 占位 → **明确回填政策 + 硬触发 checklist**（§ 5 3d 入库不完成 = 回填提议不可跳过）

#### Known Issues · 留 v2.2 实测后再看

- Tier 分级阈值 / 规模 S/M/L 边界 / ROI 30-45min 预估 / § 10.0 瘦身后 §③ 加重 owner 工作 / § 5 3a 嵌套深 — 都是 calibration 问题，需要 v2.1 首个真实 case 数据回填后才能 ground truth

---

## [2.0] · 2026-05-15 (Superseded by 2.1 same day)

### Added

- 三段式 → 四段式架构（加 Claude 收尾核对 SOP）
- § 10.0 硬骨架（首版 · 字符过长 / SOP 与 prompt 混淆，已 v2.1 修复）
- § 5 阶段三 3a 全量核对（首版 · 全量 WebFetch 不可行，已 v2.1 改分级）
- E / F 类变体（E1 跨法域合规扫盲 / F1 事件 timeline 还原）

---

## [1.x] · 2026-04-30 → 2026-05-06

### Added

- 三段式架构（搜索大纲 + Custom Instructions + 报告 prompt）
- 9 变体（A1-A4 / B1-B2 / C1-C3 / D1）
- 三维度判定（规模 / 性质 / 时效）
- § 5 阶段三 3a 抽样核对（v1 时为人脑 grep 抽 3-5 个）
- 启动姿势"默认直跑"（2026-05-06 · 取消问 owner 拍板）
