"""Admin panel routes."""
from flask import Blueprint, request
from flask_jwt_extended import jwt_required
from app import db
from app.models.user import User
from app.models.course import Course, Module, Lesson
from app.models.quiz import Quiz, QuizQuestion
from app.models.certificate import Certificate
from app.utils.decorators import admin_required
from app.utils.response import success, error, paginate

admin_bp = Blueprint("admin", __name__)


# ── Users ─────────────────────────────────────────────────
@admin_bp.get("/users")
@admin_required
def list_users():
    page    = request.args.get("page", 1, type=int)
    per_page= request.args.get("per_page", 20, type=int)
    query   = User.query.order_by(User.created_at.desc())
    return success(paginate(query, page, per_page, lambda u: u.to_dict()))


@admin_bp.put("/users/<user_id>/toggle-active")
@admin_required
def toggle_user(user_id):
    user = User.query.get_or_404(user_id)
    user.is_active = not user.is_active
    db.session.commit()
    return success({"is_active": user.is_active})


@admin_bp.put("/users/<user_id>/role")
@admin_required
def set_user_role(user_id):
    data = request.get_json(silent=True) or {}
    role = data.get("role")
    if role not in ("student", "instructor", "admin"):
        return error("Invalid role", 422)
    user = User.query.get_or_404(user_id)
    user.role = role
    db.session.commit()
    return success(user.to_dict())


# ── Courses ───────────────────────────────────────────────
@admin_bp.post("/courses")
@admin_required
def create_course():
    data   = request.get_json(silent=True) or {}
    required = ["slug", "title", "description", "category"]
    missing  = [f for f in required if not data.get(f)]
    if missing:
        return error(f"Missing: {', '.join(missing)}", 422)

    course = Course(**{k: data[k] for k in required})
    course.difficulty    = data.get("difficulty", "beginner")
    course.thumbnail_url = data.get("thumbnail_url")
    course.sort_order    = data.get("sort_order", 0)
    db.session.add(course)
    db.session.commit()
    return success(course.to_dict(), status=201)


@admin_bp.put("/courses/<course_id>")
@admin_required
def update_course(course_id):
    course = Course.query.get_or_404(course_id)
    data   = request.get_json(silent=True) or {}
    fields = ["title", "description", "difficulty", "thumbnail_url", "is_published", "sort_order"]
    for f in fields:
        if f in data:
            setattr(course, f, data[f])
    db.session.commit()
    return success(course.to_dict())


@admin_bp.post("/courses/<course_id>/modules")
@admin_required
def create_module(course_id):
    Course.query.get_or_404(course_id)
    data   = request.get_json(silent=True) or {}
    module = Module(
        course_id  = course_id,
        title      = data.get("title", ""),
        description= data.get("description"),
        sort_order = data.get("sort_order", 0),
    )
    db.session.add(module)
    db.session.commit()
    return success(module.to_dict(), status=201)


@admin_bp.post("/modules/<module_id>/lessons")
@admin_required
def create_lesson(module_id):
    module = Module.query.get_or_404(module_id)
    data   = request.get_json(silent=True) or {}
    lesson = Lesson(
        module_id       = module_id,
        course_id       = module.course_id,
        title           = data.get("title", ""),
        content         = data.get("content", ""),
        code_examples   = data.get("code_examples", []),
        lesson_type     = data.get("lesson_type", "theory"),
        duration_minutes= data.get("duration_minutes", 10),
        sort_order      = data.get("sort_order", 0),
        is_free         = data.get("is_free", False),
    )
    db.session.add(lesson)
    # Update total lesson count
    course = Course.query.get(module.course_id)
    if course:
        course.total_lessons = Lesson.query.filter_by(course_id=course.id).count() + 1
    db.session.commit()
    return success(lesson.to_dict(), status=201)


# ── Analytics ─────────────────────────────────────────────
@admin_bp.get("/analytics")
@admin_required
def analytics():
    from app.models.certificate import Certificate
    from app.models.progress import UserCourseEnrollment
    return success({
        "total_users":       User.query.count(),
        "active_users":      User.query.filter_by(is_active=True).count(),
        "total_courses":     Course.query.count(),
        "total_enrollments": UserCourseEnrollment.query.count(),
        "total_certificates":Certificate.query.count(),
    })
