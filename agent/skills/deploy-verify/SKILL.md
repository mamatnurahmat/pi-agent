---
name: deploy-verify
description: Verifikasi deployment aplikasi — health check, endpoint test, dan rollback jika diperlukan.
allowed-tools: bash read curl
---

# Deploy Verification

Memverifikasi bahwa deployment berjalan dengan benar dan siap digunakan.

## Cek Status Helm
```bash
helm list -n temporal
helm status temporal -n temporal
helm history temporal -n temporal
```

## Verifikasi Pod (Semua Running)
```bash
kubectl get pods -n temporal | grep -v Running | grep -v Completed
```

## Cek Service & Port
```bash
kubectl get svc -n temporal

# Test endpoint
curl -so /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null || \
  echo "Web UI: running di NodePort 8080"
curl -so /dev/null -w "%{http_code}" http://localhost:8888 2>/dev/null || \
  echo "phpMyAdmin: running di NodePort 8888"
```

## Uji Koneksi Temporal
```bash
# Dari admin-tools
kubectl exec deployment/temporal-admintools -n temporal -- temporal cluster health 2>&1
```

## Rollback Jika Gagal
```bash
# Rollback 1 versi
helm rollback temporal 1 -n temporal
```

## Cek Resource Deployment
```bash
kubectl describe deployment -n temporal
```

## Output Lulus/Tidak

```
=== Deploy Verification ===
Service          Status    Port
─────────────────────────────────
temporal-frontend ✅       7233
temporal-web     ✅       8080:8080
phpmyadmin      ✅       80:8888

Helm: deployed (revision 5)
Cluster: Healthy ✅
Database: Connected ✅

Result: ✅ LULUS
```