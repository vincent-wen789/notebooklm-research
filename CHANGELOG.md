# Changelog

All notable changes to this playbook will be documented in this file.

Format inspired by [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) but adapted for SOP-style content. Each release opens with an English summary; the detailed notes below it are working records in Chinese.

---

## [2.3] · 2026-07-04 · taxonomy repair + install hardening

**EN summary**: a multi-lens review (correctness + intent lenses, 4 cold-read personas, adversarial verification pass) found the variant taxonomy in SKILL.md/READMEs had drifted from PLAYBOOK § 4 — 8 of 12 codes meant different things, so an agent picking a code at Stage 1 could emit the wrong framework at Stage 3. This release realigns everything to the PLAYBOOK taxonomy (spec-of-record), hardens `install.sh` edge cases, clears the remaining i18n stragglers, and fixes every cross-file numeric inconsistency the review caught.

### Fixed

- **变体编号漂移（运行时会坏）**：SKILL/README 写 C1=合规、D1=时间线、F1=画像，而 PLAYBOOK § 4（及 templates / 历史 CHANGELOG）是 C=决策辅助、D=画像、E=合规、F=时间线。已把 SKILL/README 对齐到 PLAYBOOK 编号；SKILL Stage 1 表格内嵌每个变体的英文输出框架（runtime 不再依赖中文 PLAYBOOK）
- **「11 个变体」数错了**——实际 12 个码（2 有模板 + 10 雏形）。README ×3 / SKILL.md / PLAYBOOK § 4 标题一并修正
- **install.sh**：`--uninstall` 不再先 clone/pull（离线可用）；无原生 host 的机器改为 exit 0 + rules-based agent 指引（兑现 README 的「无害」承诺）；未知 `--hosts` key 显式报错；`--help` 与收尾提示不再依赖 `$0`（curl-pipe 下是耗尽的 /dev/fd）；从本地 checkout 安装时警告 symlink 悬空风险
- **magic prompt 标成「Stage 2 片段」**（实为 Stage 3 硬骨架）——三语 README 修正；根因是 PLAYBOOK ①-④ 编号错位泄漏
- **PLAYBOOK 陈旧引用**：8 处仍指向旧编号 § 9 的模板库（vault→开源重排后应为 § 10）；「约 320 中文字符」与实测 301 矛盾；§ 12 加指针说明 v2.2+ 记录在本文件
- **SKILL.md i18n 残留**（违反它自己的 output-language 铁律）：中文 fallback 提问、Stage 2 搜索大纲模板、Stage 4 verdict 模板与括注——全部改英文为主 + 「emit in the user's language」
- **README.ja 中文直译腔**：痛み → 何が問題か、弾薬庫 → ネタ集め、跨法域 → 複数法域、硬骨格 → hard skeleton（必須ルール）、壁時計 → 所要時間、源対照表/源リスト → 出典対照表/出典リスト（templates ja 块同步）

### Changed（README · 第二轮 persona 冷读驱动）

- Tagline 先说事（"make NotebookLM catch its own hallucinations"），不先甩 "cross-host skill" 术语
- 新增「What you need」（NotebookLM 链接 / agent / 终端）、「在终端里跑」、装完验证步骤、诚实时间账、NotebookLM 免费层配额小字、对比表加「你的 agent 裸跑」基准行
- 「4 层防御」改为逐项列出四层；verdict 示例补上 Tier B；硬编码「624 行」删除
- 「抓 ChatGPT/Perplexity 漏的」收窄到证据支持的范围；「跑了 1 年」改为可由 CHANGELOG 追溯的迭代表述
- 「人在环里」从括号注释提升为「用起来什么感觉」开头的显式说明

---

## [2.2] · 2026-06-26 · i18n + simple mode

**EN summary**: output language now follows the user (was hardcoded Chinese), a plain-language "simple mode" for non-technical users, and real install paths beyond Claude Code (native hosts + rules-based agents via AGENTS.md pointer).

调研发现 skill 对非中文用户实际不可用：所有 example / template 硬编码中文，且模板写死「中文输出」强制 NotebookLM 用中文回。同时缺一个给非技术用户的降级版。本次修复。

### Fixed

