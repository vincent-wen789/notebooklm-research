# notebooklm-research

🌐 [English](README.md) | [中文](README.zh.md) | [日本語](README.ja.md)

**NotebookLM に、自分の幻覚を自分で捕まえさせる：捏造された引用、こっそり変わる数字、時間がずれた「現在」の結論。** 4 段階のリサーチワークフロー——プロンプトを手で貼るだけでも使えるし、agent skill としてインストールもできる。各レポートには構造化された判定（verdict）が付き、「なんとなく OK」でレビューを通しません。

> **正直に言うと**：ChatGPT Deep Research や Perplexity Pro で十分満足しているなら、これは多分必要ありません。あれらのツールが安定して見えるのは、失敗モードが派手に壊れないから。「この引用は私が作りました」という警告は出ない。この skill はその種のサイレントエラーで痛い目を見たことがある人向けです。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill version](https://img.shields.io/badge/skill-v2.3-blue)](./CHANGELOG.md)
[![Cross-host](https://img.shields.io/badge/install-Claude_Code_%7C_Codex_%7C_Cursor_%7C_Windsurf_%7C_Copilot_%7C_Gemini-7C3AED)](#インストール--ネイティブ-skill-ホストclaude-code--codex)

**必要なもの**：[NotebookLM](https://notebooklm.google.com)（Google アカウントで無料）。ゼロインストールの道ならこれだけで OK。フルの 4 段階ワークフローにはさらに AI コーディングエージェント——[Claude Code](https://claude.com/claude-code)、Codex、Cursor など（目安として月 $20 前後から。ツールごとに異なる）——と、インストール用のターミナル（コマンドを打つ黒い画面）が要ります。

## 何が問題か

NotebookLM はそれ自体としては良いツールです。ただ素の NotebookLM には、**人がレポートを読んで照合しても拾えない** 3 つの系統的なゆがみがあります：

1. **数字の幻覚**：source A の「310 万」が source B に紐づけられる。言い換えのうちに「350 万」へ変わる
2. **事実と見解の混在**：source 著者の判断（「市場は過熱している」）が事実として書かれる
3. **時間のドリフト**：source が 2024 年に「現在」と書いた箇所を、NotebookLM もそのまま「現在」と書く

ChatGPT Deep Research と Perplexity も同じ種類の失敗を抱えています。綺麗な UI で見えなくなっているだけ。市場に出ている他の自動化 wrapper（LangChain、GPT Researcher、汎用 agent）の大半は verification 層を持たず、合成したらそのまま納品します。安定して見えるのは派手に壊れないから。壊れ方は静かです：意思決定に使おうとしているレポートの数字が、微妙に間違っている。

このプロジェクトはすべてのツールを直そうとはしません。NotebookLM というひとつのツールに、自分の失敗を捕まえさせます。

## インストールしたくない？まずコピペ用プロンプトだけ試す

[NotebookLM](https://notebooklm.google.com) を開き、ノートブックの **Notebook Settings → Custom Instructions** にこれを貼るだけ。ゼロインストール：

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

**エンジニアじゃない方へ：この貼り付けだけで完了です——以下のインストール手順は読まなくて OK。** 上の 6 ルールが重いと感じたら、平易な 4 ルール版（`[#N]` 記法も専門用語もなし）をどうぞ。こちらを貼ってください：

```
このノートに書くすべての文について：
1. 事実・数字・引用の後ろに [1]、[2]、[3]… を付け、最後に対応する出典（タイトル + リンク）を一覧にする。
2. 見解や自分の推測である文は、冒頭に「見解：」または「推測：」と書く。事実として書かない。
3. 日付は「2025 年 3 月時点…」のように省略せず書く。「現在」「最近」は使わない。
4. ある主張の根拠が 1 つの出典しかない場合は「（単一出典）」と付け、未確認だと分かるようにする。
```

中文 / 日本語の同版：[`templates/simple-prompt.md`](./templates/simple-prompt.md)。フル 6 ルール版は EN / ZH / JA 版が [`templates/ci-hard-skeleton.md`](./templates/ci-hard-skeleton.md) にあります。

**貼るだけで得られるもの**：引用とラベルの規律——NotebookLM の出力品質はすぐ一段上がります。**貼るだけでは得られないもの**：捏造論文や数字のずれを自動で捕まえる Stage 4 の照合——そこは skill を動かすエージェントが必要です（インストールは下記）。2 つの版の選び方：4 ルール版でも核心的な保護（出典、見解ラベル、日付の明記、単一出典フラグ）はそのまま。6 ルール版はそれに加えて、自動照合が読み取る厳密な記法が付きます。この貼り付け内容は、フル 4 段階ワークフローのうち Stage 3 の中核ルールです。

Before / after：

- **Before**：NotebookLM が「現在、業界の主流ソリューションは XYZ」と書く。引用は塊で、事実と見解が混在、数字も幻覚
- **After**：すべての claim に `[#N]`、`[事実]` / `[見解]` / `[推論]` ラベル、`YYYY-MM-DD 時点（[#N] 公開日）`、3 段階 confidence

## 差別化ポイント

- **またひとつの deep-research wrapper、ではない**。重い仕事は NotebookLM 本体に任せる（15-30 ソースの長 context 合成——これが NotebookLM の本来の強み）。この skill はコンパクトな Custom Instructions で外側を固める：すべての claim に inline citation を強制し、事実 / 見解 / 推論のラベルと 3 段階の confidence を付けさせる。
- **数字は目視ではなく、元ソースに当たって照合される**。完成レポートを渡し返すと Stage 4 が Tier A / B / C の照合を回す：意思決定に効く数字は 1 つずつ web フェッチで元ソースと突き合わせ、時間マーカーはサンプリング検査、固有名詞は出典リストと照合。paywall で取得に失敗したものは `unverifiable` と明示し、verified だと偽らない。正直に言うと：ワークフロー自体は人が貼り付けて渡す往復ループで、自動なのは照合のステップです。
- **検知ルールは実際の事故から生まれた**。実 vault からのキャプチャ例（[原本の記録はこちら](./examples/fabricated-source-catch.md)）：NotebookLM が捏造した論文 "Talos: Anatomy of Bitcoin ETF" / "Amberdata: Microstructure of Taker BSR"（両方とも 404。なのに著者と所属まで付いて本物っぽく見える）、「310 万」が言い換えで静かに「350 万」になっていた、2024 年の「現在」が今日の「現在」として書かれていた——この skill は全部フラグを立てます。
- **スタック全体にインストールできる**。ネイティブ `SKILL.md` host（Claude Code · Codex · Agents SDK · Hermes）は自動検出インストーラ、ルールファイル型 agent（Cursor · Windsurf · Copilot · Gemini · Aider）は 1 行の pointer を貼るだけ。source-of-truth は 1 箇所、`git pull` 一発で全部更新。
- **事故駆動の反復改善、机上の設計ではない**。Personal vault のメソドロジーを v1 → v2.3 と反復し、どのパッチも実際の失敗に遡れる——記録は [CHANGELOG](./CHANGELOG.md) に。

## インストール · ネイティブ skill ホスト（Claude Code · Codex）

`SKILL.md` はクロス agent のオープン標準です。インストーラはそれをネイティブに読む host を自動検出し、各所へ symlink します。このコマンドは**ターミナルで**実行します（macOS / Linux。Windows は WSL か Git Bash で）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
```

- `~/.claude/skills/` · **Claude Code CLI**
- `~/.codex/skills/` · **OpenAI Codex CLI** — 2025 年 12 月から `SKILL.md` をネイティブに読む
- `~/.agents/skills/` · Anthropic Agents SDK
- `~/.hermes/skills/` · Hermes *(作者の個人的な自律 agent ランタイム — 使っていなければ無視)*

Source-of-truth は `~/.local/share/notebooklm-research/`。`git pull` 一発ですべての host が更新され、`./install.sh --uninstall` でクリーンに撤去できます。

フラグ：`--dry-run` · `--hosts claude,codex` · `--uninstall` · `--force` · `--print-agents-snippet`

**動作確認**：エージェントを開いて `/notebooklm-research "test"` と打つ——Stage 1 の variant / 規模の質問が返ってくれば成功です。

## インストール · その他の agent（Cursor · Windsurf · Copilot · Gemini · Aider …）

これらの agent には **skill の概念がなく**、常駐の指示ファイルしか読みません。`SKILL.md` を symlink しても何も起きません。代わりに、そのファイルへ短い *pointer* を貼ります（agent はワークフロー本体を必要時に読むので context をほぼ消費しません）。

**Step 0 · ファイルをローカルに置く。** pointer は skill のファイルを参照するので、まず一度取得します（これもターミナルで）。ネイティブ skill host が無いマシンでは、インストーラはソースを `~/.local/share/notebooklm-research/` に clone して、このセクションへ案内するだけです：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vincent-wen789/notebooklm-research/main/install.sh)
# またはスクリプト無し：git clone https://github.com/vincent-wen789/notebooklm-research ~/.local/share/notebooklm-research
```

**Step 1 · プロジェクトの指示ファイルへ pointer を追記：**

```bash
# プロジェクト内で — pointer を AGENTS.md に追記
sed -n '/^## Deep research/,/Emit all output/p' ~/.local/share/notebooklm-research/templates/agents-md-snippet.md >> ./AGENTS.md
```

| Agent | 読むファイル |
|-------|-------------|
| Cursor · Windsurf · Aider · Zed · Jules · Amp · Devin · JetBrains Junie · VS Code | プロジェクトの `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md`（または `AGENTS.md`） |
| Gemini CLI | `GEMINI.md` |

`AGENTS.md` は [Linux Foundation 管理のオープン標準](https://agents.md/)で、ほとんどの agent が読みます — 一度貼ればスタック全体をだいたいカバー。詳細 + 生のブロック：[`templates/agents-md-snippet.md`](./templates/agents-md-snippet.md)（または `install.sh --print-agents-snippet`）。

**ここで実際に動く範囲。** Stage 1-3（NotebookLM に渡す prompt）はどの agent でも動きます — 価値の大半はここ。Stage 4 の自動数字照合には web-fetch ツールが必要：持っている agent（Cursor、Codex など）なら動き、無ければ citation 規律のあるレポートは得られるので、フラグの付いた数字を手で確認します。Stage 1 の対話的な variant 選択は、ネイティブの質問 UI が無い agent ではプレーンテキストの prompt にフォールバックします。

## 一行で起動

インストール後、エージェント側でこう打つ（NotebookLM 側ではありません）：

```
/notebooklm-research "<調査したいトピック>"
```

または自然言語で：「crypto+AI スタートアップの採用マッピングをして」「X 業界のネタ集めをして」「X を日本へ持ち込むコンプライアンス調査をして」——これらの意図は skill が自動で拾います。**NotebookLM の名前を出す必要はありません**。

## 実際の流れ

先にループの形を正直に：**エージェントと NotebookLM が直接通信することはありません**——各 stage で skill が成果物を出力し、あなたが NotebookLM へ貼り、NotebookLM の出力を持ち帰ります。自動化されているのは照合の計算で、貼り付けの往復は手動のままです。

インストールは一度だけ。あとはこう言う：

```
/notebooklm-research "Crypto+AI スタートアップ 2026 採用マッピング"
```

Skill は 4 つの Stage を回します：

**Stage 1 · variant + 規模**。デフォルトは A1（mapping）+ M 規模（15-30 ソース）。明らかに S か L 寄りのときだけ聞く。

**Stage 2 · 検索アウトライン**。skill が検索アウトラインを出力するので、NotebookLM の **Deep Research mode** に貼る：

```
NotebookLM Deep Research · 検索アウトライン
[トピック + バイリンガルキーワード + スコープ制限 + ソース種別の優先 + 出力要件]
```

NotebookLM が走り終わるとソース一覧が返ってきます。あなたが目を通して、品質が低いものや脱線したものを切る。

**Stage 3 · Custom Instructions**。ソースの審査が終わったら、skill が variant ごとの Custom Instructions（以下 CI）を出力する（必須ルールの hard skeleton を含む）：

```
## ソースと照合可能性（必須要件）
1. 事実 / 数字 / 引用の文末に必ず [#N]
2. 数字は独立した [#N · 原文引用 50 字以内] · 複数で共用しない
3. 各記述の冒頭に [事実] / [見解] / [推論] のいずれか一つ
...
```

NotebookLM の **Notebook Settings → Custom Instructions** に貼る（永続プリセット）。この notebook 以降のレポートはすべてこのルールで動きます。

**Stage 4 · 最終照合**。完成したレポートを skill に渡し直す。skill は Tier A / B / C verification を回し、構造化 verdict を出力します：

```
【Tier A · 決定数字】 計 12 / cross-ref 成功 9 / 要修正 1 / fetch 失敗 2 (paywall)
【Tier B · 時間マーカー】 計 9 / サンプル 3 / 通過 3
【Tier C · 固有名】 レポート内 23 / 出典リスト内 21 / ゼロヒット 2
                    (未検証: "Talos Anatomy of Bitcoin ETF" / "Amberdata Microstructure" — likely fabricated)
【総合】 ⚠ 修正後 ship
```

加えて 5 種類の異常自動検知：fetch 成功率 <50% · 検証の所要時間が規模の想定の 2 倍超 · CI が NotebookLM に無視/切り詰められた · 数字の幻覚 · 自己診断 4 ブロック中 2 つ以上が欠落。どれかに当たると 1 件ログを残し、NotebookLM の挙動変化を追えるようにします。

**所要時間も正直に**：1 周のフルループ = NotebookLM 自身の Deep Research 実行 + あなたのソース審査 + Stage 4 の照合。照合だけで S 規模なら約 15-30 分、M なら 30-60 分、L は数時間（規模の段階分けはこのためにあります）。

## 他ツールとの比較

| ツール | 深さ | Citation の規律 | 数字 cross-ref | コスト |
|------|------|---------------|----------------|------|
| ChatGPT Deep Research | 中 | 弱（citation はあるが幻覚は出る） | ❌ | $20/月 |
| Perplexity Deep Research | 中 | 弱 | ❌ | $20/月 |
| GPT Researcher · 類似 wrapper | 低（合成が浅い） | なし | ❌ | self-host |
| エージェント単体（Claude / GPT + web 検索） | 低〜中（1 回のソース数が少ない） | 中（fetch したものは引用する） | ❌ | すでに払っている分 |
| 素の NotebookLM | 高（長 context 合成） | なし（3 つのゆがみに無防備） | ❌ | 無料（Plus は任意） |
| **NotebookLM + 本 skill** | **高** | **強制：inline `[#N]` + 事実/見解/推論ラベル + 時点表記 + confidence 段階** | **✅ Tier A/B/C 自動** | **skill 無料（MIT）** |

コストの補足：NotebookLM 無料枠には Deep Research の 1 日あたり回数制限があります（上限は変わるので公式を確認）。S / M 規模なら十分収まります。Stage 4 はあなた自身のエージェントの利用枠で動きます——そこはすでに払っている分です。

この skill は deep-research ツールの代替ではありません。**NotebookLM という 1 つのツールに、自分の失敗を捕まえさせる**ためのものです。

## 12 種類の variant フレーム（A1 · B1 は完全テンプレあり · 残り 10 は枠のみ）

| 系列 | コード | 用途 |
|------|-------|------|
| A · 認知拡張 | A1 領域マッピング · A2 概念の深掘り · A3 トレンド調査 · A4 規制変更トラッキング | 「X 業界を map して」·「Y の全体像を掴みたい」 |
| B · ナラティブ | B1 ストーリー素材のリサーチ · B2 歴史の振り返り | 創作・記事の下調べ ·「1929 年から何を学べるか」 |
| C · 意思決定支援 | C1 競合分析 · C2 技術選定 · C3 面接前の企業情報 | 「X vs Y」·「どのスタックにする」· 面接準備 |
| D · 市場/ユーザー調査 | D1 ユーザーペルソナ + チャネル | プロダクト launch のユーザー調査 |
| E · コンプライアンス | E1 複数法域コンプライアンス入門 | 「Y 市場で X をやって合法か」 |
| F · イベント/タイムライン | F1 事件タイムライン再構成 | 「X で実際に何が起きたのか」 |

A1 · B1 の完全テンプレ、hard skeleton、verdict、anomaly-log は [`templates/`](./templates/) に。残り 10 のフレーム定義は [PLAYBOOK § 4](./PLAYBOOK.md)（現状中国語のみ——同じ表の英語版は SKILL.md に内蔵）。fork して改造、または PR でテンプレを埋めてもらえると嬉しい。

## リポジトリ構成

```
notebooklm-research/
├── SKILL.md              ← skill 本体（host はこれを読む · 英語）
├── install.sh            ← クロス host インストールスクリプト
├── README.md             ← 英語（主ページ）
├── README.zh.md          ← 中文
├── README.ja.md          ← あなたが読んでいるもの
├── PLAYBOOK.md           ← 完全仕様（深い参考 · 現状中国語のみ）
├── CHANGELOG.md          ← v1 → v2.3
├── templates/            ← テンプレ（CI · verdict · anomaly-log · 貼ればすぐ使える）
├── examples/             ← 実キャプチャ（捏造論文の検出記録 · 原本ノート）
└── LICENSE               ← MIT
```

## メンテのリズム

Personal vault workflow · 隔週でメンテ · share as-is。Issue 対応は保証しない · PR 歓迎だが merge のリズムは owner 次第。

## 関連プロジェクト

[ORP (Obsidian RAG Protocol)](https://github.com/vincent-wen789/obsidian-rag-protocol) · ORP は vault → AI agent の state / memory プロトコル。本 skill は research handoff のワークフロー仕様。隣接しているが疎結合。

## ライセンス

MIT
