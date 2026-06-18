"""Quiz routes — attempt, grade, history."""
from flask import Blueprint, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.quiz import Quiz, QuizQuestion, QuizAttempt
from app.utils.response import success, error

quiz_bp = Blueprint("quiz", __name__)


@quiz_bp.get("/<quiz_id>")
@jwt_required()
def get_quiz(quiz_id):
    """Get quiz without correct answers."""
    quiz = Quiz.query.get_or_404(quiz_id)
    return success(quiz.to_dict(include_answers=False))


@quiz_bp.post("/<quiz_id>/submit")
@jwt_required()
def submit_quiz(quiz_id):
    """Grade a quiz submission."""
    user_id = get_jwt_identity()
    data    = request.get_json(silent=True) or {}
    answers = data.get("answers", {})  # {question_id: selected_index}

    quiz      = Quiz.query.get_or_404(quiz_id)
    questions = QuizQuestion.query.filter_by(quiz_id=quiz.id).all()

    if not questions:
        return error("Quiz has no questions", 400)

    total_points = sum(q.points for q in questions)
    earned       = 0
    results      = []

    for q in questions:
        selected  = answers.get(str(q.id))
        is_correct = selected == q.correct_index
        if is_correct:
            earned += q.points
        results.append({
            "question_id":    str(q.id),
            "selected":       selected,
            "correct_index":  q.correct_index,
            "is_correct":     is_correct,
            "explanation":    q.explanation,
        })

    score  = round(earned / total_points * 100) if total_points else 0
    passed = score >= quiz.pass_score

    attempt = QuizAttempt(
        user_id   = user_id,
        quiz_id   = quiz.id,
        answers   = answers,
        score     = score,
        passed    = passed,
        time_taken= data.get("time_taken"),
    )
    db.session.add(attempt)
    db.session.commit()

    return success({
        "attempt":   attempt.to_dict(),
        "score":     score,
        "passed":    passed,
        "pass_score":quiz.pass_score,
        "results":   results,
    })


@quiz_bp.get("/<quiz_id>/history")
@jwt_required()
def quiz_history(quiz_id):
    """Get user's past attempts for this quiz."""
    user_id  = get_jwt_identity()
    attempts = QuizAttempt.query.filter_by(
        user_id=user_id, quiz_id=quiz_id
    ).order_by(QuizAttempt.completed_at.desc()).all()
    return success([a.to_dict() for a in attempts])
