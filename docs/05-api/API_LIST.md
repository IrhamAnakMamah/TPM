# PillPal - Daftar API yang Digunakan

**Project:** PillPal - Aplikasi Manajemen Pengobatan  
**Last Updated:** 2026-05-05  
**Version:** 1.0.0

---

## 📋 Table of Contents

1. [Backend API (FastAPI)](#backend-api-fastapi)
2. [External APIs](#external-apis)
3. [Device APIs & Sensors](#device-apis--sensors)
4. [Summary](#summary)

---

## 1. Backend API (FastAPI)

Base URL: `http://192.168.18.14:8000`

### 🔐 Authentication APIs

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/auth/register` | POST | ❌ | Registrasi user baru |
| `/api/auth/login/json` | POST | ❌ | Login dengan JSON body (untuk mobile) |
| `/api/auth/login` | POST | ❌ | Login dengan form-data (untuk Swagger) |
| `/api/auth/me` | GET | ✅ | Get profil user yang sedang login |
| `/api/auth/check-token` | GET | ✅ | Cek validitas JWT token |
| `/api/auth/refresh` | POST | ✅ | Refresh JWT token |

**Authentication Type:** JWT (JSON Web Token)  
**Token Expiry:** 24 hours (1440 minutes)  
**Encryption:** PBKDF2-SHA256 untuk password hashing

---

### 🤖 AI & Service APIs

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/services/ping-gemini` | GET | ✅ | Test koneksi ke Gemini AI |
| `/api/services/ask-gemini` | POST | ✅ | Chat dengan Gemini AI (chatbot) |
| `/api/services/ping-rxnorm` | GET | ✅ | Test koneksi ke RxNorm API |
| `/api/services/search-drug` | GET | ✅ | Cari obat di RxNorm database |

**AI Model:** Gemini 3.1 Flash Lite  
**Provider:** Google Generative AI

---

### 💊 Medication APIs

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/medications/parse-schedule` | POST | ✅ | Parse teks alami jadwal obat via Gemini AI |
| `/api/medications/drug-summary` | POST | ✅ | Rangkuman medis obat (RxNorm + OpenFDA + Gemini) |

**Features:**
- Natural Language Processing untuk jadwal obat
- Integrasi RxNorm + OpenFDA + Gemini AI

---

## 2. External APIs

### 🧠 Google Gemini AI API

**Provider:** Google AI Studio  
**Base URL:** `https://generativelanguage.googleapis.com`  
**Model:** `gemini-3.1-flash-lite`

**Usage:**
- AI Chatbot untuk konsultasi kesehatan
- Natural Language Processing untuk parsing jadwal obat
- Drug summary generation

**Rate Limits (Free Tier):**
- RPM: 2 / 15 requests per minute
- TPM: 336 / 250K tokens per minute
- RPD: 12 / 20 requests per day

**Authentication:** API Key  
**Documentation:** https://ai.google.dev/docs

---

### 💊 RxNorm API

**Provider:** U.S. National Library of Medicine (NLM)  
**Base URL:** `https://rxnav.nlm.nih.gov/REST`

**Endpoints Used:**
- `/drugs.json?name={drugName}` - Search drug by name
- Get RxCUI (RxNorm Concept Unique Identifier)
- Get drug information

**Usage:**
- Drug validation
- Get standardized drug names
- Get RxCUI for drug identification

**Rate Limits:** No strict limits (public API)  
**Authentication:** None (public API)  
**Documentation:** https://rxnav.nlm.nih.gov/

---

### 🏥 OpenFDA API

**Provider:** U.S. Food and Drug Administration (FDA)  
**Base URL:** `https://api.fda.gov/drug`

**Endpoints Used:**
- `/label.json?search=...` - Get drug label information

**Data Retrieved:**
- Generic name & brand name
- Manufacturer information
- Indications and usage
- Dosage and administration
- Warnings and precautions
- Adverse reactions
- Active ingredients
- Route of administration

**Rate Limits:** 240 requests per minute (no API key)  
**Authentication:** None (public API)  
**Documentation:** https://open.fda.gov/apis/

---

### 🗺️ OpenStreetMap (OSM) API

**Provider:** OpenStreetMap Foundation  
**Base URL:** `https://tile.openstreetmap.org`

**Usage:**
- Map tiles untuk pharmacy finder
- Display peta interaktif
- Marker untuk lokasi apotek

**Integration:** Via `flutter_map` package  
**Rate Limits:** Fair use policy  
**Authentication:** None  
**Documentation:** https://wiki.openstreetmap.org/

---

### 📍 Overpass API

**Provider:** OpenStreetMap  
**Base URL:** `https://overpass-api.de/api/interpreter`

**Usage:**
- Query apotek terdekat berdasarkan koordinat
- Filter berdasarkan radius
- Get pharmacy details (name, address, phone)

**Query Example:**
```
[out:json];
node["amenity"="pharmacy"](around:5000,lat,lon);
out body;
```

**Rate Limits:** Fair use policy  
**Authentication:** None  
**Documentation:** https://wiki.openstreetmap.org/wiki/Overpass_API

---

## 3. Device APIs & Sensors

### 📱 Flutter/Dart APIs

| API | Package | Usage |
|-----|---------|-------|
| **SQLite** | `sqflite: ^2.3.0` | Local database untuk menyimpan data obat & jadwal |
| **HTTP Client** | `http: ^1.2.1` | HTTP requests ke backend & external APIs |
| **Local Notifications** | `flutter_local_notifications: ^17.0.0` | Notifikasi pengingat minum obat |
| **Geolocator** | `geolocator: ^10.1.0` | GPS location untuk pharmacy finder |
| **URL Launcher** | `url_launcher: ^6.2.0` | Buka maps, phone, website apotek |
| **Sensors Plus** | `sensors_plus: ^4.0.0` | Accelerometer untuk shake detection |
| **Local Auth** | `local_auth: ^2.1.7` | Biometric authentication (fingerprint/face) |
| **Shared Preferences** | `shared_preferences: ^2.2.0` | Persistent storage untuk settings |
| **Secure Storage** | `flutter_secure_storage: ^9.0.0` | Secure storage untuk credentials |
| **Image Picker** | `image_picker: ^1.0.4` | Ambil foto dari kamera/galeri |
| **Google ML Kit** | `google_mlkit_text_recognition: ^0.11.0` | OCR untuk scan label obat |
| **Flutter Markdown** | `flutter_markdown: ^0.7.4+1` | Render Markdown di chatbot |
| **FL Chart** | `fl_chart: ^0.66.0` | Charts untuk analytics |
| **Flutter Map** | `flutter_map: ^6.1.0` | Interactive maps |

---

### 📡 Device Sensors

| Sensor | Usage | Permission |
|--------|-------|------------|
| **Camera** | Foto label obat untuk OCR | `CAMERA` |
| **Storage** | Simpan/baca foto obat | `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` |
| **Location (GPS)** | Cari apotek terdekat | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` |
| **Accelerometer** | Shake detection untuk fitur khusus | No permission needed |
| **Biometric** | Fingerprint/Face ID untuk login | `USE_BIOMETRIC`, `USE_FINGERPRINT` |
| **Internet** | Akses backend & external APIs | `INTERNET` |
| **Notifications** | Pengingat minum obat | `POST_NOTIFICATIONS` (Android 13+) |

---

## 4. Summary

### 📊 API Statistics

| Category | Count | Details |
|----------|-------|---------|
| **Backend Endpoints** | 10 | FastAPI (Python) |
| **External APIs** | 4 | Gemini AI, RxNorm, OpenFDA, OSM |
| **Flutter Packages** | 14 | Various functionalities |
| **Device Sensors** | 7 | Camera, GPS, Accelerometer, etc. |
| **Total APIs/Services** | 35+ | Including all integrations |

---

### 🔑 API Keys Required

| API | Key Required | Location |
|-----|--------------|----------|
| **Gemini AI** | ✅ Yes | `backend/.env` → `GEMINI_API_KEY` |
| **RxNorm** | ❌ No | Public API |
| **OpenFDA** | ❌ No | Public API (optional for higher limits) |
| **OpenStreetMap** | ❌ No | Public API |

---

### 🌐 Network Requirements

**Backend:**
- FastAPI server running on `http://192.168.18.14:8000`
- Python 3.12+
- Dependencies: `fastapi`, `uvicorn`, `google-generativeai`, `httpx`

**Frontend:**
- Internet connection untuk external APIs
- WiFi/Mobile data untuk backend communication
- GPS enabled untuk pharmacy finder

---

### 🔒 Security & Privacy

**Authentication:**
- JWT tokens dengan PBKDF2-SHA256 encryption
- Token expiry: 24 hours
- Auto-refresh mechanism

**Data Storage:**
- Local: SQLite database (encrypted)
- Secure: `flutter_secure_storage` untuk credentials
- Session: `shared_preferences` untuk settings

**API Security:**
- HTTPS untuk external APIs
- JWT Bearer token untuk backend APIs
- API key untuk Gemini AI (stored in `.env`)

---

### 📚 Documentation Links

| Resource | URL |
|----------|-----|
| **Gemini AI** | https://ai.google.dev/docs |
| **RxNorm** | https://rxnav.nlm.nih.gov/ |
| **OpenFDA** | https://open.fda.gov/apis/ |
| **OpenStreetMap** | https://wiki.openstreetmap.org/ |
| **Flutter Packages** | https://pub.dev/ |
| **FastAPI** | https://fastapi.tiangolo.com/ |

---

### 🎯 API Usage by Feature

| Feature | APIs Used |
|---------|-----------|
| **Authentication** | Backend Auth API, JWT, PBKDF2 |
| **AI Chatbot** | Gemini AI API, Backend API |
| **Drug Information** | Google ML Kit OCR, RxNorm API, OpenFDA API |
| **Pharmacy Finder** | Geolocator, OpenStreetMap, Overpass API |
| **Notifications** | Flutter Local Notifications |
| **Analytics** | FL Chart, SQLite |
| **Biometric Login** | Local Auth (Fingerprint/Face ID) |
| **Shake Detection** | Sensors Plus (Accelerometer) |

---

## 📝 Notes

1. **API Keys:** Pastikan `GEMINI_API_KEY` sudah dikonfigurasi di `backend/.env`
2. **Rate Limits:** Perhatikan rate limits untuk Gemini AI (free tier)
3. **Network:** Backend harus running untuk fitur yang memerlukan backend API
4. **Permissions:** Pastikan semua permissions sudah granted di device
5. **Testing:** Test semua API endpoints sebelum production

---

**Created:** 2026-05-05  
**Maintained by:** PillPal Development Team  
**Version:** 1.0.0
