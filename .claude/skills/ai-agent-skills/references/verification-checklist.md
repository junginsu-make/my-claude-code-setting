# Verification Checklist

에이전트 검증 시 사용하는 체크리스트. 각 항목은 agent.py, services.py, skill-manifest.json을 읽고 확인한다.

## CRITICAL (하나라도 실패 시 Grade F)

### V01: execute()에 _set_status(BUSY) 호출
- 확인: `agent.py`에서 `execute` 메서드 내부에 `self._set_status(AgentStatus.BUSY)` 존재
- Grep: `_set_status.*BUSY`

### V02: 성공 시 _set_status(IDLE)
- 확인: `execute` 또는 `_dispatch` 후 `self._set_status(AgentStatus.IDLE)` 존재
- Grep: `_set_status.*IDLE`

### V03: 실패 시 _set_status(ERROR)
- 확인: except 블록 내에 `self._set_status(AgentStatus.ERROR)` 존재
- Grep: `_set_status.*ERROR`

### V04: try/except → AgentResult(success=False)
- 확인: execute()에 try/except 구조, except에서 AgentResult(success=False) 반환
- Grep: `AgentResult.*success=False`

## HIGH (2개 초과 시 Grade C 이하)

### V05: _CAPABILITY_METHOD_MAP 모듈 레벨 정의
- 확인: `agent.py` 최상위에 `_CAPABILITY_METHOD_MAP: dict[str, str]` 정의
- Grep: `^_CAPABILITY_METHOD_MAP`
- 실패 사유: `_get_dispatch()` 인스턴스 메서드 사용 (Pattern B)

### V06: skill-manifest.json 존재
- 확인: `backend/app/agents/<name>/skill-manifest.json` 파일 존재
- 명령: `test -f backend/app/agents/<name>/skill-manifest.json`

### V07: skill-manifest.json 유효한 JSON
- 확인: `python3 -c "import json; json.load(open('path'))"`
- manifest_version, agent_id, capabilities 필드 존재

### V08: manifest capabilities ↔ agent capabilities 일치
- 확인: manifest의 capabilities[].name 리스트 == agent의 capabilities 튜플
- 불일치 시: 어떤 항목이 빠졌거나 추가인지 보고

## MEDIUM

### V09: task.context 추출
- 확인: `_dispatch` 메서드에 `task.context` 또는 `ctx` 참조 존재
- Grep: `task\.context|ctx\s*=`

### V10: 서비스 메서드에 ctx 전달
- 확인: 서비스 메서드 호출 시 `ctx=` 인자 전달
- Grep: `ctx=ctx`

### V11: __init__.py에서 Agent 클래스 export
- 확인: `__init__.py`에 `from .agent import` 구문 존재
- Grep: `from \.agent import`

## LOW

### V12: set_provider() 메서드 존재
- 확인: `agent.py`에 `def set_provider` 정의
- Grep: `def set_provider`

### V13: 클래스/메서드 docstring
- 확인: 클래스와 execute() 메서드에 docstring 존재

### V14: agent.py 200줄 이하
- 확인: `wc -l agent.py`

### V15: services.py 800줄 이하
- 확인: `wc -l services.py`

## 등급 산정

| 등급 | 조건 |
|------|------|
| A | CRITICAL 0, HIGH 0-1, MEDIUM 0-2 |
| B | CRITICAL 0, HIGH 1-2 |
| C | CRITICAL 0, HIGH 3+ 또는 MEDIUM 5+ |
| F | CRITICAL 1+ |
