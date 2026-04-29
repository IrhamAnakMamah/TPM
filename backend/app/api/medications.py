"""
PillPal-AI — Medications API Routes

POST /api/medications/parse-schedule  → Parse teks alami jadi jadwal obat (F-04B)
POST /api/medications/drug-summary    → Rangkuman medis obat via LLM (F-07)
"""

from fastapi import APIRouter, Depends
from pydantic import BaseModel, Field

from app.core.security import get_current_user
from app.models.user import User
from app.services import schedule_service, drug_summary_service

router = APIRouter(prefix="/api/medications", tags=["💊 Medications"])


# ════════════════════════════════════════════════════════════════════════════
# F-04B — Parse Schedule (Natural Language → Structured JSON)
# ════════════════════════════════════════════════════════════════════════════

class ParseScheduleRequest(BaseModel):
    """Request body untuk parsing jadwal obat dari teks alami."""
    text: str = Field(
        ...,
        min_length=5,
        max_length=500,
        description="Instruksi jadwal minum obat dalam teks bebas",
        examples=["Minum Paracetamol 500mg setiap 8 jam, stok 30 tablet"],
    )


@router.post(
    "/parse-schedule",
    summary="Parse jadwal obat dari teks alami (F-04B)",
)
def parse_schedule(
    payload: ParseScheduleRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Terima instruksi jadwal minum obat dalam teks bebas (Bahasa Indonesia),
    lalu gunakan Gemini AI untuk mengekstrak data jadwal terstruktur.

    **Contoh input:**
    - `"Minum Paracetamol 500mg setiap 8 jam, stok 30 tablet"`
    - `"Amoxicillin 250mg 3x sehari, mulai jam 7 pagi, stok 21 kapsul"`

    **Response sukses** akan berisi field `data` yang siap diisi ke form konfirmasi.

    **Terkait SKPL:** F-04B — Input LLM (Natural Language Parsing)
    **NF-02:** Target respons ≤ 5 detik
    """
    return schedule_service.parse_schedule(payload.text)


# ════════════════════════════════════════════════════════════════════════════
# F-07 — Drug Summary (RxNorm + OpenFDA + Gemini)
# ════════════════════════════════════════════════════════════════════════════

class DrugSummaryRequest(BaseModel):
    """Request body untuk rangkuman medis obat."""
    drug_name: str = Field(
        ...,
        min_length=2,
        max_length=200,
        description="Nama obat (generik atau dagang)",
        examples=["Paracetamol"],
    )
    allergy_profile: str = Field(
        default="",
        max_length=1000,
        description="Profil alergi pengguna dari tabel users (F-03). Kosongkan jika tidak ada.",
        examples=["Alergi penisilin dan sulfa"],
    )


@router.post(
    "/drug-summary",
    summary="Rangkuman medis obat via AI (F-07)",
)
async def drug_summary(
    payload: DrugSummaryRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Hasilkan rangkuman medis yang dipersonalisasi untuk sebuah obat.

    **Alur internal:**
    1. Cari RxCUI obat via RxNorm API
    2. Ambil data label dari OpenFDA API
    3. Kirim data + profil alergi pengguna ke Gemini AI
    4. Kembalikan rangkuman dalam Bahasa Indonesia

    **Response sukses** berisi field `summary` (teks rangkuman) dan `rxcui`.

    **Terkait SKPL:** F-07 — Rangkuman Medis LLM  
    **NF-02:** Target respons ≤ 5 detik
    """
    return await drug_summary_service.get_drug_summary(
        drug_name=payload.drug_name,
        allergy_profile=payload.allergy_profile,
    )
