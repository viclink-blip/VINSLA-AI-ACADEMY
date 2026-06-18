"""Quiz models."""
import uuid
from datetime import datetime
from app import db
from sqlalchemy.dialects.postgresql import UUID, JSONB


class Quiz(db.Model):
    __tablename__ = "quizzes"

    id          = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    lesson_id   = db.Column(UUID(as_uuid=True), db.ForeignKey("lessons.id"))
    course_id   = db.Column(UUID(as_uuid=True), db.ForeignKey("courses.id"), nullable=False)
    title       = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text)
    pass_score  = db.Column(db.Integer, default=70)
    time_limit  = db.Column(db.Integer, default=0)
    created_at  = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    questions = db.relationship("QuizQuestion", backref="quiz", lazy="dynamic", cascade="all, delete-orphan")
    attempts  = db.relationship("QuizAttempt",  backref="quiz", lazy="dynamic", cascade="all, delete-orphan")

    def to_dict(self, include_answers=False):
        return {
            "id":          str(self.id),
            "lesson_id":   str(self.lesson_id) if self.lesson_id else None,
            "course_id":   str(self.course_id),
            "title":       self.title,
            "description": self.description,
            "pass_score":  self.pass_score,
            "time_limit":  self.time_limit,
            "questions":   [q.to_dict(include_answers) for q in self.questions.order_by(QuizQuestion.sort_order)],
        }


class QuizQuestion(db.Model):
    __tablename__ = "quiz_questions"

    id            = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    quiz_id       = db.Column(UUID(as_uuid=True), db.ForeignKey("quizzes.id"), nullable=False)
    question_text = db.Column(db.Text, nullable=False)
    options       = db.Column(JSONB, nullable=False)
    correct_index = db.Column(db.Integer, nullable=False)
    explanation   = db.Column(db.Text)
    points        = db.Column(db.Integer, default=1)
    sort_order    = db.Column(db.Integer, default=0)

    def to_dict(self, include_answers=False):
        data = {
            "id":            str(self.id),
            "question_text": self.question_text,
            "options":       self.options,
            "points":        self.points,
            "sort_order":    self.sort_order,
        }
        if include_answers:
            data["correct_index"] = self.correct_index
            data["explanation"]   = self.explanation
        return data


class QuizAttempt(db.Model):
    __tablename__ = "quiz_attempts"

    id           = db.Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id      = db.Column(UUID(as_uuid=True), db.ForeignKey("users.id"), nullable=False)
    quiz_id      = db.Column(UUID(as_uuid=True), db.ForeignKey("quizzes.id"), nullable=False)
    answers      = db.Column(JSONB, nullable=False)
    score        = db.Column(db.Integer, nullable=False)
    passed       = db.Column(db.Boolean, nullable=False)
    time_taken   = db.Column(db.Integer)
    completed_at = db.Column(db.DateTime(timezone=True), default=datetime.utcnow)

    def to_dict(self):
        return {
            "id":           str(self.id),
            "quiz_id":      str(self.quiz_id),
            "score":        self.score,
            "passed":       self.passed,
            "time_taken":   self.time_taken,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
        }
