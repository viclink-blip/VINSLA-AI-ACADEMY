"""Learning progress routes."""
from datetime import datetime
from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import func
from app import db
from app.models.progress import UserLessonProgress, UserCourseEnrollment
from app.models.course import Course, Lesson
from app.utils.response import success, error

progress_bp = Blueprint("progress", __name__)


@progress_bp.post("/lesson/<lesson_id>/complete")
@jwt_required()
def mark_complete(lesson_id):
    """Mark a lesson as complete and update course progress."""
    user_id    = get_jwt_identity()
    lesson     = Lesson.query.get_or_404(lesson_id)
    time_spent = request.get_json(silent=True, force=True).get("time_spent", 0)

    prog = UserLessonProgress.query.filter_by(
        user_id=user_id, lesson_id=lesson_id
    ).first()

    if not prog:
        prog = UserLessonProgress(
            user_id=user_id,
            lesson_id=lesson_id,
            course_id=lesson.course_id,
        )
        db.session.add(prog)

    prog.completed   = True
    prog.time_spent  += time_spent
    prog.completed_at = datetime.utcnow()

    # Recalculate course progress
    total    = Lesson.query.filter_by(course_id=lesson.course_id).count()
    done     = UserLessonProgress.query.filter_by(
        user_id=user_id, course_id=lesson.course_id, completed=True
    ).count()
    pct      = round((done / total * 100), 2) if total else 0

    enrollment = UserCourseEnrollment.query.filter_by(
        user_id=user_id, course_id=lesson.course_id
    ).first()
    if enrollment:
        enrollment.progress_pct = pct
        if pct >= 100:
            enrollment.completed    = True
            enrollment.completed_at = datetime.utcnow()

    db.session.commit()
    return success({"progress_pct": pct, "completed": pct >= 100})


@progress_bp.get("/dashboard")
@jwt_required()
def dashboard():
    """Return dashboard stats for the current user."""
    user_id = get_jwt_identity()

    enrollments = UserCourseEnrollment.query.filter_by(user_id=user_id).all()
    total_completed = UserLessonProgress.query.filter_by(
        user_id=user_id, completed=True
    ).count()

    return success({
        "enrollments":     [e.to_dict() for e in enrollments],
        "lessons_done":    total_completed,
        "courses_enrolled": len(enrollments),
        "courses_completed": sum(1 for e in enrollments if e.completed),
    })
