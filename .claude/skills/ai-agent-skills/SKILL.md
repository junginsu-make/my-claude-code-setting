---
name: ai-agent-skills
description: >
  Synapse AI 에이전트 전체 라이프사이클 관리. 생성(create), 검증(verify), 테스트(test),
  코드리뷰(review), 자동수정(fix), 자동배포(auto). "에이전트 만들어", "agent create",
  "에이전트 검증", "agent verify", "에이전트 추가", "새 에이전트" 키워드에 트리거.
argument-hint: "<help|create|verify|test|review|fix|auto> [agent-name]"
---

# Synapse AI Agent Skills

AI 에이전트의 생성부터 배포까지 전체 워크플로우를 자동화한다.

## 표준 문서 위치

- **에이전트 표준 계약**: `docs/ai-agent-skills/01-agent-contract.md`
- **Skill Manifest 시스템**: `docs/ai-agent-skills/02-skill-manifest-system.md`
- **검증 체크리스트**: 이 스킬의 `references/verification-checklist.md`
- **코드 패턴 카탈로그**: 이 스킬의 `references/pattern-catalog.md`
- **에이전트 표준 계약 (스킬용)**: 이 스킬의 `references/agent-contract.md`
- **프론트엔드 연동 규칙**: 이 스킬의 `references/frontend-integration.md`

## 모드 선택

인자를 파싱하여 모드를 결정한다:

| 인자 | 모드 | 설명 |
|------|------|------|
| `help` | Help | 이 스킬의 전체 사용법 안내 |
| `create <name>` | Create | 표준 구조로 새 에이전트 생성 |
| `verify [name]` | Verify | 표준 계약 준수 검증 (name 생략 시 전체) |
| `test <name>` | Test | TDD 워크플로우 (테스트 생성+실행) |
| `review <name>` | Review | 아키텍처 기준 코드 리뷰 |
| `fix <name>` | Fix | CRITICAL/HIGH 이슈 자동 수정 |
| `auto <name>` | Auto | verify→test→review→commit→push 자동 파이프라인 |

인자가 없으면 AskUserQuestion으로 모드를 물어본다.

---

## Mode: Help

이 스킬의 사용법을 안내한다. 아래 내용을 **그대로** 사용자에게 출력한다:

```
# /ai-agent-skills — Synapse AI 에이전트 자동화 스킬

Synapse 플랫폼의 AI 에이전트를 생성, 검증, 테스트, 리뷰, 수정, 배포하는 통합 도구입니다.

## 사용 가능한 명령어

| 명령어 | 설명 |
|--------|------|
| `/ai-agent-skills help` | 이 도움말을 표시합니다 |
| `/ai-agent-skills create <name>` | 새 에이전트를 표준 구조로 생성합니다 |
| `/ai-agent-skills verify` | 전체 에이전트의 표준 준수를 검증합니다 |
| `/ai-agent-skills verify <name>` | 특정 에이전트만 검증합니다 |
| `/ai-agent-skills test <name>` | 에이전트 테스트를 생성하고 실행합니다 |
| `/ai-agent-skills review <name>` | 아키텍처 기준으로 코드를 리뷰합니다 |
| `/ai-agent-skills fix <name>` | CRITICAL/HIGH 이슈를 자동 수정합니다 |
| `/ai-agent-skills auto <name>` | 검증→테스트→리뷰→커밋→푸시 자동 파이프라인 |

## 예시

### 새 에이전트 만들기
```
/ai-agent-skills create email_sender
```
→ agent_name, display_name, capabilities 등을 물어본 뒤 4개 파일 자동 생성

### 기존 에이전트 검증
```
/ai-agent-skills verify text_toolkit
```
→ 15개 항목 체크 (CRITICAL/HIGH/MEDIUM/LOW) → 등급 보고 (A~F)

### 문제 자동 수정
```
/ai-agent-skills fix text_toolkit
```
→ Pattern B→A 변환, 상태 관리 추가, manifest 생성 등 자동 처리

### 자동 파이프라인
```
/ai-agent-skills auto email_sender
```
→ Gate 1(verify) → Gate 2(test) → Gate 3(review) → commit → push

## 검증 등급 기준

| 등급 | 조건 |
|------|------|
| A | CRITICAL 0, HIGH 0-1 |
| B | CRITICAL 0, HIGH 1-2 |
| C | CRITICAL 0, HIGH 3+ |
| F | CRITICAL 1+ |

## 에이전트 표준 구조

```
backend/app/agents/<name>/
├── __init__.py              # Agent 클래스 export
├── agent.py                 # BaseAgent 상속 + Pattern A
├── services.py              # 비즈니스 로직
└── skill-manifest.json      # 워크플로우 메타데이터
```

## 관련 문서

- 표준 계약: docs/ai-agent-skills/01-agent-contract.md
- Skill Manifest: docs/ai-agent-skills/02-skill-manifest-system.md
- 조직+AI 아키텍처: docs/ai-agent-skills/03-hybrid-organization.md
```

