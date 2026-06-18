"""Progress tracking models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID


class UserLessonProgress(db.Model):
    __tablename__ = "user_lesson_progress"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id      = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    lesson_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("lessons.id"), nullable=False)
    course_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    completed    = db.Column(db.Boolean, default=False)
    time_spent   = db.Column(db.Integer, default=0)
    completed_at = db.Column(db.DateTime(timezone=True))
    created_at   = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    __table_args__ = (db.UniqueConstraint("user_id", "lesson_id"),)


class UserCourseEnrollment(db.Model):
    __tablename__ = "user_course_enrollments"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id      = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    course_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    progress_pct = db.Column(db.Numeric(5, 2), default=0)
    completed    = db.Column(db.Boolean, default=False)
    completed_at = db.Column(db.DateTime(timezone=True))
    enrolled_at  = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    course = db.relationship("Course")

    __table_args__ = (db.UniqueConstraint("user_id", "course_id"),)

    def to_dict(self):
        return {
            "course_id":    str(self.course_id),
            "progress_pct": float(self.progress_pct),
            "completed":    self.completed,
            "enrolled_at":  self.enrolled_at.isoformat() if self.enrolled_at else None,
        }
