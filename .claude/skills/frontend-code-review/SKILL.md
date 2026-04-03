---
name: frontend-code-review
description: "사용자가 프론트엔드 파일(예: `.tsx`, `.ts`, `.js`)의 리뷰를 요청할 때 트리거합니다. 체크리스트 규칙을 적용하면서 대기 중인 변경 리뷰와 특정 파일 리뷰를 모두 지원합니다."
---

# 프론트엔드 코드 리뷰

## 목적
사용자가 프론트엔드 코드(특히 `.tsx`, `.ts`, `.js` 파일) 리뷰를 요청할 때 이 스킬을 사용합니다. 두 가지 리뷰 모드를 지원합니다:

1. **대기 중인 변경 리뷰** – 커밋 예정인 스테이징/작업 트리 파일을 검사하고 제출 전 체크리스트 위반을 표시합니다.
2. **특정 파일 리뷰** – 사용자가 지정한 특정 파일을 리뷰하고 관련 체크리스트 결과를 보고합니다.

적용 가능한 모든 파일과 모드에 대해 아래 체크리스트를 준수합니다.

## 체크리스트
카테고리별로 분류된 체크리스트는 [references/code-quality.md](references/code-quality.md), [references/performance.md](references/performance.md), [references/business-logic.md](references/business-logic.md)를 참조하세요 - 이를 따라야 할 정규 규칙 세트로 취급합니다.

향후 리뷰어가 수정 우선순위를 정할 수 있도록 각 규칙 위반에 긴급도 메타데이터를 표시합니다.

## 리뷰 프로세스
1. 관련 컴포넌트/모듈을 엽니다. 클래스 이름, React Flow 훅, prop 메모이제이션, 스타일링과 관련된 라인을 수집합니다.
2. 리뷰 포인트의 각 규칙에 대해 코드가 벗어나는 부분을 기록하고 대표적인 코드 스니펫을 캡처합니다.
3. 아래 템플릿에 따라 리뷰 섹션을 구성합니다. 위반 사항을 먼저 **긴급** 플래그별로, 그다음 카테고리 순서(코드 품질, 성능, 비즈니스 로직)로 그룹화합니다.

## 필수 출력
호출 시 응답은 다음 두 템플릿 중 하나를 정확히 따라야 합니다:

### 템플릿 A (발견 사항 있음)
```
# Code review
Found <N> urgent issues need to be fixed:

## 1 <brief description of bug>
FilePath: <path> line <line>
<relevant code snippet or pointer>


### Suggested fix
<brief description of suggested fix>

---
... (repeat for each urgent issue) ...

Found <M> suggestions for improvement:

## 1 <brief description of suggestion>
FilePath: <path> line <line>
<relevant code snippet or pointer>


### Suggested fix
<brief description of suggested fix>

---

... (repeat for each suggestion) ...
```

긴급 이슈가 없으면 해당 섹션을 생략합니다. 제안 사항이 없으면 해당 섹션을 생략합니다.

이슈 수가 10개를 초과하면 "10+ 긴급 이슈" 또는 "10+ 제안 사항"으로 요약하고 처음 10개만 출력합니다.

섹션 간 빈 줄을 압축하지 마세요; 가독성을 위해 그대로 유지합니다.

템플릿 A를 사용하고(즉, 수정할 이슈가 있고) 최소 하나의 이슈에 코드 변경이 필요한 경우, 구조화된 출력 후 사용자에게 제안된 수정 사항을 적용할지 묻는 간략한 후속 질문을 추가합니다. 예시: "제안된 수정 사항 섹션을 사용하여 이 이슈들을 해결할까요?"

### 템플릿 B (이슈 없음)
```
## Code review
No issues found.
```

