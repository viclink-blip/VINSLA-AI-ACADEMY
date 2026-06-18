"""User profile routes."""
from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.utils.response import success, error

users_bp = Blueprint("users", __name__)


@users_bp.put("/profile")
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    user    = User.query.get_or_404(user_id)
    data    = request.get_json(silent=True) or {}

    if "full_name"  in data: user.full_name  = data["full_name"].strip()
    if "avatar_url" in data: user.avatar_url = data["avatar_url"]

    db.session.commit()
    return success(user.to_dict())


@users_bp.put("/change-password")
@jwt_required()
def change_password():
    from app.utils.security import verify_password, hash_password
    user_id     = get_jwt_identity()
    user        = User.query.get_or_404(user_id)
    data        = request.get_json(silent=True) or {}
    old_pass    = data.get("old_password", "")
    new_pass    = data.get("new_password", "")

    if not verify_password(old_pass, user.password_hash):
        return error("Current password is incorrect", 400)
    if len(new_pass) < 8:
        return error("New password must be at least 8 characters", 422)

    user.password_hash = hash_password(new_pass)
    db.session.commit()
    return success(message="Password updated")
