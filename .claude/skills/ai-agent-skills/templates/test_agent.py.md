# Template: test_agent.py

변수 치환 후 `backend/tests/test_{{AGENT_NAME}}.py`에 저장한다.

```python
"""Tests for {{AGENT_CLASS}}."""
from __future__ import annotations

import pytest

from app.core.base_agent import AgentStatus, AgentTask
from app.agents.{{AGENT_NAME}} import {{AGENT_CLASS}}


@pytest.fixture
def agent() -> {{AGENT_CLASS}}:
    return {{AGENT_CLASS}}()


class Test{{AGENT_CLASS}}Init:
    """초기화 테스트."""

    def test_agent_id(self, agent: {{AGENT_CLASS}}) -> None:
        assert agent.agent_id == "{{AGENT_ID}}"

    def test_initial_status(self, agent: {{AGENT_CLASS}}) -> None:
        assert agent.status == AgentStatus.IDLE

    def test_capabilities_not_empty(self, agent: {{AGENT_CLASS}}) -> None:
        assert len(agent.capabilities) > 0


class Test{{AGENT_CLASS}}Execute:
    """실행 테스트."""

    @pytest.mark.asyncio
    async def test_unknown_capability_returns_error(
        self, agent: {{AGENT_CLASS}}
    ) -> None:
        task = AgentTask.create(
            description="test unknown",
            input_data={"capability": "nonexistent_capability"},
        )
        result = await agent.execute(task)
        assert not result.success
        assert "Unknown capability" in (result.error or "")
        assert agent.status == AgentStatus.IDLE

    @pytest.mark.asyncio
    async def test_status_returns_to_idle_after_execute(
        self, agent: {{AGENT_CLASS}}
    ) -> None:
        task = AgentTask.create(
            description="test status",
            input_data={"capability": "nonexistent_capability"},
        )
        await agent.execute(task)
        assert agent.status == AgentStatus.IDLE

{{CAPABILITY_TESTS}}


class Test{{AGENT_CLASS}}Contract:
    """표준 계약 테스트."""

    def test_has_set_provider(self, agent: {{AGENT_CLASS}}) -> None:
        assert hasattr(agent, "set_provider")

    def test_capabilities_match_map(self, agent: {{AGENT_CLASS}}) -> None:
        from app.agents.{{AGENT_NAME}}.agent import _CAPABILITY_METHOD_MAP
        assert set(agent.capabilities) == set(_CAPABILITY_METHOD_MAP.keys())
```

## Capability 테스트 템플릿 (각 capability마다 생성)

```python
    @pytest.mark.asyncio
    async def test_{{CAPABILITY_NAME}}_basic(
        self, agent: {{AGENT_CLASS}}
    ) -> None:
        task = AgentTask.create(
            description="test {{CAPABILITY_NAME}}",
            input_data={"capability": "{{CAPABILITY_NAME}}"},
        )
        result = await agent.execute(task)
        assert agent.status == AgentStatus.IDLE
        # TODO: 구체적 assertion 추가
```
