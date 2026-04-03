# Pattern Catalog

에이전트 코드 패턴 레퍼런스. 표준(A)과 비표준(B)을 구분한다.

## Pattern A: 표준 (모든 새 에이전트에 적용)

참고 에이전트: `hr_agent`, `copywriter`, `pdf_analyzer`

```python
"""에이전트 설명."""
from __future__ import annotations

import logging
from typing import Any

from app.core.base_agent import AgentResult, AgentStatus, AgentTask, BaseAgent
from .services import MyService

logger = logging.getLogger(__name__)

_CAPABILITY_METHOD_MAP: dict[str, str] = {
    "cap_one": "handle_cap_one",
    "cap_two": "handle_cap_two",
}


class MyAgent(BaseAgent):
    def __init__(self) -> None:
        super().__init__(
            agent_id="aNN-my-agent",
            name="my_agent",
            display_name="내 에이전트",
            description="설명",
            capabilities=list(_CAPABILITY_METHOD_MAP.keys()),
        )
        self._service = MyService()

    def set_provider(self, provider: Any) -> None:
        self._service = MyService(provider=provider)

    async def execute(self, task: AgentTask) -> AgentResult:
        self._set_status(AgentStatus.BUSY)
        try:
            result = await self._dispatch(task)
            self._set_status(AgentStatus.IDLE)
            return result
        except Exception as exc:
            logger.exception("Agent %s failed", self.agent_id)
            self._set_status(AgentStatus.ERROR)
            return AgentResult(
                task_id=task.id, agent_id=self.agent_id,
                success=False, output_data={}, error=str(exc),
            )

    async def _dispatch(self, task: AgentTask) -> AgentResult:
        capability: str = task.input_data.get("capability", "")
        method_name = _CAPABILITY_METHOD_MAP.get(capability)
        if method_name is None:
            return AgentResult(
                task_id=task.id, agent_id=self.agent_id,
                success=False, output_data={},
                error=f"Unknown capability: {capability}. "
                      f"Available: {list(_CAPABILITY_METHOD_MAP.keys())}",
            )
        data: dict[str, Any] = task.input_data
        ctx: dict[str, Any] = task.context or {}
        method = getattr(self._service, method_name)
        output = await method(data=data, ctx=ctx)
        return AgentResult(
            task_id=task.id, agent_id=self.agent_id,
            success=True, output_data=output,
        )
```

## Pattern A: 서비스 표준

```python
"""서비스 설명."""
from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


class MyService:
    def __init__(self, provider: Any = None) -> None:
        self._provider = provider

    async def handle_cap_one(
        self, *, data: dict[str, Any], ctx: dict[str, Any]
    ) -> dict[str, Any]:
        """cap_one 처리."""
        user_id = ctx.get("user_id", "")
        text = data.get("text", "")
        # ... 비즈니스 로직
        return {
            "status": "completed",
            "summary": "처리 완료",
            "structured_data": {"result": "..."},
        }
```

## Pattern B: 비표준 (마이그레이션 대상)

현재 사용 에이전트: `text_toolkit`, `image_toolkit`, `pdf_toolkit`, `data_toolkit`, `video_toolkit`

```python
# 비표준 — _get_dispatch() 인스턴스 메서드
class TextToolkitAgent(BaseAgent):
    def _get_dispatch(self) -> dict[str, Any]:
        return {
            "text_translate": self._service.handle_translate,
            "text_rewrite": self._service.handle_rewrite,
        }

    async def execute(self, task: AgentTask) -> AgentResult:
        # 상태 관리 없음
        capability = task.input_data.get("capability", "")
        handler = self._get_dispatch().get(capability)
        result = await handler(task.input_data)  # context 무시
        return AgentResult(...)
```

### B→A 변환 방법

1. `_get_dispatch()` 딕셔너리 키 → `_CAPABILITY_METHOD_MAP` 모듈 레벨로 이동
2. 값을 메서드 이름 문자열로 변경 (callable → str)
3. `execute()`에 BUSY/IDLE/ERROR 상태 관리 추가
4. `_dispatch()`에서 `ctx = task.context or {}` 추출
5. 서비스 메서드 시그니처를 `(self, *, data, ctx)` 로 통일

## DI 패턴: 단일 프로바이더

```python
def set_provider(self, provider: Any) -> None:
    self._service = MyService(provider=provider)
```

## DI 패턴: 듀얼 프로바이더

```python
def set_provider(self, provider: Any) -> None:
    self._service = MyService(gemini_provider=provider)

def set_claude_provider(self, provider: Any) -> None:
    self._service = MyService(claude_provider=provider)
```

## DI 패턴: 저장소 주입

```python
def set_hr_repos(self, hr_repo, notif_repo) -> None:
    self._service = MyService(hr_repo=hr_repo, notif_repo=notif_repo)
```
