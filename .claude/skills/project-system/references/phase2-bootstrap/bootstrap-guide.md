# Phase 2: 프로젝트 부트스트랩 가이드

이 가이드는 Phase 1 기획 완료 후 프로젝트 환경을 셋업하는 방법을 설명합니다.

---

## 개요

Phase 2에서는 다음을 수행합니다:

1. **프로젝트 구조 생성** - 백엔드/프론트엔드 디렉토리
2. **AI 에이전트 팀 설치** - `.claude/agents/` 및 `.claude/commands/`
3. **개발 환경 설정** - Docker, 의존성, 환경 변수

---

## 1단계: 기술 스택 확인

Phase 1 기획 문서에서 결정된 기술 스택을 확인합니다.

### TRD (02-trd.md)에서 확인할 항목

| 항목 | 예시 |
|------|------|
| 백엔드 | FastAPI, Express, Rails |
| 프론트엔드 | React + Vite, Next.js, SvelteKit |
| 데이터베이스 | PostgreSQL, MySQL, MongoDB |
| 인증 | JWT, OAuth |

---

## 2단계: AI 에이전트 팀 설치

### 에이전트 파일 복사

`references/phase2-bootstrap/agents/` 의 파일들을 프로젝트의 `.claude/agents/`로 복사합니다:

```
프로젝트/
└── .claude/
    ├── agents/
    │   ├── backend-specialist.md
    │   ├── frontend-specialist.md
    │   ├── database-specialist.md
    │   └── test-specialist.md
    └── commands/
        ├── orchestrate.md
        └── integration-validator.md
```

### Placeholder 치환

기술 스택에 맞게 `{{placeholder}}`를 치환합니다:

**백엔드 (FastAPI 예시)**
```
{{BACKEND_LANGUAGE}} → Python
{{BACKEND_FRAMEWORK}} → FastAPI
{{VALIDATION_LIB}} → Pydantic v2
{{ORM}} → SQLAlchemy 2.0
{{DATABASE}} → PostgreSQL
{{MIGRATION_TOOL}} → Alembic
{{DB_DRIVER}} → asyncpg
{{BACKEND_ROUTES_PATH}} → app/api/routes/
{{BACKEND_SCHEMAS_PATH}} → app/schemas/
{{BACKEND_MODELS_PATH}} → app/models/
```

**프론트엔드 (React + Vite 예시)**
```
{{FRONTEND_FRAMEWORK}} → React
{{FRONTEND_LANGUAGE}} → TypeScript
{{BUILD_TOOL}} → Vite
{{ROUTER}} → React Router v6
{{DATA_FETCHING}} → TanStack Query
{{STATE_MANAGEMENT}} → Zustand
{{CSS_FRAMEWORK}} → TailwindCSS
{{HTTP_CLIENT}} → Axios
{{FRONTEND_COMPONENTS_PATH}} → src/components/
{{FRONTEND_HOOKS_PATH}} → src/hooks/
{{FRONTEND_API_PATH}} → src/services/
{{FRONTEND_TYPES_PATH}} → src/types/
{{FRONTEND_ROUTES_PATH}} → src/routes/
```

**테스트**
```
{{BACKEND_TEST}} → pytest
{{HTTP_TEST_CLIENT}} → httpx
{{FRONTEND_TEST}} → Vitest
{{E2E_TEST}} → Playwright
{{TEST_DATA}} → Factory Boy / Faker
{{BACKEND_TESTS_PATH}} → tests/
{{FRONTEND_TESTS_PATH}} → src/__tests__/
{{E2E_TESTS_PATH}} → e2e/
{{TEST_CONFIG_PATH}} → pytest.ini / vitest.config.ts
```

---

## 3단계: 프로젝트 구조 생성

### 기본 구조

```
프로젝트/
├── .claude/
│   ├── agents/
│   └── commands/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   └── routes/
│   │   ├── core/
│   │   ├── models/
│   │   ├── schemas/
│   │   └── services/
│   ├── tests/
│   ├── alembic/
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── pages/
│   │   ├── services/
│   │   ├── stores/
│   │   └── types/
│   ├── public/
│   └── package.json
├── docs/
│   └── planning/
│       ├── 01-prd.md
│       ├── 02-trd.md
│       ├── 03-user-flow.md
│       ├── 04-database-design.md
│       ├── 05-design-system.md
│       └── 06-tasks.md
├── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

---

## 4단계: Docker Compose 설정

### PostgreSQL 예시

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
      POSTGRES_DB: ${DB_NAME}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

---

## 5단계: 의존성 설치

### 백엔드

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 프론트엔드

```bash
cd frontend
npm install
```

### Docker 시작

```bash
docker compose up -d
```

---

## 6단계: 환경 변수 설정

### .env.example → .env 복사

```bash
cp .env.example .env
```

### 필수 환경 변수

```
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=your_database

# JWT
JWT_SECRET_KEY=your-secret-key
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30

# Frontend
VITE_API_URL=http://localhost:8000
```

---

## 7단계: 초기 마이그레이션

```bash
cd backend

# Alembic 초기화 (최초 1회)
alembic init alembic

# 마이그레이션 생성
alembic revision --autogenerate -m "Initial migration"

# 마이그레이션 적용
alembic upgrade head
```

---

## 완료 확인

다음 명령어로 셋업이 완료되었는지 확인합니다:

```bash
# 백엔드 서버 실행
cd backend && uvicorn app.main:app --reload

# 프론트엔드 서버 실행
cd frontend && npm run dev

# 테스트 실행
cd backend && pytest -v
cd frontend && npm run test
```

---

## 다음 단계

- **Phase 3**: AGENTS.md 시스템 생성 (프로젝트 거버넌스 규칙)
- **Phase 4**: TASKS.md 생성 (태스크 목록)
- **Phase 5**: TDD 기반 개발 시작
