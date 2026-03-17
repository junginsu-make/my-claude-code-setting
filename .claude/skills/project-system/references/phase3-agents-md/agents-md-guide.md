# Phase 3: AGENTS.md 시스템 가이드

프로젝트의 **거버넌스 규칙**을 정의하는 AGENTS.md 파일 시스템을 설계합니다.

> `.claude/agents/` (AI 에이전트 역할)과는 다른 목적의 파일입니다.
> AGENTS.md는 **프로젝트 전체의 규칙과 제약사항**을 정의합니다.

---

## 핵심 철학

1. **500라인 제한**: 모든 AGENTS.md 파일은 가독성과 토큰 효율성을 위해 **500라인 미만**으로 유지
2. **이모지 금지**: 컨텍스트 낭비를 막기 위해 이모지와 불필요한 서술 금지
3. **중앙 통제 & 위임**: 루트 파일은 "관제탑"이며, 상세 구현은 하위 파일로 위임
4. **기계 가독성**: 실행 가능한 명령어와 구체적 지침 제공

---

## 파일 구조

```
프로젝트/
├── AGENTS.md                  # 루트: 프로젝트 전체 규칙
├── backend/
│   └── AGENTS.md              # 백엔드 전용 규칙
├── frontend/
│   └── AGENTS.md              # 프론트엔드 전용 규칙
└── core/                      # 핵심 비즈니스 로직
    └── AGENTS.md              # 도메인 전용 규칙
```

---

## 루트 AGENTS.md 필수 섹션

### 1. Project Context & Operations

```markdown
## Project Context

- **비즈니스 목표**: {한 줄 설명}
- **Tech Stack**: {백엔드} + {프론트엔드} + {DB}
- **Target Users**: {대상 사용자}

## Operational Commands

# 개발 서버 실행
npm run dev          # 프론트엔드
uvicorn app.main:app --reload  # 백엔드

# 테스트 실행
npm run test         # 프론트엔드
pytest -v            # 백엔드

# 빌드
npm run build        # 프론트엔드
```

### 2. Golden Rules (황금 규칙)

```markdown
## Golden Rules

### Immutable (절대 변경 불가)

- 프로덕션 DB에 직접 쿼리 실행 금지
- API 키 하드코딩 금지
- 인증 없이 민감 API 접근 금지

### Do's

- 모든 API 엔드포인트에 입력 검증 적용
- 새 기능은 TDD로 개발
- 커밋 전 린트 및 타입 체크 통과
- 환경 변수는 .env 파일로 관리

### Don'ts

- SQL 직접 문자열 조합 금지 (ORM 사용)
- console.log 프로덕션 코드에 남기지 않음
- 테스트 없이 PR 생성 금지
- node_modules, .env 파일 커밋 금지
```

### 3. Standards & References

```markdown
## Standards

### 코딩 컨벤션

- **백엔드**: PEP 8, Black formatter
- **프론트엔드**: ESLint + Prettier
- **타입**: Python - type hints, TypeScript - strict mode

### Git 전략

- **브랜치**: main ← develop ← feature/*, fix/*
- **커밋 메시지**: Conventional Commits
  - feat: 새 기능
  - fix: 버그 수정
  - refactor: 리팩토링
  - docs: 문서
  - test: 테스트

### Maintenance Policy

규칙과 코드의 괴리가 발생하면 AGENTS.md 업데이트를 제안하세요.
```

### 4. Context Map (Action-Based Routing)

```markdown
## Context Map

- **[API Routes 수정 (BE)](./backend/AGENTS.md)** — Route Handler 작성 및 서버 로직 수정 시
- **[UI 컴포넌트 (FE)](./frontend/AGENTS.md)** — React 컴포넌트 및 스타일링 작업 시
- **[DB 스키마 (Models)](./backend/app/models/AGENTS.md)** — 데이터 모델 및 마이그레이션 시
- **[테스트 작성](./tests/AGENTS.md)** — 테스트 케이스 추가 시
```

**Context Map 규칙:**
- 표(Table) 형식 금지
- 이모지 사용 금지
- 형식: `- **[트리거/작업 영역](경로)** — 설명`

---

## 하위 AGENTS.md 생성 기준

