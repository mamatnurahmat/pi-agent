# 🤖 pi-agent — Multi-Agent System for Pi

> Multi-agent extension + agent library for [Pi coding agent](https://pi.dev)

## 📦 What's Inside

### Extension: `extensions/multi-agent/`
Register custom `subagent` tool for delegating tasks to specialized agents with isolated context windows.

### Agents: `agents/*.md`
Specialist agent definitions with optimized model/tool configs:

| Agent | Model | Tools | Purpose |
|-------|-------|-------|---------|
| `scout` | Haiku | read,grep,find,ls,bash | Fast codebase recon |
| `planner` | Sonnet | read,grep,find,ls | Implementation plans |
| `worker` | Sonnet | read,bash,edit,write,... | General implementation |
| `reviewer` | Sonnet | read,grep,find,ls,bash | Code review |
| `debugger` | Sonnet | read,bash,grep,find,ls | Debugging |
| `daily-devops` | Sonnet | read,bash,grep,ls | **Daily DevOps routine** |
| `*-deepseek` | V3/R1 | per agent | DeepSeek variants (5-11x cheaper) |

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