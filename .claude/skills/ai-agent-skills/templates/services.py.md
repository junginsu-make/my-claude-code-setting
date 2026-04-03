# Template: services.py

변수 치환 후 `backend/app/agents/{{AGENT_NAME}}/services.py`에 저장한다.

```python
"""{{AGENT_NAME}} service — business logic."""
from __future__ import annotations

import logging
from typing import Any

logger = logging.getLogger(__name__)


class {{SERVICE_CLASS}}:
    """{{DISPLAY_NAME}} 서비스."""

    def __init__(self, provider: Any = None) -> None:
        self._provider = provider

{{SERVICE_METHODS}}
```

## 서비스 메서드 템플릿 (각 capability마다 생성)

```python
    async def handle_{{CAPABILITY_NAME}}(
        self, *, data: dict[str, Any], ctx: dict[str, Any]
    ) -> dict[str, Any]:
        """{{CAPABILITY_NAME}} 처리."""
        user_id = ctx.get("user_id", "")
        # TODO: 비즈니스 로직 구현
        return {
            "status": "completed",
            "summary": "{{CAPABILITY_NAME}} 처리 완료",
            "structured_data": {},
        }
```
