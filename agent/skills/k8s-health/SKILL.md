---
name: k8s-health
description: Memeriksa kesehatan cluster Kubernetes, pod, service, dan resource. Gunakan untuk daily health check.
allowed-tools: bash read
---

# K8s Health Check

Daily health check untuk cluster Kubernetes (k3s).

## Perintah Dasar

### Cek Node
```bash
kubectl get nodes -o wide
kubectl describe node
```

### Cek Pod (semua namespace)
```bash
kubectl get pods -A -o wide
kubectl get pods -A --field-selector status.phase!=Running
kubectl get pods -A | grep -v Running | grep -v Completed
```

### Cek Service & Endpoint
```bash
kubectl get svc -A
kubectl get ep -A
```

### Cek Resource Usage
```bash
kubectl top nodes
kubectl top pods -A
```

### Cek Event
```bash
kubectl get events -A --sort-by='.lastTimestamp' | tail -20
```

### Cek Persistent Volume
```bash
kubectl get pv
kubectl get pvc -A
```

### Restart Count Abnormal
```bash
kubectl get pods -A | awk '$5 > 5 {print $0}'
```

## Output Report Format

```
=== K8s Health Check ===
Date: $(date)

Nodes:
- qoindevtemporal01: Ready (control-plane)

Problem Pods:
- <name>: CrashLoopBackOff (5 restarts)

Events (last 20):
- <timestamp> Warning ...
```

## Penggunaan

```bash
/skill:k8s-health
# atau panggil agent scout dulu
/subagent scout "Jalankan daily health check k8s cluster"
```