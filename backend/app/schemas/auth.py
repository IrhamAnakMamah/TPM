"""
PillPal-AI — Pydantic Schemas for Auth
"""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, EmailStr, Field


# ── Request Schemas ───────────────────────────────

class UserCreate(BaseModel):
    """Schema for user registration."""
    username: str = Field(
        ..., min_length=3, max_length=50, examples=["irham_pillpal"]
    )
    email: str = Field(
        ..., min_length=5, max_length=120, examples=["irham@pillpal.id"]
    )
    password: str = Field(
        ..., min_length=6, max_length=128, examples=["RahasiaKuat!23"]
    )
    full_name: Optional[str] = Field(
        None, max_length=100, examples=["Irham Maulana"]
    )


class UserLogin(BaseModel):
    """Schema for user login."""
    username: str = Field(..., examples=["irham_pillpal"])
    password: str = Field(..., examples=["RahasiaKuat!23"])


# ── Response Schemas ──────────────────────────────

class Token(BaseModel):
    """JWT token response after successful login."""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Decoded token payload."""
    username: Optional[str] = None


class UserResponse(BaseModel):
    """Public user data returned by the API."""
    id: int
    username: str
    email: str
    full_name: Optional[str] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class MessageResponse(BaseModel):
    """Generic message response."""
    message: str
    detail: Optional[dict] = None
