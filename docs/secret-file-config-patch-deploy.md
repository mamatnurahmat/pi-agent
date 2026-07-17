# Secret File Config — Patch Deployment Volume

> **Namespace:** `production-payout`  
> **Kube Context:** `hw-pro-p`  
> **Dokumentasi:** Cara menambahkan `file-config-volume` ke deployment yang belum memiliki volume untuk mount file konfigurasi (.env / appsettings.json) dari Secret.

---

## 📋 Status Awal (Production Payout)

| Status | Item | Keterangan |
|--------|------|------------|
| ✅ | 39 file-config Secret di cluster | Semua `pay-be-*` service |
| ✅ | 39 file-config YAML di gitops | `cce/production-payout/file-config-*_secret.yaml` |
| ✅ | 39 deployment + nginx-ws-proxy + s3-minio + vaopenpayment + vatransferbag | Sudah punya `file-config-volume` |
| ❌ | **pay-apigateway** | **Belum punya file-config-volume & belum ada Secret** |

---

## 1️⃣ Dry-Run: Generate Secret dari File Config

### Go App (.env)
```bash
# Pastikan context benar
kubectl config current-context
# Output: hw-pro-p

# Dry-run: generate Secret YAML dari .env.production
kubectl create secret generic file-config-{deployment-name} \
  --namespace=production-payout \
  --from-file=.env={deployment-name}/.env.production \
  --dry-run=client -o yaml
```

**Contoh:**
```bash
kubectl create secret generic file-config-pay-be-workflow \
  --namespace=production-payout \
  --from-file=.env=pay-be-workflow/.env.production \
  --dry-run=client -o yaml
```

### .NET App (appsettings.json)
```bash
kubectl create secret generic file-config-{deployment-name} \
  --namespace=production-payout \
  --from-file=appsettings.production.json={deployment-name}/appsettings.production.json \
  --dry-run=client -o yaml
```

**Contoh:**
```bash
kubectl create secret generic file-config-pay-be-vaopenpayment-manager \
  --namespace=production-payout \
  --from-file=appsettings.production.json=pay-be-vaopenpayment-manager/appsettings.production.json \
  --dry-run=client -o yaml
```

### Output
Output akan disimpan sebagai:  
`file-config-{deployment-name}_secret.yaml` di folder namespace yang sama.

---

## 2️⃣ Patch Deployment: Tambah file-config-volume

Ada dua bagian yang perlu ditambahkan ke deployment:

### A. Tambah `volumeMounts` di container
```yaml
volumeMounts:
  - mountPath: /etc/localtime
    name: tz-config
  # ⇩ TAMBAHKAN INI
  - mountPath: /.env
    name: file-config-volume
    subPath: .env
```

### B. Tambah `volumes` di spec
```yaml
volumes:
  - hostPath:
      path: /usr/share/zoneinfo/Asia/Jakarta
      type: ""
    name: tz-config
  # ⇩ TAMBAHKAN INI
  - name: file-config-volume
    secret:
      defaultMode: 420
      secretName: file-config-{deployment-name}
```

### Patch YAML Lengkap (Strategic Merge Patch)

Simpan sebagai `patch-file-config-volume.yaml`:

```yaml
# patch-file-config-volume.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pay-apigateway
  namespace: production-payout
spec:
  template:
    spec:
      containers:
        - name: pay-apigateway
          volumeMounts:
            - mountPath: /.env
              name: file-config-volume
              subPath: .env
      volumes:
        - name: file-config-volume
          secret:
            defaultMode: 420
            secretName: file-config-pay-apigateway
```

### Apply Patch (Dry-Run)
```bash
kubectl patch deployment pay-apigateway \
  -n production-payout \
  --patch-file patch-file-config-volume.yaml \
  --dry-run=client -o yaml
```

### Apply (Live)
```bash
kubectl patch deployment pay-apigateway \
  -n production-payout \
  --patch-file patch-file-config-volume.yaml
```

---

## 3️⃣ Verifikasi

### Cek Secret sudah ada
```bash
kubectl -n production-payout get secret | grep file-config-{deployment-name}
```

### Cek Volume di Deployment
```bash
kubectl -n production-payout get deployment {deployment-name} -o jsonpath='{.spec.template.spec.volumes[?(@.name=="file-config-volume")].secret.secretName}'
```

### Cek Mount Path di Container
```bash
kubectl -n production-payout get deployment {deployment-name} -o jsonpath='{.spec.template.spec.containers[0].volumeMounts[?(@.name=="file-config-volume")].mountPath}'
```

### Rollout Status
```bash
kubectl -n production-payout rollout status deployment/{deployment-name}
```

### Verifikasi file ter-mount di Pod
```bash
kubectl -n production-payout exec deploy/{deployment-name} -- cat /.env
```

---

## 4️⃣ Rollback Jika Gagal

```bash
# Rollback ke revisi sebelumnya
kubectl -n production-payout rollout undo deployment/{deployment-name}

# Lihat history rollout
kubectl -n production-payout rollout history deployment/{deployment-name}
```

---

## 5️⃣ Contoh: Patch pay-apigateway (Production Payout)

### Step 1: Buat Secret YAML (dry-run)
```bash
# Siapkan file .env.production di folder secret/production-payout/pay-apigateway/
# Lalu jalankan:
kubectl create secret generic file-config-pay-apigateway \
  --namespace=production-payout \
  --from-file=.env=secret/production-payout/pay-apigateway/.env.production \
  --dry-run=client -o yaml > cce/production-payout/file-config-pay-apigateway_secret.yaml
```

### Step 2: Apply Secret ke cluster
```bash
kubectl apply -f cce/production-payout/file-config-pay-apigateway_secret.yaml
```

### Step 3: Patch deployment
```bash
kubectl patch deployment pay-apigateway \
  -n production-payout \
  --type strategic \
  --patch '
spec:
  template:
    spec:
      containers:
        - name: pay-apigateway
          volumeMounts:
            - mountPath: /.env
              name: file-config-volume
              subPath: .env
      volumes:
        - name: file-config-volume
          secret:
            defaultMode: 420
            secretName: file-config-pay-apigateway
'
```

### Step 4: Update file deployment YAML di gitops
Tambahkan `volumeMounts` dan `volumes` ke `cce/production-payout/pay-apigateway_deployment.yaml` sesuai pola di atas.

### Step 5: Verifikasi
```bash
kubectl -n production-payout rollout status deployment/pay-apigateway
kubectl -n production-payout exec deploy/pay-apigateway -- cat /.env
```

---

## 📊 Referensi: Struktur Mount yang Sudah Jalan

Semua deployment di `production-payout` menggunakan pola yang sama:

```yaml
# volumeMounts (di container)
- mountPath: /.env
  name: file-config-volume
  subPath: .env

# volumes (di spec)
- name: file-config-volume
  secret:
    defaultMode: 420
    secretName: file-config-{deployment-name}
```

> **Catatan:** Baik Go app (.env) maupun .NET app (appsettings.json) sama-sama di-mount ke `/.env` dengan `subPath: .env`. Perbedaannya hanya di key/data Secret yang di-generate.

---

## 🔍 Auto-Detect: Go vs .NET

| File ditemukan | Bahasa | Secret Key |
|---------------|--------|------------|
| `.env.production` | Go | `.env` |
| `appsettings.production.json` | .NET | `appsettings.production.json` |

Gunakan `secret-from-file` skill untuk auto-generate:
```bash
# Dari folder gitops root
~/.pi/agent/bin/generate.sh production-payout/pay-apigateway
```

---

*Dibuat: 17 Juli 2026 | Context: hw-pro-p | Namespace: production-payout*