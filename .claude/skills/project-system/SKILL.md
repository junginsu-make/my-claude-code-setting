---
name: project-system
description: 신규 프로젝트를 위한 통합 워크플로우. 기획 + 프로젝트 셋업 + AGENTS.md 규칙 시스템 + 태스크 생성(Quality Gate) + TDD 개발을 하나의 흐름으로 통합. "프로젝트 시작", "새 프로젝트", "project system" 키워드에 반응.
---

# Project System

신규 프로젝트를 위한 통합 워크플로우입니다.

## 절대 금지 사항

1. **직접 코드 작성 금지** - 각 Phase를 순서대로 완료해야 합니다
2. **Phase 건너뛰기 금지** - Phase 1 → 2 → 3 → 4 → 5 순서 필수
3. **질문 없이 진행 금지** - 각 Phase 시작 전 사용자 확인 필수

---

## 스킬 발동 시 즉시 실행

```
1. Read 도구로 이 SKILL.md의 전체 워크플로우 확인
2. 인사 메시지 출력
3. AskUserQuestion으로 프로젝트 유형 확인
4. Phase 1부터 순차 진행
```

---

## 통합 워크플로우 개요

```
Phase 1: 기획 (Planning)
    └→ 21개 질문 → 6개 기획 문서 생성

Phase 2: 프로젝트 셋업 (Bootstrap)
    └→ 기술 스택 선택 → 스캐폴딩 + .claude/agents/

Phase 3: AGENTS.md 시스템 (Governance)
    └→ 프로젝트 분석 → 루트 + 하위 AGENTS.md 생성

Phase 4: 태스크 생성 (Tasks)
    └→ 기획 문서 + 프로젝트 구조 → TASKS.md (Quality Gate 포함)

Phase 5: 개발 실행 (Development)
    └→ Git Worktree + TDD + Quality Gate 검증
```

---

## Phase 1: 기획 (Planning)

### 목적
21개 질문을 통해 모호한 아이디어를 구체적인 기획 문서로 변환합니다.

### 필수 파일 읽기

스킬 시작 시 **반드시 Read 도구**로 읽습니다:

```
references/phase1-planning/questions.md
references/phase1-planning/conversation-rules.md
```

### 실행 절차

1. **인사 메시지 출력**
2. **Q1~Q21 질문 진행** (AskUserQuestion 도구 사용)
3. **3~4문답마다 현재 합의 요약**
4. **6개 문서 생성** (docs/planning/)

### 산출물

| 순서 | 파일 | 템플릿 |
|------|------|--------|
| 1 | 01-prd.md | references/phase1-planning/templates/prd-template.md |
| 2 | 02-trd.md | references/phase1-planning/templates/trd-template.md |
| 3 | 03-user-flow.md | references/phase1-planning/templates/user-flow-template.md |
| 4 | 04-database-design.md | references/phase1-planning/templates/database-design-template.md |
| 5 | 05-design-system.md | references/phase1-planning/templates/design-system-template.md |
| 6 | 07-coding-convention.md | references/phase1-planning/templates/coding-convention-template.md |

### Phase 1 완료 조건

- [ ] 21개 질문 완료
- [ ] 6개 문서 생성 완료
- [ ] 사용자 승인

---

## Phase 2: 프로젝트 셋업 (Bootstrap)

### 목적
선택한 기술 스택으로 프로젝트 스캐폴딩과 AI 에이전트 팀을 생성합니다.

### 필수 질문 (AskUserQuestion)

**질문 2-1: 데이터베이스 선택**
```
어떤 데이터베이스를 사용하시겠습니까?
1. PostgreSQL (권장)
2. MySQL
3. SQLite
4. MongoDB
```

**질문 2-2: 인증 포함 여부**
```
인증 기능을 포함할까요?
1. 예 (권장) - JWT 인증 + 로그인/회원가입/프로필
2. 아니오
```

