---
name: skill-factory
description: >
  세션 작업을 분석하여 재사용 가능한 패턴을 자동으로 Claude Code 스킬로 변환합니다.
  사용 시점: "세션을 스킬로", "스킬 만들어", "이거 스킬로", "skill factory",
  "이 작업 자동화해", "스킬 추출", "make this a skill", "extract skill",
  "convert to skill", "스킬 팩토리", "자동 스킬 생성".
  skill-creator(보관됨) 및 manage-skills(드리프트 감지)와의 차이:
  이 스킬은 세션을 능동적으로 분석하고, 중복을 확인하고, Agent Teams를 통해 스킬을 생성합니다.
disable-model-invocation: true
argument-hint: "[--dry-run] [--no-team] [--target name] [--scope global|project]"
---

# 스킬 팩토리

자동화 파이프라인: 세션 분석 -> 중복 확인 -> 스킬 생성.
필요 환경: Python 3.8+, bash, git. Agent Teams 경로는 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 필요.

| 기존 스킬 | 역할 | skill-factory와의 차이 |
|-----------|------|----------------------|
| skill-creator (보관됨) | 수동 6단계 가이드 | 자동화 파이프라인 |
| manage-skills | 드리프트 감지 (verify-* 스킬) | 능동적 스킬 생성 (manage-skills는 기존 스킬 검증, skill-factory는 새 스킬 생성) |
| continuous-learning | 수동적 패턴 추출 | 온디맨드 + 팀 실행 |

## 파라미터 파싱

`$ARGUMENTS`에서 플래그를 추출합니다:

| 플래그 | 기본값 | 설명 |
|--------|--------|------|
| `--dry-run` | false | 분석과 보고만 수행, 파일 생성 없음 |
| `--no-team` | false | Agent Teams 없이 순차 실행 |
| `--target` | (자동) | 추출할 특정 패턴 이름 |
| `--scope` | global | `global` (~/.claude/skills/) 또는 `project` (.claude/skills/) |

인수가 없으면 전체 자동 감지 파이프라인을 실행합니다.

## Phase 1: 세션 분석

이 세션에서 발생한 작업을 수집합니다:

```bash
# 커밋되지 않은 변경사항
git diff HEAD --name-only 2>/dev/null

# 현재 브랜치의 최근 커밋
git log --oneline -20 2>/dev/null

# main에서 분기된 브랜치 diff
git diff main...HEAD --name-only 2>/dev/null
```

수집된 변경사항에서 **후보 패턴** - 반복적으로 나타난 워크플로우를 식별합니다:

1. **다단계 시퀀스** - 일관된 순서로 수행된 3개 이상의 액션
2. **도구 조합** - 함께 사용된 특정 도구 (예: Grep + Read + Edit)
3. **도메인 절차** - 특정 작업으로 접근한 파일 유형이나 디렉토리
4. **반복 변환** - 여러 파일에 적용된 동일 유형의 변경

`--target`이 지정되면 해당 패턴에만 분석을 집중합니다.

각 후보에 대해 JSON 항목을 생성합니다 (내부용, 사용자에게 표시하지 않음):

```json
{
  "name": "pattern-name",
  "description": "반복적으로 수행된 작업 설명",
  "files": ["path/a.ts", "path/b.ts"],
  "steps": ["Step1", "Step2", "Step3"],
  "step_count": 3
}
```

사용자에게 결과를 제시합니다:

```
세션 분석 완료

발견된 후보 패턴: N개

1. [pattern-name] - "반복적으로 수행된 작업 설명"
   파일: path/a.ts, path/b.ts (N개 파일)
   단계: Step1 -> Step2 -> Step3

2. [pattern-name] - "설명"
   ...

어떤 패턴을 스킬로 만들까요? (선택 또는 'all')
```

진행 전 사용자 선택을 기다립니다.

## Phase 2: 유사도 검사

선택된 각 패턴에 대해 기존 인벤토리와 비교합니다.

**1단계: 인벤토리 스캔**
```bash
bash $HOME/.claude/skills/skill-factory/scripts/scan-inventory.sh --scope all > /tmp/sf-manifest.json
```

**2단계: 유사도 점수 산출**
```bash
python3 $HOME/.claude/skills/skill-factory/scripts/similarity-scorer.py \
  --candidate "<패턴 설명>" \
  --candidate-name "<pattern-name>" \
  --manifest /tmp/sf-manifest.json \
  --top 3
```

**3단계: 결정 로직 적용** ([references/decision-tree.md](references/decision-tree.md) 참조)

사용자에게 결과를 제시합니다:

