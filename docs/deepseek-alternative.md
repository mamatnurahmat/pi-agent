# 🔀 DeepSeek Model Configuration

> Alternatif model menggunakan DeepSeek untuk pi multi-agent system
> **Setup:** `cp models.json.example ~/.pi/agent/models.json` lalu isi `$DEEPSEEK_API_KEY`

---

## 📊 Perbandingan Model

| Agent | Claude (Default) | DeepSeek Alternatif | Cost Saving |
|-------|-----------------|-------------------|-------------|
| **Scout** | Haiku ($0.25/M) | **DeepSeek V3** ($0.27/M) | ~sama |
| **Planner** | Sonnet ($3.00/M) | **DeepSeek R1** ($0.55/M) | **~5.5x lebih murah** |
| **Worker** | Sonnet ($3.00/M) | **DeepSeek V3** ($0.27/M) | **~11x lebih murah** |
| **Reviewer** | Sonnet ($3.00/M) | **DeepSeek R1** ($0.55/M) | **~5.5x lebih murah** |
| **Debugger** | Sonnet ($3.00/M) | **DeepSeek R1** ($0.55/M) | **~5.5x lebih murah** |

> *Harga per 1M token input. Output DeepSeek R1 ~$2.19/M, tetap jauh lebih murah dari Sonnet.*
> *DeepSeek V3 mendukung **1M context window**, unggul untuk codebase besar.*

---

## 🧠 Model DeepSeek yang Tersedia

### 1. `deepseek-chat` (DeepSeek V3 — General Purpose)
| Properti | Nilai |
|----------|-------|
| Context | 1,000,000 token |
| Max Output | 8,192 token |
| Input Cost | $0.27 / 1M token |
| Output Cost | $1.10 / 1M token |
| Cache Hit | $0.07 / 1M token |
| Reasoning | ❌ (tidak punya extended thinking) |
| Terbaik untuk | Scout, Worker |

### 2. `deepseek-reasoner` (DeepSeek R1 — Reasoning)
| Properti | Nilai |
|----------|-------|
| Context | 1,000,000 token (64K untuk thinking) |
| Max Output | 8,192 token |
| Input Cost | $0.55 / 1M token |
| Output Cost | $2.19 / 1M token |
| Cache Hit | $0.14 / 1M token |
| Reasoning | ✅ Extended thinking bawaan |
| Terbaik untuk | Planner, Reviewer, Debugger |

---

## ⚙️ Konfigurasi

### File: `~/.pi/agent/models.json`

```json
{
  "providers": {
    "deepseek": {
      "apiKey": "$DEEPSEEK_API_KEY",
      "models": [
        {
          "id": "deepseek-chat",
          "name": "DeepSeek V3",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 1000000,
          "maxTokens": 8192,
          "cost": {
            "input": 0.27,
            "output": 1.10,
            "cacheRead": 0.07,
            "cacheWrite": 0.07
          }
        },
        {
          "id": "deepseek-reasoner",
          "name": "DeepSeek R1",
          "reasoning": true,
          "thinkingLevelMap": {
            "off": null
          },
          "input": ["text"],
          "contextWindow": 1000000,
          "maxTokens": 8192,
          "cost": {
            "input": 0.55,
            "output": 2.19,
            "cacheRead": 0.14,
            "cacheWrite": 0.14
          }
        }
      ]
    }
  }
}
```

> **Catatan:** `deepseek-reasoner` tidak bisa disable thinking (`thinkingLevelMap: {"off": null}`),
> karena R1 selalu menggunakan reasoning. Ini normal untuk model reasoning.

---

## 📝 Agent Config dengan DeepSeek

### Agent Definitions — DeepSeek Variants

Copy agent files berikut untuk menggunakan DeepSeek:

### `scout-deepseek.md`
```yaml
---
name: scout-deepseek
description: Fast codebase reconnaissance using DeepSeek V3. Use for initial investigation.
tools: read,grep,find,ls,bash
model: deepseek-chat
---
```
> Menggunakan **DeepSeek V3** — cepat dan murah untuk scan codebase.
> Kelebihan: context window **1M token** — bisa baca file besar.

### `planner-deepseek.md`
```yaml
---
name: planner-deepseek
description: Implementation plans using DeepSeek R1 reasoning. Use after scout-deepseek.
tools: read,grep,find,ls
model: deepseek-reasoner
---
```
> Menggunakan **DeepSeek R1** — extended thinking untuk analisis mendalam.
> Cocok untuk: perencanaan arsitektur, analisis dependensi.

