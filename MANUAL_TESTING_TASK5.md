# 🧪 MANUAL TESTING TASK 5: MEDICATION LIST SCREEN

**Tanggal:** 3 Mei 2026  
**Tester:** [Nama Anda]  
**Device:** Infinix X6871 (Android 15, API 35)  
**Device ID:** 120692544Q007664

---

## 📋 TEST CASES

### ✅ TEST 1: Empty State
**Precondition:** Database kosong (fresh install atau hapus semua jadwal)

**Steps:**
1. Buka app
2. Tap "Lihat Semua" di HomeScreen (jika ada jadwal) ATAU
3. Navigate langsung ke MedicationListScreen

**Expected Result:**
- ✅ Tampil icon calendar besar (abu-abu)
- ✅ Tampil text "Belum Ada Jadwal"
- ✅ Tampil text "Tap tombol + untuk menambahkan jadwal obat pertama"
- ✅ FAB "Tambah Jadwal" terlihat di kanan bawah

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 2: List Schedules
**Precondition:** Ada 3-5 jadwal di database

**Steps:**
1. Tambah 3-5 jadwal dengan obat berbeda
2. Buka MedicationListScreen

**Expected Result:**
- ✅ Semua jadwal tampil dalam list
- ✅ Setiap card menampilkan:
  - Nama obat + dosis (bold)
  - Waktu + notes (abu-abu)
  - Stok obat
  - Icon delete (merah)
- ✅ Card bisa di-tap (muncul snackbar "Fitur detail akan tersedia di Task 6")

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 3: Search Functionality
**Precondition:** Ada jadwal dengan nama "Paracetamol", "Amoxicillin", "Vitamin C"

**Steps:**
1. Buka MedicationListScreen
2. Ketik "Para" di search bar
3. Ketik "Vitamin"
4. Hapus text (kosongkan search)

**Expected Result:**
- ✅ Ketik "Para" → hanya Paracetamol yang tampil
- ✅ Ketik "Vitamin" → hanya Vitamin C yang tampil
- ✅ Kosongkan search → semua jadwal tampil kembali
- ✅ Search case-insensitive (tidak peduli huruf besar/kecil)

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 4: Search Not Found
**Precondition:** Ada beberapa jadwal

**Steps:**
1. Buka MedicationListScreen
2. Ketik "XYZ123" di search bar (obat yang tidak ada)

**Expected Result:**
- ✅ Tampil icon search_off (abu-abu)
- ✅ Tampil text "Obat Tidak Ditemukan"
- ✅ Tampil text "Coba kata kunci lain"

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 5: Delete Schedule
**Precondition:** Ada jadwal "Paracetamol 500mg"

**Steps:**
1. Buka MedicationListScreen
2. Tap icon delete (🗑️) pada card Paracetamol
3. Dialog konfirmasi muncul
4. Tap "HAPUS"

**Expected Result:**
- ✅ Dialog konfirmasi muncul dengan:
  - Icon warning (orange)
  - Title "Hapus Jadwal?"
  - Pesan konfirmasi dengan nama obat
  - Button "BATAL" dan "HAPUS" (merah)
- ✅ Setelah tap "HAPUS":
  - Snackbar hijau muncul: "✅ Jadwal "Paracetamol 500mg" berhasil dihapus"
  - Jadwal hilang dari list
  - List ter-refresh otomatis

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 6: Delete Cancel
**Precondition:** Ada jadwal

**Steps:**
1. Buka MedicationListScreen
2. Tap icon delete
3. Tap "BATAL" di dialog

**Expected Result:**
- ✅ Dialog tertutup
- ✅ Jadwal TIDAK dihapus (masih ada di list)

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 7: Low Stock Warning
**Precondition:** Ada jadwal dengan stok < 5 (misal: 3 tablet)

**Steps:**
1. Tambah jadwal dengan stok 3
2. Buka MedicationListScreen

**Expected Result:**
- ✅ Card memiliki border orange tipis
- ✅ Icon warning (⚠️) berwarna orange (bukan icon medication biru)
- ✅ Background icon orange muda
- ✅ Text stok: "⚠️ Stok tinggal 3" (bold, orange)

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 8: Pull to Refresh
**Precondition:** Ada beberapa jadwal

**Steps:**
1. Buka MedicationListScreen
2. Swipe down dari atas list (pull to refresh)
3. Tunggu loading selesai

**Expected Result:**
- ✅ Loading indicator muncul
- ✅ List ter-refresh (data reload dari database)
- ✅ Tidak ada error

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 9: FAB Add Schedule
**Precondition:** -

**Steps:**
1. Buka MedicationListScreen
2. Tap FAB "Tambah Jadwal" (kanan bawah)
3. Isi form dan save
4. Kembali ke MedicationListScreen

**Expected Result:**
- ✅ Navigate ke ScheduleChoiceScreen
- ✅ Setelah save, kembali ke MedicationListScreen
- ✅ Jadwal baru muncul di list (auto-refresh)

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 10: Navigate from HomeScreen
**Precondition:** Ada jadwal di HomeScreen

**Steps:**
1. Buka HomeScreen
2. Tap "Lihat Semua" di section "Jadwal Hari Ini"
3. Hapus 1 jadwal di MedicationListScreen
4. Tap back button
5. Lihat HomeScreen

**Expected Result:**
- ✅ Navigate ke MedicationListScreen
- ✅ Setelah delete dan back, HomeScreen ter-refresh otomatis
- ✅ Jadwal yang dihapus tidak muncul di HomeScreen

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 11: Card Tap (Detail Screen Placeholder)
**Precondition:** Ada jadwal

**Steps:**
1. Buka MedicationListScreen
2. Tap pada card (bukan icon delete)

**Expected Result:**
- ✅ Snackbar muncul: "Fitur detail akan tersedia di Task 6"

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 12: UI Consistency
**Precondition:** -

**Steps:**
1. Buka MedicationListScreen
2. Bandingkan dengan HomeScreen

**Expected Result:**
- ✅ Warna primary sama (Teal #0D9488)
- ✅ Card style sama (border radius, shadow, padding)
- ✅ Typography sama (font size, weight)
- ✅ Icon style sama
- ✅ Loading indicator sama

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

### ✅ TEST 13: Performance
**Precondition:** Ada 10+ jadwal

**Steps:**
1. Tambah 10-15 jadwal
2. Buka MedicationListScreen
3. Scroll list
4. Search obat
5. Delete jadwal

**Expected Result:**
- ✅ Load time < 500ms
- ✅ Scroll smooth (tidak lag)
- ✅ Search instant (tidak lag)
- ✅ Delete smooth

**Actual Result:**
- [ ] PASS / [ ] FAIL
- Notes: _______________________________________________

---

## 📊 SUMMARY

**Total Test Cases:** 13  
**Passed:** _____ / 13  
**Failed:** _____ / 13  
**Pass Rate:** _____ %

---

## 🐛 BUGS FOUND

### Bug 1:
- **Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low
- **Description:** _______________________________________________
- **Steps to Reproduce:** _______________________________________________
- **Expected:** _______________________________________________
- **Actual:** _______________________________________________

### Bug 2:
- **Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low
- **Description:** _______________________________________________

---

## 💡 SUGGESTIONS

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

---

## ✅ SIGN OFF

- [ ] All critical bugs fixed
- [ ] All test cases passed
- [ ] UI consistent with design
- [ ] Performance acceptable
- [ ] Ready for next task (Task 6)

**Tester Signature:** _______________________________________________  
**Date:** _______________________________________________