Help 모드에서는 위 내용만 출력하고 다른 작업은 하지 않는다.

---

## Mode: Create

새 에이전트를 표준 구조로 생성한다.

### Step 1: 정보 수집

AskUserQuestion으로 아래를 수집한다:
- `agent_name`: snake_case (예: `email_sender`)
- `display_name`: 한국어 (예: `이메일 발송기`)
- `description`: 1-2줄 설명
- `capabilities`: 쉼표 구분 리스트 (예: `send_email, draft_email, check_inbox`)
- `category`: 분류 (예: `Communication`)

### Step 2: ID 계산

```bash
ls backend/app/agents/*/agent.py | wc -l
```
현재 에이전트 수를 확인하고 다음 번호를 할당한다 (현재 a0~a16이므로 a17부터).

### Step 3: 파일 생성

이 스킬의 `templates/` 디렉토리에서 템플릿을 읽고 변수를 치환하여 4개 파일을 생성한다:

1. 템플릿 읽기: `templates/agent.py.md`, `templates/services.py.md`, `templates/init.py.md`, `templates/skill-manifest.json.md`
2. 변수 치환: `{{AGENT_NAME}}`, `{{AGENT_CLASS}}`, `{{AGENT_ID}}`, `{{DISPLAY_NAME}}`, `{{DESCRIPTION}}`, `{{CAPABILITIES}}`, `{{CATEGORY}}`, `{{CAPABILITY_MAP_ENTRIES}}`, `{{SERVICE_CLASS}}`
3. 파일 쓰기:
   - `backend/app/agents/{{AGENT_NAME}}/__init__.py`
   - `backend/app/agents/{{AGENT_NAME}}/agent.py`
   - `backend/app/agents/{{AGENT_NAME}}/services.py`
   - `backend/app/agents/{{AGENT_NAME}}/skill-manifest.json`

변수 변환 규칙:
- `AGENT_CLASS`: agent_name을 PascalCase + "Agent" (예: `email_sender` → `EmailSenderAgent`)
- `SERVICE_CLASS`: agent_name을 PascalCase + "Service" (예: `email_sender` → `EmailSenderService`)
- `CAPABILITY_MAP_ENTRIES`: 각 capability에 대해 `"cap_name": "handle_cap_name"` 생성

### Step 4: 테스트 파일 생성

`templates/test_agent.py.md`에서 테스트 파일을 생성한다:
- `backend/tests/test_{{AGENT_NAME}}.py`

### Step 5: 검증

```bash
cd backend && python3 -c "from app.agents.{{AGENT_NAME}} import {{AGENT_CLASS}}; a = {{AGENT_CLASS}}(); print(f'OK: {a.agent_id} with {len(a.capabilities)} capabilities')"
```

### Step 6: 보고

생성된 파일 목록과 다음 단계를 안내한다:
1. `services.py`에서 TODO 메서드를 구현
2. `/ai-agent-skills test {{AGENT_NAME}}`으로 테스트
3. `/ai-agent-skills auto {{AGENT_NAME}}`으로 자동 파이프라인 실행

---

## Mode: Verify

에이전트가 표준 계약을 준수하는지 검증한다.

### Step 1: 대상 결정

- `name` 지정 시: 해당 에이전트만 검증
- `name` 생략 시: `backend/app/agents/*/agent.py`의 모든 에이전트 검증

### Step 2: 검증 실행

`references/verification-checklist.md`를 읽고 각 항목을 체크한다.

에이전트별로 아래 파일을 읽는다:
- `backend/app/agents/<name>/agent.py`
- `backend/app/agents/<name>/__init__.py`
- `backend/app/agents/<name>/skill-manifest.json` (존재 여부)

### Step 3: 검증 항목

| ID | 심각도 | 항목 |
|----|--------|------|
| V01 | CRITICAL | execute()에 `_set_status(AgentStatus.BUSY)` |
| V02 | CRITICAL | 성공 시 `_set_status(AgentStatus.IDLE)` |
| V03 | CRITICAL | 실패 시 `_set_status(AgentStatus.ERROR)` |
| V04 | CRITICAL | try/except → `AgentResult(success=False)` |
| V05 | HIGH | `_CAPABILITY_METHOD_MAP` 모듈 레벨 |
| V06 | HIGH | `skill-manifest.json` 존재 |
| V07 | HIGH | manifest JSON 유효 |
| V08 | HIGH | manifest ↔ agent capabilities 일치 |
| V09 | MEDIUM | `task.context` 추출 |
| V10 | MEDIUM | 서비스 메서드에 ctx 전달 |
| V11 | MEDIUM | `__init__.py` export |
| V12 | LOW | `set_provider()` 메서드 |
| V13 | LOW | docstring 존재 |
| V14 | LOW | agent.py 200줄 이하 |
| V15 | LOW | services.py 800줄 이하 |