### `worker-deepseek.md`
```yaml
---
name: worker-deepseek
description: General implementation using DeepSeek V3. Full tool access.
tools: read,bash,edit,write,grep,find,ls
model: deepseek-chat
---
```
> Menggunakan **DeepSeek V3** — eksekusi kode dengan biaya **11x lebih murah** dari Sonnet.
> Hati-hati: V3 bisa **halusinasi** lebih tinggi — review hasilnya baik-baik.

### `reviewer-deepseek.md`
```yaml
---
name: reviewer-deepseek
description: Code review using DeepSeek R1 reasoning. Thorough analysis.
tools: read,grep,find,ls,bash
model: deepseek-reasoner
---
```
> Menggunakan **DeepSeek R1** — reasoning untuk deteksi bug, security, best practices.

### `debugger-deepseek.md`
```yaml
---
name: debugger-deepseek
description: Debugging specialist using DeepSeek R1. Root cause analysis.
tools: read,bash,grep,find,ls
model: deepseek-reasoner
---
```
> Menggunakan **DeepSeek R1** — tracing dan analisis error dengan reasoning.

---

## 📊 Cost Analysis: Claude vs DeepSeek

### Per Task (Chain: Scout → Planner → Worker)

| Skenario | Model | Cost/Task | Budget/hari (50 task) |
|----------|-------|-----------|----------------------|
| **Claude** | Haiku→Sonnet→Sonnet | **~$0.025–0.06** | **$1.25–3.00** |
| **DeepSeek** | V3→R1→V3 | **~$0.003–0.008** | **$0.15–0.40** |
| **Hybrid** | V3→Sonnet→V3 | **~$0.008–0.02** | **$0.40–1.00** |

### Rekomendasi Hybrid (Best Balance)

| Step | Agent | Model | Cost/Step |
|------|-------|-------|-----------|
| 1. Scout | scout-deepseek | DeepSeek V3 | $0.0008 |
| 2. Planner | planner | Claude Sonnet | $0.009-0.015 |
| 3. Worker | worker-deepseek | DeepSeek V3 | $0.002-0.006 |
| 4. Reviewer | reviewer-deepseek | DeepSeek R1 | $0.003-0.008 |
| **Total** | | | **~$0.015-0.03/task** |

---

## 🚀 Setup

```bash
# 1. Set API Key
export DEEPSEEK_API_KEY=sk-xxxxx
# atau via /login di pi
# pi → /login → pilih DeepSeek → masukkan key

# 2. Copy models.json
mkdir -p ~/.pi/agent
cp models.json.example ~/.pi/agent/models.json
# atau langsung buat manual

# 3. Copy agent definitions (opsional — kalau mau pakai agent terpisah)
mkdir -p ~/.pi/agent/agents
cp agents/scout-deepseek.md ~/.pi/agent/agents/
cp agents/planner-deepseek.md ~/.pi/agent/agents/
cp agents/worker-deepseek.md ~/.pi/agent/agents/
cp agents/reviewer-deepseek.md ~/.pi/agent/agents/
cp agents/debugger-deepseek.md ~/.pi/agent/agents/
```

---

## 🎯 Kapan Pakai yang Mana?

| Situasi | Pilihan | Alasan |
|---------|---------|--------|
| **Budget ketat** | DeepSeek semua | 5-11x lebih murah |
| **Codebase besar** | DeepSeek V3 scout | 1M context — bisa baca banyak file |
| **Kode kritis (production)** | Claude Sonnet worker | Akurasi lebih tinggi, halusinasi rendah |
| **Eksplorasi / prototyping** | DeepSeek V3 worker | Cepat & murah |
| **Review keamanan** | DeepSeek R1 / Claude Sonnet | Reasoning mendalam |
| **Best balance** | Hybrid (V3→Sonnet→V3) | Hemat 50% tanpa kompromi kualitas |

---

## ⚠️ Catatan Penting

1. **DeepSeek V3 bisa halusinasi** — selalu review kode yang dihasilkan
2. **DeepSeek R1 selalu thinking** — tidak bisa dimatikan (`thinkingLevelMap: {"off": null}`)
3. **API Key** — set via `DEEPSEEK_API_KEY` env var atau `/login` di pi
4. **Rate Limit** — DeepSeek punya rate limit, siapkan retry logic
5. **Region** — server DeepSeek di China, latency mungkin lebih tinggi
6. **Context window 1M** — hanya DeepSeek yang punya ini, cocok untuk monorepo besar