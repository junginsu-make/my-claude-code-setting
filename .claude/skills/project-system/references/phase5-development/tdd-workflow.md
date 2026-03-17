# Phase 5: TDD 기반 개발 워크플로우

TASKS.md가 생성된 후, 실제 개발을 진행하는 워크플로우입니다.

---

## 개요

### Contract-First TDD

본 프로젝트는 **계약 우선 개발(Contract-First Development)** 방식을 채택합니다.
BE/FE가 독립적으로 병렬 개발하면서도 통합 시 호환성을 보장합니다.

```
┌─────────────────────────────────────────────────────────┐
│  1. API 계약 정의 (OpenAPI/TypeScript Interface)        │
│                    ↓                                    │
│  2. BE/FE 각각 테스트 작성 (RED)                        │
│                    ↓                                    │
│  3. 병렬 구현 (GREEN) - Git Worktree 활용               │
│                    ↓                                    │
│  4. 통합 테스트 (E2E)                                   │
│                    ↓                                    │
│  5. Quality Gate 통과 후 병합                           │
└─────────────────────────────────────────────────────────┘
```

---

## Git Worktree 전략

### Phase별 Worktree 운영

| Phase | 브랜치 | Worktree 경로 | 설명 |
|-------|--------|--------------|------|
| Phase 0 | main | 프로젝트 루트 | 셋업, 계약 정의 |
| Phase 1 | phase/1-auth | ../project-phase1-auth | 인증 기능 |
| Phase 2 | phase/2-core | ../project-phase2-core | 핵심 기능 |

### Worktree 생성 명령어

```bash
# Phase 1 Worktree 생성
git worktree add ../project-phase1-auth -b phase/1-auth

# 작업 디렉토리 이동
cd ../project-phase1-auth

# 작업 완료 후 main에서 병합
cd ../project-main
git checkout main
git merge phase/1-auth

# Worktree 정리
git worktree remove ../project-phase1-auth
```

### BE/FE 병렬 작업

```bash
# BE 워크트리
git worktree add ../project-phase1-auth-be -b phase/1-auth-be

# FE 워크트리 (동시에)
git worktree add ../project-phase1-auth-fe -b phase/1-auth-fe

# 각 워크트리에서 독립 작업
# BE: ../project-phase1-auth-be
# FE: ../project-phase1-auth-fe

# 완료 후 순차 병합
git checkout main
git merge phase/1-auth-be
git merge phase/1-auth-fe
```

---

## TDD 사이클

### RED → GREEN → REFACTOR

```
┌─────────────────────────────────────────────────────────┐
│  RED    → 실패하는 테스트 먼저 작성                      │
│           - 구현 없이 테스트만 작성                      │
│           - 반드시 FAILED 확인 후 커밋                   │
│                                                         │
│  GREEN  → 테스트를 통과하는 최소한의 코드 구현           │
│           - 테스트 통과만을 목표로 최소 구현             │
│           - 반드시 PASSED 확인 후 커밋                   │
│                                                         │
│  REFACTOR → 테스트 통과 유지하며 코드 개선               │
│           - 중복 제거, 구조 개선                         │
│           - 테스트 계속 통과 확인                        │
└─────────────────────────────────────────────────────────┘
```

### Phase 0, T0.5.x (테스트 작성 단계)

```bash
# 1. 테스트 파일만 작성
# tests/api/test_auth.py

# 2. 테스트 실행 → 반드시 실패해야 함
pytest tests/api/test_auth.py -v
# Expected: FAILED (구현이 없으므로)

# 3. RED 상태로 커밋
git add tests/
git commit -m "test: T0.5.2 인증 API 테스트 작성 (RED)"
```

**T0.5.x에서 금지:**
- 구현 코드 작성
- 테스트가 통과하는 상태로 커밋

### Phase 1+, T*.1/T*.2 (구현 단계)

```bash
# 1. RED 확인 (테스트가 이미 있어야 함!)
pytest tests/api/test_auth.py -v
# Expected: FAILED

# 2. 구현 코드 작성
# app/api/routes/auth.py

# 3. GREEN 확인
pytest tests/api/test_auth.py -v
# Expected: PASSED

# 4. GREEN 상태로 커밋
git add .
git commit -m "feat: T1.1 인증 API 구현 (GREEN)"
```

**T*.1/T*.2에서 금지:**
- 새 테스트 파일 작성 (이미 T0.5.x에서 작성됨)
- RED 상태에서 커밋
- 테스트 실행 없이 커밋

---

## Quality Gate

### 병합 전 필수 체크

모든 태스크 완료 시 다음을 통과해야 합니다:

