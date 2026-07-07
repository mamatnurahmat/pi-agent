# 🤖 pi-agent — Multi-Agent System for Pi

> Multi-agent extension + agent library for [Pi coding agent](https://pi.dev)

## 📦 What's Inside

### Extension: `extensions/multi-agent/`
Register custom `subagent` tool for delegating tasks to specialized agents with isolated context windows.

### Agents: `agents/*.md`
Specialist agent definitions with optimized model/tool configs:

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| `scout` | DeepSeek V3 | read,grep,find,ls,bash | Fast codebase recon |
| `planner` | DeepSeek R1 | read,grep,find,ls | Implementation plans |
| `worker` | DeepSeek V3 | read,bash,edit,write,... | General implementation |
| `reviewer` | DeepSeek R1 | read,grep,find,ls,bash | Code review |
| `debugger` | DeepSeek R1 | read,bash,grep,find,ls | Debugging |
| `daily-devops` | DeepSeek V3 | read,bash,grep,ls | **Daily DevOps routine** |

> **Provider:** OpenRouter | **Etika:** Islami (salam, santun, doa)

### System Prompt: `APPEND_SYSTEM.md`
Etika komunikasi Islami otomatis ditambahkan ke setiap percakapan:
- Salam pembuka **Assalamu'alaikum**
- Bahasa santun & islami (Alhamdulillah, InsyaAllah, MasyaAllah, Barakallah)
- Doa penutup

### Skills: `skills/*/SKILL.md`
Reusable step-by-step workflows for DevOps tasks:

| Skill | Purpose |
|-------|---------|
| `k8s-health` | Cluster health check (nodes, pods, events) |
| `temporal-admin` | Temporal server admin & namespace management |
| `log-inspector` | Log analysis & error tracing |
| `db-backup` | Database backup status & health |
| `deploy-verify` | Deployment verification & rollback |

### Workflows: `prompts/*.md` (via pi)
- `/implement <task>` — scout → planner → worker
- `/implement-and-review <task>` — worker → reviewer → worker
- `/debug <task>` — debugger → worker
- `/devops <action>` — daily-devops → full routine

## 🚀 Quick Start

```bash
# Install pi jika belum
npm install -g @earendil-works/pi-coding-agent

# Clone
git clone https://github.com/mamatnurahmat/pi-agent ~/.pi

# Restart pi — agents and extension auto-discovered
pi
```

## 🔧 Usage

In pi interactive mode:

```
# Single agent
/subagent scout "Find all auth-related code"

# Chain workflow
/subagent chain '[{"agent":"scout","task":"Find auth code"},{"agent":"planner","task":"Plan refactor for {previous}"}]'

# Parallel
/subagent tasks '[{"agent":"scout","task":"Find models"},{"agent":"scout","task":"Find providers"}]'
```

## 🛡️ Security

- Agents from `~/.pi/agent/agents/` only (user scope)
- No credentials in repo
- Project agents require explicit confirmation

## 📚 Docs

| File | Description |
|------|-------------|
| [README.md](./README.md) | This file |
| [ROADMAP.md](./ROADMAP.md) | Development roadmap |

## 👤 Author

**Mamat Nurahmat** — [@mamatnurahmat](https://github.com/mamatnurahmat)