# 🔀 OpenRouter + DeepSeek Model Configuration

> **Default setup:** OpenRouter sebagai provider dengan model DeepSeek V3 (hemat) dan R1 (reasoning)
> **API Key:** `export OPENROUTER_API_KEY=sk-or-...`
> **Setup:** `cp models.json.example ~/.pi/agent/models.json`

---

## 🏗️ Arsitektur

```
User ──► Pi Agent ──► OpenRouter ──► DeepSeek API
                          │
                          ├─ deepseek/deepseek-chat (V3) — $0.30/M input
                          └─ deepseek/deepseek-r1 (R1)  — $0.55/M input
```

---

## 📊 Perbandingan Biaya (via OpenRouter)

| Model | OpenRouter ID | Input/M | Output/M | vs Claude Sonnet |
|-------|--------------|---------|----------|-----------------|
| **DeepSeek V3** ⭐ | `deepseek/deepseek-chat` | **$0.30** | **$1.15** | **~10x lebih murah** |
| DeepSeek R1 | `deepseek/deepseek-r1` | $0.55 | $2.19 | **~5x lebih murah** |
| Claude Sonnet 4 (via OR) | `anthropic/claude-sonnet-4` | $3.00 | $15.00 | — |

---

## 🧠 Model via OpenRouter

### 1. `deepseek/deepseek-chat` (V3 — Default)
| Properti | Nilai |
|----------|-------|
| Context | 1,000,000 token |
| Max Output | 8,192 token |
| Input Cost | $0.30 / 1M token |
| Output Cost | $1.15 / 1M token |
| Reasoning | ❌ |
| Cocok untuk | **Scout, Worker, Daily-DevOps** |

### 2. `deepseek/deepseek-r1` (R1 — Reasoning)
| Properti | Nilai |
|----------|-------|
| Context | 1,000,000 token |
| Max Output | 8,192 token |
| Input Cost | $0.55 / 1M token |
| Output Cost | $2.19 / 1M token |
| Reasoning | ✅ (bawaan) |
| Cocok untuk | **Planner, Reviewer, Debugger** |

---

## ⚙️ Konfigurasi per Agent (Default)

```
Agent                OpenRouter Model ID
─────                ───────────────────
scout             →  deepseek/deepseek-chat   ($0.30/M)
planner           →  deepseek/deepseek-r1     ($0.55/M)
worker            →  deepseek/deepseek-chat   ($0.30/M)
reviewer          →  deepseek/deepseek-r1     ($0.55/M)
debugger          →  deepseek/deepseek-r1     ($0.55/M)
daily-devops      →  deepseek/deepseek-chat   ($0.30/M)
```

---

## 💰 Estimasi Biaya Harian

| Skenario | Per Task | Per Hari (50 task) |
|----------|----------|-------------------|
| **Full DeepSeek** (V3→R1→V3) | ~$0.003–0.008 | **$0.15–0.40** 🔥 |

---

## 🚀 Setup

```bash
# 1. Set OpenRouter API Key
export OPENROUTER_API_KEY=sk-or-v1-xxxxx
# atau via /login di pi, pilih OpenRouter

# 2. Copy models.json
cp models.json.example ~/.pi/agent/models.json

# 3. Restart pi
pi
# atau reload: /reload
```

---

## ⚠️ Catatan

1. **OpenRouter** butuh akun dan API key dari [openrouter.ai/keys](https://openrouter.ai/keys)
2. **DeepSeek V3** sangat hemat — cocok untuk development sehari-hari
3. **DeepSeek R1** selalu menggunakan reasoning — tidak bisa dimatikan
4. Jika ingin fallback ke **Direct DeepSeek API**, gunakan agent `*-deepseek.md`
5. Lihat alternatif model lain di OpenRouter: `mistralai/mistral-*`, `google/gemini-*`, dll

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