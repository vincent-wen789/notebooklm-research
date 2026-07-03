# Real capture · two fabricated papers in one NotebookLM report

This is the incident the README refers to. Excerpted from the author's research vault (May 2026, a crypto multi-signal validation study), lightly trimmed; the Chinese passages are the original working notes, kept verbatim for authenticity.

## What NotebookLM emitted

The report's "Top 5 papers to read" section confidently recommended, among others:

> 1. Microstructure of the Taker Buy/Sell Ratio: Price Impact and Conviction
> * 为什么 informative: 由 Amberdata 量化团队发布的机构层面研究，系统性分析了加密货币衍生品微观结构中 Taker 订单流动态对价格冲击的实质影响，为衍生品信号交叉验证提供了极具针对性的微观依据。
> * URL: https://amberdata.io/blog/taker-buy-sell-microstructure/
> * 预估阅读时间: 30 分钟
> 1. The Anatomy of the Bitcoin Spot ETF: Cash Create vs. In-Kind Mechanics
> * …

Author and institution attached, a plausible URL, an estimated reading time, and a paragraph explaining *why* the paper matters. Everything about these entries looks legitimate.

## What the Tier C check found

Both URLs were fetched during the verification pass (Stage 4, named-entity tier): **404. Neither paper exists.** From the cross-confirmation notes:

> **§Top 5 内含矛盾**: Q2 Q3 declared gap 后 §Top 5 又给 Amberdata + Talos URL 凑数。Agent 验证两个 URL 都 **404 hallucinated**。

The tell that a human reviewer would likely have missed: earlier in the *same report*, NotebookLM had honestly declared a literature gap for exactly these questions — then fabricated two "institutional" papers a few sections later to fill its own "Top 5" quota.

## Root cause · the "give me N" trap

The failure wasn't random. The prompt's output schema demanded a Top-**5** list; NotebookLM had only ~3 real candidates, and under a strict anti-hallucination prompt it still chose to invent plausible entries rather than deliver a short list:

> 即使你硬性禁掉 synthesis / generic-title / paraphrase 数字，只要你写"给我 5 个 paper"，它会在没有 5 个真实候选时编出 plausible 的 URL 来填空。

Two lessons folded back into this playbook:

1. **Schema fix**: never ask for "exactly N" — ask for "≤ N, and 0 is acceptable". (Escape hatch in the report prompt.)
2. **Verification fix**: a strict prompt is necessary but not sufficient. The last line of defense is mechanical — fetch every URL, verify every DOI. That's what Stage 4 Tier C automates.

## Why this example is here

The README claims this skill "catches fabricated citations". A claim like that deserves a receipt — this is one, from a real run, with the original notes. If you run the workflow and catch one of your own, a PR adding it here is welcome.
