"""
PillPal-AI — Drug Summary Service (F-07)

Alur:
1. Cari RxCUI obat via RxNorm API (nama → rxcui)
2. Ambil detail label obat dari OpenFDA API (rxcui → indikasi, efek samping, dll.)
3. Kirim data + profil alergi pengguna ke Gemini untuk dirangkum dalam Bahasa Indonesia

Terkait SKPL: F-07 — Rangkuman Medis LLM
"""

import httpx
import time
import google.generativeai as genai

from app.core.config import settings

RXNORM_BASE_URL = "https://rxnav.nlm.nih.gov/REST"
OPENFDA_BASE_URL = "https://api.fda.gov/drug"

# Model paling ringan — paling hemat quota free tier
_GEMINI_MODEL = "gemini-3.1-flash-lite-preview"

# Cache in-memory untuk sesi yang sama (sesuai skill_api.md)
_rxcui_cache: dict[str, str | None] = {}
_openfda_cache: dict[str, dict] = {}

# ── Prompt Template (sesuai skill_api.md) ────────────────────────────────────
_SUMMARY_PROMPT_TEMPLATE = """
Kamu adalah asisten informasi medis yang membantu pasien awam.
Data obat dari RxNorm/OpenFDA: {drug_data}
Profil alergi pengguna: {allergy_profile}

Buat rangkuman dalam Bahasa Indonesia yang mencakup:
1. Kegunaan utama obat
2. Efek samping umum (maksimal 5 poin)
3. Peringatan khusus berdasarkan alergi pengguna (jika relevan)
4. Kontraindikasi penting

Format output: teks paragraf singkat, mudah dipahami pasien awam.
Jika data obat tidak tersedia atau tidak lengkap, tetap berikan informasi umum yang kamu ketahui tentang obat tersebut.
""".strip()


async def _get_rxcui(drug_name: str) -> str | None:
    """
    Dapatkan RxCUI dari nama obat via RxNorm API.
    Menggunakan in-memory cache untuk menghindari request berulang.
    """
    cache_key = drug_name.lower().strip()
    if cache_key in _rxcui_cache:
        return _rxcui_cache[cache_key]

    url = f"{RXNORM_BASE_URL}/drugs.json"
    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url, params={"name": drug_name})
            resp.raise_for_status()
            data = resp.json()

        concept_groups = data.get("drugGroup", {}).get("conceptGroup", [])
        for group in concept_groups:
            for prop in group.get("conceptProperties", []):
                rxcui = prop.get("rxcui")
                if rxcui:
                    _rxcui_cache[cache_key] = rxcui
                    return rxcui

        _rxcui_cache[cache_key] = None
        return None

    except Exception:
        return None


async def _get_openfda_data(rxcui: str) -> dict:
    """
    Ambil data label obat dari OpenFDA API menggunakan RxCUI.
    Menggunakan in-memory cache.
    """
    if rxcui in _openfda_cache:
        return _openfda_cache[rxcui]

    url = f"{OPENFDA_BASE_URL}/label.json"
    params = {"search": f"openfda.rxcui:{rxcui}", "limit": 1}

    try:
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.get(url, params=params)
            resp.raise_for_status()
            data = resp.json()

        results = data.get("results", [])
        if not results:
            _openfda_cache[rxcui] = {}
            return {}

        label = results[0]
        extracted = {
            "brand_name": label.get("openfda", {}).get("brand_name", []),
            "generic_name": label.get("openfda", {}).get("generic_name", []),
            "indications_and_usage": label.get("indications_and_usage", []),
            "adverse_reactions": label.get("adverse_reactions", []),
            "warnings": label.get("warnings", []),
            "contraindications": label.get("contraindications", []),
            "drug_interactions": label.get("drug_interactions", []),
        }

        _openfda_cache[rxcui] = extracted
        return extracted

    except httpx.HTTPStatusError as e:
        # 404 = tidak ditemukan di OpenFDA — bukan error fatal
        if e.response.status_code == 404:
            _openfda_cache[rxcui] = {}
            return {}
        return {}
    except Exception:
        return {}


