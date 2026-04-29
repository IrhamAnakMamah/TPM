# Skill: SKPL Review

## Deskripsi
Gunakan skill ini ketika diminta untuk memeriksa, memvalidasi, atau mengaudit file SKPL (Spesifikasi Kebutuhan Perangkat Lunak), terutama `SKPL_PillPal-AI.md`. Skill ini juga aktif ketika ada pertanyaan tentang kelengkapan, konsistensi, atau kesesuaian implementasi terhadap spesifikasi.

## Prosedur

### Langkah 1 — Baca SKPL
Buka dan baca seluruh isi file `SKPL_PillPal-AI.md` dari root proyek.

### Langkah 2 — Periksa Kelengkapan Dokumen
Verifikasi bahwa SKPL mengandung semua bagian berikut:
- [ ] Tujuan dan lingkup produk
- [ ] Deskripsi arsitektur sistem
- [ ] Semua kebutuhan fungsional (F-01 s.d F-13) dengan kriteria penerimaan
- [ ] Kebutuhan non-fungsional dan sensor (S-01 s.d S-06)
- [ ] Skema database yang lengkap
- [ ] Daftar API/integrasi eksternal
- [ ] Pembagian kerja tim
- [ ] Tech stack yang digunakan

### Langkah 3 — Periksa Konsistensi Internal
Cari inkonsistensi seperti:
- Fitur yang disebutkan di satu bagian tapi tidak dijelaskan di bagian lain
- Tabel database yang tidak memiliki kolom yang dibutuhkan fitur
- Tech stack yang disebutkan tidak mendukung fitur yang direncanakan
- Dependency antar fitur yang tidak terdokumentasi (misal: F-07 bergantung pada F-03)

### Langkah 4 — Periksa Kelayakan Teknis
Evaluasi apakah setiap fitur dapat diimplementasikan dalam 1 bulan oleh 2 orang dengan stack yang dipilih:
- Tandai fitur yang berisiko tinggi (kompleks + waktu terbatas)
- Tandai fitur yang bergantung pada API eksternal yang mungkin tidak stabil
- Berikan estimasi kompleksitas: Rendah / Sedang / Tinggi

### Langkah 5 — Buat Laporan Review
Hasilkan laporan dalam format berikut:

```
## Laporan Review SKPL — PillPal-AI
**Tanggal Review:** [tanggal]
**Status Dokumen:** ✅ Lengkap / ⚠️ Perlu Perbaikan / ❌ Tidak Lengkap

### ✅ Bagian yang Sudah Baik
[daftar poin positif]

### ⚠️ Temuan & Rekomendasi
[daftar masalah beserta saran perbaikan]

### 🚨 Risiko Implementasi
[daftar risiko teknis berdasarkan timeline]

### 📋 Checklist Kelengkapan
[checklist semua bagian SKPL]
```