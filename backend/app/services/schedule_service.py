"""
PillPal-AI — Schedule Parsing Service (F-04B)

Menggunakan Gemini AI untuk mem-parsing input teks alami pengguna
menjadi data jadwal obat terstruktur (JSON).

Contoh input : "Minum Paracetamol 500mg setiap 8 jam, stok 30 tablet"
Contoh output: {"name": "Paracetamol", "dosage": 500.0, "dosage_unit": "mg",
                "frequency_type": "every_n_hours", "frequency_value": 8,
                "total_stock": 30}
"""

import json
import re
import time

import google.generativeai as genai

from app.core.config import settings

# Model paling ringan — paling hemat quota free tier
_GEMINI_MODEL = "gemini-3.1-flash-lite-preview"

# ── Prompt Template (sesuai skill_api.md) ────────────────────────────────────
_PARSE_PROMPT_TEMPLATE = """
Kamu adalah asisten parsing jadwal minum obat yang sangat teliti.
Ekstrak informasi berikut dari teks pengguna dan kembalikan HANYA JSON valid tanpa markdown atau penjelasan tambahan:
{{
  "name": "nama obat (string)",
  "dosage": angka_dosis (float),
  "dosage_unit": "mg | ml | tablet | kapsul",
  "frequency_type": "daily | every_n_hours",
  "frequency_value": angka_N (integer, gunakan 1 jika daily),
  "total_stock": angka_stok (integer),
  "time_intake": "HH:MM (estimasi waktu pertama, default 08:00 jika tidak disebutkan)"
}}

Aturan:
- Jika pengguna menyebut "sekali sehari" / "1x sehari" → frequency_type: "daily", frequency_value: 1
- Jika pengguna menyebut "2x sehari" → frequency_type: "every_n_hours", frequency_value: 12
- Jika pengguna menyebut "3x sehari" → frequency_type: "every_n_hours", frequency_value: 8
- Jika pengguna menyebut "tiap N jam" / "setiap N jam" → frequency_type: "every_n_hours", frequency_value: N
- Jika stok tidak disebutkan, gunakan total_stock: 0
- Kembalikan HANYA JSON. Tidak boleh ada teks lain di luar JSON.

Teks pengguna: {user_input}
""".strip()


def _extract_json(text: str) -> dict:
    """Ekstrak JSON dari response Gemini (handle jika ada markdown code block)."""
    text = re.sub(r"```(?:json)?\s*", "", text).strip()
    text = text.strip("`").strip()
    return json.loads(text)


def _call_gemini_with_retry(prompt: str, max_retries: int = 3) -> str:
    """
    Panggil Gemini dengan retry otomatis jika terkena rate limit (429).
    Menggunakan exponential backoff: tunggu 5s, 10s, 20s sebelum retry.
    """
    genai.configure(api_key=settings.GEMINI_API_KEY)
    model = genai.GenerativeModel(
        _GEMINI_MODEL,
        generation_config={"temperature": 0.1},
    )

    last_error = None
    for attempt in range(max_retries):
        try:
            response = model.generate_content(prompt)
            return response.text.strip()
        except Exception as e:
            last_error = e
            error_str = str(e)
            if "429" in error_str or "quota" in error_str.lower():
                wait_seconds = 5 * (2 ** attempt)  # 5s, 10s, 20s
                time.sleep(wait_seconds)
            else:
                raise e

    raise last_error


def parse_schedule(user_input: str) -> dict:
    """
    Parse teks alami pengguna menjadi data jadwal obat terstruktur.

    Args:
        user_input: Teks bebas dari pengguna, contoh:
                    "Minum Amoxicillin 500mg 3x sehari, stok 21 tablet"

    Returns:
        dict dengan key: status, data (jika berhasil), message (jika error)

    Terkait SKPL: F-04B — Input LLM (Natural Language Parsing)
    """
    if not settings.GEMINI_API_KEY:
        return {
            "status": "error",
            "message": "GEMINI_API_KEY belum dikonfigurasi di file .env",
        }

    if not user_input or not user_input.strip():
        return {
            "status": "error",
            "message": "Input teks tidak boleh kosong",
        }

    try:
        prompt = _PARSE_PROMPT_TEMPLATE.format(user_input=user_input.strip())
        raw_text = _call_gemini_with_retry(prompt)

        parsed = _extract_json(raw_text)

        required_fields = ["name", "dosage", "dosage_unit", "frequency_type",
                           "frequency_value", "total_stock", "time_intake"]
        missing = [f for f in required_fields if f not in parsed]
        if missing:
            return {
                "status": "error",
                "message": f"Gemini mengembalikan data tidak lengkap. Field kurang: {missing}",
                "raw_response": raw_text,
            }

        parsed["dosage"] = float(parsed["dosage"])
        parsed["frequency_value"] = int(parsed["frequency_value"])
        parsed["total_stock"] = int(parsed["total_stock"])

        return {
            "status": "ok",
            "original_input": user_input,
            "data": parsed,
        }

    except json.JSONDecodeError as e:
        return {
            "status": "error",
            "message": f"Gagal mem-parse respons Gemini sebagai JSON: {str(e)}",
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Terjadi kesalahan saat memanggil Gemini: {str(e)}",
        }
