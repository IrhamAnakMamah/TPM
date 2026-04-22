"""
PillPal-AI — Service Test Routes
GET /api/services/ping-gemini   → Test Gemini API connection
GET /api/services/ping-rxnorm   → Test RxNorm API connection
GET /api/services/search-drug   → Search a drug by name via RxNorm
"""

from fastapi import APIRouter, Depends, Query

from app.core.security import get_current_user
from app.models.user import User
from app.services import gemini_service, rxnorm_service

router = APIRouter(prefix="/api/services", tags=["🧪 Service Tests"])


# ── Gemini Ping ───────────────────────────────────
@router.get(
    "/ping-gemini",
    summary="Test koneksi ke Gemini AI",
)
def ping_gemini(current_user: User = Depends(get_current_user)):
    """
    Mengirim prompt sederhana ke Gemini untuk memverifikasi API key.
    **Endpoint terproteksi** — memerlukan JWT token.
    """
    return gemini_service.test_connection()


# ── RxNorm Ping ───────────────────────────────────
@router.get(
    "/ping-rxnorm",
    summary="Test koneksi ke RxNorm API",
)
async def ping_rxnorm(current_user: User = Depends(get_current_user)):
    """
    Mencari 'aspirin' di RxNorm API untuk memverifikasi konektivitas.
    **Endpoint terproteksi** — memerlukan JWT token.
    """
    return await rxnorm_service.test_connection()


# ── Drug Search ───────────────────────────────────
@router.get(
    "/search-drug",
    summary="Cari obat di RxNorm",
)
async def search_drug(
    name: str = Query(..., min_length=2, description="Nama obat yang dicari"),
    current_user: User = Depends(get_current_user),
):
    """
    Cari obat berdasarkan nama menggunakan RxNorm REST API.
    **Endpoint terproteksi** — memerlukan JWT token.
    """
    return await rxnorm_service.search_drug(name)


# ── Gemini AI Chat ────────────────────────────────
from pydantic import BaseModel, Field


class GeminiChatRequest(BaseModel):
    """Request body untuk chat dengan Gemini AI."""
    question: str = Field(
        ..., max_length=2000,
        examples=["Apa efek samping Paracetamol?"]
    )


@router.post(
    "/ask-gemini",
    summary="Tanya Gemini AI tentang obat/kesehatan",
)
def ask_gemini(
    payload: GeminiChatRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Kirim pertanyaan ke Gemini AI dan dapatkan jawaban.
    Context: asisten kesehatan/obat.
    **Endpoint terproteksi** — memerlukan JWT token.
    """
    return gemini_service.ask_question(payload.question)
