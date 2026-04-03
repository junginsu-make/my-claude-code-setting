# Agent Contract (Quick Reference)

> 전체 문서: `docs/ai-agent-skills/01-agent-contract.md`

## 필수 구조

```
backend/app/agents/<name>/
├── __init__.py              # Agent 클래스 export
├── agent.py                 # BaseAgent 상속
├── services.py              # 비즈니스 로직
└── skill-manifest.json      # 워크플로우 메타데이터
```

## Agent ID 형식

`a<번호>-<kebab-name>` (예: `a17-email-sender`)

## Execute 패턴 (필수)

```python
_CAPABILITY_METHOD_MAP: dict[str, str] = {
    "cap_name": "handle_cap_name",
}

class MyAgent(BaseAgent):
    async def execute(self, task: AgentTask) -> AgentResult:
        self._set_status(AgentStatus.BUSY)
        try:
            result = await self._dispatch(task)
            self._set_status(AgentStatus.IDLE)
            return result
        except Exception as exc:
            self._set_status(AgentStatus.ERROR)
            return AgentResult(task_id=task.id, agent_id=self.agent_id,
                             success=False, output_data={}, error=str(exc))

    async def _dispatch(self, task: AgentTask) -> AgentResult:
        capability = task.input_data.get("capability", "")
        method_name = _CAPABILITY_METHOD_MAP.get(capability)
        if method_name is None:
            return AgentResult(success=False, error=f"Unknown: {capability}")
        data = task.input_data
        ctx = task.context or {}
        output = await getattr(self._service, method_name)(data=data, ctx=ctx)
        return AgentResult(task_id=task.id, agent_id=self.agent_id,
                         success=True, output_data=output)
```

## 서비스 메서드 시그니처

```python
async def handle_<cap>(self, *, data: dict[str, Any], ctx: dict[str, Any]) -> dict[str, Any]:
```

## Normalized Output

```json
{
  "status": "completed",
  "summary": "결과 설명",
  "structured_data": {},
  "artifacts": [],
  "handoff": { "requires_approval": false },
  "native_output": {}
}
```

## 금지 패턴

- `_get_dispatch()` 인스턴스 메서드 (Pattern B)
- 상태 관리 없는 execute()
- task.context 무시
- 에이전트 간 직접 import
