# 🗺️ ROADMAP 7 Hari — Multi-Agent Pi System

**Mulai:** 2026-07-07 | **Target:** Pi extension multi-agent lengkap

---

## Hari 1 — Foundation ✅ Selesai
- Setup Git repo di `~/.pi`
- Sanitasi file (hanya pi-agent related)
- 5 agent definitions: scout, planner, worker, reviewer, debugger
- **daily-devops** agent + DeepSeek variant
- 5 **DevOps skills**: k8s-health, temporal-admin, log-inspector, db-backup, deploy-verify
- DeepSeek alternative config (models.json.example + 5 agent variants)
- Push ke `github.com/mamatnurahmat/pi-agent`

## Hari 2 — Agent Pool Manager
- [ ] Pool manager: queue, concurrency (max 4), timeout (60s)
- [ ] Auto-retry (2x)
- [ ] Register `subagent` tool di extension
- [ ] Test single agent invocation

## Hari 3 — Workflow Engine
- [ ] Chain execution dengan `{previous}` context passing
- [ ] Workflow templates (prompts)
- [ ] Error handling: retry, skip, abort
- [ ] Result aggregation

## Hari 4 — Advanced Workflows
- [ ] DAG execution (branching)
- [ ] Vote mechanism (multi-reviewer)
- [ ] Debate pattern (review → revise → review)

## Hari 5 — UI & Rendering
- [ ] Live status widget (parallel tasks)
- [ ] Cost tracker per agent
- [ ] Progress bar untuk chain

## Hari 6 — Optimization
- [ ] Scout result caching (hash-based, 5min TTL)
- [ ] Budget management & cost estimator
- [ ] Context compression antar chain step

## Hari 7 — Polish & Deploy
- [ ] Full documentation
- [ ] Smoke & integration tests
- [ ] GitHub Release v1.0.0-alpha
- [ ] Publish as pi package (npm)

---

## Progress

- [x] **Hari 1** — Foundation ✅
- [ ] **Hari 2** — Pool Manager
- [ ] **Hari 3** — Workflow Engine
- [ ] **Hari 4** — Advanced Workflow
- [ ] **Hari 5** — UI/UX
- [ ] **Hari 6** — Optimization
- [ ] **Hari 7** — Deploy