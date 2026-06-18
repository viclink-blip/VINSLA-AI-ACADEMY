-- ============================================================
-- Vinsla AI Academy — PostgreSQL Database Schema
-- Version: 1.0.0
-- ============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────
CREATE TABLE users (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email         VARCHAR(255) UNIQUE NOT NULL,
    username      VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(255) NOT NULL,
    avatar_url    TEXT,
    role          VARCHAR(20) DEFAULT 'student' CHECK (role IN ('student','instructor','admin')),
    is_active     BOOLEAN DEFAULT TRUE,
    is_verified   BOOLEAN DEFAULT FALSE,
    streak_days   INTEGER DEFAULT 0,
    last_active   TIMESTAMP WITH TIME ZONE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Password reset tokens
CREATE TABLE password_reset_tokens (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token      VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used       BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Email verification tokens
CREATE TABLE email_verification_tokens (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token      VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- COURSES
-- ─────────────────────────────────────────
CREATE TABLE courses (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug         VARCHAR(100) UNIQUE NOT NULL,
    title        VARCHAR(255) NOT NULL,
    description  TEXT NOT NULL,
    category     VARCHAR(50) NOT NULL CHECK (category IN ('python','ai','ml')),
    difficulty   VARCHAR(20) DEFAULT 'beginner' CHECK (difficulty IN ('beginner','intermediate','advanced')),
    thumbnail_url TEXT,
    total_lessons INTEGER DEFAULT 0,
    is_published  BOOLEAN DEFAULT FALSE,
    sort_order    INTEGER DEFAULT 0,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Course modules (sections)
CREATE TABLE modules (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id   UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    description TEXT,
    sort_order  INTEGER DEFAULT 0,
    created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Individual lessons
CREATE TABLE lessons (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    module_id       UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title           VARCHAR(255) NOT NULL,
    content         TEXT NOT NULL,          -- Markdown content
    code_examples   JSONB DEFAULT '[]',      -- Array of {title, language, code}
    lesson_type     VARCHAR(30) DEFAULT 'theory' CHECK (lesson_type IN ('theory','practice','quiz','project')),
    duration_minutes INTEGER DEFAULT 10,
    sort_order      INTEGER DEFAULT 0,
    is_free         BOOLEAN DEFAULT FALSE,  -- Preview lessons
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- QUIZZES
-- ─────────────────────────────────────────
CREATE TABLE quizzes (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id    UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id    UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title        VARCHAR(255) NOT NULL,
    description  TEXT,
    pass_score   INTEGER DEFAULT 70,    -- Percentage required to pass
    time_limit   INTEGER DEFAULT 0,     -- Minutes, 0 = no limit
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE quiz_questions (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id       UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    options       JSONB NOT NULL,        -- ["option A", "option B", ...]
    correct_index INTEGER NOT NULL,      -- 0-based index of correct answer
    explanation   TEXT,                  -- Why the answer is correct
    points        INTEGER DEFAULT 1,
    sort_order    INTEGER DEFAULT 0
);

CREATE TABLE quiz_attempts (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    quiz_id       UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    answers       JSONB NOT NULL,        -- {question_id: selected_index}
    score         INTEGER NOT NULL,      -- Percentage 0-100
    passed        BOOLEAN NOT NULL,
    time_taken    INTEGER,               -- Seconds
    completed_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- PROGRESS TRACKING
-- ─────────────────────────────────────────
CREATE TABLE user_lesson_progress (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id     UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    course_id     UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    completed     BOOLEAN DEFAULT FALSE,
    time_spent    INTEGER DEFAULT 0,     -- Seconds
    completed_at  TIMESTAMP WITH TIME ZONE,
    created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, lesson_id)
);

CREATE TABLE user_course_enrollments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id       UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    progress_pct    NUMERIC(5,2) DEFAULT 0.00,
    completed       BOOLEAN DEFAULT FALSE,
    completed_at    TIMESTAMP WITH TIME ZONE,
    enrolled_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- ─────────────────────────────────────────
-- ASSIGNMENTS
-- ─────────────────────────────────────────
CREATE TABLE assignments (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lesson_id    UUID REFERENCES lessons(id) ON DELETE CASCADE,
    course_id    UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title        VARCHAR(255) NOT NULL,
    description  TEXT NOT NULL,
    starter_code TEXT,
    solution     TEXT,                   -- Hidden from students
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE assignment_submissions (
    id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assignment_id UUID NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    code          TEXT NOT NULL,
    feedback      TEXT,
    score         INTEGER,
    graded_by_ai  BOOLEAN DEFAULT FALSE,
    submitted_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    graded_at     TIMESTAMP WITH TIME ZONE
);

-- ─────────────────────────────────────────
-- CERTIFICATES
-- ─────────────────────────────────────────
CREATE TABLE certificates (
    id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cert_id        VARCHAR(20) UNIQUE NOT NULL,   -- Human-readable: VAA-2024-XXXXX
    user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id      UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    student_name   VARCHAR(255) NOT NULL,
    course_name    VARCHAR(255) NOT NULL,
    final_score    NUMERIC(5,2) NOT NULL,
    issued_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    pdf_url        TEXT,
    UNIQUE(user_id, course_id)
);

-- ─────────────────────────────────────────
-- AI TUTOR CHAT
-- ─────────────────────────────────────────
CREATE TABLE chat_sessions (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title      VARCHAR(255) DEFAULT 'New Chat',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE chat_messages (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
    role       VARCHAR(20) NOT NULL CHECK (role IN ('user','assistant')),
    content    TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ─────────────────────────────────────────
-- ACHIEVEMENTS & BADGES
-- ─────────────────────────────────────────
CREATE TABLE badges (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    icon        VARCHAR(100),
    criteria    JSONB        -- {type: 'streak', value: 7}
);

CREATE TABLE user_badges (
    id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id   UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

-- ─────────────────────────────────────────
-- STREAK TRACKING
-- ─────────────────────────────────────────
CREATE TABLE daily_activity (
    id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    date      DATE NOT NULL,
    xp_earned INTEGER DEFAULT 0,
    UNIQUE(user_id, date)
);

-- ─────────────────────────────────────────
-- INDEXES FOR PERFORMANCE
-- ─────────────────────────────────────────
CREATE INDEX idx_lessons_course ON lessons(course_id);
CREATE INDEX idx_lessons_module ON lessons(module_id);
CREATE INDEX idx_progress_user ON user_lesson_progress(user_id);
CREATE INDEX idx_progress_course ON user_lesson_progress(course_id);
CREATE INDEX idx_enrollments_user ON user_course_enrollments(user_id);
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id);
CREATE INDEX idx_certificates_user ON certificates(user_id);
CREATE INDEX idx_daily_activity_user ON daily_activity(user_id, date);

-- ─────────────────────────────────────────
-- SEED: Default badges
-- ─────────────────────────────────────────
INSERT INTO badges (name, description, icon, criteria) VALUES
  ('First Step',    'Completed your first lesson',          'star',      '{"type":"lesson_count","value":1}'),
  ('Week Warrior',  '7-day learning streak',                'fire',      '{"type":"streak","value":7}'),
  ('Python Rookie', 'Completed Introduction to Python',     'snake',     '{"type":"course_module","module":"python_intro"}'),
  ('AI Explorer',   'Completed Introduction to AI',         'robot',     '{"type":"course_module","module":"ai_intro"}'),
  ('ML Pioneer',    'Completed Introduction to ML',         'chart',     '{"type":"course_module","module":"ml_intro"}'),
  ('Quiz Master',   'Scored 100% on any quiz',              'trophy',    '{"type":"perfect_quiz","value":1}'),
  ('Streak Legend', '30-day learning streak',               'lightning', '{"type":"streak","value":30}'),
  ('Graduate',      'Earned a course certificate',          'diploma',   '{"type":"certificate","value":1}');

-- Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated    BEFORE UPDATE ON users    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_courses_updated  BEFORE UPDATE ON courses  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_lessons_updated  BEFORE UPDATE ON lessons  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

