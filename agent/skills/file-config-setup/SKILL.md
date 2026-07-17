---
name: file-config-setup
description: Generate K8s Secret YAML dari file config (.env / appsettings.json), apply secret ke cluster, dan patch deployment dengan volume file-config-volume. Gunakan untuk setup konfigurasi aplikasi di namespace production-payout, production-saas, dan namespace lainnya.
---

# File Config Setup

Lihat dokumentasi lengkap di [~/.pi/docs/secret-file-config-patch-deploy.md](../../../.pi/docs/secret-file-config-patch-deploy.md)

## Alur Cepat

### Generate Secret

```bash
~/.pi/agent/skills/secret-from-file/generate.sh <path-to-deploy-dir>
```

### Apply Secret

```bash
kubectl apply -f file-config-{app}_secret.yaml --namespace=<ns>
```

### Patch Deployment

```bash
# Dry-run (generate YAML)
~/.pi/agent/bin/patch-file-config-deploy <namespace> <deployment>

# Apply ke cluster + rollout
~/.pi/agent/bin/patch-file-config-deploy <namespace> <deployment> --apply
```

## Script Terkait

- `~/.pi/agent/bin/patch-file-config-deploy` — Patch deployment dg auto-detect semua file di secret
- `~/.pi/agent/bin/patch-dotenv-go` — Patch deployment khusus Go (.env saja)
- `~/.pi/agent/skills/secret-from-file/generate.sh` — Generate secret YAML dari file config

## Catatan

- Skip deployment: `pay-apigateway`, `nginx-ws-proxy`, `s3-minio`
- Script akan skip jika volume/volumeMount sudah ada (idempotent)