"""Custom route decorators."""
from functools import wraps
from flask_jwt_extended import get_jwt_identity, verify_jwt_in_request
from app.models.user import User
from app.utils.response import error


def admin_required(fn):
    """Decorator: only allows admin role."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or user.role != "admin":
            return error("Admin access required", 403)
        return fn(*args, **kwargs)
    return wrapper


def active_user_required(fn):
    """Decorator: requires verified + active user."""
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        if not user or not user.is_active:
            return error("Account is inactive", 403)
        return fn(*args, **kwargs)
    return wrapper
