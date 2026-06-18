"""User models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID


class User(db.Model):
    __tablename__ = "users"

    id            = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email         = db.Column(db.String(255), unique=True, nullable=False)
    username      = db.Column(db.String(100), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    full_name     = db.Column(db.String(255), nullable=False)
    avatar_url    = db.Column(db.Text)
    role          = db.Column(db.String(20), default="student")
    is_active     = db.Column(db.Boolean, default=True)
    is_verified   = db.Column(db.Boolean, default=False)
    streak_days   = db.Column(db.Integer, default=0)
    last_active   = db.Column(db.DateTime(timezone=True))
    created_at    = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    updated_at    = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    enrollments   = db.relationship("UserCourseEnrollment", backref="user", lazy="dynamic")
    certificates  = db.relationship("Certificate", backref="user", lazy="dynamic")
    chat_sessions = db.relationship("ChatSession", backref="user", lazy="dynamic")
    badges        = db.relationship("UserBadge", backref="user", lazy="dynamic")

    def to_dict(self, include_private=False):
        data = {
            "id":          str(self.id),
            "email":       self.email,
            "username":    self.username,
            "full_name":   self.full_name,
            "avatar_url":  self.avatar_url,
            "role":        self.role,
            "is_active":   self.is_active,
            "streak_days": self.streak_days,
            "created_at":  self.created_at.isoformat() if self.created_at else None,
        }
        if include_private:
            data["is_verified"] = self.is_verified
        return data

    def __repr__(self):
        return f"<User {self.email}>"


class PasswordResetToken(db.Model):
    __tablename__ = "password_reset_tokens"

    id         = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    token      = db.Column(db.String(255), unique=True, nullable=False)
    expires_at = db.Column(db.DateTime(timezone=True), nullable=False)
    used       = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
