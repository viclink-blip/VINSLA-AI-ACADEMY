"""Achievements and badges models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID, JSONB


class Badge(db.Model):
    __tablename__ = "badges"

    id          = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name        = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    icon        = db.Column(db.String(100))
    criteria    = db.Column(JSONB)

    def to_dict(self):
        return {
            "id":          str(self.id),
            "name":        self.name,
            "description": self.description,
            "icon":        self.icon,
        }


class UserBadge(db.Model):
    __tablename__ = "user_badges"

    id        = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id   = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    badge_id  = db.Column(UUID(as_uuid=True), db.ForeignKey("badges.id"), nullable=False)
    earned_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    badge = db.relationship("Badge")
    __table_args__ = (db.UniqueConstraint("user_id", "badge_id"),)


class DailyActivity(db.Model):
    __tablename__ = "daily_activity"

    id        = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id   = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    date      = db.Column(db.Date, nullable=False)
    xp_earned = db.Column(db.Integer, default=0)
    __table_args__ = (db.UniqueConstraint("user_id", "date"),)
