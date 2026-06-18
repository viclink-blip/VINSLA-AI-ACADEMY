"""
Vinsla AI Academy — Flask Application Factory
"""
from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_mail import Mail
from flask_sqlalchemy import SQLAlchemy

# ── Extensions (initialized here, bound in create_app) ──
db   = SQLAlchemy()
jwt  = JWTManager()
mail = Mail()


def create_app(config=None):
    """Application factory."""
    app = Flask(__name__)

    # ── Load Config ──────────────────────────────────────
    if config is None:
        from config.settings import get_config
        app.config.from_object(get_config())
    else:
        app.config.from_object(config)

    # ── Init Extensions ───────────────────────────────────
    db.init_app(app)
    jwt.init_app(app)
    mail.init_app(app)
    CORS(app, origins=app.config.get("CORS_ORIGINS", ["*"]))

    # ── Ensure upload dirs exist ──────────────────────────
    import os
    os.makedirs(app.config["UPLOAD_FOLDER"],      exist_ok=True)
    os.makedirs(app.config["CERTIFICATE_FOLDER"], exist_ok=True)

    # ── Register Blueprints ───────────────────────────────
    from app.routes.auth      import auth_bp
    from app.routes.courses   import courses_bp
    from app.routes.lessons   import lessons_bp
    from app.routes.quiz      import quiz_bp
    from app.routes.progress  import progress_bp
    from app.routes.ai_tutor  import ai_tutor_bp
    from app.routes.certificates import certificates_bp
    from app.routes.admin     import admin_bp
    from app.routes.users     import users_bp

    app.register_blueprint(auth_bp,         url_prefix="/api/auth")
    app.register_blueprint(courses_bp,      url_prefix="/api/courses")
    app.register_blueprint(lessons_bp,      url_prefix="/api/lessons")
    app.register_blueprint(quiz_bp,         url_prefix="/api/quiz")
    app.register_blueprint(progress_bp,     url_prefix="/api/progress")
    app.register_blueprint(ai_tutor_bp,     url_prefix="/api/ai-tutor")
    app.register_blueprint(certificates_bp, url_prefix="/api/certificates")
    app.register_blueprint(admin_bp,        url_prefix="/api/admin")
    app.register_blueprint(users_bp,        url_prefix="/api/users")

    # ── Health check ──────────────────────────────────────
    @app.get("/api/health")
    def health():
        return {"status": "ok", "app": app.config["APP_NAME"], "version": app.config["APP_VERSION"]}

    # ── JWT error handlers ────────────────────────────────
    @jwt.expired_token_loader
    def expired_token_callback(jwt_header, jwt_payload):
        return {"error": "Token has expired"}, 401

    @jwt.invalid_token_loader
    def invalid_token_callback(error):
        return {"error": "Invalid token"}, 401

    @jwt.unauthorized_loader
    def missing_token_callback(error):
        return {"error": "Authorization token required"}, 401

    return app
