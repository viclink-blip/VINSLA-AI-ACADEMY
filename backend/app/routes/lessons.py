"""Lesson routes."""
from flask import Blueprint
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.course import Lesson
from app.models.progress import UserLessonProgress
from app.utils.response import success, error

lessons_bp = Blueprint("lessons", __name__)


@lessons_bp.get("/<lesson_id>")
@jwt_required()
def get_lesson(lesson_id):
    """Get lesson content."""
    lesson = Lesson.query.get_or_404(lesson_id)
    data   = lesson.to_dict()

    user_id  = get_jwt_identity()
    progress = UserLessonProgress.query.filter_by(
        user_id=user_id, lesson_id=lesson_id
    ).first()
    data["progress"] = {
        "completed":  progress.completed  if progress else False,
        "time_spent": progress.time_spent if progress else 0,
    }
    return success(data)
