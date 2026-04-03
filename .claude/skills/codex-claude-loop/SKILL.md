---
name: codex-claude-loop
description: Claude Code가 설계하고 구현하며, Codex가 검증하고 리뷰하는 이중 AI 엔지니어링 루프를 오케스트레이션합니다. 지속적 피드백으로 최적의 코드 품질을 달성합니다.
---

# Codex-Claude 엔지니어링 루프 스킬

## 핵심 워크플로우 철학
이 스킬은 균형 잡힌 엔지니어링 루프를 구현합니다:
- **Claude Code**: 아키텍처, 설계, 실행
- **Codex**: 검증 및 코드 리뷰
- **지속적 리뷰**: 각 AI가 상대방의 작업을 리뷰
- **컨텍스트 핸드오프**: 마지막으로 정리를 완료한 쪽에서 이어서 진행

## Phase 1: Claude Code로 설계
1. 작업에 대한 상세 계획 수립
2. 구현을 명확한 단계로 분해
3. 가정 사항 및 잠재적 문제점 문서화
4. 구조화된 형식으로 계획 출력

## Phase 2: Codex로 계획 검증
1. 사용자에게 질문 (`AskUserQuestion`): 
   - 모델: `gpt-5` 또는 `gpt-5-codex`
   - 추론 수준: `low`, `medium`, 또는 `high`
2. 검증을 위해 Codex에 계획 전송:
```bash
   echo "Review this implementation plan and identify any issues:
   [Claude's plan here]
   
   Check for:
   - Logic errors
   - Missing edge cases
   - Architecture flaws
   - Security concerns" | codex exec -m  --config model_reasoning_effort="" --sandbox read-only
```
3. Codex 피드백 수집

## Phase 3: 피드백 루프
Codex가 문제를 발견한 경우:
1. Codex의 우려 사항을 사용자에게 요약
2. 피드백을 기반으로 계획 수정
3. 사용자에게 질문 (`AskUserQuestion`): "계획을 수정하고 재검증할까요, 아니면 수정 사항을 적용하고 진행할까요?"
4. 필요 시 Phase 2 반복

## Phase 4: 실행
계획이 검증되면:
1. Claude가 사용 가능한 도구(Edit, Write, Read 등)로 코드 구현
2. 구현을 관리 가능한 단계로 분해
3. 각 단계를 적절한 에러 핸들링과 함께 신중하게 실행
4. 구현 내용 문서화

## Phase 5: 변경 후 교차 리뷰
모든 변경 후:
1. Claude의 구현을 Codex에 리뷰 요청:
   - 버그 탐지
   - 성능 이슈
   - 모범 사례 검증
   - 보안 취약점
2. Claude가 Codex 피드백을 분석하고 결정:
   - 치명적인 이슈는 즉시 수정 적용
   - 아키텍처 변경이 필요하면 사용자와 논의
   - 결정 사항 문서화

## Phase 6: 반복 개선
1. Codex 리뷰 후 Claude가 필요한 수정 적용
2. 중요한 변경 사항은 Codex에 재검증 요청
3. 코드 품질 기준을 충족할 때까지 루프 지속
4. `codex exec resume --last`로 검증 세션 이어서 진행:
```bash
   echo "Review the updated implementation" | codex exec resume --last
```
   **참고**: resume은 원래 세션의 모든 설정(모델, 추론 수준, 샌드박스)을 상속합니다

## 문제 발견 시 복구
Codex가 문제를 식별한 경우:
1. Claude가 근본 원인 분석
2. 사용 가능한 도구로 수정 구현
3. 업데이트된 코드를 Codex에 재검증 요청
4. 검증 통과까지 반복

구현 오류 발생 시:
1. Claude가 오류/이슈 리뷰
2. 구현 전략 조정
3. 진행 전 Codex로 재검증

## 모범 사례
- **실행 전 항상 계획을 검증**
- **변경 후 교차 리뷰 절대 생략 금지**
- **AI 간 명확한 핸드오프 유지**
- **누가 무엇을 했는지 문서화**
- **세션 상태 보존을 위해 resume 사용**

## 명령어 참조
| 단계 | 명령어 패턴 | 목적 |
|------|------------|------|
| 계획 검증 | `echo "plan" \| codex exec --sandbox read-only` | 코딩 전 로직 확인 |
| 구현 | Claude가 Edit/Write/Read 도구 사용 | Claude가 검증된 계획을 구현 |
| 코드 리뷰 | `echo "review changes" \| codex exec --sandbox read-only` | Codex가 Claude의 구현을 검증 |
| 리뷰 이어하기 | `echo "next step" \| codex exec resume --last` | 검증 세션 계속 |
| 수정 적용 | Claude가 Edit/Write 도구 사용 | Claude가 Codex 발견 이슈 수정 |
| 재검증 | `echo "verify fixes" \| codex exec resume --last` | Codex가 수정 후 재확인 |

## 에러 핸들링
1. Codex에서 non-zero 종료 코드 발생 시 중단
2. Codex 피드백을 요약하고 `AskUserQuestion`으로 방향 확인
3. 변경 구현 전 다음 경우 사용자와 접근법 확인:
   - 중요한 아키텍처 변경 필요 시
   - 여러 파일에 영향을 미치는 경우
   - 파괴적 변경이 필요한 경우
4. Codex 경고 발생 시 Claude가 심각도를 평가하고 다음 단계 결정

## 완벽한 루프
```
설계 (Claude) → 계획 검증 (Codex) → 피드백 →
구현 (Claude) → 코드 리뷰 (Codex) →
이슈 수정 (Claude) → 재검증 (Codex) → 완벽할 때까지 반복
```

이 구조는 자기 교정이 가능한 고품질 엔지니어링 시스템을 만듭니다:
- **Claude**가 모든 코드 구현과 수정을 담당
- **Codex**가 검증, 리뷰, 품질 보증을 제공
