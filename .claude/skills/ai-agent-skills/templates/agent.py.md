# Template: agent.py

변수 치환 후 `backend/app/agents/{{AGENT_NAME}}/agent.py`에 저장한다.

```python
"""{{DESCRIPTION}}"""
from __future__ import annotations

import logging
from typing import Any

from app.core.base_agent import (
    AgentResult,
    AgentStatus,
    AgentTask,
    BaseAgent,
)
from .services import {{SERVICE_CLASS}}

logger = logging.getLogger(__name__)

_CAPABILITY_METHOD_MAP: dict[str, str] = {
{{CAPABILITY_MAP_ENTRIES}}
}


class {{AGENT_CLASS}}(BaseAgent):
    """{{DISPLAY_NAME}} — {{DESCRIPTION}}"""

    def __init__(self) -> None:
        super().__init__(
            agent_id="{{AGENT_ID}}",
            name="{{AGENT_NAME}}",
            display_name="{{DISPLAY_NAME}}",
            description="{{DESCRIPTION}}",
            capabilities=list(_CAPABILITY_METHOD_MAP.keys()),
        )
        self._service = {{SERVICE_CLASS}}()

    def set_provider(self, provider: Any) -> None:
        """AI 프로바이더 주입."""
        self._service = {{SERVICE_CLASS}}(provider=provider)

    async def execute(self, task: AgentTask) -> AgentResult:
        """태스크 실행."""
        self._set_status(AgentStatus.BUSY)
        try:
            result = await self._dispatch(task)
            self._set_status(AgentStatus.IDLE)
            return result
        except Exception as exc:
            logger.exception("Agent %s failed", self.agent_id)
            self._set_status(AgentStatus.ERROR)
            return AgentResult(
                task_id=task.id,
                agent_id=self.agent_id,
                success=False,
                output_data={},
                error=str(exc),
            )

    async def _dispatch(self, task: AgentTask) -> AgentResult:
        """capability 기반 라우팅."""
        capability: str = task.input_data.get("capability", "")
        method_name = _CAPABILITY_METHOD_MAP.get(capability)

        if method_name is None:
            return AgentResult(
                task_id=task.id,
                agent_id=self.agent_id,
                success=False,
                output_data={},
                error=f"Unknown capability: {capability}. "
                      f"Available: {list(_CAPABILITY_METHOD_MAP.keys())}",
            )

        data: dict[str, Any] = task.input_data
        ctx: dict[str, Any] = task.context or {}
        method = getattr(self._service, method_name)
        output = await method(data=data, ctx=ctx)

        return AgentResult(
            task_id=task.id,
            agent_id=self.agent_id,
            success=True,
            output_data=output,
        )
```

## 변수 설명

| 변수 | 예시 |
|------|------|
| `{{AGENT_NAME}}` | `email_sender` |
| `{{AGENT_CLASS}}` | `EmailSenderAgent` |
| `{{AGENT_ID}}` | `a17-email-sender` |
| `{{DISPLAY_NAME}}` | `이메일 발송기` |
| `{{DESCRIPTION}}` | `이메일 작성 및 발송 관리` |
| `{{SERVICE_CLASS}}` | `EmailSenderService` |
| `{{CAPABILITY_MAP_ENTRIES}}` | `    "send_email": "handle_send_email",\n    "draft_email": "handle_draft_email",` |
