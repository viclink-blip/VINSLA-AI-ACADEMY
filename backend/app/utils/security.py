"""Security utilities: hashing, tokens."""
import secrets
import bcrypt


def hash_password(plain: str) -> str:
    """Return bcrypt hash of the password."""
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()


def verify_password(plain: str, hashed: str) -> bool:
    """Return True if plain matches hashed."""
    return bcrypt.checkpw(plain.encode(), hashed.encode())


def generate_token(length: int = 32) -> str:
    """Generate a cryptographically secure URL-safe token."""
    return secrets.token_urlsafe(length)


def generate_cert_id() -> str:
    """Generate human-readable certificate ID: VAA-YYYY-XXXXX."""
    from datetime import datetime
    year  = datetime.utcnow().year
    token = secrets.token_hex(3).upper()
    return f"VAA-{year}-{token}"