```
유사도 검사 결과

패턴: "pdf-batch-edit"
  최고 일치: nano-pdf (점수: 0.72) -> 병합(MERGE)
  권장: nano-pdf에 배치 작업 추가 확장

패턴: "config-updater"
  최고 일치: init-project (점수: 0.45) -> 업데이트(UPDATE)
  권장: init-project에 config-update 하위 섹션 추가

패턴: "api-load-test"
  최고 일치: e2e (점수: 0.24) -> 생성(CREATE)
  권장: 새 스킬 생성

각 패턴에 대한 작업? (CREATE / UPDATE / MERGE / SKIP)
```

패턴별로 사용자 결정을 기다립니다.

## Phase 3: 블루프린트

각 CREATE/UPDATE/MERGE 결정에 대해 스킬 구조를 설계합니다.

### CREATE 블루프린트

[references/skill-templates.md](references/skill-templates.md)에서 템플릿 유형을 선택합니다:
- **Workflow** - 순차 프로세스용
- **Task/Tool** - 작업 컬렉션용
- **Reference** - 도메인 지식용
- **Verification** - 자동화 검사용

블루프린트를 생성합니다:

```
블루프린트: api-load-test

유형: Workflow
범위: global (~/.claude/skills/)
구조:
  api-load-test/
  ├── SKILL.md (~200줄)
  │   ├── 프론트매터: name, 트리거 포함 description
  │   ├── 개요
  │   ├── 사전 요구사항
  │   ├── 워크플로우 (4단계)
  │   └── 출력 형식
  └── scripts/
      └── run-load-test.sh

핵심 섹션:
  1. 대상 URL 설정
  2. 부하 프로필 정의
  3. 테스트 실행
  4. 결과 분석

이 블루프린트를 승인하시겠습니까? (y/n/edit)
```

사용자 승인을 기다립니다.

### UPDATE 블루프린트

UPDATE 판정(점수 0.3-0.6)의 경우, 기존 스킬에 가벼운 추가를 계획합니다:

```
UPDATE 블루프린트: config-updater -> init-project

대상 스킬: ~/.claude/skills/init-project/SKILL.md
작업: "## Config Update" 하위 섹션에 단계 추가
예상 diff: 기존 SKILL.md에 +20-40줄
```

### MERGE 블루프린트

MERGE 판정(점수 0.6-0.8)의 경우, 기존 스킬의 대폭 확장을 계획합니다:

```
MERGE 블루프린트: pdf-batch-edit -> nano-pdf

대상 스킬: ~/.claude/skills/nano-pdf/SKILL.md
추가할 섹션: "## 배치 작업" (새 워크플로우 섹션)
추가할 스크립트: scripts/batch-process.sh
예상 diff: SKILL.md에 +60-100줄, +1 스크립트
```

## Phase 4: 실행

`--no-team` 플래그 및 Agent Teams 사용 가능 여부에 따라 두 경로로 나뉩니다.

Agent Teams 사용 가능 여부 확인:
```bash
[ "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-0}" = "1" ] && echo "teams" || echo "no-team"
```
`--no-team`이 설정되었거나 환경변수가 없거나 0이면 자동으로 경로 B를 사용합니다.

### 경로 A: Agent Teams (기본)

전체 팀 세부사항은 [references/team-composition.md](references/team-composition.md)를 참조하세요.

**팀: 3명의 팀원 (tami, jiwon, duri)**

```
TeamCreate -> "skill-factory-run"

TaskCreate -> tami의 분석 작업 (T1-T6)
TaskCreate -> jiwon의 생성 작업 (T7-T12, T6에 의존)
TaskCreate -> duri의 검증 작업 (T13-T18, T12에 의존)

Task -> tami (Explore, sonnet, blue)
  "세션 분석, scan-inventory.sh 실행, similarity-scorer.py 실행, 결과 보고"

Task -> jiwon (general-purpose, sonnet, green)
  "CREATE: skill-templates.md 읽고, 블루프린트 기반으로 SKILL.md + 리소스 생성"
  "UPDATE/MERGE: 대상 스킬 읽고, 블루프린트의 diff 적용, 새 섹션/스크립트 추가"

Task -> duri (general-purpose, sonnet, yellow)
  "validate-skill.sh 실행, 트리거 검증, 스킬 등록"
```

파이프라인:
1. **tami** 분석 완료 -> 리더에게 보고
2. 리더가 사용자와 확인 (체크포인트 1-2)
3. **jiwon** 스킬 파일 생성 -> 리더에게 보고
4. 리더가 사용자와 확인 (체크포인트 3)
5. **duri** 검증 및 등록 -> 리더에게 보고
6. 리더가 사용자와 확인 (체크포인트 4)
7. 모든 팀원 종료, TeamDelete

