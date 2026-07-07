---
name: secret-from-file
description: Auto-detect language (Go/.NET) from config file type and generate K8s Secret YAML. Scans deployment dirs for .env.* or appsettings.*.json, outputs ready-to-apply Secret manifest.
---

# secret-from-file

Generate K8s Secret YAML from config files. Auto-detect language.

## Auto-detect logic

| Found file                | Lang   | Secret key              |
|---------------------------|--------|-------------------------|
| `.env.{env}`              | Go     | `.env`                  |
| `appsettings.{env}.json`  | dotnet | `appsettings.{env}.json` |

Env is extracted from namespace dir name (`production-ngenwal` → `production`).

## Usage

```bash
# Single deploy
./generate.sh production-ngenwal/ngenwal-be-asset-module

# All deploys in an env
for d in production-ngenwal/*/; do ./generate.sh "$d"; done

# With explicit namespace override
./generate.sh production-ngenwal/ngenwal-be-asset-module production-custom
```

Output: `{parent_dir}/file-config-{deployment}_secret.yaml`

## Manual (kubectl one-liner)

```bash
# Go
kubectl create secret generic file-config-ngenwal-be-workflow \
  --namespace=production-ngenwal \
  --from-file=.env=ngenwal-be-workflow/.env.production \
  --dry-run=client -o yaml

# .NET
kubectl create secret generic file-config-ngenwal-be-asset-module \
  --namespace=production-ngenwal \
  --from-file=appsettings.production.json=ngenwal-be-asset-module/appsettings.production.json \
  --dry-run=client -o yaml
```