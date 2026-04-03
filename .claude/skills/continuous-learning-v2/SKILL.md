---
name: continuous-learning-v2
description: 훅을 통해 세션을 관찰하고, 신뢰도 점수가 부여된 원자적 본능을 생성하며, 이를 스킬/명령어/에이전트로 진화시키는 본능 기반 학습 시스템입니다.
version: 2.0.0
---

# Continuous Learning v2 - 본능 기반 아키텍처

Claude Code 세션을 원자적 "본능(instinct)" — 신뢰도 점수가 부여된 소규모 학습 행동 — 을 통해 재사용 가능한 지식으로 변환하는 고급 학습 시스템입니다.

## v2의 새로운 점

| 기능 | v1 | v2 |
|------|----|----|
| 관찰 | Stop hook (세션 종료) | PreToolUse/PostToolUse (100% 신뢰) |
| 분석 | 메인 컨텍스트 | 백그라운드 에이전트 (Haiku) |
| 세분화 | 전체 스킬 | 원자적 "본능" |
| 신뢰도 | 없음 | 0.3-0.9 가중치 |
| 진화 | 직접 스킬로 | 본능 → 클러스터 → 스킬/명령어/에이전트 |
| 공유 | 없음 | 본능 내보내기/가져오기 |

## 본능 모델

본능(instinct)은 소규모 학습 행동입니다:

```yaml
---
id: prefer-functional-style
trigger: "when writing new functions"
confidence: 0.7
domain: "code-style"
source: "session-observation"
---

# Prefer Functional Style

## Action
Use functional patterns over classes when appropriate.

## Evidence
- Observed 5 instances of functional pattern preference
- User corrected class-based approach to functional on 2025-01-15
```

**속성:**
- **원자적** — 하나의 트리거, 하나의 액션
- **신뢰도 가중치** — 0.3 = 잠정적, 0.9 = 거의 확실
- **도메인 태그** — code-style, testing, git, debugging, workflow 등
- **증거 기반** — 어떤 관찰로부터 생성되었는지 추적

## 작동 방식

```
Session Activity
      │
      │ Hooks capture prompts + tool use (100% reliable)
      ▼
┌─────────────────────────────────────────┐
│         observations.jsonl              │
│   (prompts, tool calls, outcomes)       │
└─────────────────────────────────────────┘
      │
      │ Observer agent reads (background, Haiku)
      ▼
┌─────────────────────────────────────────┐
│          PATTERN DETECTION              │
│   • User corrections → instinct         │
│   • Error resolutions → instinct        │
│   • Repeated workflows → instinct       │
└─────────────────────────────────────────┘
      │
      │ Creates/updates
      ▼
┌─────────────────────────────────────────┐
│         instincts/personal/             │
│   • prefer-functional.md (0.7)          │
│   • always-test-first.md (0.9)          │
│   • use-zod-validation.md (0.6)         │
└─────────────────────────────────────────┘
      │
      │ /evolve clusters
      ▼
┌─────────────────────────────────────────┐
│              evolved/                   │
│   • commands/new-feature.md             │
│   • skills/testing-workflow.md          │
│   • agents/refactor-specialist.md       │
└─────────────────────────────────────────┘
```

## 빠른 시작

### 1. 관찰 훅 활성화

`~/.claude/settings.json`에 추가:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/continuous-learning-v2/hooks/observe.sh pre"
      }]
    }],
    "PostToolUse": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/continuous-learning-v2/hooks/observe.sh post"
      }]
    }]
  }
}
```

### 2. 디렉토리 구조 초기화

```bash
mkdir -p ~/.claude/homunculus/{instincts/{personal,inherited},evolved/{agents,skills,commands}}
touch ~/.claude/homunculus/observations.jsonl
```

### 3. 관찰자 에이전트 실행 (선택)

관찰자는 백그라운드에서 관찰 데이터를 분석할 수 있습니다:

```bash
# Start background observer
~/.claude/skills/continuous-learning-v2/agents/start-observer.sh
```

## 명령어

| 명령어 | 설명 |
|--------|------|
| `/instinct-status` | 학습된 모든 본능과 신뢰도 표시 |
| `/evolve` | 관련 본능을 스킬/명령어로 클러스터링 |
| `/instinct-export` | 공유를 위해 본능 내보내기 |
| `/instinct-import <file>` | 다른 사람의 본능 가져오기 |

## 설정

`config.json` 편집:

```json
{
  "version": "2.0",
  "observation": {
    "enabled": true,
    "store_path": "~/.claude/homunculus/observations.jsonl",
    "max_file_size_mb": 10,
    "archive_after_days": 7
  },
  "instincts": {
    "personal_path": "~/.claude/homunculus/instincts/personal/",
    "inherited_path": "~/.claude/homunculus/instincts/inherited/",
    "min_confidence": 0.3,
    "auto_approve_threshold": 0.7,
    "confidence_decay_rate": 0.05
  },
  "observer": {
    "enabled": true,
    "model": "haiku",
    "run_interval_minutes": 5,
    "patterns_to_detect": [
      "user_corrections",
      "error_resolutions",
      "repeated_workflows",
      "tool_preferences"
    ]
  },
  "evolution": {
    "cluster_threshold": 3,
    "evolved_path": "~/.claude/homunculus/evolved/"
  }
}
```

## 파일 구조

```
~/.claude/homunculus/
├── identity.json           # Your profile, technical level
├── observations.jsonl      # Current session observations
├── observations.archive/   # Processed observations
├── instincts/
│   ├── personal/           # Auto-learned instincts
│   └── inherited/          # Imported from others
└── evolved/
    ├── agents/             # Generated specialist agents
    ├── skills/             # Generated skills
    └── commands/           # Generated commands