- **输出语言强制中文** → SKILL.md 新增「Output language · match the user」硬规则：检测用户语言，所有产出（搜索大纲 / CI / verdict）随之；模板里写死的 `中文输出（…）` 改为 `输出语言：匹配用户的研究语言`（ci-A1 / ci-B1 / PLAYBOOK §10.1/10.2）
- **README 例子语言对不上** → README.md 的 magic prompt / Stage 2-3 例子块改英文；README.ja.md 改日文（之前都贴的中文块）
- **install URL / ORP 链接指向旧账号 `wjameswen888`**（已 301 重定向但 stale）→ 全部改 `vincent-wen789`

### Added

- `templates/ci-hard-skeleton.md` 现提供 EN / ZH / JA 三版硬骨架（之前仅中文）
- `templates/simple-prompt.md` · 给非技术用户的大白话降级版：1 个 prompt、零安装、无变体、无 Tier A/B/C、无 `[#N]` 术语，4 条核心规则，EN / 中文 / 日本語三语
- SKILL.md 新增「Two modes · full vs simple」：非 power-user 直接走 simple-prompt

### Install reach（除 Claude Code 外的 agent）

之前 installer 号称 4 host 但实际只有 Claude Code 真能用。核实后修正：

- **澄清 Codex 已原生支持**：`SKILL.md` 2025-12 起成跨 agent 开放标准，Codex CLI 原生读 `~/.codex/skills/`——installer 这条路径其实已对，README / SKILL.md / install.sh 据此重写「native skill host」框架（Claude Code + Codex）
- **新增 rules-based agent 安装路径**：Cursor / Windsurf / GitHub Copilot / Gemini CLI / Aider / Zed 等没有 skill 概念，只读常驻指令文件 → 新增 `templates/agents-md-snippet.md`（往 `AGENTS.md` / `GEMINI.md` 贴一段 pointer，按需读 SKILL.md，几乎不占 context），三个 README 加「其他 agent」安装章节 + 每工具读取文件对照表
- `install.sh` 新增 `--print-agents-snippet` flag + 头部注释 / 收尾提示更新；host 列表去掉误导性的「Codex fallback path」重复项

### README clarity（4-persona 冷读审计驱动 · README-only · 不 bump）

跑 persona audit,跨镜头共识修了 README 几处:

- **安装故事自相矛盾** → differentiator 还留着旧的「四个 host」(Cursor 在 badge 里却不在四个里) → 改写成「native skill host vs rules-based agent」两层,与 badge 一致(三语)
- **rules-based 安装缺第零步** → 「其他 agent」那段直接 `sed ~/.local/share/...`,但该路径要先跑 install.sh 才存在 → 加 Step 0(curl / git clone 取源)+ Step 1(贴 pointer)(三语)
- **没说非原生 host 上 Stage 4 跑不跑** → 加「这里实际跑得起来的部分」:Stage 1-3 任何 agent 都行,Stage 4 自动反查需宿主联网工具、没有则手动核(三语)
- **简版藏在文件链接里** → 大白话 4 条版直接 inline 到 README + 加「不懂技术?只需这一步」signpost(三语)
- 软化「数字自动 cross-ref」→「被反查的,不是眼睛扫的」(承认是 human-in-the-loop);`Hermes` 加一句脚注;「11 variants covered」→「A1·B1 有模板·其余 9 雏形」

---

## [2.1] · 2026-05-18

**EN summary**: tiered Tier A/B/C verification (full WebFetch was infeasible), the 301-char hard skeleton, single-source-of-truth SOP — all driven by three adversarial review rounds.

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

**EN summary**: three-stage → four-stage architecture (adds the Claude-side verification SOP); E/F variant families join.

### Added

- 三段式 → 四段式架构（加 Claude 收尾核对 SOP）
- § 10.0 硬骨架（首版 · 字符过长 / SOP 与 prompt 混淆，已 v2.1 修复）
- § 5 阶段三 3a 全量核对（首版 · 全量 WebFetch 不可行，已 v2.1 改分级）
- E / F 类变体（E1 跨法域合规扫盲 / F1 事件 timeline 还原）

---

## [1.x] · 2026-04-30 → 2026-05-06

**EN summary**: initial three-stage architecture, the first variant families, and human-sampled verification.

### Added

- 三段式架构（搜索大纲 + Custom Instructions + 报告 prompt）
- 9 变体（A1-A4 / B1-B2 / C1-C3 / D1）
- 三维度判定（规模 / 性质 / 时效）
- § 5 阶段三 3a 抽样核对（v1 时为人脑 grep 抽 3-5 个）
- 启动姿势"默认直跑"（2026-05-06 · 取消问 owner 拍板）
