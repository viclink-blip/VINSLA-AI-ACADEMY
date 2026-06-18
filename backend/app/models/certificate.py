"""Certificate model."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID


class Certificate(db.Model):
    __tablename__ = "certificates"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    cert_id      = db.Column(db.String(20), unique=True, nullable=False)
    user_id      = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    course_id    = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    student_name = db.Column(db.String(255), nullable=False)
    course_name  = db.Column(db.String(255), nullable=False)
    final_score  = db.Column(db.Numeric(5, 2), nullable=False)
    issued_at    = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    pdf_url      = db.Column(db.Text)

    course = db.relationship("Course")

    __table_args__ = (db.UniqueConstraint("user_id", "course_id"),)

    def to_dict(self):
        return {
            "id":           str(self.id),
            "cert_id":      self.cert_id,
            "student_name": self.student_name,
            "course_name":  self.course_name,
            "final_score":  float(self.final_score),
            "issued_at":    self.issued_at.isoformat() if self.issued_at else None,
            "pdf_url":      self.pdf_url,
        }
