# Skill: FastAPI Backend Development

## Deskripsi
Gunakan skill ini saat membuat, memodifikasi, atau mereview kode backend FastAPI untuk proyek PillPal-AI. Aktif untuk kata kunci: "buat endpoint", "API", "backend", "FastAPI", "route", "service".

## Struktur Folder Backend (Wajib Diikuti)

```
backend/
├── main.py                  # Entry point FastAPI app
├── .env                     # API keys (JANGAN commit ke git)
├── requirements.txt
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── llm.py       # Endpoint Gemini (F-04, F-07)
│   │   │   ├── classify.py  # Endpoint klasifikasi citra (F-06)
│   │   │   └── drugs.py     # Endpoint RxNorm + OpenFDA (F-07)
│   ├── services/
│   │   ├── gemini_service.py
│   │   ├── rxnorm_service.py
│   │   └── ml_service.py
│   ├── models/
│   │   └── schemas.py       # Pydantic models
│   └── core/
│       └── config.py        # Konfigurasi dari .env
```

## Standar Penulisan Endpoint

Setiap endpoint FastAPI harus mengikuti template berikut:

```python
from fastapi import APIRouter, HTTPException
from app.models.schemas import RequestModel, ResponseModel

router = APIRouter(prefix="/api/v1", tags=["nama_fitur"])

@router.post("/nama-endpoint", response_model=ResponseModel)
async def nama_fungsi(request: RequestModel):
    """
    Deskripsi singkat endpoint.
    
    Terkait SKPL: F-XX — Nama Fitur
    """
    try:
        # logika bisnis
        pass
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
```

## Aturan Integrasi Gemini API (F-04, F-07)

- Gunakan model: `gemini-1.5-flash`
- Waktu timeout maksimal: **5 detik** (NF-02)
- Selalu sertakan instruksi bahasa Indonesia dalam system prompt
- Untuk parsing jadwal (F-04), output harus dalam format JSON yang divalidasi Pydantic
- Untuk rangkuman medis (F-07), sertakan `allergy_profile` pengguna sebagai konteks

**Template Prompt Parsing Jadwal (F-04):**
```
Kamu adalah asisten parsing jadwal minum obat.
Ekstrak informasi berikut dari teks pengguna dan kembalikan HANYA JSON valid:
{
  "name": "nama obat",
  "dosage": angka,
  "dosage_unit": "mg/ml/tablet",
  "frequency_hours": angka (interval dalam jam),
  "total_stock": angka
}
Teks pengguna: {user_input}
```

**Template Prompt Rangkuman Medis (F-07):**
```
Kamu adalah asisten informasi medis yang membantu pasien awam.
Data obat dari RxNorm/OpenFDA: {drug_data}
Profil alergi pengguna: {allergy_profile}

Buat rangkuman dalam Bahasa Indonesia yang mencakup:
1. Kegunaan utama obat
2. Efek samping umum (maksimal 5 poin)
3. Peringatan khusus berdasarkan alergi pengguna (jika relevan)
4. Kontraindikasi penting

Format output: teks paragraf singkat, mudah dipahami pasien awam.
```

## Aturan Integrasi API Eksternal

- **RxNorm:** Gunakan endpoint `/REST/drugs.json?name={drug_name}` untuk mendapat RxCUI
- **OpenFDA:** Gunakan endpoint `/drug/label.json?search=openfda.rxcui:{rxcui}` untuk detail obat
- Selalu handle error jika API tidak menemukan obat (404 atau hasil kosong)
- Cache response API eksternal menggunakan dictionary in-memory untuk sesi yang sama