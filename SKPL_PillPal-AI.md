# Spesifikasi Kebutuhan Perangkat Lunak (SKPL)
# PillPal-AI

> **Versi:** 1.1  
> **Tanggal:** April 2026  
> **Tim Pengembang:** Irham dan Rekan  
> **Mata Kuliah:** Teknologi Pemrograman Mobile (TPM)  
> **Durasi Pengerjaan:** 1 Bulan

---

## Daftar Isi

1. [Pendahuluan](#1-pendahuluan)
2. [Deskripsi Umum Sistem](#2-deskripsi-umum-sistem)
3. [Kebutuhan Fungsional](#3-kebutuhan-fungsional)
4. [Kebutuhan Non-Fungsional & Sensor](#4-kebutuhan-non-fungsional--sensor)
5. [Arsitektur Data](#5-arsitektur-data)
6. [Antarmuka Eksternal](#6-antarmuka-eksternal)
7. [Rencana Pengerjaan & Pembagian Kerja](#7-rencana-pengerjaan--pembagian-kerja)
8. [Tech Stack](#8-tech-stack)
9. [Risiko & Mitigasi](#9-risiko--mitigasi)
10. [Glosarium](#10-glosarium)

---

## 1. Pendahuluan

### 1.1 Tujuan

Dokumen ini mendefinisikan seluruh kebutuhan fungsional dan non-fungsional dari aplikasi **PillPal-AI**. Dokumen ini berfungsi sebagai acuan resmi pengembangan bagi tim selama periode pengerjaan satu bulan untuk mata kuliah TPM, dan dapat digunakan sebagai referensi dalam pengujian, evaluasi, serta presentasi akhir.

### 1.2 Lingkup Produk

**PillPal-AI** adalah aplikasi manajemen kesehatan berbasis mobile yang berfokus pada:

- Pengelolaan dan penjadwalan minum obat secara cerdas
- Identifikasi obat menggunakan model AI/ML berbasis kamera
- Rangkuman informasi medis menggunakan Large Language Model (LLM)
- Sistem notifikasi adaptif untuk meningkatkan kepatuhan pengguna (medication adherence)

Aplikasi ini **tidak** dirancang sebagai pengganti diagnosis atau anjuran medis profesional.

### 1.3 Definisi & Singkatan

| Singkatan | Keterangan |
|-----------|------------|
| SKPL | Spesifikasi Kebutuhan Perangkat Lunak |
| LLM | Large Language Model |
| LBS | Location-Based Service |
| ML | Machine Learning |
| TPM | Teknologi Pemrograman Mobile |
| SQLite | Embedded relational database engine |
| RxNorm | Database standar nomenclature obat dari NLM (National Library of Medicine) |
| OpenFDA | API publik data obat dari U.S. Food & Drug Administration |

### 1.4 Referensi

- RxNorm API: https://rxnav.nlm.nih.gov/
- OpenFDA API: https://open.fda.gov/
- Google Maps Platform: https://developers.google.com/maps
- Gemini API: https://ai.google.dev/
- Flutter SDK: https://flutter.dev/

---

## 2. Deskripsi Umum Sistem

### 2.1 Arsitektur Sistem

Sistem mengadopsi arsitektur **Client-Server** yang ringan dan berorientasi pada ketersediaan offline:

```
┌─────────────────────────────────────┐
│           MOBILE CLIENT             │
│    Flutter (Android / iOS)          │
│  ┌─────────────┐  ┌──────────────┐  │
│  │  UI / UX    │  │  SQLite DB   │  │
│  │  (Dart)     │  │  (Lokal)     │  │
│  └──────┬──────┘  └──────────────┘  │
└─────────┼───────────────────────────┘
          │ HTTP / REST
          ▼
┌─────────────────────────────────────┐
│           BACKEND SERVICE           │
│         FastAPI (Python)            │
│  ┌──────────┐  ┌──────────────────┐ │
│  │ Gemini   │  │  TensorFlow Lite │ │
│  │ LLM API  │  │  (Image Clasif.) │ │
│  └──────────┘  └──────────────────┘ │
│  ┌──────────┐  ┌──────────────────┐ │
│  │  RxNorm  │  │    OpenFDA API   │ │
│  │   API    │  │                  │ │
│  └──────────┘  └──────────────────┘ │
└─────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│         LAYANAN PIHAK KETIGA        │
│  Google Maps API | Currency API     │
└─────────────────────────────────────┘
```

### 2.2 Kebutuhan Stakeholder

| Stakeholder | Kebutuhan |
|-------------|-----------|
| Mahasiswa / Masyarakat Umum | Pengingat obat yang mudah digunakan, akurat, dan tidak bergantung internet |
| Dosen Pengampu | Implementasi teknis mencakup: Biometrik, Sensor, AI/ML, LLM, LBS |
| Pengguna dengan Kondisi Medis Khusus | Personalisasi berbasis profil alergi dan interaksi obat |

### 2.3 Asumsi & Batasan

- Aplikasi hanya tersedia untuk platform **Android** dalam scope pengerjaan 1 bulan. Dukungan iOS dapat dipertimbangkan pasca-TPM.
- Fitur AI memerlukan koneksi internet; fitur dasar (jadwal & stok) tetap berjalan secara offline.
- Aplikasi **tidak** menyimpan data pengguna di server cloud; semua data tersimpan lokal di perangkat.
- Model klasifikasi citra hanya mengklasifikasikan 3 kategori: **Tablet**, **Kapsul**, dan **Sirup**.

---

## 3. Kebutuhan Fungsional

### 3.1 Keamanan & Profil

#### F-01 — Autentikasi Terenkripsi

- **Deskripsi:** Sistem menyediakan mekanisme login mandiri menggunakan username dan password.
- **Detail Teknis:**
  - Password di-hash menggunakan **SHA-256** sebelum disimpan di SQLite.
  - Penggunaan **Firebase Authentication dilarang**.
  - Sesi pengguna dikelola menggunakan token lokal dengan masa berlaku yang dapat dikonfigurasi.
- **Kriteria Penerimaan:**
  - Login berhasil jika hash password cocok dengan yang tersimpan.
  - Percobaan login gagal lebih dari 5 kali mengunci akun selama 30 menit.

#### F-02 — Biometric Login

- **Deskripsi:** Pengguna dapat masuk ke aplikasi menggunakan autentikasi biometrik.
- **Detail Teknis:**
  - Mendukung **Fingerprint** dan **Face ID** melalui Flutter `local_auth` package.
  - Biometrik hanya aktif setelah login pertama berhasil dilakukan secara manual.
  - Status `biometric_enabled` disimpan di tabel `users`.
- **Kriteria Penerimaan:**
  - Autentikasi biometrik berhasil membuka aplikasi tanpa memasukkan password.
  - Jika biometrik gagal 3 kali, sistem fallback ke login manual.

#### F-03 — Manajemen Profil

- **Deskripsi:** Pengguna dapat mengelola data pribadi dan profil medis mereka.
- **Detail Teknis:**
  - Data yang dapat diubah: foto profil, nama tampilan, profil alergi (format teks bebas atau tag).
  - **Profil Alergi** digunakan sebagai konteks tambahan oleh LLM (F-07) saat menghasilkan peringatan interaksi obat.
- **Kriteria Penerimaan:**
  - Perubahan profil tersimpan dan langsung tercermin pada fitur LLM Summary.

---

### 3.2 Manajemen Obat & AI

#### F-04 — Penjadwalan Cerdas (Smart Timer)

- **Deskripsi:** Pengguna dapat menambahkan jadwal minum obat secara manual maupun menggunakan input teks alami yang diproses LLM.

**A. Input Manual**

| Field | Tipe Data | Keterangan |
|-------|-----------|------------|
| Nama Obat | String | Wajib diisi |
| Dosis | Float | Dalam satuan mg, ml, tablet, dll. |
| Frekuensi | Enum | Sehari sekali, 2x, 3x, tiap N jam |
| Waktu Pertama | Time | Waktu intake pertama |
| Stok Awal | Integer | Jumlah unit obat yang tersedia. Nilai ini mengisi kolom `total_stock` di tabel `medications` (dikelola per obat, bukan per jadwal). |

**B. Input LLM (Natural Language Parsing)**

- Pengguna mengetikkan instruksi teks seperti:
  > _"Minum Paracetamol 500mg setiap 8 jam, stok 30 tablet"_
- LLM (Gemini) melakukan **parsing** dan mengisi field jadwal secara otomatis.
- Hasil parsing ditampilkan dalam form konfirmasi sebelum disimpan.

- **Kriteria Penerimaan:**
  - Parsing berhasil menghasilkan data jadwal yang valid dari input teks alami dalam waktu ≤ 5 detik.
  - Pengguna dapat mengedit hasil parsing sebelum menyimpan.

#### F-05 — Pelacakan Stok Otomatis

- **Prasyarat:** F-04 (Jadwal harus sudah dibuat dan obat terdaftar di tabel `medications`).
- **Deskripsi:** Sistem secara otomatis mengelola stok obat berdasarkan log konsumsi.
- **Detail Teknis:**
  - Setiap konfirmasi "sudah minum" mengurangi `total_stock` sebesar nilai `dosage`.
  - Jadwal berstatus `expired` secara otomatis ketika `total_stock` ≤ 0.
  - Notifikasi peringatan dikirim ketika stok tersisa cukup untuk < 2 hari (F-09).
- **Kriteria Penerimaan:**
  - Stok berkurang tepat sesuai dosis setiap kali pengguna mengkonfirmasi konsumsi.
  - Status jadwal berubah menjadi `expired` secara otomatis saat stok habis.

#### F-06 — Identifikasi Citra AI/ML

- **Deskripsi:** Pengguna dapat memfoto obat untuk mengidentifikasi jenisnya secara otomatis.
- **Detail Teknis:**
  - Model: **TensorFlow Lite** yang dijalankan on-device.
  - Kelas yang didukung: `Tablet`, `Kapsul`, `Sirup`.
  - Sebelum menjalankan kamera, sensor cahaya (S-02) diperiksa untuk memastikan kondisi pencahayaan memadai.
  - Hasil klasifikasi mengisi field `drug_type` pada data obat.
- **Model Training:**
  - Arsitektur: MobileNetV2 (Transfer Learning / Fine-Tuning)
  - Dataset: Dataset gambar obat (tablet, kapsul, sirup) — custom atau dari sumber publik
  - Akurasi target: ≥ 85% pada validation set
  - Format output: `.tflite` (quantized int8), target ukuran model < 5 MB
- **Kriteria Penerimaan:**
  - Klasifikasi menghasilkan output dengan confidence score ≥ 75% untuk diterima otomatis.
  - Jika confidence < 75%, pengguna diminta memilih secara manual.

#### F-07 — Rangkuman Medis LLM

- **Prasyarat:** F-03 (Profil alergi pengguna harus dapat diisi melalui manajemen profil).
- **Deskripsi:** Sistem menyediakan informasi medis yang dipersonalisasi untuk setiap obat.
- **Detail Teknis:**
  - Data obat diambil dari **RxNorm API** dan **OpenFDA API** menggunakan `rx_cui` sebagai identifier.
  - Data tersebut dikirim bersama **profil alergi pengguna** (F-03) ke **Gemini API** untuk dirangkum.
  - Output mencakup:
    - Kegunaan/indikasi obat
    - Efek samping umum
    - Peringatan interaksi berdasarkan alergi pengguna
    - Kontraindikasi penting
- **Kriteria Penerimaan:**
  - Rangkuman dihasilkan dalam waktu ≤ 5 detik.
  - Peringatan interaksi muncul jika profil alergi pengguna relevan dengan kandungan obat.

---

### 3.3 Lokasi & Notifikasi

#### F-08 — LBS: Pharmacy Finder

- **Deskripsi:** Pengguna dapat menemukan apotek terdekat dari lokasi mereka saat ini.
- **Detail Teknis:**
  - Menggunakan **Google Maps SDK** dan **Places API** untuk menampilkan peta dan marker apotek.
  - Menampilkan informasi: nama apotek, jarak, jam operasional, dan rating.
  - Fitur rute navigasi terintegrasi dengan Google Maps.
- **Kriteria Penerimaan:**
  - Peta menampilkan minimal 5 apotek terdekat dalam radius 5 km.

#### F-09 — Notifikasi Cerdas

- **Prasyarat:** F-04 (Jadwal aktif) dan F-05 (Pelacakan stok aktif untuk notifikasi stok rendah).
- **Deskripsi:** Sistem mengirimkan notifikasi tepat waktu dan peringatan stok rendah.
- **Jenis Notifikasi:**

| Tipe | Trigger | Konten |
|------|---------|--------|
| Pengingat Minum Obat | Waktu intake sesuai jadwal | Nama obat, dosis, aksi: Sudah Minum / Snooze |
| Stok Hampir Habis | Stok tersisa < dosis 2 hari | Nama obat, sisa stok, link ke Pharmacy Finder |
| Jadwal Kedaluwarsa | Stok = 0 | Notifikasi bahwa jadwal dinonaktifkan |

- **Detail Teknis:**
  - Notifikasi diimplementasikan menggunakan **Flutter Local Notifications**.
  - Fitur Snooze menggunakan deteksi guncangan (Accelerometer, S-01) atau tombol di notifikasi.
  - Default durasi snooze: 10 menit.

---

### 3.4 Analitik & Utilitas

#### F-10 — Analitik Kepatuhan

- **Deskripsi:** Visualisasi data kepatuhan minum obat pengguna.
- **Detail Teknis:**
  - Data diambil dari tabel `intake_logs` berdasarkan rentang waktu (minggu/bulan).
  - Visualisasi:
    - **Pie Chart:** Persentase on-time / late / missed.
    - **Bar Chart:** Tren harian selama 7 atau 30 hari terakhir.
- **Kriteria Penerimaan:**
  - Grafik diperbarui secara real-time setiap kali ada perubahan pada log konsumsi.

#### F-11 — Konversi Global

**A. Konversi Mata Uang**

- Konversi harga obat antar mata uang: **IDR**, **USD**, **EUR**.
- Menggunakan API konversi mata uang pihak ketiga (misalnya: ExchangeRate-API).

**B. Penyesuaian Zona Waktu**

- Mendeteksi perubahan zona waktu perangkat secara otomatis.
- Jadwal minum obat disesuaikan ke zona waktu lokal yang baru tanpa mengubah frekuensi.
- **Kriteria Penerimaan:**
  - Ketika zona waktu perangkat berubah, semua jadwal aktif otomatis menyesuaikan `time_intake` ke zona waktu baru.
  - Nilai `frequency_type` dan `frequency_value` tidak berubah setelah penyesuaian zona waktu.

#### F-12 — Ekspor Laporan

- **Deskripsi:** Pengguna dapat mengekspor riwayat konsumsi obat.
- **Format yang Didukung:** PDF dan Plain Text (.txt).
- **Konten Laporan:**
  - Nama obat, jadwal, dan dosis
  - Log konsumsi dengan status (on-time / late / missed) beserta timestamp
  - Grafik kepatuhan (khusus format PDF)
- **Kriteria Penerimaan:**
  - File dapat disimpan ke penyimpanan lokal dan dibagikan via share sheet.

#### F-13 — Mini Game Edukasi: Med-Match

- **Deskripsi:** Game kasual berbasis edukasi kesehatan untuk meningkatkan literasi pengguna tentang obat-obatan.
- **Mekanisme:**
  - Pengguna mencocokkan nama obat dengan kegunaannya (matching game).
  - Soal diambil secara dinamis dari database obat pengguna sendiri.
- **Tujuan:** Meningkatkan engagement dan retensi pengguna terhadap informasi medis.
- **Kriteria Penerimaan:**
  - Game menampilkan minimal 5 soal yang diambil dari database obat pengguna.
  - Skor tertinggi pengguna tersimpan dan ditampilkan di halaman game.
  - Jika pengguna belum memiliki obat, gunakan soal dari bank soal statis bawaan aplikasi.

---

## 4. Kebutuhan Non-Fungsional & Sensor

### 4.1 Sensor Perangkat

| ID | Sensor | Implementasi |
|----|--------|--------------|
| S-01 | **Accelerometer** | Deteksi gerakan shake untuk men-snooze alarm pengingat obat |
| S-02 | **Light Sensor** | Validasi kecukupan cahaya sebelum memulai klasifikasi citra AI (F-06) |

**Detail S-01 (Accelerometer):**
- Threshold guncangan: akselerasi ≥ 15 m/s² selama ≥ 300ms.
- Snooze dipicu maksimal 3 kali per sesi alarm; setelah itu notifikasi ditandai sebagai "missed".

**Detail S-02 (Light Sensor):**
- Batas minimum cahaya: ≥ 50 lux.
- Jika cahaya tidak mencukupi, tampilkan peringatan: _"Intensitas cahaya kurang. Pindah ke area yang lebih terang."_

### 4.2 Kebutuhan Non-Fungsional (Ketersediaan & Performa)

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NF-01 | **Ketersediaan Offline** | Fitur jadwal, stok, log konsumsi, dan notifikasi lokal tetap berfungsi tanpa koneksi internet |
| NF-02 | **Performa LLM** | Respons dari Gemini API ≤ 5 detik pada koneksi 4G normal |
| NF-03 | **Performa Klasifikasi** | Inferensi model TFLite on-device ≤ 2 detik |
| NF-04 | **Ukuran Aplikasi** | Target ukuran APK ≤ 50 MB |

### 4.3 Keamanan Data

- Semua data sensitif (password hash, profil alergi) disimpan hanya di SQLite lokal perangkat.
- Tidak ada data pengguna yang dikirim ke server backend kecuali untuk keperluan proses AI (dan hanya data obat, bukan data identitas).
- Komunikasi dengan backend menggunakan **HTTPS**.

---

## 5. Arsitektur Data

### 5.1 Skema SQLite

#### Tabel: `users`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `username` | TEXT NOT NULL UNIQUE | Username unik pengguna |
| `password_hash` | TEXT NOT NULL | SHA-256 hash password |
| `display_name` | TEXT | Nama tampilan |
| `profile_photo` | BLOB | Foto profil (opsional) |
| `allergy_profile` | TEXT | Daftar alergi dalam format teks/JSON |
| `biometric_enabled` | BOOLEAN | Status aktif fitur biometrik |
| `created_at` | DATETIME | Timestamp registrasi |

#### Tabel: `medications`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `user_id` | INTEGER FK | Referensi ke `users.id` |
| `name` | TEXT NOT NULL | Nama obat |
| `drug_type` | TEXT | Hasil klasifikasi AI: Tablet / Kapsul / Sirup |
| `total_stock` | REAL | Jumlah stok saat ini |
| `description` | TEXT | Rangkuman medis dari LLM |
| `rx_cui` | TEXT | Identifier RxNorm untuk integrasi API |
| `created_at` | DATETIME | Timestamp penambahan obat |

#### Tabel: `schedules`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `med_id` | INTEGER FK | Referensi ke `medications.id` |
| `time_intake` | TIME | Waktu minum per hari |
| `dosage` | REAL | Dosis per konsumsi |
| `dosage_unit` | TEXT | Satuan dosis (mg, ml, tablet) |
| `frequency_type` | TEXT | Tipe frekuensi: `daily` atau `every_n_hours` |
| `frequency_value` | INTEGER | Nilai N (contoh: `8` untuk tiap 8 jam; `1` untuk sekali sehari) |
| `status` | TEXT | `active` atau `expired` |

#### Tabel: `intake_logs`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `schedule_id` | INTEGER FK | Referensi ke `schedules.id` |
| `timestamp` | DATETIME | Waktu aktual konsumsi dikonfirmasi |
| `status` | TEXT | `on-time`, `late`, atau `missed` |

#### Tabel: `app_feedback`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER PRIMARY KEY | Auto-increment |
| `user_id` | INTEGER FK | Referensi ke `users.id` |
| `message` | TEXT | Isi feedback pengguna |
| `created_at` | DATETIME | Timestamp pengiriman feedback |

### 5.2 Diagram Relasi (ERD Sederhana)

```
users ──< medications ──< schedules ──< intake_logs
  └───────────────────────────────────< app_feedback
```

---

## 6. Antarmuka Eksternal

### 6.1 API Pihak Ketiga

| API | Kegunaan | Endpoint Utama |
|-----|----------|----------------|
| **Gemini API** (Google AI) | Parsing jadwal & rangkuman medis | `generativelanguage.googleapis.com` |
| **RxNorm API** (NLM) | Data obat standar (nama, RxCUI) | `rxnav.nlm.nih.gov/REST/` |
| **OpenFDA API** | Informasi keamanan & efek samping obat | `api.fda.gov/drug/` |
| **Google Maps / Places API** | Pencarian dan tampilan apotek terdekat | `maps.googleapis.com` |
| **ExchangeRate-API** | Konversi mata uang real-time | `api.exchangerate-api.com` |

### 6.2 Antarmuka Hardware

| Komponen | Interaksi |
|----------|-----------|
| Kamera | Akuisisi gambar untuk klasifikasi obat (F-06) |
| Sensor Cahaya | Validasi kecukupan cahaya (S-02) |
| Accelerometer | Deteksi shake untuk snooze alarm (S-01) |
| Sensor Biometrik | Autentikasi fingerprint/face (F-02) |
| Speaker / Notifikasi | Output alarm pengingat obat (F-09) |

---

## 7. Rencana Pengerjaan & Pembagian Kerja

### 7.1 Pembagian Tugas

#### Irham — Backend & AI

| No | Tugas |
|----|-------|
| 1 | Pembuatan API Service dengan FastAPI (endpoint untuk LLM, klasifikasi, data obat) |
| 2 | Integrasi Gemini API (parsing jadwal natural language & LLM summary) |
| 3 | Pengembangan & training model ML klasifikasi citra (TensorFlow → TFLite) |
| 4 | Integrasi RxNorm API dan OpenFDA API |
| 5 | Pengelolaan environment, deployment lokal, dan dokumentasi API |

#### Rekan Kelompok — Frontend & Mobile

| No | Tugas |
|----|-------|
| 1 | Pengembangan seluruh UI/UX menggunakan Flutter (Dart) |
| 2 | Implementasi SQLite dan enkripsi data lokal |
| 3 | Integrasi autentikasi biometrik (F-02) menggunakan `local_auth` |
| 4 | Integrasi sensor Accelerometer dan Light Sensor (S-01, S-02) |
| 5 | Sistem notifikasi lokal menggunakan Flutter Local Notifications |
| 6 | Visualisasi data analitik (Pie Chart & Bar Chart) |

### 7.2 Estimasi Timeline (4 Minggu)

| Minggu | Fokus Pengerjaan |
|--------|-----------------|
| **Minggu 1** | Setup proyek, autentikasi (F-01, F-02), manajemen profil (F-03), skema SQLite |
| **Minggu 2** | Penjadwalan manual & LLM (F-04), pelacakan stok (F-05), notifikasi dasar (F-09) |
| **Minggu 3** | Klasifikasi citra ML (F-06), rangkuman LLM (F-07), Pharmacy Finder (F-08), sensor (S-01, S-02) |
| **Minggu 4** | Analitik (F-10), konversi (F-11), ekspor (F-12), mini game (F-13), testing & polish |

---

## 8. Tech Stack

| Layer | Teknologi | Keterangan |
|-------|-----------|------------|
| **Mobile Frontend** | Flutter (Dart) | Cross-platform Android/iOS |
| **Backend** | Python, FastAPI | REST API server untuk pemrosesan AI |
| **Database** | SQLite (Embedded) | Penyimpanan lokal on-device |
| **AI/LLM** | Gemini-1.5-Flash | Parsing teks dan rangkuman medis |
| **ML On-Device** | TensorFlow Lite | Klasifikasi gambar obat |
| **Maps** | Google Maps SDK & Places API | Pencarian apotek terdekat |
| **Biometrik** | Flutter `local_auth` | Fingerprint & Face ID |
| **Notifikasi** | Flutter Local Notifications | Alarm & reminder lokal |
| **Konversi Mata Uang** | ExchangeRate-API | Data kurs real-time |

---

## 9. Risiko & Mitigasi

| Risiko | Probabilitas | Dampak | Mitigasi |
|--------|-------------|--------|----------|
| Gemini API timeout atau quota habis | Sedang | Tinggi | Implementasi retry logic + fallback pesan error yang informatif |
| Akurasi model klasifikasi rendah | Sedang | Sedang | Tambahkan threshold confidence; user dapat override manual |
| RxNorm/OpenFDA tidak mengenali nama obat Indonesia | Tinggi | Sedang | Fallback ke pencarian berdasarkan nama generik; tampilkan pesan "data tidak ditemukan" |
| Sensor tidak tersedia di perangkat tertentu | Sedang | Rendah | Cek ketersediaan sensor saat startup; nonaktifkan fitur terkait secara graceful |
| Ukuran model TFLite terlalu besar | Rendah | Sedang | Gunakan model quantized (int8); targetkan ukuran model < 10 MB |

---

## 10. Glosarium

| Istilah | Definisi |
|---------|----------|
| **Medication Adherence** | Kepatuhan pengguna dalam mengonsumsi obat sesuai jadwal yang telah ditentukan |
| **LLM Parsing** | Proses ekstraksi informasi terstruktur dari teks alami menggunakan model bahasa besar |
| **RxCUI** | RxNorm Concept Unique Identifier — kode unik standar untuk identifikasi obat |
| **TFLite** | TensorFlow Lite — versi ringan TensorFlow untuk inferensi on-device di mobile |
| **On-device Inference** | Proses menjalankan model ML langsung di perangkat tanpa memerlukan koneksi server |
| **Confidence Score** | Nilai kepercayaan model ML terhadap hasil prediksinya (0–100%) |
| **Snooze** | Penundaan sementara alarm/notifikasi untuk waktu tertentu |
| **SHA-256** | Algoritma hashing kriptografis yang digunakan untuk menyimpan password secara aman |

---

*Dokumen ini bersifat living document dan dapat diperbarui seiring perkembangan proyek.*

**PillPal-AI © 2026 — Irham dan Rekan | Mata Kuliah TPM**
