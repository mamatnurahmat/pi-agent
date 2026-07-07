#!/usr/bin/env bash
# ============================================================
# 🚀 pi-agent init.sh — First-time setup
# Repo: github.com/mamatnurahmat/pi-agent
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

log_info()  { echo -e "${CYAN}ℹ️${NC} $1"; }
log_ok()    { echo -e "${GREEN}✅${NC} $1"; }
log_warn()  { echo -e "${YELLOW}⚠️${NC} $1"; }
log_error() { echo -e "${RED}❌${NC} $1"; }
log_step()  { echo -e "\n${BOLD}${CYAN}━━━ $1 ━━━${NC}\n"; }

PI_AGENT_DIR="${PI_AGENT_DIR:-$HOME/.pi/agent}"
PI_DIR="${PI_DIR:-$HOME/.pi}"
PI_MODELS="$PI_AGENT_DIR/models.json"
PI_AUTH="$PI_AGENT_DIR/auth.json"
PI_BASHRC="$HOME/.bashrc"
PI_ZSHRC="$HOME/.zshrc"

# ── Header ──
echo -e "\n${BOLD}${CYAN}"
echo '  ╔═══════════════════════════════════════════════╗'
echo '  ║        🚀 pi-agent — First Time Setup         ║'
echo '  ║   Multi-Agent System untuk Pi Coding Agent    ║'
echo '  ╚═══════════════════════════════════════════════╝'
echo -e "${NC}"
echo -e "  Assalamu'alaikum warahmatullahi wabarakatuh 🕌"
echo -e "  Selamat datang di setup pi-agent!\n"

# ============================================================
# STEP 1: Cek Prasyarat
# ============================================================
log_step "Langkah 1/6 — Cek Prasyarat"

PREREQ_OK=true

if command -v pi &>/dev/null; then
    PI_VER=$(pi --version 2>/dev/null || echo "?")
    log_ok "pi terinstall — v$PI_VER"
else
    log_warn "pi belum terinstall. Install dulu:"
    echo "  curl -fsSL https://pi.dev/install.sh | sh"
    PREREQ_OK=false
fi

if command -v git &>/dev/null; then
    log_ok "git tersedia"
else
    log_error "git tidak ditemukan"
    PREREQ_OK=false
fi

if command -v kubectl &>/dev/null; then
    log_ok "kubectl tersedia"
else
    log_warn "kubectl tidak ditemukan (skip)"
fi

if command -v curl &>/dev/null; then
    log_ok "curl tersedia"
else
    log_error "curl tidak ditemukan"
    PREREQ_OK=false
fi

[ "$PREREQ_OK" = false ] && { log_error "Install prerequisites first"; exit 1; }

# ============================================================
# STEP 2: OpenRouter API Key
# ============================================================
log_step "Langkah 2/6 — OpenRouter API Key"

echo -e "  Model default: ${BOLD}DeepSeek V3${NC} (\$0.30/1M token)"
echo -e "  Dapatkan key di: ${CYAN}https://openrouter.ai/keys${NC}\n"

if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    log_ok "OPENROUTER_API_KEY sudah terdeteksi"
    echo "  Key: ${OPENROUTER_API_KEY:0:20}..."
else
    echo -n "➤ Masukkan OpenRouter API Key (sk-or-v1-...): "
    read -r OR_KEY
    if [ -z "$OR_KEY" ]; then
        log_warn "API Key kosong — bisa diisi nanti via /login di pi"
    else
        SHELL_RC="$PI_BASHRC"; [ -f "$PI_ZSHRC" ] && SHELL_RC="$PI_ZSHRC"
        echo "" >> "$SHELL_RC"
        echo "# pi-agent: OpenRouter API Key" >> "$SHELL_RC"
        echo "export OPENROUTER_API_KEY=$OR_KEY" >> "$SHELL_RC"
        export OPENROUTER_API_KEY="$OR_KEY"
        log_ok "API Key disimpan ke $SHELL_RC"

        mkdir -p "$PI_AGENT_DIR"
        echo "{\"openrouter\":{\"type\":\"api_key\",\"key\":\"$OR_KEY\"}}" > "$PI_AUTH"
        chmod 600 "$PI_AUTH"
        log_ok "API Key juga disimpan ke auth.json"
    fi
fi

