"""AI Tutor chat models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID


class ChatSession(db.Model):
    __tablename__ = "chat_sessions"

    id         = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    title      = db.Column(db.String(255), default="New Chat")
    created_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    updated_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    messages = db.relationship("ChatMessage", backref="session", lazy="dynamic",
                               cascade="all, delete-orphan", order_by="ChatMessage.created_at")

    def to_dict(self):
        return {
            "id":         str(self.id),
            "title":      self.title,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }


class ChatMessage(db.Model):
    __tablename__ = "chat_messages"

    id         = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    session_id = db.Column(UUID(as_uuid=True), db.ForeignKey("chat_sessions.id"), nullable=False)
    role       = db.Column(db.String(20), nullable=False)   # user | assistant
    content    = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    def to_dict(self):
        return {
            "id":         str(self.id),
            "role":       self.role,
            "content":    self.content,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
