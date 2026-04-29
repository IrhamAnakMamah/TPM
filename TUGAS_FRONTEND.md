# 📋 Tugas Frontend — Fitur Jadwal Obat (F-04 & F-05)
> **PillPal-AI** | Dikerjakan oleh: Rekan Frontend  
> **Target selesai:** Akhir Minggu 2  
> **Berkoordinasi dengan:** Irham (Backend)

---

## 🗺️ Gambaran Umum

Kamu akan membuat fitur **Jadwal Obat** lengkap dari sisi Flutter:
1. Halaman daftar jadwal obat (menggantikan data dummy di `home_screen.dart`)
2. Form tambah jadwal obat secara manual
3. Tampilan konfirmasi "Sudah Minum" yang mengurangi stok

Backend (Irham) akan menyiapkan endpoint LLM parsing jadwal. Kamu **tidak perlu** menyentuh backend.

---

## 📁 Struktur File yang Harus Dibuat

```
lib/
├── data/
│   ├── models/
│   │   └── schedule_model.dart        ← [BUAT BARU]
│   └── local/
│       └── database_helper.dart       ← [UPDATE — tambah tabel schedules]
│
├── features/
│   └── medications/                   ← [FOLDER BARU]
│       ├── screens/
│       │   ├── medication_list_screen.dart   ← [BUAT BARU] daftar semua obat
│       │   ├── add_medication_screen.dart    ← [BUAT BARU] form tambah obat
│       │   └── medication_detail_screen.dart ← [BUAT BARU] detail + konfirmasi minum
│       └── widgets/
│           ├── medication_card.dart          ← [BUAT BARU] card obat reusable
│           └── schedule_badge.dart           ← [BUAT BARU] badge waktu/frekuensi
│
└── features/dashboard/screens/
    └── home_screen.dart               ← [UPDATE — ganti data dummy dengan data real]
```

---

## ✅ Task 1 — Buat `ScheduleModel` (Model Data)

**File:** `lib/data/models/schedule_model.dart`

Buat model Dart untuk jadwal obat sesuai skema SKPL:

```dart
class ScheduleModel {
  final int? id;
  final int medId;           // foreign key ke medications.id
  final String timeIntake;   // format "HH:mm", contoh "08:00"
  final double dosage;       // jumlah dosis per konsumsi
  final String dosageUnit;   // "mg", "ml", "tablet"
  final String frequencyType;  // "daily" atau "every_n_hours"
  final int frequencyValue;    // 1 = sekali sehari, 8 = tiap 8 jam
  final String status;       // "active" atau "expired"

  // Tambahkan constructor, fromMap(), toMap(), copyWith()
}
```

---

## ✅ Task 2 — Update `DatabaseHelper` (Tambah Tabel Baru)

**File:** `lib/data/local/database_helper.dart`

> ⚠️ **PENTING:** Naikkan versi database dari `version: 1` ke `version: 2`  
> dan tambahkan `onUpgrade` agar tidak crash di device yang sudah install.

**Tambahkan tabel `schedules` dan `intake_logs`:**

```sql
-- Tabel schedules (jadwal per obat)
CREATE TABLE schedules (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  med_id INTEGER NOT NULL,
  time_intake TEXT NOT NULL,      -- "HH:mm"
  dosage REAL NOT NULL,
  dosage_unit TEXT NOT NULL,
  frequency_type TEXT NOT NULL,   -- "daily" | "every_n_hours"
  frequency_value INTEGER NOT NULL,
  status TEXT DEFAULT 'active',
  FOREIGN KEY (med_id) REFERENCES medications(id)
);

-- Tabel intake_logs (log setiap konfirmasi minum)
CREATE TABLE intake_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  schedule_id INTEGER NOT NULL,
  timestamp TEXT NOT NULL,
  status TEXT NOT NULL,           -- "on-time" | "late" | "missed"
  FOREIGN KEY (schedule_id) REFERENCES schedules(id)
);
```

**Tambahkan juga method CRUD berikut ke DatabaseHelper:**

```dart
// Jadwal
Future<List<Map<String, dynamic>>> getSchedulesWithMed(int userId);
Future<int> insertSchedule(ScheduleModel schedule);
Future<int> updateScheduleStatus(int scheduleId, String status);

// Log Konsumsi
Future<int> logIntake(int scheduleId, String status);
Future<List<Map<String, dynamic>>> getIntakeLogs({int limit = 50});
```

