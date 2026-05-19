# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**クロスホスト対応の Claude × NotebookLM ディープリサーチ skill。NotebookLM が自分で隠している 3 種類の AI 幻覚を捕まえます：捏造された引用 · こっそり改ざんされた数字 · 時間がずれた「現在」の結論。** 4 段階ワークフロー · 各レポートに構造化 verdict を付ける · 感覚でレビューを通さない。

> **正直に言うと**：ChatGPT Deep Research や Perplexity Pro で十分満足しているなら、これは多分必要ありません。あれらのツールが安定して見えるのは、失敗モードが派手に壊れないから。「この引用は私が作りました」という警告は出ない。この skill はその種のサイレントエラーで痛い目を見たことがある人向けです。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.1-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/install-Claude_Code_%7C_Codex_CLI_%7C_Agents_SDK_%7C_Hermes-7C3AED)](#一度インストール--4-つのホストで使える)

### 差別化ポイント

- **またひとつの deep-research wrapper、ではない**。重い仕事は NotebookLM 本体に任せる（15-30 ソースの長 context 合成 · これが NotebookLM の本来の強み）。この skill は 301 文字の Custom Instructions で外側を固める：すべての claim に inline citation を強制 + 事実 / 著者の見解 / 推論のラベル + 3 段階の confidence。
- **数字を自動で cross-ref**。Tier A / B / C の照合：決定に効く数字は 100% WebFetch で逆引き · 時間マーカーは 30% サンプリング · 固有名は源リストに grep で突き合わせ · paywall で fetch 失敗したものは `unverifiable` と明示し、verified だと偽らない。
- **ChatGPT / Perplexity が見逃すものを拾う**。実 vault からのキャプチャ例：NotebookLM が捏造した論文 "Talos: Anatomy of Bitcoin ETF" / "Amberdata: Microstructure of Taker BSR"（両方とも 404 · 著者と所属まで付いて本物っぽく見える）· 「310 万」が言い換えで静かに「350 万」になっていた · 2024 年の「現在」が今日の「現在」として書かれていた · この skill は全部フラグを立てます。
- **一度入れれば 4 つのホストで使える**。Claude Code / Codex CLI / Anthropic Agents SDK / Hermes · source-of-truth は 1 箇所 · 各 host へ symlink · `git pull` 一発で全部更新。
- **隔週メンテ · 1 年回している実 SOP**。Personal vault のメソドロジーを v1 → v2.0 → v2.1 + 3 ラウンドのパッチで反復してきた。スタートアップが量産した wrapper ではない。5 カテゴリの異常検知は実際の事故から削り出したもので、ホワイトボードでひねり出したものではありません。

---

## 痛み

NotebookLM はそれ自体としては良いツールです。ただ素の NotebookLM には、**人がレポートを読んで照合しても拾えない**3 つの系統的なゆがみがあります：

1. **数字幻覚**：source A の「310 万」が source B に紐づけられる · 言い換えで「350 万」に漂う
2. **事実と見解の混在**：source 著者の判断（「市場は過熱している」）が事実として書かれる
3. **時間ドリフト**：source が 2024 年に「現在」と書いた箇所を、NotebookLM もそのまま「現在」と書く

ChatGPT Deep Research と Perplexity にも同じ問題はあります、ただ綺麗な UI で見えなくなっているだけ。市場に出ている他の自動化 wrapper（LangChain · GPT Researcher · 汎用 agent）の大半は verification 層を持たない · 合成したらそのまま出荷。安定して見えるのは派手に壊れないから。壊れ方は静かです：意思決定に使おうとしているレポートの数字が、微妙に間違っている。

## インストールしたくない？まず 301 文字の魔法プロンプトだけ試す

これを NotebookLM の Notebook Settings → Custom Instructions に貼るだけ、ゼロインストール：

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

Before / after：

- **Before**：NotebookLM が「現在、業界の主流ソリューションは XYZ」と書く · 引用は塊で · 事実と見解が混在 · 数字も幻覚
- **After**：すべての claim に `[#N]` · `[事実]` / `[作者観点]` / `[推論]` ラベル · `截至 YYYY-MM-DD（[#N] 发布日期）` · 3 段階 confidence

これは skill 内蔵 4 段階ワークフローの Stage 2 の一部に過ぎません · これだけ単体で使っても NotebookLM の出力品質は即座に上がります。skill を入れるとさらに：Stage 1 の自動 variant 選択（A1 mapping / B1 narrative / C1 compliance など 11 種類）· Stage 4 の自動 Tier A/B/C 数字逆引き · 捏造論文の検出（下の「使った感覚」を参照）。

## 一度インストール · 4 つのホストで使える

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/wjameswen888/notebooklm-research/main/install.sh)
```

インストーラはマシン上の AI host のパスを自動検出し、見つかった先すべてに skill を配置します：

- `~/.claude/skills/` · Claude Code CLI
- `~/.agents/skills/` · Anthropic Agents SDK · OpenAI Codex CLI
- `~/.codex/skills/` · Codex CLI 予備パス
- `~/.hermes/skills/` · Hermes

Source-of-truth は `~/.local/share/notebooklm-research/` · `git pull` 一発ですべての host が更新される · `./install.sh --uninstall` でクリーン撤去。

フラグ：`--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force`

## 一行で起動

任意の host にインストール後：

```
/notebooklm-research "<調査したいトピック>"
```

または自然言語で：「crypto+AI スタートアップの採用マッピングをして」 ·「X 領域の弾薬庫を整理して」 ·「X を日本へ持ち込むコンプライアンス調査をして」 · これらの intent は skill が自動で拾います、**NotebookLM の名前を出す必要はありません**。

## 使った感覚

一度インストール。その後こう言う：

```
/notebooklm-research "Crypto+AI スタートアップ 2026 採用マッピング"
```

Skill は 4 つの Stage を回します：

**Stage 1 · variant + 規模**。デフォルトは A1（mapping）+ M 規模（15-30 ソース）。明らかに S か L 寄りのときだけ聞く。

**Stage 2 · 検索アウトライン**。skill が検索アウトラインを吐くので、NotebookLM の **Deep Research mode** に貼る：

```
NotebookLM Deep Research · 搜索大纲
[トピック + バイリンガルキーワード + スコープ制限 + ソース種別の優先 + 出力要件]
```

NotebookLM が走り終わるとソースリストが返ってきます。あなたが目を通して、品質が低いものや脱線したものを切る。

**Stage 3 · Custom Instructions**。ソースの審査が終わったら、skill が variant ごとの CI を吐く（301 文字の硬骨格を含む）：

```
## 来源与可核对性（硬要求）
1. 事实/数字/引述句末必带 [#N]
2. 数字独立 [#N · 原文引述≤50 字]，不许多条共用
3. 每条陈述前缀 [事实]/[作者观点]/[推论] 三选一
...
```

NotebookLM の **Notebook Settings → Custom Instructions** に貼る（永続プリセット）。この notebook 以降のレポートはすべてこのルールで動きます。

**Stage 4 · 最終照合**。完成したレポートを skill に渡し直す。skill は Tier A / B / C verification を回し、構造化 verdict を吐きます：

```
【Tier A · 決定数字】 計 12 / cross-ref 成功 9 / 要修正 1 / fetch 失敗 2 (paywall)
【Tier C · 固有名】 レポート内 23 / 源リスト内 21 / ゼロヒット 2
                    (未検証: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【総合】 ⚠ 修正後 ship
```

加えて 5 種類の異常自動検知：fetch <50% · 壁時計 >2× · CI 違反 · 数字幻覚 · 自己診断ブロック欠落 ≥ 2 · どれか hit したら 1 件ログを残し、NotebookLM の挙動変化を追えるようにする。

## 他ツールとの比較

| ツール | 深さ | Citation の規律 | 数字 cross-ref | コスト |
|------|------|---------------|----------------|------|
| ChatGPT Deep Research | 中 | 弱（citation はあるが幻覚は出る） | ❌ | $20/月 |
| Perplexity Deep Research | 中 | 弱 | ❌ | $20/月 |
| GPT Researcher · 類似 wrapper | 低（合成が浅い） | なし | ❌ | self-host |
| 素の NotebookLM | 高（長 context 合成） | なし（3 大ゆがみ無防備） | ❌ | 無料（Plus $20/月は任意） |
| **NotebookLM + 本 skill** | **高** | **4 層の強制防御** | **✅ Tier A/B/C 自動** | **無料**（skill 無料 + NotebookLM 無料枠で足りる） |

この skill は deep-research ツールの代替ではありません。**NotebookLM という 1 つのツールに、自分の失敗を捕まえさせる**ためのものです。

## 11 種類の variant をカバー

| 系列 | コード | 用途 |
|------|-------|------|
| A · Mapping | A1, A2, A3, A4 | 業界 · ツール · 地域 · 人物のマッピング |
| B · Narrative | B1, B2 | ストーリー弾薬 · 逆方向ナラティブ |
| C · Compliance | C1, C2, C3 | 規制 · 標準 · 政策の入門整理 |
| D · Timeline | D1 | 事件タイムライン |
| E · 跨法域 | E1 | 複数地域コンプライアンス |
| F · ユーザーペルソナ | F1 | ユーザーペルソナ · marketing |

A1 · B1 の完全テンプレ · 硬骨格 · verdict · anomaly-log は [`templates/`](./templates/) に。他 variant のフレームは [PLAYBOOK § 10.3+](./PLAYBOOK.md) に · fork して改造、または PR で埋めてもらえると嬉しい。

## リポジトリ構成

```
notebooklm-research/
├── SKILL.md              ← skill 本体（host はこれを読む）
├── install.sh            ← クロス host インストールスクリプト
├── README.md             ← 英語（主ページ）
├── README.zh.md          ← 中文
├── README.ja.md          ← あなたが読んでいるもの
├── PLAYBOOK.md           ← v2.1 完全仕様（深い参考 · 624 行）
├── CHANGELOG.md          ← v1 → v2.0 → v2.1 → 3 ラウンドのパッチ
├── templates/            ← テンプレ（CI · verdict · anomaly-log · 貼ればすぐ使える）
└── LICENSE               ← MIT
```

## メンテのリズム

Personal vault workflow · 隔週でメンテ · share as-is。Issue 対応は保証しない · PR 歓迎だが merge のリズムは owner 次第。

## 関連プロジェクト

[ORP (Obsidian RAG Protocol)](https://github.com/wjameswen888/obsidian-rag-protocol) · ORP は vault → AI agent の state / memory プロトコル。本 skill は research handoff のワークフロー仕様。隣接しているが疎結合。

## ライセンス

MIT
