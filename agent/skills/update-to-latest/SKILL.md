---
name: update-to-latest
description: Update deployment/image tag ke tag release terbaru (v*) dari GitHub. Cocok untuk GitOps roll update di cluster Kubernetes.
---

# Update Repo / Deployment ke Latest Tag

Gunakan workflow ini ketika user ingin memperbarui sebuah deployment ke versi terbaru atau "latest tag" dari repository GitHub-nya.

## Alur Kerja

### 1. Cek versi terbaru di GitHub
Gunakan script `gh-latest-tag` untuk melihat tag `v*` paling baru.

```bash
~/.pi/agent/bin/gh-latest-tag <repo>
```

Contoh: `~/.pi/agent/bin/gh-latest-tag qoinplus-backend`

### 2. Cek versi yang sedang berjalan di K8s
```bash
~/.pi/agent/bin/k8s-latest-tag <namespace> <deployment>
```

Contoh: `~/.pi/agent/bin/k8s-latest-tag develop-qoinplus qoinplus-backend`

### 3. Bandingkan versi (opsional)
```bash
~/.pi/agent/bin/is-match <namespace> <deployment> [repo] [org]
```

Atau untuk cek semua deployment dalam satu namespace sekaligus:
```bash
~/.pi/agent/bin/is-match-ns <namespace> [org]
```

### 4. Update deployment ke versi terbaru
Jika ingin langsung update image deployment di K8s ke tag terbaru:

```bash
~/.pi/agent/bin/set-image <namespace> <deployment> <tag>
```

Contoh: `~/.pi/agent/bin/set-image develop-qoinplus qoinplus-backend v1.2.3`

Atau untuk konteks GitOps, clone repo di tag tersebut:
```bash
~/.pi/agent/bin/gh-clone <repo> <tag> [org]
```

### 5. Verifikasi hasil update
```bash
~/.pi/agent/bin/is-match <namespace> <deployment> [repo]
```

## Contoh Skenario Lengkap

**User:** "Update qoinplus-backend ke yang terbaru"

**Agent akan menjalankan:**
1. `~/.pi/agent/bin/gh-latest-tag qoinplus-backend` → dapat tag `v1.5.0`
2. `~/.pi/agent/bin/k8s-latest-tag develop-qoinplus qoinplus-backend` → dapat tag `v1.4.2`
3. Informasikan ke user bahwa ada versi baru `v1.5.0` (sekarang `v1.4.2`)
4. Konfirmasi ke user, lalu jalankan:
   - `~/.pi/agent/bin/set-image develop-qoinplus qoinplus-backend v1.5.0`
5. Verifikasi dengan `is-match`

## Catatan
- Organization default untuk GitHub adalah `Qoin-Digital-Indonesia` jika tidak disebutkan lain.
- Default branch untuk `gh-check-lang` adalah `staging`.
- Script `set-image` bisa update semua container dalam satu deployment.
- Gunakan `gh-clone` jika perlu menarik kode sumber di tag tertentu.