---

## ✅ Task 3 — Buat `MedicationListScreen` (Halaman Daftar Jadwal)

**File:** `lib/features/medications/screens/medication_list_screen.dart`

**Yang harus ditampilkan:**
- AppBar: "Jadwal Obat Saya" + tombol `+` (FAB atau di AppBar)
- List jadwal obat yang diambil dari SQLite (bukan dummy)
- Setiap item menampilkan: nama obat, waktu minum, dosis, status (active/expired)
- Swipe-to-delete atau long press untuk hapus
- Pull-to-refresh untuk memuat ulang data
- Empty state jika belum ada jadwal

**Navigasi:**
- Tap item → buka `MedicationDetailScreen`
- Tap `+` → buka `AddMedicationScreen`

---

## ✅ Task 4 — Buat `AddMedicationScreen` (Form Tambah Jadwal)

**File:** `lib/features/medications/screens/add_medication_screen.dart`

**Form fields yang dibutuhkan (sesuai F-04 SKPL):**

| Field | Widget | Keterangan |
|---|---|---|
| Nama Obat | `TextFormField` | Wajib diisi |
| Dosis | `TextFormField` (angka) | Contoh: 500 |
| Satuan Dosis | `DropdownButtonFormField` | mg / ml / tablet |
| Frekuensi | `DropdownButtonFormField` | Sehari 1x / 2x / 3x / Tiap N Jam |
| Nilai N (jika tiap N jam) | `TextFormField` (angka) | Muncul hanya jika pilih "Tiap N Jam" |
| Waktu Pertama | `TimePickerDialog` | Waktu intake pertama |
| Stok Awal | `TextFormField` (angka) | Jumlah unit obat |
| Catatan (opsional) | `TextFormField` | Sebelum/Sesudah Makan, dll. |

**Logika form:**
1. Validasi semua field wajib sebelum simpan
2. Simpan ke tabel `medications` (nama, stok) dan `schedules` (waktu, frekuensi, dosis)
3. Tampilkan `SnackBar` sukses setelah simpan
4. Kembali ke `MedicationListScreen` setelah sukses

> 💡 **Catatan:** Field "Input LLM" (F-04B) **belum perlu diimplementasikan** sekarang. Irham akan selesaikan backend-nya dulu, nanti kamu tinggal sambungkan.

---

## ✅ Task 5 — Buat `MedicationDetailScreen` (Detail + Konfirmasi Minum)

**File:** `lib/features/medications/screens/medication_detail_screen.dart`

**Yang ditampilkan:**
- Info obat: nama, dosis, frekuensi, waktu minum, sisa stok
- Tombol **"✅ Sudah Minum"** yang:
  1. Mengurangi `total_stock` di tabel `medications` sebesar `dosage`
  2. Menambahkan record ke `intake_logs` dengan status `on-time`
  3. Jika stok ≤ 0, update `schedules.status` menjadi `expired`
  4. Tampilkan `SnackBar` konfirmasi
- Riwayat konsumsi hari ini (dari `intake_logs`)

---

## ✅ Task 6 — Update `HomeScreen` (Ganti Data Dummy)

**File:** `lib/features/dashboard/screens/home_screen.dart`

Ganti 2 card dummy (`_buildProMedCard(...)`) dengan data real dari SQLite:

```dart
// Sebelumnya (dummy):
_buildProMedCard('Paracetamol 500mg', '08:00 WIB', 'Sesudah Makan', true),
_buildProMedCard('Amoxicillin', '13:00 WIB', 'Sebelum Makan', false),

// Sesudahnya (real):
// Load dari DatabaseHelper().getAllMedications() atau getSchedulesWithMed()
// Tampilkan jadwal hari ini yang belum diminum
// Tambahkan tombol "Lihat Semua" yang navigate ke MedicationListScreen
```

---

## ✅ Task 7 — Hubungkan ke `MainScreen` atau Navigasi

**File:** `lib/features/dashboard/screens/main_screen.dart`

Tambahkan navigasi ke `MedicationListScreen` dari HomeScreen atau bottom nav jika diperlukan.  
Diskusikan dengan Irham apakah perlu tab baru di bottom nav.