# ============================================================
# STEP 3: Pilih Model
# ============================================================
log_step "Langkah 3/6 — Pilih Model Default"

echo "  ${BOLD}1)${NC} DeepSeek V3 + R1 ✅ Paling Hemat (\$0.15-0.40/hari)"
echo "  ${BOLD}2)${NC} Claude Sonnet + Haiku 🔥 Kualitas Terbaik (\$1.25-3.00/hari)"
echo "  ${BOLD}3)${NC} Mixed (DeepSeek Scout + Claude Worker) ⚖️ Balance"
echo -n "➤ Pilihan [1-3] (default: 1): "
read -r MODEL_CHOICE
MODEL_CHOICE="${MODEL_CHOICE:-1}"

case "$MODEL_CHOICE" in
    2)
        log_ok "Model: Claude Sonnet + Haiku"
        cat > /tmp/pi-models.json << 'EOF'
{
  "providers": {
    "openrouter": {
      "apiKey": "$OPENROUTER_API_KEY",
      "models": [
        {"id":"anthropic/claude-sonnet-4","name":"Claude Sonnet 4","reasoning":true,"input":["text"],"contextWindow":200000,"maxTokens":8192,"cost":{"input":3.00,"output":15.00,"cacheRead":0.30,"cacheWrite":0.30}},
        {"id":"anthropic/claude-3-5-haiku","name":"Claude Haiku","reasoning":false,"input":["text"],"contextWindow":200000,"maxTokens":8192,"cost":{"input":0.80,"output":4.00,"cacheRead":0.08,"cacheWrite":0.08}}
      ]
    }
  }
}
EOF
        # Update agents
        for f in scout daily-devops; do
            sed -i 's|model: deepseek/deepseek-chat|model: anthropic/claude-3-5-haiku|' "$PI_DIR/agent/agents/$f.md"
        done
        for f in planner worker reviewer debugger; do
            sed -i 's|model: deepseek/deepseek-r1|model: anthropic/claude-sonnet-4|' "$PI_DIR/agent/agents/$f.md" 2>/dev/null || true
            sed -i 's|model: deepseek/deepseek-chat|model: anthropic/claude-sonnet-4|' "$PI_DIR/agent/agents/$f.md" 2>/dev/null || true
        done
        ;;
    3)
        log_ok "Model: Mixed (DeepSeek Scout + Claude Worker)"
        cat > /tmp/pi-models.json << 'EOF'
{
  "providers": {
    "openrouter": {
      "apiKey": "$OPENROUTER_API_KEY",
      "models": [
        {"id":"deepseek/deepseek-chat","name":"DeepSeek V3","reasoning":false,"input":["text"],"contextWindow":1000000,"maxTokens":8192,"cost":{"input":0.30,"output":1.15,"cacheRead":0.07,"cacheWrite":0.07}},
        {"id":"deepseek/deepseek-r1","name":"DeepSeek R1","reasoning":true,"thinkingLevelMap":{"off":null},"input":["text"],"contextWindow":1000000,"maxTokens":8192,"cost":{"input":0.55,"output":2.19,"cacheRead":0.14,"cacheWrite":0.14}},
        {"id":"anthropic/claude-sonnet-4","name":"Claude Sonnet 4","reasoning":true,"input":["text"],"contextWindow":200000,"maxTokens":8192,"cost":{"input":3.00,"output":15.00,"cacheRead":0.30,"cacheWrite":0.30}}
      ]
    }
  }
}
EOF
        sed -i 's|model: deepseek/deepseek-r1|model: anthropic/claude-sonnet-4|' "$PI_DIR/agent/agents/planner.md" "$PI_DIR/agent/agents/reviewer.md" "$PI_DIR/agent/agents/debugger.md"
        sed -i 's|model: deepseek/deepseek-chat|model: anthropic/claude-sonnet-4|' "$PI_DIR/agent/agents/worker.md"
        # scout & devops tetap DeepSeek
        ;;
    *)
        log_ok "Model: DeepSeek V3 + R1 (Paling Hemat)"
        cp "$PI_DIR/models.json.example" /tmp/pi-models.json
        ;;
esac

cp /tmp/pi-models.json "$PI_MODELS"
log_ok "Model config → $PI_MODELS"

# ============================================================
# STEP 4: Integrasi Pi
# ============================================================
log_step "Langkah 4/6 — Integrasi ke Pi"