### 경로 B: 순차 실행 (--no-team)

Agent Teams 없이 동일한 단계를 인라인으로 실행합니다:

1. `scan-inventory.sh` 및 `similarity-scorer.py` 직접 실행
2. **체크포인트 1-2**: 유사도 결과 제시, 패턴별 CREATE/UPDATE/MERGE/SKIP 사용자 확인
3. 템플릿 선택 기반 블루프린트 설계
4. **체크포인트 3**: 블루프린트 제시, 사용자 승인 대기
5. 승인된 블루프린트 기반 스킬 디렉토리 및 파일 생성/수정
6. `validate-skill.sh` 실행하여 검증
7. **체크포인트 4**: 검증 결과 제시, 등록 또는 편집 사용자 확인
8. 등록 및 로깅

### --dry-run 모드

Phase 3(블루프린트) 후 중단합니다. 블루프린트를 출력하고 파일 생성 없이 종료합니다:

```
DRY RUN 완료

분석된 패턴: N개
결정: X CREATE, Y MERGE, Z SKIP
생성된 블루프린트: X개

파일이 생성되지 않았습니다. 실행하려면 --dry-run을 제거하세요.
```

## Phase 5: 등록

검증 통과 후:

1. **생성 로깅** - `~/.claude/skill-factory.log`에 추가:
   ```
   [2026-02-18T14:30:00] CREATED api-load-test (global) from session patterns
   [2026-02-18T14:30:00] MERGED batch-operations into nano-pdf
   ```

2. **범위 배치**:
   - `--scope global`: `~/.claude/skills/<name>/`
   - `--scope project`: `.claude/skills/<name>/`

3. **CLAUDE.md 업데이트 (선택)**: 프로젝트 범위인 경우, 프로젝트 CLAUDE.md에 스킬 참조 추가를 제안합니다.

## 출력 형식

모든 패턴 처리 후 최종 보고서:

```
스킬 팩토리 보고서

세션: <branch-name 또는 "main">
발견된 패턴: N개
처리된 패턴: M개

결과:
  생성됨: api-load-test (global) - 4개 파일, 180줄
  병합됨: batch-ops -> nano-pdf - 2개 섹션 추가
  건너뜀: data-transform (data-research와 0.85 일치)

생성/수정된 파일:
  ~/.claude/skills/api-load-test/SKILL.md
  ~/.claude/skills/api-load-test/scripts/run-load-test.sh
  ~/.claude/skills/nano-pdf/SKILL.md (수정됨)

검증: 전체 통과
로그: ~/.claude/skill-factory.log

다음 단계:
  새 스킬 테스트: /api-load-test
  리뷰: cat ~/.claude/skills/api-load-test/SKILL.md
```

## 에러 처리

| 상황 | 조치 |
|------|------|
| git 이력 없음 | staged/unstaged 변경사항만 분석 |
| 패턴 미발견 | "재사용 가능한 패턴이 감지되지 않았습니다. 더 복잡한 세션 후에 시도해보세요." |
| scan-inventory.sh 실패 | 수동 인벤토리로 폴백 (SKILL.md 파일 glob) |
| similarity-scorer.py 실패 | 유사도 검사 생략, CREATE로 기본 설정 |
| Agent Teams 사용 불가 | `--no-team` 모드로 자동 폴백 |
| validate-skill.sh 실패 | 오류 표시, 사용자가 수정 또는 취소 |
| 사용자가 체크포인트에서 취소 | 정상 중단, 부분 파일 남기지 않음 |

## 관련 파일

| 파일 | 용도 | 읽는 시점 |
|------|------|----------|
| [scripts/scan-inventory.sh](scripts/scan-inventory.sh) | 모든 스킬/커맨드/에이전트를 JSON으로 스캔 | Phase 2 - 항상 |
| [scripts/similarity-scorer.py](scripts/similarity-scorer.py) | 4차원 유사도 점수 산출 | Phase 2 - 패턴별 |
| [scripts/validate-skill.sh](scripts/validate-skill.sh) | 생성된 스킬 구조 검증 | Phase 5 - 생성 후 |
| [references/decision-tree.md](references/decision-tree.md) | CREATE/UPDATE/MERGE/SKIP 로직 | Phase 2 - 결정 시 |
| [references/team-composition.md](references/team-composition.md) | tami/jiwon/duri 팀 구성 | Phase 4 - Agent Teams 경로 |
| [references/skill-templates.md](references/skill-templates.md) | 스킬 유형 템플릿 | Phase 3 - 블루프린트 설계 |
