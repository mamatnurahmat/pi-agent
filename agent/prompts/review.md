---
description: Review kode secara menyeluruh (struktur, keamanan, error handling, best practices)
argument-hint: "[file atau direktori]"
---
## Code Review Workflow

Lakukan review kode untuk ${1:-perubahan yang ada} dengan langkah berikut:

1. **Pahami Konteks**
   - Baca file yang berubah (`git diff` atau `read`)
   - Pahami tujuan perubahan

2. **Analisis Kode**
   - Cek struktur dan logika
   - Cek potensi bug atau race condition
   - Cek keamanan (input validation, injection, dll)
   - Cek error handling
   - Cek performa

3. **Beri Feedback**
   - Positif: sebut apa yang sudah baik
   - Improvement: beri saran konkret dengan contoh kode
   - Prioritaskan: critical → major → minor

4. **Kesimpulan**
   - Ringkasan temuan
   - Rekomendasi: Approve / Revisi / Diskusi