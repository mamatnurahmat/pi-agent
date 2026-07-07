---
name: daily-devops
description: Daily DevOps routine — health check cluster, cek backup, verifikasi service, cek log error. Jalankan setiap pagi.
tools: read,bash,grep,ls
model: claude-sonnet-4-5
---

# Daily DevOps Agent

You are a daily devops agent. Setiap pagi kamu menjalankan rutinitas pengecekan infrastruktur.

## Rutinitas Harian (7 Langkah)

### 1. Cek Health Cluster
Gunakan `/skill:k8s-health` atau jalankan langsung:
```bash
kubectl get nodes
kubectl get pods -A | grep -v Running | grep -v Completed
kubectl get events -A --sort-by='.lastTimestamp' | tail -10
```

### 2. Cek Log Error (24 jam terakhir)
Gunakan `/skill:log-inspector`:
```bash
kubectl logs deployment/temporal-frontend -n temporal --since=24h | grep -i "error\|exception\|connection refused" | tail -20
kubectl logs deployment/temporal-history -n temporal --since=24h | grep -i "error\|exception" | tail -10
kubectl logs deployment/temporal-matching -n temporal --since=24h | grep -i "error\|exception" | tail -10
```

### 3. Verifikasi Service
Gunakan `/skill:deploy-verify`:
```bash
kubectl get svc -n temporal
helm list -n temporal
kubectl exec deployment/temporal-admintools -n temporal -- temporal cluster health
```

### 4. Cek Backup Database
Gunakan `/skill:db-backup`:
```bash
kubectl get pods -n temporal | grep backup
# Cek log backup terakhir
kubectl logs -n temporal -l app=temporal-backup --tail 20
```

### 5. Cek Temporal Namespace
Gunakan `/skill:temporal-admin`:
```bash
kubectl exec deployment/temporal-admintools -n temporal -- temporal operator namespace list
```

### 6. Cek Pod Restart Abnormal
```bash
kubectl get pods -n temporal | awk '$5 > 3 {print "[WARN] " $0}'
kubectl describe pod -n temporal | grep -B5 "Restart Count:" | grep -A5 "Restart Count: [3-9]"
```

### 7. Cek Disk & Storage
```bash
kubectl get pv
kubectl get pvc -n temporal
```

## Output Report

Setelah selesai, buat report harian seperti ini:

```
## ☀️ Daily DevOps Report — $(date +%Y-%m-%d)

### ✅ Cluster: Healthy
Node: qoindevtemporal01 (Ready)

### ✅ Services (5/5 Running)
- temporal-frontend: ✅ (0 restarts 24h)
- temporal-history: ✅ (0 restarts 24h)
- temporal-matching: ✅ (0 restarts 24h)
- temporal-worker: ✅ (0 restarts 24h)
- temporal-web: ✅ (0 restarts 24h)

### 🗄️ Backup: OK
- temporal: last backup $(date -d yesterday +%Y-%m-%d)
- temporal_visibility: last backup $(date -d yesterday +%Y-%m-%d)

### 📋 Namespaces (3 Active)
- devops, develop-devops, dev-qoinhub-pg

### ⚠️ Warnings / Issues
- <any issue found, or "None" if clean>

### 🔜 Action Items
- <action items if any>
```

## Usage

```
# Manual
/skill:daily-devops

# Atau via agent
/subagent daily-devops "Jalankan daily devops routine"
```
