# Vinsla AI Academy — Complete Setup Guide

## Prerequisites
- Flutter SDK 3.3+
- Python 3.11+
- PostgreSQL 14+
- Docker & Docker Compose (optional)
- Anthropic API key

---

## Option A: Docker (Recommended — 5 minutes)

```bash
# 1. Clone / unzip the project
cd vinsla_ai_academy

# 2. Create .env file
cp backend/.env.example backend/.env
# Edit backend/.env — add your ANTHROPIC_API_KEY

# 3. Start everything
docker-compose up --build -d

# 4. Verify backend is running
curl http://localhost:5000/api/health
# → {"status":"ok","app":"Vinsla AI Academy","version":"1.0.0"}
```

---

## Option B: Manual Setup

### Backend (Flask)

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env — fill in DATABASE_URL, JWT_SECRET_KEY, ANTHROPIC_API_KEY

# Create database
psql -U postgres -c "CREATE USER vinsla WITH PASSWORD 'vinsla123';"
psql -U postgres -c "CREATE DATABASE vinsla_academy OWNER vinsla;"
psql -U vinsla -d vinsla_academy -f migrations/001_initial_schema.sql

# Run development server
python run.py
# Backend live at http://localhost:5000
```

### Flutter App

```bash
cd flutter_app

# Install dependencies
flutter pub get

# Configure API URL
# Edit lib/core/constants/app_constants.dart
# Change baseUrl to your backend URL

# Run on device/emulator
flutter run

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## Seed Course Content

After the backend is running, seed the three courses via the admin API:

```bash
# Get admin token (create admin user first via register, then set role)
TOKEN="your-jwt-token"

# Create Python course
curl -X POST http://localhost:5000/api/admin/courses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "python-programming",
    "title": "Python Programming",
    "description": "Learn Python from scratch — variables, loops, OOP, APIs and more.",
    "category": "python",
    "difficulty": "beginner",
    "sort_order": 1,
    "is_published": true
  }'

# Create AI course
curl -X POST http://localhost:5000/api/admin/courses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "artificial-intelligence",
    "title": "Artificial Intelligence",
    "description": "Master AI concepts — generative AI, prompt engineering, and building AI applications.",
    "category": "ai",
    "difficulty": "beginner",
    "sort_order": 2,
    "is_published": true
  }'

# Create ML course
curl -X POST http://localhost:5000/api/admin/courses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "slug": "machine-learning",
    "title": "Machine Learning",
    "description": "From data preparation to model deployment — complete ML mastery.",
    "category": "ml",
    "difficulty": "intermediate",
    "sort_order": 3,
    "is_published": true
  }'
```

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/auth/register | Create account |
| POST | /api/auth/login | Sign in |
| POST | /api/auth/refresh | Refresh token |
| GET  | /api/auth/me | Current user |
| POST | /api/auth/forgot-password | Request reset link |
| POST | /api/auth/reset-password | Reset with token |
| GET  | /api/courses/ | List all courses |
| GET  | /api/courses/:slug | Course + curriculum |
| POST | /api/courses/:id/enroll | Enroll in course |
| GET  | /api/lessons/:id | Lesson content |
| POST | /api/progress/lesson/:id/complete | Mark complete |
| GET  | /api/progress/dashboard | Dashboard stats |
| GET  | /api/quiz/:id | Quiz questions |
| POST | /api/quiz/:id/submit | Submit answers |
| POST | /api/ai-tutor/chat | Chat with AI tutor |
| POST | /api/ai-tutor/generate-quiz | AI-generated quiz |
| POST | /api/ai-tutor/study-plan | Personalized plan |
| POST | /api/certificates/issue/:course_id | Issue certificate |
| GET  | /api/certificates/ | My certificates |
| GET  | /api/certificates/:cert_id/download | Download PDF |
| GET  | /api/certificates/verify/:cert_id | Verify (public) |
| GET  | /api/admin/analytics | Platform stats |
| GET  | /api/admin/users | All users |
| POST | /api/admin/courses | Create course |

---

## Production Deployment (VPS/Cloud)

```bash
# 1. Set strong secrets in .env
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# 2. Build and start with Docker
docker-compose -f docker-compose.yml up -d

# 3. Set up SSL with Certbot
apt install certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com

# 4. Update Flutter app
# In lib/core/constants/app_constants.dart
# Set baseUrl = 'https://yourdomain.com/api'
# Then rebuild: flutter build apk --release
```

---

## Project Structure

```
vinsla_ai_academy/
├── backend/
│   ├── app/
│   │   ├── models/          # SQLAlchemy ORM models
│   │   ├── routes/          # Flask blueprints (API endpoints)
│   │   ├── services/        # Certificate PDF generation
│   │   └── utils/           # Security, response helpers, decorators
│   ├── config/settings.py   # App configuration
│   ├── migrations/          # PostgreSQL schema SQL
│   ├── requirements.txt
│   ├── run.py               # Dev entry point
│   ├── wsgi.py              # Production (gunicorn)
│   └── Dockerfile
│
├── flutter_app/
│   └── lib/
│       ├── core/
│       │   ├── constants/   # App constants & API URL
│       │   ├── theme/       # Colors, typography, dark/light themes
│       │   ├── utils/       # API client (Dio + JWT), router
│       │   └── widgets/     # Shared UI components
│       │
│       └── features/
│           ├── auth/        # Splash, Onboarding, Login, Register, Forgot PW
│           ├── dashboard/   # Home dashboard + main navigation shell
│           ├── courses/     # Course list, course detail, lesson viewer
│           ├── ai_tutor/    # AI chat interface
│           ├── quiz/        # Quiz taking + results
│           ├── certificates/# Certificate list + download
│           ├── profile/     # User profile + settings
│           └── admin/       # Admin panel (analytics, users, courses)
│
├── docker-compose.yml
├── nginx.conf
└── docs/
    └── SETUP_GUIDE.md       # ← This file
```
