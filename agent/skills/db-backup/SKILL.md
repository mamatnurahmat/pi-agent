---
name: db-backup
description: Backup dan restore database MySQL Temporal. Cek status backup terakhir dan health database.
allowed-tools: bash read
---

# Database Backup

Backup dan monitoring database MySQL Temporal.

## Backup Manual
```bash
kubectl apply -f backup/cronjob-backup.yaml -n temporal
```

## Cek Status Backup Terakhir
```bash
kubectl get jobs -n temporal -l app=temporal-backup
kubectl get pods -n temporal | grep backup

# Log backup terakhir
kubectl logs job/temporal-backup-<job-id> -n temporal
```

## Test Koneksi Database
```bash
kubectl run mysql-test --image=mysql:8 --rm -it --restart=Never -- \
  mysql -h 193.2.1.6 -u temporal_user -p<PASSWORD> -e "SHOW DATABASES;"
```

## Cek Size Database
```bash
kubectl run mysql-test --image=mysql:8 --rm -it --restart=Never -- \
  mysql -h 193.2.1.6 -u temporal_user -p<PASSWORD> -e "
    SELECT table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
    FROM information_schema.tables
    WHERE table_schema IN ('temporal', 'temporal_visibility')
    GROUP BY table_schema;"
```

## Daftar Backup
```bash
# Dari PVC (masuk ke pod)
kubectl exec -it deployment/temporal-admintools -n temporal -- ls -lh /backup/
```

## Report Harian

```
=== DB Backup Check ===
Last Backup: 2026-07-07 02:00 (Completed)
Databases: temporal, temporal_visibility
Size: temporal (200MB), temporal_visibility (50MB)
Retention: 7 hari
```