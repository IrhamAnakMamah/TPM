# Manual Testing - UI Login & Register Baru

**Branch**: `fe/ui-login-register`  
**Tanggal Testing**: _[Isi tanggal testing]_  
**Tester**: _[Isi nama tester]_  
**Device**: Infinix X6871 (Android 15)

---

## 📋 Test Cases

### 1. TAMPILAN AWAL (Initial Load)

#### Test 1.1: Verifikasi Tampilan Pertama Kali
**Langkah:**
1. Buka aplikasi
2. Perhatikan tampilan yang muncul

**Expected Result:**
- [ ] Background berwarna light teal (#B8E6E1)
- [ ] Card putih dengan rounded corners muncul di tengah
- [ ] Logo icon medication dengan background teal terlihat
- [ ] Text "MedRemind Pro" terlihat jelas
- [ ] Tagline "Your health, expertly managed" terlihat di bawah nama app
- [ ] Toggle button "Login" dan "Register" terlihat
- [ ] Toggle "Login" dalam keadaan aktif (background teal)
- [ ] Form login terlihat (Username dan Password field)

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

**Screenshot:** _[Lampirkan screenshot jika ada]_

---

### 2. TOGGLE BUTTON

#### Test 2.1: Switch dari Login ke Register
**Langkah:**
1. Pastikan berada di mode Login
2. Tap toggle button "Register"

**Expected Result:**
- [ ] Toggle "Register" menjadi aktif (background teal)
- [ ] Toggle "Login" menjadi inactive (background transparent)
- [ ] Form berubah menampilkan field Register:
  - Full Name
  - Username
  - Email Address
  - Password
- [ ] Button berubah menjadi "Create Account"
- [ ] Quick Access section (fingerprint & face) TIDAK terlihat di mode Register

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 2.2: Switch dari Register ke Login
**Langkah:**
1. Pastikan berada di mode Register
2. Tap toggle button "Login"

**Expected Result:**
- [ ] Toggle "Login" menjadi aktif (background teal)
- [ ] Toggle "Register" menjadi inactive (background transparent)
- [ ] Form berubah menampilkan field Login:
  - Username
  - Password
- [ ] Link "FORGOT?" terlihat di samping label PASSWORD
- [ ] Button berubah menjadi "Secure Login"
- [ ] Quick Access section (fingerprint & face) terlihat

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 3. FORM LOGIN - UI & INTERACTION

#### Test 3.1: Username Field
**Langkah:**
1. Berada di mode Login
2. Tap pada Username field
3. Ketik beberapa karakter

**Expected Result:**
- [ ] Label "USERNAME" terlihat di atas field
- [ ] Icon @ (alternate_email) terlihat di kiri field
- [ ] Placeholder "john.doe" terlihat sebelum input
- [ ] Keyboard muncul saat tap
- [ ] Text yang diketik terlihat di field
- [ ] Field memiliki background abu-abu muda
- [ ] Field memiliki rounded corners

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 3.2: Password Field
**Langkah:**
1. Berada di mode Login
2. Tap pada Password field
3. Ketik beberapa karakter
4. Tap icon eye (visibility toggle)

**Expected Result:**
- [ ] Label "PASSWORD" terlihat di atas field
- [ ] Link "FORGOT?" terlihat di kanan label PASSWORD (warna teal)
- [ ] Icon lock terlihat di kiri field
- [ ] Icon eye (visibility_off) terlihat di kanan field
- [ ] Placeholder "••••••••" terlihat sebelum input
- [ ] Password ter-obscure (tidak terlihat) saat diketik
- [ ] Setelah tap icon eye, password menjadi terlihat
- [ ] Icon berubah dari visibility_off ke visibility

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 3.3: Forgot Password Link
**Langkah:**
1. Berada di mode Login
2. Tap link "FORGOT?" di samping label PASSWORD

**Expected Result:**
- [ ] Navigasi ke halaman Forgot Password
- [ ] Halaman Forgot Password terbuka dengan benar

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 3.4: Secure Login Button
**Langkah:**
1. Berada di mode Login
2. Perhatikan button "Secure Login"

**Expected Result:**
- [ ] Button berwarna teal
- [ ] Text "Secure Login" berwarna putih dan bold
- [ ] Icon arrow_forward terlihat di sebelah kanan text
- [ ] Button memiliki rounded corners
- [ ] Button memiliki shadow/elevation

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 3.5: Quick Access Section
**Langkah:**
1. Berada di mode Login
2. Scroll ke bawah jika perlu
3. Perhatikan section Quick Access

**Expected Result:**
- [ ] Text "QUICK ACCESS" terlihat (uppercase, abu-abu, kecil)
- [ ] 2 circular button terlihat:
  - Button dengan icon fingerprint
  - Button dengan icon face
- [ ] Kedua button memiliki border abu-abu
- [ ] Kedua button memiliki background putih
- [ ] Icon berwarna abu-abu

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 4. FORM REGISTER - UI & INTERACTION

#### Test 4.1: Full Name Field
**Langkah:**
1. Switch ke mode Register
2. Tap pada Full Name field
3. Ketik nama lengkap

**Expected Result:**
- [ ] Label "FULL NAME" terlihat di atas field
- [ ] Icon person_outline terlihat di kiri field
- [ ] Placeholder "John Doe" terlihat sebelum input
- [ ] Text yang diketik terlihat di field

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 4.2: Username Field (Register)
**Langkah:**
1. Berada di mode Register
2. Tap pada Username field
3. Ketik username

**Expected Result:**
- [ ] Label "USERNAME" terlihat di atas field
- [ ] Icon account_circle_outlined terlihat di kiri field
- [ ] Placeholder "john.doe" terlihat sebelum input
- [ ] Text yang diketik terlihat di field

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 4.3: Email Address Field
**Langkah:**
1. Berada di mode Register
2. Tap pada Email Address field
3. Ketik email

**Expected Result:**
- [ ] Label "EMAIL ADDRESS" terlihat di atas field
- [ ] Icon @ (alternate_email) terlihat di kiri field
- [ ] Placeholder "john.doe@medical.com" terlihat sebelum input
- [ ] Keyboard email muncul (dengan @ dan .com)
- [ ] Text yang diketik terlihat di field

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 4.4: Password Field (Register)
**Langkah:**
1. Berada di mode Register
2. Tap pada Password field
3. Ketik password
4. Tap icon eye

**Expected Result:**
- [ ] Label "PASSWORD" terlihat di atas field
- [ ] TIDAK ada link "FORGOT?" (hanya di Login)
- [ ] Icon lock terlihat di kiri field
- [ ] Icon eye terlihat di kanan field
- [ ] Password ter-obscure saat diketik
- [ ] Password terlihat setelah tap icon eye

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 4.5: Create Account Button
**Langkah:**
1. Berada di mode Register
2. Perhatikan button "Create Account"

**Expected Result:**
- [ ] Button berwarna teal
- [ ] Text "Create Account" berwarna putih dan bold
- [ ] Icon arrow_forward terlihat di sebelah kanan text
- [ ] Button memiliki rounded corners
- [ ] Button memiliki shadow/elevation

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 5. FUNCTIONAL TESTING - LOGIN

#### Test 5.1: Login dengan Field Kosong
**Langkah:**
1. Berada di mode Login
2. Biarkan Username dan Password kosong
3. Tap button "Secure Login"

**Expected Result:**
- [ ] SnackBar muncul dengan pesan "Username dan password harus diisi"
- [ ] SnackBar berwarna merah
- [ ] Tidak terjadi navigasi ke dashboard

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 5.2: Login dengan Kredensial Valid
**Langkah:**
1. Berada di mode Login
2. Isi Username dengan akun yang valid (misal: `testuser`)
3. Isi Password dengan password yang benar
4. Tap button "Secure Login"

**Expected Result:**
- [ ] Button menampilkan loading indicator (CircularProgressIndicator)
- [ ] Setelah berhasil, SnackBar hijau muncul: "Login berhasil! Selamat datang 👋"
- [ ] Navigasi ke dashboard (MainScreen)
- [ ] Dashboard menampilkan data user yang login

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 5.3: Login dengan Kredensial Invalid
**Langkah:**
1. Berada di mode Login
2. Isi Username dengan akun yang tidak ada
3. Isi Password dengan password random
4. Tap button "Secure Login"

**Expected Result:**
- [ ] Button menampilkan loading indicator
- [ ] Setelah gagal, SnackBar merah muncul dengan pesan error dari API
- [ ] Tetap berada di halaman login
- [ ] Field tidak ter-clear (masih berisi input)

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 6. FUNCTIONAL TESTING - REGISTER

#### Test 6.1: Register dengan Field Kosong
**Langkah:**
1. Switch ke mode Register
2. Biarkan semua field kosong
3. Tap button "Create Account"

**Expected Result:**
- [ ] SnackBar merah muncul: "Semua field harus diisi"
- [ ] Tidak terjadi registrasi
- [ ] Tetap di mode Register

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 6.2: Register dengan Username < 3 Karakter
**Langkah:**
1. Berada di mode Register
2. Isi Full Name: "Test User"
3. Isi Username: "ab" (2 karakter)
4. Isi Email: "test@email.com"
5. Isi Password: "password123"
6. Tap button "Create Account"

**Expected Result:**
- [ ] SnackBar merah muncul: "Username minimal 3 karakter"
- [ ] Tidak terjadi registrasi

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 6.3: Register dengan Password < 6 Karakter
**Langkah:**
1. Berada di mode Register
2. Isi Full Name: "Test User"
3. Isi Username: "testuser"
4. Isi Email: "test@email.com"
5. Isi Password: "12345" (5 karakter)
6. Tap button "Create Account"

**Expected Result:**
- [ ] SnackBar merah muncul: "Password minimal 6 karakter"
- [ ] Tidak terjadi registrasi

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 6.4: Register dengan Email Invalid
**Langkah:**
1. Berada di mode Register
2. Isi Full Name: "Test User"
3. Isi Username: "testuser"
4. Isi Email: "testemail.com" (tanpa @)
5. Isi Password: "password123"
6. Tap button "Create Account"

**Expected Result:**
- [ ] SnackBar merah muncul: "Email tidak valid"
- [ ] Tidak terjadi registrasi

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 6.5: Register dengan Data Valid (User Baru)
**Langkah:**
1. Berada di mode Register
2. Isi Full Name: "New Test User"
3. Isi Username: "newtestuser" (username yang belum ada)
4. Isi Email: "newtest@email.com"
5. Isi Password: "password123"
6. Tap button "Create Account"

**Expected Result:**
- [ ] Button menampilkan loading indicator
- [ ] Setelah berhasil, SnackBar hijau muncul dengan pesan sukses
- [ ] Otomatis switch ke mode Login
- [ ] Field register ter-clear (kosong)
- [ ] Bisa login dengan akun yang baru dibuat

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 6.6: Register dengan Username yang Sudah Ada
**Langkah:**
1. Berada di mode Register
2. Isi dengan username yang sudah terdaftar
3. Tap button "Create Account"

**Expected Result:**
- [ ] SnackBar merah muncul dengan pesan error dari API (misal: "Username sudah digunakan")
- [ ] Tetap di mode Register
- [ ] Field tidak ter-clear

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 7. RESPONSIVENESS & UI BEHAVIOR

#### Test 7.1: Scroll Behavior
**Langkah:**
1. Berada di mode Register (form lebih panjang)
2. Scroll ke atas dan ke bawah

**Expected Result:**
- [ ] Form bisa di-scroll dengan smooth
- [ ] Semua field tetap accessible
- [ ] Tidak ada overflow atau clipping

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 7.2: Keyboard Behavior
**Langkah:**
1. Tap pada field paling bawah (Password di Register)
2. Perhatikan saat keyboard muncul

**Expected Result:**
- [ ] Keyboard tidak menutupi field yang sedang di-input
- [ ] Form otomatis scroll agar field terlihat
- [ ] Setelah keyboard ditutup, layout kembali normal

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 7.3: Landscape Mode (Optional)
**Langkah:**
1. Rotate device ke landscape
2. Perhatikan tampilan

**Expected Result:**
- [ ] Layout tetap terlihat baik
- [ ] Tidak ada overflow
- [ ] Semua element tetap accessible

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 7.4: Loading State
**Langkah:**
1. Lakukan login atau register
2. Perhatikan saat proses loading

**Expected Result:**
- [ ] Button menampilkan CircularProgressIndicator putih
- [ ] Button menjadi disabled (tidak bisa di-tap lagi)
- [ ] Setelah selesai, button kembali normal

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

### 8. EDGE CASES

#### Test 8.1: Rapid Toggle Switching
**Langkah:**
1. Tap toggle Login-Register berkali-kali dengan cepat

**Expected Result:**
- [ ] Toggle tetap responsive
- [ ] Tidak ada crash atau freeze
- [ ] Form selalu menampilkan mode yang benar

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 8.2: Input dengan Karakter Spesial
**Langkah:**
1. Coba input karakter spesial di berbagai field
2. Misal: `!@#$%^&*()` di username, email, password

**Expected Result:**
- [ ] Field menerima input
- [ ] Tidak ada crash
- [ ] Validasi tetap berjalan dengan benar

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 8.3: Input dengan Spasi
**Langkah:**
1. Coba input dengan spasi di awal/akhir
2. Misal: " testuser " (dengan spasi)

**Expected Result:**
- [ ] Input di-trim (spasi dihapus) karena ada `.trim()` di code
- [ ] Validasi dan submit berjalan normal

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

#### Test 8.4: Back Button Behavior
**Langkah:**
1. Dari halaman auth, tekan back button device

**Expected Result:**
- [ ] App keluar atau menampilkan dialog konfirmasi
- [ ] Tidak crash

**Actual Result:**
```
[Isi hasil testing di sini]
```

**Status:** ⬜ Pass / ⬜ Fail

---

## 📊 SUMMARY

### Test Statistics
- **Total Test Cases**: 30
- **Passed**: _[Isi jumlah]_
- **Failed**: _[Isi jumlah]_
- **Skipped**: _[Isi jumlah]_
- **Pass Rate**: _[Isi persentase]_%

### Critical Issues Found
```
[List critical issues yang ditemukan]
1. 
2. 
3. 
```

### Minor Issues Found
```
[List minor issues yang ditemukan]
1. 
2. 
3. 
```

### Recommendations
```
[Saran perbaikan atau improvement]
1. 
2. 
3. 
```

### Overall Assessment
```
[Penilaian keseluruhan UI]
- UI Design: ⬜ Excellent / ⬜ Good / ⬜ Fair / ⬜ Poor
- Functionality: ⬜ Excellent / ⬜ Good / ⬜ Fair / ⬜ Poor
- User Experience: ⬜ Excellent / ⬜ Good / ⬜ Fair / ⬜ Poor
- Performance: ⬜ Excellent / ⬜ Good / ⬜ Fair / ⬜ Poor
```

### Ready for Merge?
⬜ Yes - Ready to merge to main  
⬜ No - Needs fixes before merge  
⬜ Conditional - Can merge with minor fixes later

---

## 📸 Screenshots

### Login Mode
_[Lampirkan screenshot login mode]_

### Register Mode
_[Lampirkan screenshot register mode]_

### Loading State
_[Lampirkan screenshot saat loading]_

### Error State
_[Lampirkan screenshot saat error]_

### Success State
_[Lampirkan screenshot saat success]_

---

**Catatan Tambahan:**
```
[Tambahkan catatan lain yang relevan]
```