단순 폴더 매핑이 아닌, **고유한 컨텍스트가 발생하는 지점**을 식별합니다:

### 생성 조건 (Signal)

| Signal | 설명 | 예시 |
|--------|------|------|
| **Dependency Boundary** | 별도 package.json 등 존재 | frontend/, mobile/ |
| **Framework Boundary** | 기술 스택 전환점 | backend/ (Python), frontend/ (TypeScript) |
| **Logical Boundary** | 비즈니스 로직 밀도 높은 핵심 모듈 | features/billing, core/engine |

### 하위 파일 필수 섹션

```markdown
## Module Context

- **역할**: {이 모듈의 책임}
- **의존성**: {연관 모듈}
- **데이터 흐름**: {입력 → 처리 → 출력}

## Tech Stack & Constraints

- **프레임워크**: {해당 폴더 전용 기술}
- **버전 제약**: {특정 버전 요구사항}
- **제한사항**: {여기서만 사용하는 규칙}

## Implementation Patterns

### 파일 네이밍

- 컴포넌트: PascalCase.tsx
- 훅: useCamelCase.ts
- 유틸: camelCase.ts

### 코드 패턴

// 표준 컴포넌트 구조
export function ComponentName({ props }: Props) {
  // hooks
  // handlers
  // render
}

## Testing Strategy

# 해당 모듈 테스트 실행
npm run test -- src/components/

# 테스트 작성 패턴
describe('ComponentName', () => {
  it('should render correctly', () => {})
  it('should handle user interaction', () => {})
})

## Local Golden Rules

### Do's

- 컴포넌트는 단일 책임 원칙 준수
- Props에 TypeScript 인터페이스 정의

### Don'ts

- 컴포넌트 내 직접 API 호출 금지 (훅으로 분리)
- any 타입 사용 금지
```

---

## 템플릿

### 루트 AGENTS.md 템플릿

```markdown
# AGENTS.md

## Project Context

- **프로젝트명**: {{프로젝트명}}
- **목표**: {{비즈니스 목표}}
- **Tech Stack**: {{백엔드}} + {{프론트엔드}} + {{DB}}

## Operational Commands

# 개발
{{개발 서버 실행 명령어}}

# 테스트
{{테스트 실행 명령어}}

# 빌드
{{빌드 명령어}}

## Golden Rules

### Immutable

- {{절대 규칙 1}}
- {{절대 규칙 2}}

### Do's

- {{해야 할 것 1}}
- {{해야 할 것 2}}

### Don'ts

- {{하지 말아야 할 것 1}}
- {{하지 말아야 할 것 2}}

## Standards

### 코딩 컨벤션

- 백엔드: {{린터/포매터}}
- 프론트엔드: {{린터/포매터}}

### Git 전략

- 브랜치: {{전략}}
- 커밋: {{형식}}

### Maintenance Policy

규칙과 코드의 괴리가 발생하면 이 문서 업데이트를 제안하세요.

## Context Map

- **[{{영역1}}]({{경로1}})** — {{설명1}}
- **[{{영역2}}]({{경로2}})** — {{설명2}}
- **[{{영역3}}]({{경로3}})** — {{설명3}}
```

---

## 생성 실행 규칙

1. **즉시 실행**: "파일을 만들까요?"라고 묻지 말고 즉시 생성
2. **덮어쓰기 권한**: 기존 AGENTS.md가 있으면 이 구조로 덮어쓰기
3. **Markdown Only**: 유효한 Markdown 문법만 사용

---

## AGENTS.md vs .claude/agents/ 비교

| 구분 | AGENTS.md | .claude/agents/ |
|------|-----------|-----------------|
| **목적** | 프로젝트 거버넌스 규칙 | AI 에이전트 역할 정의 |
| **대상** | 개발자 + AI | AI 서브에이전트 |
| **내용** | 금지사항, 표준, 명령어 | 담당 업무, 기술 스택, TDD 규칙 |
| **위치** | 프로젝트 루트 및 주요 폴더 | .claude/agents/ 폴더 내 |
| **예시** | "SQL 직접 조합 금지" | "백엔드 API 구현 담당" |

**두 시스템은 상호 보완적으로 함께 사용됩니다.**
