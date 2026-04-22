"""
PillPal-AI — FastAPI Application Entry Point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.database import engine, Base
from app.api import auth, services

# ── Create all database tables ────────────────────
Base.metadata.create_all(bind=engine)

# ── FastAPI App ───────────────────────────────────
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=(
        "🩺 **PillPal-AI** — Asisten obat cerdas berbasis AI.\n\n"
        "Backend API untuk autentikasi pengguna, integrasi Gemini AI, "
        "dan pencarian obat melalui RxNorm."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS Middleware (untuk Flutter frontend) ──────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Ubah ke domain spesifik di production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Register Routers ─────────────────────────────
app.include_router(auth.router)
app.include_router(services.router)


# ── Root Health Check ─────────────────────────────
@app.get("/", tags=["🏠 Root"])
def root():
    """Health check endpoint."""
    return {
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "🟢 running",
        "docs": "/docs",
    }
