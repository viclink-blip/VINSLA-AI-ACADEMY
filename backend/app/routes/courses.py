"""Course and module routes."""
from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.course import Course, Module, Lesson
from app.models.progress import UserCourseEnrollment
from app.utils.response import success, error

courses_bp = Blueprint("courses", __name__)


@courses_bp.get("/")
@jwt_required()
def list_courses():
    """List all published courses."""
    category = request.args.get("category")
    query    = Course.query.filter_by(is_published=True)
    if category:
        query = query.filter_by(category=category)
    courses = query.order_by(Course.sort_order).all()
    return success([c.to_dict() for c in courses])


@courses_bp.get("/<slug>")
@jwt_required()
def get_course(slug):
    """Get course with full curriculum."""
    user_id = get_jwt_identity()
    course  = Course.query.filter_by(slug=slug, is_published=True).first_or_404()
    data    = course.to_dict()

    # Attach modules + lessons
    modules = Module.query.filter_by(course_id=course.id).order_by(Module.sort_order).all()
    data["modules"] = []
    for m in modules:
        md = m.to_dict()
        lessons = Lesson.query.filter_by(module_id=m.id).order_by(Lesson.sort_order).all()
        md["lessons"] = [l.to_dict() for l in lessons]
        data["modules"].append(md)

    # Attach enrollment/progress
    enrollment = UserCourseEnrollment.query.filter_by(
        user_id=user_id, course_id=course.id
    ).first()
    data["enrollment"] = enrollment.to_dict() if enrollment else None

    return success(data)


@courses_bp.post("/<course_id>/enroll")
@jwt_required()
def enroll(course_id):
    """Enroll in a course."""
    user_id = get_jwt_identity()
    course  = Course.query.get_or_404(course_id)

    existing = UserCourseEnrollment.query.filter_by(
        user_id=user_id, course_id=course.id
    ).first()
    if existing:
        return success(existing.to_dict(), message="Already enrolled")

    enrollment = UserCourseEnrollment(user_id=user_id, course_id=course.id)
    db.session.add(enrollment)
    db.session.commit()
    return success(enrollment.to_dict(), message="Enrolled successfully", status=201)