**질문 2-3: 추가 기능 (다중 선택)**
```
추가 기능이 필요하신가요?
1. 벡터 DB (PGVector)
2. Redis 캐시
3. 없음
```

### 실행 절차

1. **에이전트 팀 생성** (.claude/agents/, .claude/commands/)
2. **백엔드 스캐폴딩** (FastAPI/Express/Rails/Django)
3. **프론트엔드 스캐폴딩** (React+Vite/Next.js/SvelteKit/Remix)
4. **Docker Compose 생성**
5. **Git 초기화**

### 에이전트 파일 (references/phase2-bootstrap/agents/)

| 파일 | 역할 |
|------|------|
| backend-specialist.md | 백엔드 API, 비즈니스 로직 |
| frontend-specialist.md | UI 컴포넌트, 상태 관리 |
| database-specialist.md | DB 스키마, 마이그레이션 |
| test-specialist.md | 테스트 작성, 커버리지 |

### 커맨드 파일 (references/phase2-bootstrap/commands/)

| 파일 | 역할 |
|------|------|
| orchestrate.md | 오케스트레이터 (Task 도구로 에이전트 호출) |

### 산출물 구조

```
project/
├── .claude/
│   ├── agents/
│   │   ├── backend-specialist.md
│   │   ├── frontend-specialist.md
│   │   ├── database-specialist.md
│   │   └── test-specialist.md
│   └── commands/
│       └── orchestrate.md
├── backend/
├── frontend/
├── docker-compose.yml
└── docs/planning/  (Phase 1에서 생성)
```

### Phase 2 완료 조건

- [ ] 에이전트 팀 생성 완료
- [ ] 백엔드/프론트엔드 스캐폴딩 완료
- [ ] Docker 설정 완료
- [ ] CLAUDE.md Development History 초기화
- [ ] 사용자 승인

---

## Phase 3: AGENTS.md 시스템 (Governance)

### 목적
프로젝트 구조를 분석하여 AI 거버넌스 규칙 시스템을 생성합니다.

### 필수 파일 읽기

```
references/phase3-agents-md/agents-md-guide.md
references/phase3-agents-md/AGENTS_md_Master_Prompt.md
```

### 핵심 철학

1. **500라인 제한**: 모든 AGENTS.md는 500라인 미만
2. **이모지 금지**: 토큰 효율성을 위해 이모지 사용 금지
3. **중앙 통제 + 위임**: 루트 파일이 관제탑, 상세는 하위로 위임
4. **실행 가능한 지침**: Golden Rules, Operational Commands

### AGENTS.md 생성 기준

다음 신호가 감지될 때 별도 AGENTS.md 생성:

- **Dependency Boundary**: package.json, requirements.txt 등이 별도 존재
- **Framework Boundary**: 기술 스택 전환 지점
- **Logical Boundary**: 비즈니스 로직 밀도가 높은 핵심 모듈

### 루트 AGENTS.md 필수 섹션

```markdown
# Project Context & Operations
- 비즈니스 목표, Tech Stack 요약
- Operational Commands (빌드, 테스트 명령어)

# Golden Rules
- Immutable (절대 불변 규칙)
- Do's & Don'ts (행동 수칙)

# Standards & References
- 코딩 컨벤션 (docs/planning/07-coding-convention.md 링크)
- Git 전략, 커밋 메시지 포맷

# Context Map
- **[API Routes (BE)](./backend/AGENTS.md)** — 백엔드 로직 수정 시
- **[UI Components (FE)](./frontend/AGENTS.md)** — 프론트엔드 작업 시
```

### 하위 AGENTS.md 필수 섹션

- Module Context
- Tech Stack & Constraints
- Implementation Patterns
- Testing Strategy
- Local Golden Rules

### 산출물

```
project/
├── AGENTS.md              (루트 - 관제탑)
├── backend/
│   └── AGENTS.md          (백엔드 규칙)
├── frontend/
│   └── AGENTS.md          (프론트엔드 규칙)
└── ...
```

