"""
Authentication routes: register, login, logout, refresh, forgot/reset password.
"""
from datetime import datetime, timedelta
from flask import Blueprint, request, current_app
from flask_jwt_extended import (
    create_access_token, create_refresh_token,
    jwt_required, get_jwt_identity
)
from app import db
from app.models.user import User, PasswordResetToken
from app.utils.security import hash_password, verify_password, generate_token
from app.utils.response import success, error

auth_bp = Blueprint("auth", __name__)


@auth_bp.post("/register")
def register():
    """Create a new student account."""
    data = request.get_json(silent=True) or {}

    # ── Validation ────────────────────────────────────────
    required = ["email", "username", "password", "full_name"]
    missing  = [f for f in required if not data.get(f)]
    if missing:
        return error(f"Missing fields: {', '.join(missing)}", 422)

    email    = data["email"].strip().lower()
    username = data["username"].strip()
    password = data["password"]

    if len(password) < 8:
        return error("Password must be at least 8 characters", 422)

    if User.query.filter_by(email=email).first():
        return error("Email already registered", 409)

    if User.query.filter_by(username=username).first():
        return error("Username already taken", 409)

    # ── Create user ───────────────────────────────────────
    user = User(
        email=email,
        username=username,
        password_hash=hash_password(password),
        full_name=data["full_name"].strip(),
    )
    db.session.add(user)
    db.session.commit()

    access_token  = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))

    return success(
        {
            "user":          user.to_dict(include_private=True),
            "access_token":  access_token,
            "refresh_token": refresh_token,
        },
        message="Account created successfully",
        status=201,
    )


@auth_bp.post("/login")
def login():
    """Authenticate and return JWT tokens."""
    data = request.get_json(silent=True) or {}
    email    = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""

    if not email or not password:
        return error("Email and password are required", 422)

    user = User.query.filter_by(email=email).first()
    if not user or not verify_password(password, user.password_hash):
        return error("Invalid email or password", 401)

    if not user.is_active:
        return error("Account has been deactivated", 403)

    # Update last active + streak
    now  = datetime.utcnow()
    user.last_active = now
    db.session.commit()

    access_token  = create_access_token(identity=str(user.id))
    refresh_token = create_refresh_token(identity=str(user.id))

    return success({
        "user":          user.to_dict(include_private=True),
        "access_token":  access_token,
        "refresh_token": refresh_token,
    })


@auth_bp.post("/refresh")
@jwt_required(refresh=True)
def refresh():
    """Get new access token using refresh token."""
    identity     = get_jwt_identity()
    access_token = create_access_token(identity=identity)
    return success({"access_token": access_token})


@auth_bp.get("/me")
@jwt_required()
def me():
    """Return current authenticated user profile."""
    user_id = get_jwt_identity()
    user    = User.query.get(user_id)
    if not user:
        return error("User not found", 404)
    return success(user.to_dict(include_private=True))


@auth_bp.post("/forgot-password")
def forgot_password():
    """Send password reset email."""
    data  = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()

    if not email:
        return error("Email is required", 422)

    user = User.query.filter_by(email=email).first()
    # Always return success to prevent email enumeration
    if not user:
        return success(message="If this email exists, a reset link has been sent")

    token = generate_token()
    reset = PasswordResetToken(
        user_id    = user.id,
        token      = token,
        expires_at = datetime.utcnow() + timedelta(hours=1),
    )
    db.session.add(reset)
    db.session.commit()

    # TODO: send email with reset link
    reset_url = f"{current_app.config['APP_URL']}/reset-password?token={token}"
    current_app.logger.info(f"Password reset URL for {email}: {reset_url}")

    return success(message="If this email exists, a reset link has been sent")


@auth_bp.post("/reset-password")
def reset_password():
    """Reset password using token from email."""
    data     = request.get_json(silent=True) or {}
    token    = data.get("token")
    password = data.get("password")

    if not token or not password:
        return error("Token and new password are required", 422)

    if len(password) < 8:
        return error("Password must be at least 8 characters", 422)

    reset = PasswordResetToken.query.filter_by(token=token, used=False).first()
    if not reset or reset.expires_at < datetime.utcnow():
        return error("Invalid or expired reset token", 400)

    user = User.query.get(reset.user_id)
    if not user:
        return error("User not found", 404)

    user.password_hash = hash_password(password)
    reset.used = True
    db.session.commit()

    return success(message="Password reset successfully")
