"""Assignment models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID


class Assignment(db.Model):
    __tablename__ = "assignments"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    lesson_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("lessons.id"))
    course_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    title        = db.Column(db.String(255), nullable=False)
    description  = db.Column(db.Text, nullable=False)
    starter_code = db.Column(db.Text)
    solution     = db.Column(db.Text)
    created_at   = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    submissions = db.relationship("AssignmentSubmission", backref="assignment", lazy="dynamic")

    def to_dict(self):
        return {
            "id":           str(self.id),
            "title":        self.title,
            "description":  self.description,
            "starter_code": self.starter_code,
        }


class AssignmentSubmission(db.Model):
    __tablename__ = "assignment_submissions"

    id            = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id       = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    assignment_id = db.Column(UUID(as_uuid=True), db.ForeignKey("assignments.id"), nullable=False)
    code          = db.Column(db.Text, nullable=False)
    feedback      = db.Column(db.Text)
    score         = db.Column(db.Integer)
    graded_by_ai  = db.Column(db.Boolean, default=False)
    submitted_at  = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    graded_at     = db.Column(db.DateTime(timezone=True))

    def to_dict(self):
        return {
            "id":           str(self.id),
            "code":         self.code,
            "feedback":     self.feedback,
            "score":        self.score,
            "graded_by_ai": self.graded_by_ai,
            "submitted_at": self.submitted_at.isoformat() if self.submitted_at else None,
        }