### Phase 3 완료 조건

- [ ] 루트 AGENTS.md 생성
- [ ] 하위 AGENTS.md 생성 (필요한 경우)
- [ ] 사용자 승인

---

## Phase 4: 태스크 생성 (Tasks)

### 목적
기획 문서와 프로젝트 구조를 기반으로 실행 가능한 TASKS.md를 생성합니다.

### 필수 파일 읽기

```
references/phase4-tasks/tasks-rules.md
```

### 핵심 규칙

**Phase 번호 규칙**:
| Phase | Git Worktree | 설명 |
|-------|-------------|------|
| Phase 0 | 불필요 | main 브랜치에서 직접 작업 |
| Phase 1+ | 필수 | 별도 worktree에서 작업 |

**TDD 워크플로우**:
```
1. RED: 테스트 작성 (실패 확인)
2. GREEN: 최소 구현 (테스트 통과)
3. REFACTOR: 리팩토링 (테스트 유지)
```

**태스크 독립성**:
- 각 태스크는 독립적으로 실행 가능
- 의존성이 있으면 Mock 설정 포함
- 병렬 실행 가능 여부 명시

### Quality Gate (feature-planner 통합)

각 태스크 완료 시 검증:

**빌드 & 테스트**:
- [ ] 프로젝트 빌드 성공
- [ ] 모든 테스트 통과
- [ ] 커버리지 ≥80%

**코드 품질**:
- [ ] 린트 통과
- [ ] 타입 체크 통과
- [ ] 포매팅 일관성

**기능 검증**:
- [ ] 수동 테스트 완료
- [ ] 엣지 케이스 확인
- [ ] 회귀 없음

### 산출물

```
docs/planning/06-tasks.md
```

### TASKS.md 구조

```markdown
# TASKS: {프로젝트명}

## MVP 캡슐
1. 목표: ...
2. 페르소나: ...
...

## 마일스톤 개요
| 마일스톤 | 설명 | Phase |
|----------|------|-------|
| M0 | 프로젝트 셋업 | 0 |
| M1 | 공통 흐름 | 1 |
...

## M0: 프로젝트 셋업

### [] Phase 0, T0.1: {태스크명}
**담당**: {specialist}
**산출물**: ...

## M1: 핵심 기능

### [] Phase 1, T1.1: {태스크명} RED→GREEN
**담당**: {specialist}
**Git Worktree**: `git worktree add ../project-phase1-{feature} -b phase/1-{feature}`

**TDD 사이클**:
1. RED: 테스트 작성
2. GREEN: 구현
3. REFACTOR: 정리

**Quality Gate**:
- [ ] 빌드 성공
- [ ] 테스트 통과 (커버리지 ≥80%)
- [ ] 린트/타입 체크 통과
- [ ] 수동 테스트 완료

**산출물**: ...
**인수 조건**: ...

## 의존성 그래프
(Mermaid flowchart)

## 병렬 실행 가능 태스크
(테이블)
```

### Phase 4 완료 조건

- [ ] TASKS.md 생성 완료
- [ ] Quality Gate 포함 확인
- [ ] 사용자 승인

---

## Phase 5: 개발 실행 (Development)

### 목적
생성된 TASKS.md를 기반으로 TDD 방식으로 개발을 진행합니다.

### 필수 파일 읽기

```
references/phase5-development/tdd-workflow.md
references/phase5-development/plan-template.md  # 개별 기능 상세 플랜 템플릿
```

### 개별 기능 플랜 (선택)

복잡한 기능 개발 시 `plan-template.md`를 사용하여 상세 플랜 문서를 생성합니다:

```
docs/plans/PLAN_<feature-name>.md
```

### Git Worktree 워크플로우

```bash
# Phase 1 시작
git worktree add ../project-phase1-feature -b phase/1-feature
cd ../project-phase1-feature

# 작업 완료 후
git add . && git commit -m "feat: implement feature"
cd ../project
git merge phase/1-feature
git worktree remove ../project-phase1-feature
```