# Cek apakah repo sudah diclone ke ~/.pi
if [ -d "$PI_DIR/.git" ]; then
    log_ok "Repo pi-agent sudah di ~/.pi"
else
    echo -n "➤ Clone repo pi-agent ke ~/.pi? (Y/n): "
    read -r CLONE
    if [[ ! "$CLONE" =~ ^[Nn]$ ]]; then
        git clone https://github.com/mamatnurahmat/pi-agent.git "$PI_DIR.tmp"
        # Backup file yang mungkin bentrok
        for f in auth.json settings.json telegram.json locks.json; do
            [ -f "$PI_DIR/agent/$f" ] && cp "$PI_DIR/agent/$f" /tmp/
        done
        cp -r "$PI_DIR.tmp/"* "$PI_DIR/"
        rm -rf "$PI_DIR.tmp"
        # Restore file personal
        for f in auth.json settings.json telegram.json locks.json; do
            [ -f "/tmp/$f" ] && cp "/tmp/$f" "$PI_DIR/agent/$f"
        done
        log_ok "Repo cloned ke ~/.pi"
    fi
fi

# Pi settings
PI_SETTINGS="$PI_AGENT_DIR/settings.json"
if [ ! -f "$PI_SETTINGS" ]; then
    cat > "$PI_SETTINGS" << 'EOF'
{
  "enableSkillCommands": true,
  "defaultProjectTrust": "ask"
}
EOF
    log_ok "Default settings.json dibuat"
fi

# ============================================================
# STEP 5: Info & Verifikasi
# ============================================================
log_step "Langkah 5/6 — Verifikasi"

echo "  File yang sudah siap:"
[ -f "$PI_MODELS" ]         && log_ok "models.json"          || log_warn "models.json belum ada"
[ -f "$PI_AUTH" ]           && log_ok "auth.json"            || log_warn "auth.json belum ada (nanti /login)"
[ -d "$PI_DIR/agent" ]      && log_ok "agent/ directory"     || log_warn "agent/ belum ada"
[ -f "$PI_DIR/agent/APPEND_SYSTEM.md" ] && log_ok "APPEND_SYSTEM.md (etika Islami)" || log_warn "APPEND_SYSTEM.md belum ada"

echo ""
echo -n "➤ Jalankan verifikasi koneksi OpenRouter? (y/N): "
read -r VERIFY
if [[ "$VERIFY" =~ ^[Yy]$ ]]; then
    echo "  Mencoba koneksi ke OpenRouter..."
    if [ -n "${OPENROUTER_API_KEY:-}" ]; then
        RESP=$(curl -s -w "\n%{http_code}" https://openrouter.ai/api/v1/models \
          -H "Authorization: Bearer $OPENROUTER_API_KEY" 2>/dev/null || true)
        HTTP_CODE=$(echo "$RESP" | tail -1)
        if [ "$HTTP_CODE" = "200" ]; then
            log_ok "Koneksi ke OpenRouter berhasil!"
        else
            log_warn "Gagal connect ke OpenRouter (HTTP $HTTP_CODE). Cek API key."
        fi
    else
        log_warn "OPENROUTER_API_KEY belum diset, skip verifikasi"
    fi
fi

# ============================================================
# STEP 6: Selesai
# ============================================================
log_step "Langkah 6/6 — Selesai! 🎉"

echo -e "  ${BOLD}pi-agent siap digunakan!${NC}"
echo ""
echo -e "  Jalankan ${CYAN}pi${NC} dan coba perintah berikut:\n"
echo -e "  ${GREEN}/subagent scout \"Cari file README\"${NC}"
echo -e "  ${GREEN}/subagent daily-devops \"Jalankan daily devops routine\"${NC}"
echo -e "  ${GREEN}/subagent chain '\"'[{\\\"agent\\\":\\\"scout\\\",\\\"task\\\":\\\"Cari semua API\\\"},{\\\"agent\\\":\\\"planner\\\",\\\"task\\\":\\\"Buat rencana\"}]'\"'${NC}"
echo ""
echo -e "  📖 Dokumentasi: ${CYAN}https://github.com/mamatnurahmat/pi-agent${NC}"
echo ""
echo -e "  ${BOLD}Barakallah, selamat bekerja! 🤲${NC}"
echo ""
