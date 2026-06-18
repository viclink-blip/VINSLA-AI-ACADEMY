"""Certificate generation and retrieval routes."""
import os
from datetime import datetime
from flask import Blueprint, send_file, current_app
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.certificate import Certificate
from app.models.progress import UserCourseEnrollment
from app.models.quiz import QuizAttempt, Quiz
from app.models.user import User
from app.models.course import Course
from app.utils.security import generate_cert_id
from app.utils.response import success, error
from app.services.certificate_service import generate_pdf_certificate

certificates_bp = Blueprint("certificates", __name__)


@certificates_bp.post("/issue/<course_id>")
@jwt_required()
def issue_certificate(course_id):
    """Issue certificate if requirements met (70%+ avg quiz score + course complete)."""
    user_id = get_jwt_identity()
    user    = User.query.get(user_id)
    course  = Course.query.get_or_404(course_id)

    # Check existing
    existing = Certificate.query.filter_by(user_id=user_id, course_id=course_id).first()
    if existing:
        return success(existing.to_dict(), message="Certificate already issued")

    # Check course completion
    enrollment = UserCourseEnrollment.query.filter_by(
        user_id=user_id, course_id=course_id
    ).first()
    if not enrollment or not enrollment.completed:
        return error("Course not yet completed", 400)

    # Calculate average quiz score for this course
    quizzes = Quiz.query.filter_by(course_id=course_id).all()
    if quizzes:
        quiz_ids = [str(q.id) for q in quizzes]
        best_attempts = []
        for qid in quiz_ids:
            best = QuizAttempt.query.filter_by(
                user_id=user_id, quiz_id=qid
            ).order_by(QuizAttempt.score.desc()).first()
            if best:
                best_attempts.append(best.score)

        avg_score = sum(best_attempts) / len(best_attempts) if best_attempts else 0
        if avg_score < 70:
            return error(f"Minimum score of 70% required. Your average: {avg_score:.0f}%", 400)
    else:
        avg_score = 100.0

    cert_id = generate_cert_id()
    cert    = Certificate(
        cert_id      = cert_id,
        user_id      = user_id,
        course_id    = course_id,
        student_name = user.full_name,
        course_name  = course.title,
        final_score  = round(avg_score, 2),
    )
    db.session.add(cert)
    db.session.flush()

    # Generate PDF
    pdf_path = generate_pdf_certificate(cert, current_app.config["CERTIFICATE_FOLDER"])
    cert.pdf_url = pdf_path
    db.session.commit()

    return success(cert.to_dict(), message="Certificate issued!", status=201)


@certificates_bp.get("/")
@jwt_required()
def my_certificates():
    """List current user's certificates."""
    user_id = get_jwt_identity()
    certs   = Certificate.query.filter_by(user_id=user_id)\
        .order_by(Certificate.issued_at.desc()).all()
    return success([c.to_dict() for c in certs])


@certificates_bp.get("/<cert_id>/download")
@jwt_required()
def download_certificate(cert_id):
    """Download certificate PDF."""
    user_id = get_jwt_identity()
    cert    = Certificate.query.filter_by(cert_id=cert_id, user_id=user_id).first_or_404()

    if not cert.pdf_url or not os.path.exists(cert.pdf_url):
        return error("Certificate PDF not found", 404)

    return send_file(
        cert.pdf_url,
        as_attachment=True,
        download_name=f"certificate_{cert.cert_id}.pdf",
        mimetype="application/pdf",
    )


@certificates_bp.get("/verify/<cert_id>")
def verify_certificate(cert_id):
    """Public endpoint to verify a certificate."""
    cert = Certificate.query.filter_by(cert_id=cert_id).first()
    if not cert:
        return error("Certificate not found or invalid", 404)
    return success({
        "valid":        True,
        "cert_id":      cert.cert_id,
        "student_name": cert.student_name,
        "course_name":  cert.course_name,
        "issued_at":    cert.issued_at.isoformat() if cert.issued_at else None,
    })
