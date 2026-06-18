"""
AI Tutor routes — powered by Anthropic Claude.
Supports: answering questions, generating quizzes, creating study plans.
"""
from flask import Blueprint, request, current_app, Response, stream_with_context
from flask_jwt_extended import jwt_required, get_jwt_identity
import anthropic
from app import db
from app.models.chat import ChatSession, ChatMessage
from app.utils.response import success, error

ai_tutor_bp = Blueprint("ai_tutor", __name__)

SYSTEM_PROMPT = """You are Vinsla, an expert AI tutor at Vinsla AI Academy.
You specialize exclusively in:
- Python Programming (from basics to advanced OOP, APIs, databases)
- Artificial Intelligence (concepts, generative AI, prompt engineering, LLMs)
- Machine Learning (data prep, supervised/unsupervised learning, model evaluation)

Your teaching style:
- Clear, beginner-friendly explanations with real examples
- Always include working code snippets with inline comments
- Break complex topics into digestible steps
- Encourage students and celebrate their progress
- Generate practice exercises and quizzes when asked
- Suggest study plans tailored to the student's goals

Format rules:
- Use Markdown for all responses
- Wrap all code in ```python or ```bash blocks
- Use numbered steps for processes
- Keep responses focused and structured

If asked about topics outside Python/AI/ML, politely redirect the student back."""


def get_anthropic_client():
    return anthropic.Anthropic(api_key=current_app.config["ANTHROPIC_API_KEY"])


@ai_tutor_bp.post("/chat")
@jwt_required()
def chat():
    """Send message to AI tutor and get response."""
    user_id = get_jwt_identity()
    data    = request.get_json(silent=True) or {}
    message = (data.get("message") or "").strip()
    session_id = data.get("session_id")

    if not message:
        return error("Message is required", 422)

    # ── Get or create session ─────────────────────────────
    if session_id:
        session = ChatSession.query.filter_by(id=session_id, user_id=user_id).first()
        if not session:
            return error("Session not found", 404)
    else:
        session = ChatSession(user_id=user_id, title=message[:60])
        db.session.add(session)
        db.session.flush()

    # ── Build message history ─────────────────────────────
    history_msgs = ChatMessage.query.filter_by(session_id=session.id)\
        .order_by(ChatMessage.created_at).limit(20).all()

    messages = [{"role": m.role, "content": m.content} for m in history_msgs]
    messages.append({"role": "user", "content": message})

    # ── Save user message ─────────────────────────────────
    user_msg = ChatMessage(session_id=session.id, role="user", content=message)
    db.session.add(user_msg)

    # ── Call Claude ───────────────────────────────────────
    try:
        client   = get_anthropic_client()
        response = client.messages.create(
            model      = current_app.config["AI_MODEL"],
            max_tokens = 2048,
            system     = SYSTEM_PROMPT,
            messages   = messages,
        )
        ai_content = response.content[0].text
    except Exception as e:
        current_app.logger.error(f"AI API error: {e}")
        return error("AI service temporarily unavailable. Please try again.", 503)

    # ── Save AI response ──────────────────────────────────
    ai_msg = ChatMessage(session_id=session.id, role="assistant", content=ai_content)
    db.session.add(ai_msg)

    # Auto-title session from first exchange
    if len(history_msgs) == 0:
        session.title = message[:60]

    db.session.commit()

    return success({
        "session_id": str(session.id),
        "message":    ai_msg.to_dict(),
    })


@ai_tutor_bp.get("/sessions")
@jwt_required()
def list_sessions():
    """List user's chat sessions."""
    user_id  = get_jwt_identity()
    sessions = ChatSession.query.filter_by(user_id=user_id)\
        .order_by(ChatSession.updated_at.desc()).limit(20).all()
    return success([s.to_dict() for s in sessions])


@ai_tutor_bp.get("/sessions/<session_id>")
@jwt_required()
def get_session(session_id):
    """Get all messages in a chat session."""
    user_id = get_jwt_identity()
    session = ChatSession.query.filter_by(id=session_id, user_id=user_id).first_or_404()
    msgs    = ChatMessage.query.filter_by(session_id=session.id)\
        .order_by(ChatMessage.created_at).all()
    return success({
        "session":  session.to_dict(),
        "messages": [m.to_dict() for m in msgs],
    })


@ai_tutor_bp.delete("/sessions/<session_id>")
@jwt_required()
def delete_session(session_id):
    """Delete a chat session."""
    user_id = get_jwt_identity()
    session = ChatSession.query.filter_by(id=session_id, user_id=user_id).first_or_404()
    db.session.delete(session)
    db.session.commit()
    return success(message="Session deleted")


@ai_tutor_bp.post("/generate-quiz")
@jwt_required()
def generate_quiz():
    """Ask AI to generate a quiz on a topic."""
    data  = request.get_json(silent=True) or {}
    topic = (data.get("topic") or "").strip()
    count = min(int(data.get("count", 5)), 10)

    if not topic:
        return error("Topic is required", 422)

    prompt = f"""Generate {count} multiple-choice quiz questions about: {topic}

Respond ONLY with valid JSON in this exact format:
{{
  "questions": [
    {{
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_index": 0,
      "explanation": "Why this answer is correct"
    }}
  ]
}}"""

    try:
        client   = get_anthropic_client()
        response = client.messages.create(
            model      = current_app.config["AI_MODEL"],
            max_tokens = 2000,
            system     = "You are a quiz generator. Always respond with valid JSON only, no markdown.",
            messages   = [{"role": "user", "content": prompt}],
        )
        import json
        quiz_data = json.loads(response.content[0].text)
        return success(quiz_data)
    except Exception as e:
        current_app.logger.error(f"Quiz generation error: {e}")
        return error("Failed to generate quiz", 503)


@ai_tutor_bp.post("/study-plan")
@jwt_required()
def study_plan():
    """Generate a personalized study plan."""
    data  = request.get_json(silent=True) or {}
    goal  = (data.get("goal") or "").strip()
    hours = data.get("hours_per_week", 5)

    if not goal:
        return error("Goal is required", 422)

    prompt = f"""Create a structured weekly study plan for: {goal}
Available time: {hours} hours per week.
Focus only on Python, AI, and ML topics from Vinsla AI Academy.
Include specific lessons, practice exercises, and milestones."""

    try:
        client   = get_anthropic_client()
        response = client.messages.create(
            model      = current_app.config["AI_MODEL"],
            max_tokens = 2000,
            system     = SYSTEM_PROMPT,
            messages   = [{"role": "user", "content": prompt}],
        )
        return success({"plan": response.content[0].text})
    except Exception as e:
        return error("Failed to generate study plan", 503)
