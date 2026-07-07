---
name: temporal-admin
description: Mengelola Temporal server — namespace, workflow, dan admin tools. Gunakan untuk task operasional Temporal.
allowed-tools: bash read
---

# Temporal Admin

Operasional harian Temporal server di namespace `temporal`.

## Daftar Namespace
```bash
kubectl exec deployment/temporal-admintools -n temporal -- temporal operator namespace list
```

## Cek Workflow
```bash
# List workflow dalam namespace
kubectl exec deployment/temporal-admintools -n temporal -- temporal workflow list --namespace devops

# Detail workflow
kubectl exec deployment/temporal-admintools -n temporal -- temporal workflow show --workflow-id <id> --namespace devops
```

## Reset / Terminate Workflow
```bash
kubectl exec deployment/temporal-admintools -n temporal -- temporal workflow terminate \
  --workflow-id <id> --namespace devops --reason "Manual reset"
```

## Cek Cluster
```bash
kubectl exec deployment/temporal-admintools -n temporal -- temporal cluster health
kubectl exec deployment/temporal-admintools -n temporal -- temporal cluster system-info
```

## Cek Search Attributes
```bash
kubectl exec deployment/temporal-admintools -n temporal -- temporal search-attribute list
```

## Akses Pod Langsung
```bash
# Masuk ke pod temporal-admintools
kubectl exec -it deployment/temporal-admintools -n temporal -- bash

# Di dalam pod:
temporal operator namespace list
temporal workflow list --namespace devops
```

## Report Harian

```
=== Temporal Admin Check ===
Namespace: devops, develop-devops, dev-qoinhub-pg
Cluster: Healthy
Pending Workflows: <count>
```