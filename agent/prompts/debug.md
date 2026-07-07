---
description: Debug workflow: identifikasi, analisis, fix, verifikasi
argument-hint: "<jelaskan issue>"
---
## Debug Workflow

Debug issue: $@

### Langkah 1: Reproduksi
- Pahami cara mereproduksi issue
- Jalankan jika bisa direproduksi
- Catat error message dan stack trace

### Langkah 2: Analisis Root Cause
- Lacak dari error ke sumber masalah
- Cek log, stack trace, dan kode terkait
- Gunakan read, grep untuk tracing

### Langkah 3: Rencana Fix
- Usulkan solusi
- Jelaskan trade-off (jika ada)
- Minta konfirmasi sebelum eksekusi

### Langkah 4: Implementasi Fix
- Terapkan perbaikan
- Pastikan tidak merusak hal lain

### Langkah 5: Verifikasi
- Cek issue sudah tidak ter-reproduksi
- Jalankan test terkait jika ada
- Pastikan regresi tidak terjadi