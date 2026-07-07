---
name: log-inspector
description: Melihat dan menganalisis log pod Kubernetes. Berguna untuk debugging dan monitoring.
allowed-tools: bash read grep
---

# Log Inspector

Melihat dan menganalisis log dari pod di cluster.

## Lihat Log (Recent)
```bash
# Semua pod di namespace
kubectl logs deployment/<deploy-name> -n <namespace> --tail 50

# Dengan follow
kubectl logs -f deployment/<deploy-name> -n <namespace>

# Pod spesifik
kubectl logs <pod-name> -n <namespace> --tail 100
```

## Cari Error
```bash
kubectl logs deployment/<deploy-name> -n <namespace> --tail 500 | grep -i error
kubectl logs deployment/<deploy-name> -n <namespace> --tail 500 | grep -i exception
kubectl logs deployment/<deploy-name> -n <namespace> --tail 500 | grep -i "connection refused"
kubectl logs deployment/<deploy-name> -n <namespace> --tail 500 | grep -i "no usable"
```

## Cek Restart History
```bash
kubectl describe pod <pod-name> -n <namespace> | grep -A10 "Container Statuses"
kubectl get pods -n <namespace> -o wide | awk '$5 > 0 {print $0}'
```

## Tail Multiple Pods
```bash
# Gunakan label selector
kubectl logs -l app=temporal-frontend -n temporal --tail 20
```

## Export Log
```bash
kubectl logs deployment/<deploy-name> -n <namespace> > /tmp/<deploy-name>.log
wc -l /tmp/<deploy-name>.log
```

## Penggunaan

```bash
/skill:log-inspector
# atau
/subagent debugger "Analisis log error di temporal-frontend"
```