### TDD 사이클 상세

**RED Phase**:
```
1. 테스트 파일 생성
2. 실패하는 테스트 작성
3. 테스트 실행 → 실패 확인
4. 커밋: "test: add failing test for X"
```

**GREEN Phase**:
```
1. 최소한의 코드 작성
2. 테스트 실행 → 통과 확인
3. 커밋: "feat: implement X to pass tests"
```

**REFACTOR Phase**:
```
1. 코드 품질 개선 (중복 제거, 네이밍 개선)
2. 테스트 실행 → 여전히 통과 확인
3. 커밋: "refactor: improve X implementation"
```

### Quality Gate 검증 명령어 예시

```bash
# Python (FastAPI/Django)
pytest --cov=src --cov-report=html
ruff check .
mypy src/

# JavaScript/TypeScript (React/Next.js)
npm test -- --coverage
npm run lint
npm run type-check

# Ruby (Rails)
bundle exec rspec --coverage
rubocop
```

### 오케스트레이터 사용

```
/orchestrate 명령으로 에이전트 팀 조율:
- 백엔드 태스크 → backend-specialist
- 프론트엔드 태스크 → frontend-specialist
- DB 태스크 → database-specialist
- 테스트 태스크 → test-specialist
```

---

## Development History 관리

### 필수 업데이트 시점

다음 상황에서 **반드시** CLAUDE.md의 Development History를 업데이트합니다:

1. **Phase 완료 시**: Phase 진행 현황 테이블 업데이트
2. **마일스톤 완료 시**: 버전 업데이트 + 업데이트 로그 작성
3. **주요 기능 추가/변경 시**: 업데이트 로그 작성
4. **버그 수정 시**: 업데이트 로그에 Fixed 항목 추가
5. **개발 중단/재개 시**: 현재 상태와 다음 작업 기록

### 업데이트 형식

```markdown
## [YYYY-MM-DD] v0.2.0 - 인증 기능 완료

### Added
- JWT 기반 로그인/회원가입 API
- 프로필 페이지 UI

### Changed
- 기존 라우팅 구조 개선

### Fixed
- CORS 설정 오류 수정

### Notes
- 다음 작업: 대시보드 기능 (Phase 2)
- 테스트 커버리지: 85%
```

### 프로젝트 재진입 시

프로젝트에 다시 접근할 때 CLAUDE.md의 Development History를 확인하여:
- 현재 진행 상황 파악
- 마지막 작업 내용 확인
- 다음 작업 계획 확인

---

## 인사 메시지

스킬 발동 시 출력:

```
안녕하세요! Project System입니다.

신규 프로젝트를 체계적으로 시작할 수 있도록 도와드릴게요.

5단계 워크플로우:
1. 기획 - 21개 질문으로 요구사항 정리
2. 프로젝트 셋업 - 스캐폴딩 + AI 에이전트 팀
3. AGENTS.md - 프로젝트 규칙 시스템
4. 태스크 생성 - TDD + Quality Gate 포함
5. 개발 실행 - Git Worktree + TDD

준비되셨으면 시작하겠습니다!
```

이후 AskUserQuestion으로 프로젝트 정보 수집 시작.

---

## 지원 기술 스택

### 백엔드

| Framework | 언어 | 인증 지원 |
|-----------|------|----------|
| FastAPI | Python | O |
| Express | TypeScript | O |
| Rails | Ruby | O |
| Django | Python | O |

### 프론트엔드

| Framework | 특징 | 인증 UI |
|-----------|------|---------|
| React + Vite | React 19, Zustand | O |
| Next.js | App Router | O |
| SvelteKit | Svelte 5 runes | O |
| Remix | Loader/Action 패턴 | O |

### 데이터베이스

| DB | Docker Template |
|----|-----------------|
| PostgreSQL | postgres |
| PostgreSQL + PGVector | postgres-pgvector |
| MySQL | mysql |
| MongoDB | mongodb |

