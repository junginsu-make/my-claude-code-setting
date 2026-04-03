# Template: __init__.py

변수 치환 후 `backend/app/agents/{{AGENT_NAME}}/__init__.py`에 저장한다.

```python
from .agent import {{AGENT_CLASS}}

__all__ = ["{{AGENT_CLASS}}"]
```
