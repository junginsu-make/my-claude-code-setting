---
name: eval-harness
description: 평가 주도 개발(EDD) 원칙을 구현하는 Claude Code 세션용 공식 평가 프레임워크
tools: Read, Write, Edit, Bash, Grep, Glob
---

# 평가 하네스 스킬

평가 주도 개발(EDD) 원칙을 구현하는 Claude Code 세션용 공식 평가 프레임워크입니다.

## 철학

평가 주도 개발은 평가를 "AI 개발의 단위 테스트"로 취급합니다:
- 구현 전에 기대 동작을 정의
- 개발 중 지속적으로 평가 실행
- 각 변경마다 회귀를 추적
- 신뢰성 측정을 위해 pass@k 지표 사용

## 평가 유형

### 기능 평가
Claude가 이전에 할 수 없었던 것을 할 수 있는지 테스트합니다:
```markdown
[CAPABILITY EVAL: feature-name]
Task: Description of what Claude should accomplish
Success Criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] Criterion 3
Expected Output: Description of expected result
```

### 회귀 평가
변경 사항이 기존 기능을 손상시키지 않는지 확인합니다:
```markdown
[REGRESSION EVAL: feature-name]
Baseline: SHA or checkpoint name
Tests:
  - existing-test-1: PASS/FAIL
  - existing-test-2: PASS/FAIL
  - existing-test-3: PASS/FAIL
Result: X/Y passed (previously Y/Y)
```

## 채점기 유형

### 1. 코드 기반 채점기
코드를 사용한 결정적 검사:
```bash
# Check if file contains expected pattern
grep -q "export function handleAuth" src/auth.ts && echo "PASS" || echo "FAIL"

# Check if tests pass
npm test -- --testPathPattern="auth" && echo "PASS" || echo "FAIL"

# Check if build succeeds
npm run build && echo "PASS" || echo "FAIL"
```

### 2. 모델 기반 채점기
Claude를 사용하여 개방형 출력을 평가합니다:
```markdown
[MODEL GRADER PROMPT]
Evaluate the following code change:
1. Does it solve the stated problem?
2. Is it well-structured?
3. Are edge cases handled?
4. Is error handling appropriate?

Score: 1-5 (1=poor, 5=excellent)
Reasoning: [explanation]
```

### 3. 사람 채점기
수동 리뷰를 위해 플래그합니다:
```markdown
[HUMAN REVIEW REQUIRED]
Change: Description of what changed
Reason: Why human review is needed
Risk Level: LOW/MEDIUM/HIGH
```

## 지표

### pass@k
"At least one success in k attempts"
- pass@1: First attempt success rate
- pass@3: Success within 3 attempts
- Typical target: pass@3 > 90%

### pass^k
"All k trials succeed"
- Higher bar for reliability
- pass^3: 3 consecutive successes
- Use for critical paths

## 평가 워크플로우

### 1. 정의 (코딩 전)
```markdown
## EVAL DEFINITION: feature-xyz

### 기능 평가
1. Can create new user account
2. Can validate email format
3. Can hash password securely

### 회귀 평가
1. Existing login still works
2. Session management unchanged
3. Logout flow intact

### Success Metrics
- pass@3 > 90% for capability evals
- pass^3 = 100% for regression evals
```

### 2. 구현
정의된 평가를 통과하는 코드를 작성합니다.

### 3. 평가
```bash
# Run capability evals
[Run each capability eval, record PASS/FAIL]

# Run regression evals
npm test -- --testPathPattern="existing"

# Generate report
```

### 4. 보고
```markdown
EVAL REPORT: feature-xyz
========================

Capability Evals:
  create-user:     PASS (pass@1)
  validate-email:  PASS (pass@2)
  hash-password:   PASS (pass@1)
  Overall:         3/3 passed

Regression Evals:
  login-flow:      PASS
  session-mgmt:    PASS
  logout-flow:     PASS
  Overall:         3/3 passed

Metrics:
  pass@1: 67% (2/3)
  pass@3: 100% (3/3)

Status: READY FOR REVIEW
```

## 통합 패턴

### 구현 전
```
/eval define feature-name
```
평가 정의 파일 생성 위치: `.claude/evals/feature-name.md`

### 구현 중
```
/eval check feature-name
```
현재 평가를 실행하고 상태를 보고합니다

### 구현 후
```
/eval report feature-name
```
전체 평가 보고서를 생성합니다

## 평가 저장

프로젝트에 평가를 저장합니다:
```
.claude/
  evals/
    feature-xyz.md      # Eval definition
    feature-xyz.log     # Eval run history
    baseline.json       # Regression baselines
```

## 모범 사례

1. **코딩 전에 평가를 정의** - 성공 기준에 대한 명확한 사고를 강제
2. **평가를 자주 실행** - 회귀를 조기에 발견
3. **시간에 따른 pass@k 추적** - 신뢰성 추세 모니터링
4. **가능하면 코드 채점기 사용** - 결정적 > 확률적
5. **보안은 사람이 리뷰** - 보안 검사를 완전히 자동화하지 않음
6. **평가를 빠르게 유지** - 느린 평가는 실행되지 않음
7. **코드와 함께 평가를 버전 관리** - 평가는 일급 산출물

## 예제: 인증 추가

```markdown
## EVAL: add-authentication

### Phase 1: Define (10 min)
Capability Evals:
- [ ] User can register with email/password
- [ ] User can login with valid credentials
- [ ] Invalid credentials rejected with proper error
- [ ] Sessions persist across page reloads
- [ ] Logout clears session

Regression Evals:
- [ ] Public routes still accessible
- [ ] API responses unchanged
- [ ] Database schema compatible

### Phase 2: Implement (varies)
[Write code]

### Phase 3: Evaluate
Run: /eval check add-authentication

### Phase 4: Report
EVAL REPORT: add-authentication
==============================
Capability: 5/5 passed (pass@3: 100%)
Regression: 3/3 passed (pass^3: 100%)
Status: SHIP IT
```
