# ✅ Quick UI Test Checklist - Login/Register

**Device**: Infinix X6871 (Android 15)  
**Branch**: `fe/ui-login-register`

---

## 🎯 Quick Visual Check (2 menit)

Buka aplikasi dan cek:

- [ ] Background light teal terlihat
- [ ] Logo icon medication dengan background teal terlihat
- [ ] Text "MedRemind Pro" dan tagline terlihat jelas
- [ ] Toggle button Login/Register terlihat dan berfungsi
- [ ] Form Login menampilkan 2 field (Username, Password)
- [ ] Form Register menampilkan 4 field (Full Name, Username, Email, Password)
- [ ] Button "Secure Login" / "Create Account" terlihat dengan arrow icon
- [ ] Quick Access (fingerprint & face) hanya muncul di Login mode
- [ ] Link "FORGOT?" hanya muncul di Login mode

---

## 🔄 Toggle Test (1 menit)

- [ ] Tap "Register" → Form berubah ke 4 field
- [ ] Tap "Login" → Form berubah ke 2 field
- [ ] Toggle animation smooth tanpa lag

---

## 📝 Input Test (3 menit)

### Login Mode:
- [ ] Ketik di Username field → text muncul
- [ ] Ketik di Password field → text ter-obscure (••••)
- [ ] Tap icon eye → password terlihat
- [ ] Tap "FORGOT?" → navigasi ke forgot password screen

### Register Mode:
- [ ] Semua 4 field bisa diisi
- [ ] Password ter-obscure dan bisa di-toggle
- [ ] Email field menampilkan keyboard email

---

## ✅ Validation Test (5 menit)

### Login:
1. **Field Kosong**
   - [ ] Kosongkan semua field → Tap "Secure Login"
   - [ ] SnackBar merah: "Username dan password harus diisi" ✓

2. **Login Valid** (gunakan akun yang sudah ada)
   - [ ] Isi username & password benar → Tap "Secure Login"
   - [ ] Loading indicator muncul
   - [ ] SnackBar hijau: "Login berhasil! Selamat datang 👋"
   - [ ] Redirect ke dashboard ✓

3. **Login Invalid**
   - [ ] Isi username/password salah → Tap "Secure Login"
   - [ ] SnackBar merah dengan pesan error ✓

### Register:
1. **Field Kosong**
   - [ ] Kosongkan semua → Tap "Create Account"
   - [ ] SnackBar: "Semua field harus diisi" ✓

2. **Username < 3 karakter**
   - [ ] Isi username "ab" → Submit
   - [ ] SnackBar: "Username minimal 3 karakter" ✓

3. **Password < 6 karakter**
   - [ ] Isi password "12345" → Submit
   - [ ] SnackBar: "Password minimal 6 karakter" ✓

4. **Email Invalid**
   - [ ] Isi email tanpa @ → Submit
   - [ ] SnackBar: "Email tidak valid" ✓

5. **Register Valid** (gunakan username baru)
   - [ ] Isi semua field dengan benar → Tap "Create Account"
   - [ ] Loading indicator muncul
   - [ ] SnackBar hijau dengan pesan sukses
   - [ ] Auto-switch ke Login mode
   - [ ] Field register ter-clear ✓

6. **Test Login dengan Akun Baru**
   - [ ] Login dengan akun yang baru dibuat
   - [ ] Berhasil masuk ke dashboard ✓

---

## 📱 Responsiveness Test (2 menit)

- [ ] Switch ke Register mode → Scroll ke bawah → Semua field terlihat
- [ ] Tap field paling bawah → Keyboard tidak menutupi field
- [ ] Rotate ke landscape → Layout tetap OK (optional)

---

## 🚀 Performance Test (1 menit)

- [ ] Tap toggle Login-Register 10x cepat → Tidak lag/crash
- [ ] Submit form → Loading smooth tanpa freeze
- [ ] SnackBar muncul dan hilang dengan timing yang baik

---

## 📊 Quick Result

**Total Checks**: 35  
**Passed**: ___  
**Failed**: ___  

**Critical Issues**:
```
[Tulis issue yang ditemukan]
```

**Status**: 
- [ ] ✅ Ready to merge
- [ ] ⚠️ Minor fixes needed
- [ ] ❌ Major issues found

---

## 📸 Screenshot Checklist

Ambil screenshot untuk dokumentasi:
1. [ ] Login mode (initial view)
2. [ ] Register mode
3. [ ] Password visibility toggle (on/off)
4. [ ] Loading state
5. [ ] Success SnackBar
6. [ ] Error SnackBar
7. [ ] Dashboard setelah login

---

## 🎬 Testing Flow Lengkap (End-to-End)

**Scenario**: User baru mendaftar dan login

1. [ ] Buka app → Lihat Login screen
2. [ ] Tap "Register"
3. [ ] Isi form register dengan data baru:
   - Full Name: "Test User UI"
   - Username: "testuiuser"
   - Email: "testui@email.com"
   - Password: "testui123"
4. [ ] Tap "Create Account"
5. [ ] Verifikasi auto-switch ke Login
6. [ ] Login dengan akun baru:
   - Username: "testuiuser"
   - Password: "testui123"
7. [ ] Tap "Secure Login"
8. [ ] Verifikasi masuk ke dashboard
9. [ ] Verifikasi data user terlihat di dashboard

**Result**: ⬜ Pass / ⬜ Fail

---

## 💡 Tips Testing

1. **Gunakan akun test** yang sudah ada untuk login test
2. **Buat username unik** untuk register test (tambahkan timestamp)
3. **Test di kondisi jaringan baik** untuk hasil akurat
4. **Perhatikan console log** jika ada error
5. **Ambil screenshot** untuk setiap issue yang ditemukan

---

## 🔧 Jika Menemukan Bug

1. Catat langkah reproduksi
2. Ambil screenshot
3. Cek console log untuk error message
4. Tulis di section "Critical Issues" atau "Minor Issues"
5. Tentukan severity: Critical / High / Medium / Low

---

**Happy Testing! 🚀**
