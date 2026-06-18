"""Course, Module, and Lesson models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID, JSONB


class Course(db.Model):
    __tablename__ = "courses"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    slug         = db.Column(db.String(100), unique=True, nullable=False)
    title        = db.Column(db.String(255), nullable=False)
    description  = db.Column(db.Text, nullable=False)
    category     = db.Column(db.String(50), nullable=False)   # python | ai | ml
    difficulty   = db.Column(db.String(20), default="beginner")
    thumbnail_url= db.Column(db.Text)
    total_lessons= db.Column(db.Integer, default=0)
    is_published = db.Column(db.Boolean, default=False)
    sort_order   = db.Column(db.Integer, default=0)
    created_at   = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    updated_at   = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    modules  = db.relationship("Module",  backref="course", lazy="dynamic", cascade="all, delete-orphan")
    lessons  = db.relationship("Lesson",  backref="course", lazy="dynamic", cascade="all, delete-orphan")
    quizzes  = db.relationship("Quiz",    backref="course", lazy="dynamic", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id":           str(self.id),
            "slug":         self.slug,
            "title":        self.title,
            "description":  self.description,
            "category":     self.category,
            "difficulty":   self.difficulty,
            "thumbnail_url":self.thumbnail_url,
            "total_lessons":self.total_lessons,
            "is_published": self.is_published,
            "sort_order":   self.sort_order,
            "created_at":   self.created_at.isoformat() if self.created_at else None,
        }


class Module(db.Model):
    __tablename__ = "modules"

    id          = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    course_id   = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    title       = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    sort_order  = db.Column(db.Integer, default=0)
    created_at  = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    lessons = db.relationship("Lesson", backref="module", lazy="dynamic", cascade="all, delete-orphan")

    def to_dict(self):
        return {
            "id":          str(self.id),
            "course_id":   str(self.course_id),
            "title":       self.title,
            "description": self.description,
            "sort_order":  self.sort_order,
        }


class Lesson(db.Model):
    __tablename__ = "lessons"

    id               = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    module_id        = db.Column(UUID(as_uuid=True), db.ForeignKey("modules.id"), nullable=False)
    course_id        = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    title            = db.Column(db.String(255), nullable=False)
    content          = db.Column(db.Text, nullable=False)
    code_examples    = db.Column(JSONB, default=list)
    lesson_type      = db.Column(db.String(30), default="theory")
    duration_minutes = db.Column(db.Integer, default=10)
    sort_order       = db.Column(db.Integer, default=0)
    is_free          = db.Column(db.Boolean, default=False)
    created_at       = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)
    updated_at       = db.Column(db.DateTime(timezone=True), default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            "id":               str(self.id),
            "module_id":        str(self.module_id),
            "course_id":        str(self.course_id),
            "title":            self.title,
            "content":          self.content,
            "code_examples":    self.code_examples or [],
            "lesson_type":      self.lesson_type,
            "duration_minutes": self.duration_minutes,
            "sort_order":       self.sort_order,
            "is_free":          self.is_free,
        }