```bash
# 1. 빌드 확인
npm run build            # 프론트엔드
python -m py_compile app/*.py  # 백엔드

# 2. 테스트 실행
npm run test             # 프론트엔드
pytest -v                # 백엔드

# 3. 린트 확인
npm run lint             # 프론트엔드
ruff check .             # 백엔드

# 4. 타입 체크
npm run type-check       # 프론트엔드
mypy app/                # 백엔드

# 5. 커버리지 확인
pytest --cov=app --cov-fail-under=80
```

### Quality Gate 체크리스트

```
+---------------------------------------------------------------+
|  Quality Gate (병합 전 필수 통과)                               |
+---------------------------------------------------------------+
|  [ ] 빌드 성공                                                 |
|  [ ] 모든 테스트 통과                                          |
|  [ ] 린트 통과                                                 |
|  [ ] 타입 체크 통과                                            |
|  [ ] 커버리지 >= 80%                                           |
+---------------------------------------------------------------+
```

---

## 오케스트레이터 워크플로우

### /orchestrate 명령 실행 시

1. **컨텍스트 파악**
   - docs/planning/06-tasks.md 읽기
   - 현재 진행 상태 확인

2. **태스크 분석**
   - Phase 번호 추출
   - 담당 에이전트 결정
   - 의존성 확인

3. **서브에이전트 호출**
   - Task 도구로 전문가 에이전트 호출
   - Git Worktree + TDD 정보 전달

4. **결과 확인**
   - TDD 상태 확인 (RED → GREEN)
   - Quality Gate 확인
   - 사용자에게 병합 승인 요청

### 병렬 실행

의존성이 없는 태스크는 동시에 여러 에이전트를 호출:

```
[동시 호출]
Task(subagent_type="backend-specialist", prompt="Phase 1, T1.1...")
Task(subagent_type="frontend-specialist", prompt="Phase 1, T1.2...")
```

---

## 목표 달성 루프 (Ralph Wiggum 패턴)

에이전트는 테스트가 실패하면 성공할 때까지 자동으로 재시도합니다:

```
┌─────────────────────────────────────────────────────────┐
│  while (테스트 실패 || 빌드 실패) {                       │
│    1. 에러 메시지 분석                                  │
│    2. 원인 파악                                         │
│    3. 코드 수정                                         │
│    4. 테스트 재실행                                     │
│  }                                                      │
│  → GREEN 달성 시 루프 종료                              │
└─────────────────────────────────────────────────────────┘
```

### 안전장치 (무한 루프 방지)

- **3회 연속 동일 에러** → 사용자에게 도움 요청
- **10회 시도 초과** → 작업 중단 및 상황 보고
- **새로운 에러 발생** → 카운터 리셋 후 계속

---

## Phase 완료 후 절차

### 1. 완료 보고

```
## T1.1 인증 API 완료 보고

**TDD 결과**:
- RED: tests/api/test_auth.py 작성 완료
- GREEN: app/api/routes/auth.py 구현 완료
- 테스트 결과: 5/5 통과

**Quality Gate**:
- [x] 빌드 성공
- [x] 테스트 통과
- [x] 린트 통과
- [x] 타입 체크 통과
- [x] 커버리지 82%
```

### 2. 병합 승인 요청

```
main 브랜치에 병합할까요?
- [Y] 병합 진행
- [N] 추가 작업 필요
```

### 3. 병합 및 정리

```bash
# 사용자 승인 후 실행
git checkout main
git merge phase/1-auth --no-ff
git worktree remove ../project-phase1-auth
git branch -d phase/1-auth
```

---

## 난관 극복 시 기록 (Lessons Learned)

어려운 문제를 해결했을 때 CLAUDE.md에 기록:

```markdown
### [YYYY-MM-DD] 제목 (키워드1, 키워드2)
- **상황**: 무엇을 하려다
- **문제**: 어떤 에러가 발생
- **원인**: 왜 발생했는지
- **해결**: 어떻게 해결
- **교훈**: 다음에 주의할 점
```

---

## 개발 시작 체크리스트

개발 시작 전 확인사항:

```
[ ] Phase 1-4 완료 확인
    - [ ] 기획 문서 (PRD, TRD, User Flow, DB Design, Design System)
    - [ ] AI 에이전트 팀 설치 (.claude/agents/)
    - [ ] AGENTS.md 시스템 생성
    - [ ] TASKS.md 생성

[ ] 개발 환경 준비
    - [ ] Docker 실행 중
    - [ ] 의존성 설치 완료
    - [ ] 환경 변수 설정 완료

[ ] Git 준비
    - [ ] main 브랜치 최신 상태
    - [ ] 커밋 전 훅 설정 (optional)

개발 시작!
→ /orchestrate T1.1
```