```

## Skill Creator 통합

[Skill Creator GitHub App](https://skill-creator.app)을 사용하면 이제 **두 가지 모두** 생성됩니다:
- 기존 SKILL.md 파일 (하위 호환)
- 본능 컬렉션 (v2 학습 시스템용)

저장소 분석에서 생성된 본능은 `source: "repo-analysis"`이며 소스 저장소 URL을 포함합니다.

## 신뢰도 점수

신뢰도는 시간에 따라 변화합니다:

| 점수 | 의미 | 동작 |
|------|------|------|
| 0.3 | 잠정적 | 제안되지만 강제되지 않음 |
| 0.5 | 보통 | 관련 시 적용 |
| 0.7 | 강함 | 적용 자동 승인 |
| 0.9 | 거의 확실 | 핵심 동작 |

**신뢰도 증가** 조건:
- 패턴이 반복적으로 관찰됨
- 사용자가 제안된 동작을 교정하지 않음
- 다른 소스의 유사 본능이 일치함

**신뢰도 감소** 조건:
- 사용자가 명시적으로 동작을 교정함
- 오랜 기간 패턴이 관찰되지 않음
- 모순되는 증거가 나타남

## 관찰에 훅을 사용하는 이유

> "v1은 스킬로 관찰에 의존했습니다. 스킬은 확률적이어서 Claude의 판단에 따라 약 50-80%의 확률로 실행됩니다."

훅은 **100%** 결정적으로 실행됩니다. 이는 다음을 의미합니다:
- 모든 도구 호출이 관찰됨
- 패턴 누락 없음
- 학습이 포괄적임

## 하위 호환성

v2는 v1과 완전히 호환됩니다:
- 기존 `~/.claude/skills/learned/` 스킬이 그대로 작동
- Stop hook이 계속 실행됨 (이제 v2에도 데이터 제공)
- 점진적 마이그레이션 경로: 둘 다 병행 실행 가능

## 프라이버시

- 관찰 데이터는 사용자의 기기에 **로컬**로 유지
- **본능**(패턴)만 내보내기 가능
- 실제 코드나 대화 내용은 공유되지 않음
- 내보낼 항목은 사용자가 제어

## 에이전트 메모리 통합

continuous-learning-v2의 instinct 시스템은 에이전트의 Self-Evolution Protocol과 상호보완적으로 동작한다.

### 관계도

````
Continuous Learning v2 (세션 관찰 기반)
  └─ observations.jsonl → instincts/personal/ → evolved/
        ↕ 상호 참조
Agent Self-Evolution (작업 완료 기반)
  └─ 에이전트 작업 결과 → ~/.claude/agent-memory/{agent-name}/
````

### 차이점

| 차원 | Continuous Learning v2 | Agent Self-Evolution |
|------|----------------------|---------------------|
| 트리거 | 세션 관찰 (hooks) | 에이전트 작업 완료 |
| 저장소 | `~/.claude/homunculus/instincts/` | `~/.claude/agent-memory/` |
| 형태 | 원자적 instinct (trigger + action) | Learnings 리스트 (발견/개선) |
| 대상 | 전체 (범용) | 개별 에이전트 |
| 자동화 | Hook → Observer → Instinct (자동) | 에이전트 작업 완료 후 자체 기록 |

### 통합 사용 시나리오

1. **세션 중**: continuous-learning-v2 hooks가 관찰 데이터 수집
2. **에이전트 작업 후**: 에이전트가 Self-Evolution으로 자체 memory 업데이트
3. **세션 종료**: `/session-wrap`이 양쪽 데이터를 종합하여 정리
4. **다음 세션 시작**: `/sync`로 프로젝트 문서 동기화

## 관련 링크

- [Skill Creator](https://skill-creator.app) - 저장소 히스토리에서 본능 생성
- [Homunculus](https://github.com/humanplane/homunculus) - v2 아키텍처 영감
- [The Longform Guide](https://x.com/affaanmustafa/status/2014040193557471352) - 지속적 학습 섹션

---

*본능 기반 학습: 한 번에 하나의 관찰로 Claude에게 당신의 패턴을 가르칩니다.*