### Step 4: 결과 보고

전체 에이전트 검증 시 요약 테이블:

```
Agent              | CRIT | HIGH | MED | LOW | Grade
hr_agent           |  0   |  0   |  0  |  1  | A
text_toolkit       |  2   |  1   |  2  |  0  | F
...
Total: X/Y agents passing (CRITICAL=0)
```

등급: A(이슈 0-1), B(HIGH 1-2), C(MEDIUM 다수), F(CRITICAL 존재)

---

## Mode: Test

에이전트의 테스트를 생성하고 실행한다.

### Step 1: 테스트 파일 확인

```bash
ls backend/tests/test_*<agent_name>*.py 2>/dev/null
```

### Step 2: 테스트 파일 생성 (없는 경우)

`templates/test_agent.py.md` 템플릿에서 생성한다.

### Step 3: 테스트 실행

```bash
cd backend && python3 -m pytest tests/test_<agent_name>.py -v --tb=short
```

### Step 4: 결과 보고

pytest 출력을 그대로 보여주고, 통과/실패 수를 요약한다.

---

## Mode: Review

에이전트 코드를 아키텍처 기준으로 리뷰한다.

### Step 1: 파일 읽기

- `backend/app/agents/<name>/agent.py`
- `backend/app/agents/<name>/services.py`
- `backend/app/agents/<name>/skill-manifest.json`

### Step 2: 검토 기준

`references/agent-contract.md`를 읽고 아래를 검토:

1. **불변성**: task.input_data, task.context 직접 변경 없음
2. **Async**: 모든 I/O 메서드가 async
3. **에러 처리**: service 메서드에 try/except, 의미 있는 에러 메시지
4. **타입 힌트**: 모든 메서드 시그니처에 반환 타입
5. **파일 크기**: agent.py < 200줄, services.py < 800줄
6. **보안**: 하드코딩된 시크릿 없음
7. **독립성**: 다른 에이전트 직접 import 없음
8. **디스패치 완전성**: capabilities 리스트의 모든 항목이 MAP에 존재
9. **Output 형식**: Normalized Output 구조 준수 여부

### Step 3: 결과 보고

파일별로 findings를 CRITICAL/HIGH/MEDIUM/LOW로 분류하여 보고.

---

## Mode: Fix

CRITICAL/HIGH 이슈를 자동으로 수정한다.

### Step 1: Verify 실행

내부적으로 Verify 모드를 실행하여 이슈 목록을 수집한다.

### Step 2: 자동 수정

`references/pattern-catalog.md`를 읽고 아래 수정을 적용:

| 이슈 | 수정 방법 |
|------|----------|
| 상태 관리 없음 | execute()를 BUSY/IDLE/ERROR 패턴으로 래핑 |
| Pattern B → A | `_get_dispatch()` → `_CAPABILITY_METHOD_MAP` 변환 |
| context 미추출 | `_dispatch()`에 `ctx = task.context or {}` 추가 |
| manifest 없음 | capabilities에서 skill-manifest.json 자동 생성 |

### Step 3: 재검증

수정 후 Verify를 다시 실행하여 수정 확인.

### Step 4: diff 표시

변경된 내용을 보여준다.

---

## Mode: Auto

검증~배포까지 전체 파이프라인을 자동 실행한다.

### Gate 1: Verify

```
/ai-agent-skills verify <name>
→ CRITICAL 0개, HIGH ≤ 2개여야 통과
```

### Gate 2: Test

```
/ai-agent-skills test <name>
→ failures 0개여야 통과
```

### Gate 3: Review

```
/ai-agent-skills review <name>
→ CRITICAL findings 0개여야 통과
```

### Gate 4: Commit

모든 게이트 통과 시:

```bash
git add backend/app/agents/<name>/
git add backend/tests/test_<name>.py
git commit -m "feat: add <name> agent with N capabilities

- Capabilities: cap1, cap2, cap3
- Skill manifest included
- N tests passing

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
```

### Gate 5: Push (선택)

AskUserQuestion으로 push 여부를 물어본다.

```bash
git push origin <current-branch>
```

### 실패 시

어느 게이트에서 실패했는지 명확히 보고하고 중단한다.
`/ai-agent-skills fix <name>`으로 자동 수정을 제안한다.

---

## 참고

- 에이전트 표준 계약 전문: `docs/ai-agent-skills/01-agent-contract.md`
- 현재 에이전트 목록: `backend/app/agents/` 아래 16개 폴더
- BaseAgent 정의: `backend/app/core/base_agent.py`
- 자동 디스커버리: `backend/app/main.py` → `_discover_agents()`
