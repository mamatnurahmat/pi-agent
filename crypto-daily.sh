#!/usr/bin/env bash
# ============================================================
# 🪙 crypto-daily.sh — Daily Crypto Report
# BTC + SUI prices, headlines, IDR conversion
# Kirim ke Telegram setiap jam 8 pagi via cron
# ============================================================
set -euo pipefail

# ── Config ──
GNEWS_KEY="4e7dcf7ce61eec4c847fb3b2d20fce3c"
BOT_TOKEN="8865272047:AAGDNjRnrYtQ6ij3PofN-_NW7y3cxL_QcbQ"
CHAT_ID="1149892378"
REPORT_DIR="$HOME/.pi/reports"
mkdir -p "$REPORT_DIR"

# ── Warna & Emoji ──
BTC_EMOJI="🟠"
SUI_EMOJI="🌊"
IDR_EMOJI="🇮🇩"

# ── Fungsi API ──
get_price() {
    curl -s "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,sui&vs_currencies=usd,idr&include_24hr_change=true"
}

get_news() {
    local coin="$1"
    curl -s "https://gnews.io/api/v4/search?q=${coin}&lang=en&max=5&apikey=${GNEWS_KEY}"
}

send_telegram() {
    local msgfile="$REPORT_DIR/msg-$(date +%s).json"
    python3 -c "
import json
msg = open('/dev/stdin').read()
payload = {
    'chat_id': '$CHAT_ID',
    'text': msg,
    'parse_mode': 'Markdown',
    'disable_web_page_preview': True
}
with open('$msgfile','w') as f:
    json.dump(payload, f)
" <<< "$1"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "@${msgfile}" > /dev/null 2>&1
    rm -f "$msgfile"
}

# ── Format Number ──
format_number() {
    python3 -c "
n = float('$1')
if n >= 1_000_000_000_000:
    print(f'{n/1_000_000_000_000:.2f}T')
elif n >= 1_000_000_000:
    print(f'{n/1_000_000_000:.2f}B')
elif n >= 1_000_000:
    print(f'{n/1_000_000:.2f}M')
elif n >= 1_000:
    print(f'{n:,.0f}')
else:
    print(f'{n:,.4f}')
"
}

format_price() {
    local coin="$1" usd="$2" idr="$3" change="$4"
    local arrow="📈"
    local sign="+"
    if (( $(echo "$change < 0" | bc -l) )); then
        arrow="📉"
        sign=""
    fi
    local change_fmt=$(printf "%.2f" "$change")
    echo "*${coin}:* \$$(format_number $usd) / Rp$(format_number $idr) ${arrow} ${sign}${change_fmt}% (24h)"
}

# ── Main ──
REPORT=""
REPORT+="📰 *Daily Crypto Report* — $(date '+%d %B %Y')\n"
REPORT+="⏰ $(date '+%H:%M WIB')\n\n"

# ── Harga ──
PRICE_DATA=$(get_price)

BTC_USD=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['bitcoin']['usd'])")
BTC_IDR=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['bitcoin']['idr'])")
BTC_CHANGE=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['bitcoin']['usd_24h_change'])")

SUI_USD=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['sui']['usd'])")
SUI_IDR=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['sui']['idr'])")
SUI_CHANGE=$(echo "$PRICE_DATA" | python3 -c "import json,sys; print(json.load(sys.stdin)['sui']['usd_24h_change'])")

REPORT+="━━━ 💰 *Harga Terbaru* ━━━\n"
REPORT+="$(format_price "Bitcoin (BTC)" "$BTC_USD" "$BTC_IDR" "$BTC_CHANGE")\n"
REPORT+="$(format_price "SUI" "$SUI_USD" "$SUI_IDR" "$SUI_CHANGE")\n"
REPORT+="\n"

# ── Berita BTC ──
BTC_NEWS=$(get_news "bitcoin%20OR%20btc%20cryptocurrency")
REPORT+="━━━ ${BTC_EMOJI} *Bitcoin News* ━━━\n"
readarray -t BTC_ARTICLES < <(echo "$BTC_NEWS" | python3 -c "
import json,sys
d=json.load(sys.stdin)
for a in d.get('articles',[])[:5]:
    t=a['title'].replace('*','').replace('_','').replace('[','').replace(']','')
    s=a['source']['name']
    dt=a['publishedAt'][:10]
    print(f'• {t}')
    print(f'  _{s}_ | {dt}')
    print('---')
" 2>/dev/null)
for line in "${BTC_ARTICLES[@]}"; do
    REPORT+="$line\n"
done
REPORT+="\n"

# ── Berita SUI ──
SUI_NEWS=$(get_news "sui%20crypto%20token")
REPORT+="━━━ ${SUI_EMOJI} *SUI News* ━━━\n"
readarray -t SUI_ARTICLES < <(echo "$SUI_NEWS" | python3 -c "
import json,sys
d=json.load(sys.stdin)
arts=d.get('articles',[])
if not arts:
    print('_(Tidak ada berita SUI dalam 30 hari terakhir — free plan limit)_')
else:
    for a in arts[:5]:
        t=a['title'].replace('*','').replace('_','').replace('[','').replace(']','')
        s=a['source']['name']
        dt=a['publishedAt'][:10]
        print(f'• {t}')
        print(f'  _{s}_ | {dt}')
        print('---')
" 2>/dev/null)
for line in "${SUI_ARTICLES[@]}"; do
    REPORT+="$line\n"
done
REPORT+="\n"

# ── Ringkasan ──
BTC_SENTIMENT=$(echo "$BTC_CHANGE > 0" | bc -l)
if [ "$BTC_SENTIMENT" = "1" ]; then
    BTC_STATUS="Menguat 📈"
else
    BTC_STATUS="Melemah 📉"
fi
SUI_SENTIMENT=$(echo "$SUI_CHANGE > 0" | bc -l)
if [ "$SUI_SENTIMENT" = "1" ]; then
    SUI_STATUS="Menguat 📈"
else
    SUI_STATUS="Melemah 📉"
fi

REPORT+="━━━ 📊 *Ringkasan* ━━━\n"
REPORT+="${BTC_EMOJI} Bitcoin: $BTC_STATUS (24h: ${BTC_CHANGE%.*}%)\n"
REPORT+="${SUI_EMOJI} SUI: $SUI_STATUS (24h: ${SUI_CHANGE%.*}%)\n"
REPORT+="${IDR_EMOJI} Kurs: Rp$(format_number $(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=usd&vs_currencies=idr" | python3 -c "import json,sys; print(json.load(sys.stdin)['usd']['idr'])"))/USD\n"
REPORT+="\n"
REPORT+="💡 *Sumber:* CoinGecko + GNews API\n"
REPORT+="⏰ Update: setiap jam 08:00 WIB\n"
REPORT+="\n"
REPORT+="_Barakallah, semoga investasinya berkah_ 🤲"

# ── Kirim ──
send_telegram "$REPORT"

# ── Save log ──
echo "$REPORT" > "$REPORT_DIR/crypto-$(date +%Y%m%d).log"
echo "✅ Crypto report sent at $(date)"