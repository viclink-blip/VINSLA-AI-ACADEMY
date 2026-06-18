"""
Vinsla AI Academy — Application Configuration
"""
import os
from datetime import timedelta
from dotenv import load_dotenv

load_dotenv()

class Config:
    # ── Core ──────────────────────────────────────────────
    SECRET_KEY = os.getenv("SECRET_KEY", "change-me-in-production")
    DEBUG = False
    TESTING = False

    # ── Database ──────────────────────────────────────────
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "postgresql://vinsla:vinsla123@localhost:5432/vinsla_academy"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_size": 10,
        "max_overflow": 20,
        "pool_pre_ping": True,
    }

    # ── JWT ───────────────────────────────────────────────
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "jwt-secret-change-me")
    JWT_ACCESS_TOKEN_EXPIRES  = timedelta(hours=24)
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)
    JWT_TOKEN_LOCATION = ["headers"]
    JWT_HEADER_NAME = "Authorization"
    JWT_HEADER_TYPE = "Bearer"

    # ── Email ─────────────────────────────────────────────
    MAIL_SERVER   = os.getenv("MAIL_SERVER", "smtp.gmail.com")
    MAIL_PORT     = int(os.getenv("MAIL_PORT", 587))
    MAIL_USE_TLS  = True
    MAIL_USERNAME = os.getenv("MAIL_USERNAME", "")
    MAIL_PASSWORD = os.getenv("MAIL_PASSWORD", "")
    MAIL_DEFAULT_SENDER = os.getenv("MAIL_DEFAULT_SENDER", "noreply@vinslaacademy.com")

    # ── AI (Anthropic Claude) ─────────────────────────────
    ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY", "")
    AI_MODEL = "claude-sonnet-4-6"

    # ── File Storage ─────────────────────────────────────
    UPLOAD_FOLDER       = os.getenv("UPLOAD_FOLDER", "/tmp/vinsla_uploads")
    CERTIFICATE_FOLDER  = os.getenv("CERTIFICATE_FOLDER", "/tmp/vinsla_certificates")
    MAX_CONTENT_LENGTH  = 16 * 1024 * 1024  # 16 MB

    # ── CORS ─────────────────────────────────────────────
    CORS_ORIGINS = os.getenv("CORS_ORIGINS", "*").split(",")

    # ── Pagination ───────────────────────────────────────
    DEFAULT_PAGE_SIZE = 20

    # ── App Info ─────────────────────────────────────────
    APP_NAME    = "Vinsla AI Academy"
    APP_VERSION = "1.0.0"
    APP_URL     = os.getenv("APP_URL", "http://localhost:5000")


class DevelopmentConfig(Config):
    DEBUG = True
    SQLALCHEMY_ECHO = False


class ProductionConfig(Config):
    DEBUG = False
    SQLALCHEMY_ECHO = False


class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = "postgresql://vinsla:vinsla123@localhost:5432/vinsla_test"


config_map = {
    "development": DevelopmentConfig,
    "production":  ProductionConfig,
    "testing":     TestingConfig,
}

def get_config():
    env = os.getenv("FLASK_ENV", "development")
    return config_map.get(env, DevelopmentConfig)