def _format_drug_data_for_prompt(drug_name: str, fda_data: dict, rxcui: str | None) -> str:
    """Formatkan data obat mentah menjadi teks yang mudah dipahami LLM."""
    if not fda_data:
        return f"Nama obat: {drug_name}. Data dari database tidak tersedia, gunakan pengetahuan umummu."

    parts = [f"Nama obat: {drug_name}"]
    if rxcui:
        parts.append(f"RxCUI: {rxcui}")

    brand = fda_data.get("brand_name", [])
    if brand:
        parts.append(f"Nama dagang: {', '.join(brand[:3])}")

    indications = fda_data.get("indications_and_usage", [])
    if indications:
        parts.append(f"Indikasi: {indications[0][:500]}")

    adverse = fda_data.get("adverse_reactions", [])
    if adverse:
        parts.append(f"Efek samping: {adverse[0][:500]}")

    warnings = fda_data.get("warnings", [])
    if warnings:
        parts.append(f"Peringatan: {warnings[0][:300]}")

    contraindications = fda_data.get("contraindications", [])
    if contraindications:
        parts.append(f"Kontraindikasi: {contraindications[0][:300]}")

    return "\n".join(parts)


async def get_drug_summary(drug_name: str, allergy_profile: str = "") -> dict:
    """
    Hasilkan rangkuman medis obat yang dipersonalisasi berdasarkan profil alergi.

    Args:
        drug_name      : Nama obat (boleh nama generik atau dagang)
        allergy_profile: Teks profil alergi pengguna dari tabel users (F-03)

    Returns:
        dict dengan key: status, drug_name, rxcui, summary, data_source

    Terkait SKPL: F-07 — Rangkuman Medis LLM
    """
    if not settings.GEMINI_API_KEY:
        return {
            "status": "error",
            "message": "GEMINI_API_KEY belum dikonfigurasi di file .env",
        }

    allergy_text = allergy_profile.strip() if allergy_profile else "Tidak ada profil alergi."

    try:
        # Step 1: Cari RxCUI
        rxcui = await _get_rxcui(drug_name)

        # Step 2: Ambil data OpenFDA (jika rxcui ditemukan)
        fda_data = {}
        data_source = "gemini_only"
        if rxcui:
            fda_data = await _get_openfda_data(rxcui)
            data_source = "rxnorm+openfda+gemini" if fda_data else "rxnorm+gemini"

        # Step 3: Format data untuk prompt
        drug_data_text = _format_drug_data_for_prompt(drug_name, fda_data, rxcui)

        # Step 4: Kirim ke Gemini dengan retry otomatis jika rate limit
        genai.configure(api_key=settings.GEMINI_API_KEY)
        model = genai.GenerativeModel(
            _GEMINI_MODEL,
            generation_config={"temperature": 0.3},
        )

        prompt = _SUMMARY_PROMPT_TEMPLATE.format(
            drug_data=drug_data_text,
            allergy_profile=allergy_text,
        )

        last_error = None
        response_text = None
        for attempt in range(3):
            try:
                resp = model.generate_content(prompt)
                response_text = resp.text.strip()
                break
            except Exception as e:
                last_error = e
                if "429" in str(e) or "quota" in str(e).lower():
                    time.sleep(5 * (2 ** attempt))  # 5s, 10s, 20s
                else:
                    raise e

        if response_text is None:
            raise last_error

        return {
            "status": "ok",
            "drug_name": drug_name,
            "rxcui": rxcui,
            "data_source": data_source,
            "allergy_profile_used": allergy_text,
            "summary": response_text,
        }

    except Exception as e:
        return {
            "status": "error",
            "message": f"Terjadi kesalahan: {str(e)}",
        }