---

## 파일 구조

```
~/.claude/skills/project-system/
├── SKILL.md                              # 메인 스킬 정의
│
├── scripts/                              # 실행 스크립트
│   ├── setup_backend.py                  # 백엔드 스캐폴딩
│   ├── setup_frontend.py                 # 프론트엔드 스캐폴딩
│   ├── setup_docker.py                   # Docker Compose 생성
│   ├── setup_mcp.py                      # MCP 서버 설정
│   ├── git_init.py                       # Git 초기화
│   ├── defense_in_depth.py               # 방어 시스템
│   ├── skill_evaluator.py                # 스킬 평가
│   └── three_tier_defense.py             # 3단계 방어
│
├── templates/                            # 코드 템플릿
│   ├── backend/
│   │   ├── fastapi/auth/                 # FastAPI 인증 코드
│   │   ├── express/auth/                 # Express 인증 코드
│   │   └── rails/auth/                   # Rails 인증 코드
│   ├── frontend/
│   │   ├── nextjs/auth/                  # Next.js 인증 UI
│   │   ├── react-vite/auth/              # React+Vite 인증 UI
│   │   ├── sveltekit/auth/               # SvelteKit 인증 UI
│   │   └── remix/auth/                   # Remix 인증 UI
│   ├── contracts/                        # 타입 정의, 계약
│   └── CLAUDE.template.md                # CLAUDE.md 템플릿
│
├── hooks/                                # 훅 스크립트
│   ├── defense_in_depth_hook.sh
│   ├── skill_evaluator_hook.sh
│   ├── session_init.py
│   └── README.md
│
├── references/
│   ├── phase1-planning/                  # Phase 1: 기획
│   │   ├── questions.md                  # 21개 질문
│   │   ├── conversation-rules.md         # 대화 규칙
│   │   └── templates/
│   │       ├── prd-template.md
│   │       ├── trd-template.md
│   │       ├── user-flow-template.md
│   │       ├── database-design-template.md
│   │       ├── design-system-template.md
│   │       └── coding-convention-template.md
│   ├── phase2-bootstrap/                 # Phase 2: 부트스트랩
│   │   ├── bootstrap-guide.md
│   │   ├── agents/
│   │   │   ├── backend-specialist.md
│   │   │   ├── frontend-specialist.md
│   │   │   ├── database-specialist.md
│   │   │   └── test-specialist.md
│   │   └── commands/
│   │       ├── orchestrate.md
│   │       └── integration-validator.md
│   ├── phase3-agents-md/                 # Phase 3: AGENTS.md 시스템
│   │   ├── agents-md-guide.md
│   │   └── AGENTS_md_Master_Prompt.md    # 마스터 프롬프트
│   ├── phase4-tasks/                     # Phase 4: 태스크 생성
│   │   ├── tasks-rules.md
│   │   └── tasks-generator-guide.md
│   └── phase5-development/               # Phase 5: TDD 개발
│       ├── tdd-workflow.md
│       └── plan-template.md              # 개별 기능 플랜 템플릿
```

---

## 스크립트 사용법

### 백엔드 스캐폴딩
```bash
python3 scripts/setup_backend.py -f <framework> -p ./backend [--with-auth]
# framework: fastapi, express, rails, django
```

### 프론트엔드 스캐폴딩
```bash
python3 scripts/setup_frontend.py -f <framework> -p ./frontend [--with-auth]
# framework: react-vite, nextjs, sveltekit, remix
```

### Docker Compose 생성
```bash
python3 scripts/setup_docker.py -t <template> -p .
# template: postgres, postgres-pgvector, postgres-redis, mysql, mongodb
```

### MCP 서버 설정
```bash
python3 scripts/setup_mcp.py -p .
```

### Git 초기화
```bash
python3 scripts/git_init.py -g fullstack -m "Initial commit"
```

