---
name: crypto-news
description: Berita crypto terbaru fokus BTC, USDT, dan SUI dari GNews API. Cek harga, tren, dan analisis pasar crypto.
---

# Skill Crypto News 🪙

Mengambil berita crypto terbaru fokus BTC, USDT, dan SUI menggunakan GNews API.

## Setup

```bash
# API Key sudah di auth.json
export GNEWS_API_KEY=4e7dcf7ce61eec4c847fb3b2d20fce3c
```

## Perintah yang Tersedia

### 1. Berita BTC Terbaru
```bash
curl -s "https://gnews.io/api/v4/search?q=bitcoin+OR+btc+cryptocurrency&lang=en&max=5&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'📰 BTC News ({d[\"totalArticles\"]} articles found)')
print('='*50)
for a in d.get('articles',[]):
    print(f\"\"\"
• {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
  🔗 {a['url']}
\"\"\")
"
```

### 2. Berita USDT Terbaru
```bash
curl -s "https://gnews.io/api/v4/search?q=Tether+OR+USDT+stablecoin&lang=en&max=5&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'💵 USDT News ({d[\"totalArticles\"]} articles found)')
print('='*50)
for a in d.get('articles',[]):
    print(f\"\"\"
• {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
  🔗 {a['url']}
\"\"\")
"
```

### 3. Berita SUI Terbaru
```bash
curl -s "https://gnews.io/api/v4/search?q=sui+crypto+token&lang=en&max=5&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'🌊 SUI News ({d[\"totalArticles\"]} articles found)')
print('='*50)
for a in d.get('articles',[]):
    print(f\"\"\"
• {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
  🔗 {a['url']}
\"\"\")
"
```

### 4. Berita Semua Crypto (Ringkasan)
```bash
curl -s "https://gnews.io/api/v4/search?q=cryptocurrency+OR+crypto+market+bitcoin+ethereum&lang=en&max=10&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'🪙 Crypto Market Overview ({d[\"totalArticles\"]} articles)')
print('='*60)
for a in d.get('articles',[]):
    title_lower = a['title'].lower()
    tag = '🟠' if any(w in title_lower for w in ['bitcoin','btc']) else \
          '💚' if any(w in title_lower for w in ['sui','sui.network']) else \
          '💵' if any(w in title_lower for w in ['tether','usdt','stablecoin']) else \
          '🔵'
    print(f\"\"\"
{tag} {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
\"\"\")
"
```

### 5. Cari Berita Spesifik
```bash
# Cari berita BTC dengan kata kunci tertentu
curl -s "https://gnews.io/api/v4/search?q=bitcoin+$1&lang=en&max=5&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'🔍 BTC search: $1 ({d[\"totalArticles\"]} results)')
for a in d.get('articles',[]):
    print(f\"\"\"
• {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
\"\"\")
"
```

### 6. Berita Bahasa Indonesia
```bash
curl -s "https://gnews.io/api/v4/search?q=bitcoin+crypto+investasi+&lang=id&max=5&apikey=$GNEWS_API_KEY" | \
  python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'🇮🇩 Crypto News Indonesia ({d[\"totalArticles\"]} articles)')
for a in d.get('articles',[]):
    print(f\"\"\"
• {a['title']}
  📍 {a['source']['name']} | {a['publishedAt'][:10]}
  🔗 {a['url']}
\"\"\")
"
```

## Output Format (Ringkasan)

```
┌─────────────────────────────────────────────┐
│      🪙 Crypto News — $(date +%Y-%m-%d)      │
├─────────────────────────────────────────────┤
│ 📰 BTC: 1.234 articles                      │
│ 💵 USDT: 567 articles                        │
│ 🌊 SUI: 89 articles                          │
├─────────────────────────────────────────────┤
│ 🔥 Headlines:                                │
│ 🟠 Bitcoin...                                │
│ 💚 SUI Network...                            │
│ 💵 Tether...                                 │
├─────────────────────────────────────────────┤
│ 💡 Sumber: GNews API                         │
└─────────────────────────────────────────────┘
```

## Cara Pakai di Pi

```bash
# Via skill command
/skill:crypto-news

# Atau via subagent
/subagent scout "Ambil berita crypto terbaru BTC, USDT, dan SUI pakai GNews API"

# Daily crypto update
/subagent daily-devops "Jalankan crypto-news skill: cek BTC, USDT, SUI"
```

> ⚠️ **Catatan:** Free GNews API terbatas 100 request/hari. Gunakan bijak.