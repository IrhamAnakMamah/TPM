# PillPal - Ringkasan API

**Quick Reference untuk semua API yang digunakan**

---

## 🎯 Backend API (FastAPI)

**Base URL:** `http://192.168.18.14:8000`

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/register` | POST | Registrasi user baru |
| `/api/auth/login/json` | POST | Login (mobile app) |
| `/api/auth/me` | GET | Get user profile |
| `/api/auth/check-token` | GET | Cek token validity |
| `/api/auth/refresh` | POST | Refresh JWT token |

### AI & Services
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/services/ping-gemini` | GET | Test Gemini AI |
| `/api/services/ask-gemini` | POST | Chat dengan AI |
| `/api/services/ping-rxnorm` | GET | Test RxNorm API |
| `/api/services/search-drug` | GET | Cari obat |

### Medications
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/medications/parse-schedule` | POST | Parse jadwal obat (NLP) |
| `/api/medications/drug-summary` | POST | Rangkuman obat lengkap |

---

## 🌐 External APIs

### 1. Google Gemini AI
- **URL:** `https://generativelanguage.googleapis.com`
- **Model:** `gemini-3.1-flash-lite`
- **Usage:** AI Chatbot, NLP parsing
- **Auth:** API Key (required)
- **Rate Limit:** 2 RPM, 336 TPM (free tier)

### 2. RxNorm API
- **URL:** `https://rxnav.nlm.nih.gov/REST`
- **Usage:** Drug validation, RxCUI lookup
- **Auth:** None (public)
- **Rate Limit:** No strict limit

### 3. OpenFDA API
- **URL:** `https://api.fda.gov/drug`
- **Usage:** Drug information (label, warnings, dosage)
- **Auth:** None (public)
- **Rate Limit:** 240 RPM

### 4. OpenStreetMap
- **URL:** `https://tile.openstreetmap.org`
- **Usage:** Map tiles untuk pharmacy finder
- **Auth:** None
- **Rate Limit:** Fair use

### 5. Overpass API
- **URL:** `https://overpass-api.de/api/interpreter`
- **Usage:** Query apotek terdekat
- **Auth:** None
- **Rate Limit:** Fair use

---

## 📱 Flutter Packages & Device APIs

### Core Packages
| Package | Version | Usage |
|---------|---------|-------|
| `sqflite` | ^2.3.0 | Local database |
| `http` | ^1.2.1 | HTTP client |
| `flutter_local_notifications` | ^17.0.0 | Notifikasi |
| `geolocator` | ^10.1.0 | GPS location |
| `sensors_plus` | ^4.0.0 | Accelerometer |
| `local_auth` | ^2.1.7 | Biometric auth |
| `image_picker` | ^1.0.4 | Camera/Gallery |
| `google_mlkit_text_recognition` | ^0.11.0 | OCR |
| `flutter_markdown` | ^0.7.4+1 | Markdown rendering |
| `flutter_map` | ^6.1.0 | Interactive maps |
| `fl_chart` | ^0.66.0 | Charts |

### Device Sensors
| Sensor | Permission | Usage |
|--------|------------|-------|
| Camera | `CAMERA` | OCR scan obat |
| Storage | `READ/WRITE_EXTERNAL_STORAGE` | Foto obat |
| GPS | `ACCESS_FINE_LOCATION` | Pharmacy finder |
| Accelerometer | None | Shake detection |
| Biometric | `USE_BIOMETRIC` | Fingerprint/Face ID |

---

## 🔑 API Keys

| API | Required | Location |
|-----|----------|----------|
| Gemini AI | ✅ Yes | `backend/.env` |
| RxNorm | ❌ No | - |
| OpenFDA | ❌ No | - |
| OpenStreetMap | ❌ No | - |

---

## 📊 Quick Stats

- **Total Backend Endpoints:** 10
- **External APIs:** 5
- **Flutter Packages:** 11+
- **Device Sensors:** 5
- **API Keys Required:** 1 (Gemini AI)

---

## 🔗 Documentation

- **Full API List:** [API_LIST.md](./API_LIST.md)
- **Backend Docs:** http://localhost:8000/docs (Swagger UI)
- **Gemini AI:** https://ai.google.dev/docs
- **RxNorm:** https://rxnav.nlm.nih.gov/
- **OpenFDA:** https://open.fda.gov/apis/

---

**Last Updated:** 2026-05-05