---

## 🎨 Panduan Desain

- Ikuti palet warna existing: teal (`#0D9488`) untuk aksen utama
- Gunakan `BorderRadius.circular(18~24)` untuk card
- Shadow ringan: `BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)`
- Status `active` → teal, `expired` → abu-abu, belum minum → orange

---

## 🔗 Koordinasi dengan Irham (Backend)

Kamu **tidak perlu menunggu** Irham untuk Task 1–6 (semua berbasis SQLite lokal).

Endpoint backend sudah siap dan bisa langsung dipakai. Gunakan method yang ada di `ApiService` (sudah disiapkan Irham di `lib/core/services/api_service.dart`).

---

### Endpoint 1 — Parse Jadwal via AI (F-04B)

**Kapan dipakai:** Di `AddMedicationScreen`, tambahkan tombol **"✨ Isi dengan AI"**.  
Saat ditekan, tampilkan dialog input teks, kirim ke API, lalu isi form secara otomatis dari hasilnya.

```dart
// Panggil di AddMedicationScreen setelah user ketik teks alami
final result = await ApiService().parseSchedule(
  "Minum Amoxicillin 500mg 3x sehari, stok 21 kapsul"
);

if (result['status'] == 'ok') {
  final data = result['data'] as Map<String, dynamic>;
  // Isi form dari data:
  // data['name']             → nama obat       (String)
  // data['dosage']           → jumlah dosis     (double)
  // data['dosage_unit']      → "mg"|"ml"|"tablet"|"kapsul"
  // data['frequency_type']   → "daily"|"every_n_hours"
  // data['frequency_value']  → nilai N           (int)
  // data['total_stock']      → stok awal         (int)
  // data['time_intake']      → waktu, "HH:MM"   (String)
} else {
  // Tampilkan SnackBar error: result['message']
}
```

---

### Endpoint 2 — Rangkuman Medis Obat (F-07)

**Kapan dipakai:** Di `MedicationDetailScreen`, tambahkan tombol **"🔍 Info Medis"**.  
Saat ditekan, tampilkan `BottomSheet` atau halaman baru dengan teks rangkuman.

```dart
// Ambil allergy_profile dari session user (bisa kosong "")
final allergyProfile = SessionManager().currentUser?['allergy_profile'] ?? '';

final result = await ApiService().getDrugSummary(
  drugName: medication.name,      // nama obat dari SQLite
  allergyProfile: allergyProfile, // dari profil user (F-03)
);

if (result['status'] == 'ok') {
  final summary = result['summary'] as String; // teks rangkuman Bahasa Indonesia
  final rxcui   = result['rxcui'];             // String | null
  // Tampilkan summary di UI
} else {
  // Tampilkan SnackBar error: result['message']
}
```

> ⚠️ **Kedua endpoint memerlukan JWT token** (sudah otomatis di-handle oleh `ApiService` via `_authHeaders`).  
> Pastikan user sudah login sebelum memanggil method ini.

---

### Format Data Tabel (untuk Koordinasi)

Pastikan saat menyimpan ke SQLite, field ini konsisten:

| Field SQLite | Tipe | Contoh nilai |
|---|---|---|
| `frequency_type` | TEXT | `"daily"` atau `"every_n_hours"` |
| `frequency_value` | INTEGER | `1` (sekali sehari) atau `8` (tiap 8 jam) |
| `dosage_unit` | TEXT | `"mg"`, `"ml"`, `"tablet"`, `"kapsul"` |
| `status` | TEXT | `"active"` atau `"expired"` |

---

## 📌 Checklist Progress

- [ ] Task 1 — `ScheduleModel` selesai
- [ ] Task 2 — `DatabaseHelper` diupdate (tabel baru + CRUD)
- [ ] Task 3 — `MedicationListScreen` selesai
- [ ] Task 4 — `AddMedicationScreen` selesai
- [ ] Task 5 — `MedicationDetailScreen` selesai
- [ ] Task 6 — `HomeScreen` pakai data real
- [ ] Task 7 — Navigasi terhubung
- [ ] Testing end-to-end: tambah obat → lihat di home → konfirmasi minum → stok berkurang

---

*File ini dibuat oleh Irham | PillPal-AI © 2026*
