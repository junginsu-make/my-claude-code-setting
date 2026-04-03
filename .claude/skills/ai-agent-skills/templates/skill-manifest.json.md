# Template: skill-manifest.json

변수 치환 후 `backend/app/agents/{{AGENT_NAME}}/skill-manifest.json`에 저장한다.

```json
{
  "manifest_version": "1.0",
  "agent_id": "{{AGENT_ID}}",
  "agent_version": "1.0.0",
  "name": "{{AGENT_NAME}}",
  "display_name": "{{DISPLAY_NAME}}",
  "description": "{{DESCRIPTION}}",
  "category": "{{CATEGORY}}",
  "supports_workflow": true,
  "supports_human_handoff": false,
  "provider_preferences": ["claude-sonnet-4-6", "gemini-2.5-flash"],
  "capabilities": [
{{CAPABILITY_ENTRIES}}
  ]
}
```

## Capability 엔트리 템플릿 (각 capability마다 생성)

```json
    {
      "name": "{{CAPABILITY_NAME}}",
      "display_name": "{{CAPABILITY_DISPLAY_NAME}}",
      "description": "{{CAPABILITY_NAME}} 처리",
      "input_schema": {
        "type": "object",
        "properties": {},
        "required": []
      },
      "native_output_schema": {
        "type": "object",
        "properties": {
          "result": { "type": "string" }
        }
      },
      "normalized_output_schema": {
        "type": "object",
        "properties": {
          "status": { "type": "string", "enum": ["completed", "waiting_input", "waiting_approval", "failed"] },
          "summary": { "type": "string" },
          "structured_data": { "type": "object" },
          "artifacts": { "type": "array", "items": { "type": "object" } },
          "handoff": { "type": "object" },
          "native_output": { "type": "object" }
        }
      },
      "result_mapping": {
        "summary": "summary",
        "structured_data": "structured_data"
      },
      "workflow_tags": [],
      "supports_human_handoff": false,
      "examples": []
    }
```
