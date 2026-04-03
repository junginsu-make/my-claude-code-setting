# Frontend Integration Rules

AI 에이전트 실행 시 프론트엔드에서 어떻게 보여야 하는지 정의한다.

## 1. 핵심 원칙

- 모든 에이전트 실행은 **실시간 라이브러리 패널**(LiveActivityPanel)에 진행 상태가 표시되어야 한다
- 채팅창은 사용자 대화만, 실행 과정/결과는 실시간 라이브러리에 표시
- 모든 메시지는 **사용자 친화 한국어**로 — 변수명, 함수명, 시스템 용어 금지

## 2. 백엔드 Output에 `progress_steps` 필수

모든 에이전트의 `output_data`에 `progress_steps` 배열을 포함해야 한다.

```python
return {
    "status": "completed",
    "summary": "연차 신청이 완료되었습니다",
    "structured_data": {...},
    "artifacts": [],
    "progress_steps": [
        {
            "step": "잔여 연차 확인",
            "status": "done",
            "detail": "15일 중 12일 남음"
        },
        {
            "step": "날짜 유효성 확인",
            "status": "done",
            "detail": "공휴일 제외 완료"
        },
        {
            "step": "신청서 생성",
            "status": "done",
            "detail": "연차 2일"
        },
        {
            "step": "상급자 승인 요청",
            "status": "waiting",
            "detail": "김부장님 승인 대기"
        }
    ]
}
```

### progress_steps 필드 규칙

| 필드 | 타입 | 설명 |
|------|------|------|
| `step` | string | 단계 이름 (사용자 친화 한국어) |
| `status` | string | `pending` / `running` / `done` / `error` / `waiting` |
| `detail` | string | 부가 설명 (사용자 친화 한국어) |

### status 값과 프론트엔드 표시 매핑

| status | 아이콘 | 색상 | 의미 |
|--------|--------|------|------|
| `pending` | Clock | 회색 | 아직 시작 안 함 |
| `running` | Spinner | 파란색 | 실행 중 |
| `done` | CheckCircle | 초록색 | 완료 |
| `error` | AlertTriangle | 빨간색 | 오류 |
| `waiting` | UserCheck | 주황색 | 사람 승인 대기 |

## 3. 사용자 친화 메시지 규칙

### 금지

```
❌ "leave_request capability 실행 중"
❌ "execute() called with task_id=abc123"
❌ "AgentResult(success=True, output_data={...})"
❌ "remaining_days = 12"
❌ "HrService.request_leave() completed"
```

### 필수

```
✅ "휴가 신청을 진행합니다"
✅ "잔여 연차를 확인하고 있습니다"
✅ "연차 12일 남아있습니다"
✅ "신청서가 생성되었습니다"
✅ "김부장님에게 승인을 요청했습니다"
```

### 변환 원칙

| 시스템 용어 | 사용자 메시지 |
|------------|-------------|
| `leave_balance` | 잔여 연차 |
| `leave_request` | 휴가 신청 |
| `leave_approve` | 승인 처리 |
| `waiting_approval` | 승인 대기 중 |
| `validation error` | 입력 정보를 확인해주세요 |
| `employee not found` | 직원 정보를 찾을 수 없습니다 |
| `remaining: 12` | 12일 남아있습니다 |

## 4. LiveActivityPanel 연동

### 현재 구조

프론트엔드 `LiveActivityPanel.tsx`는 이미 아래 상태를 지원한다:
- `pending`, `running`, `completed`, `waiting_approval`, `failed`

### 에이전트 실행 시 데이터 흐름

```
백엔드 에이전트 실행
    ↓
AgentResult.output_data.progress_steps
    ↓
API 응답 → 프론트엔드 수신
    ↓
LiveActivityPanel에 step별로 표시
    ↓
최종 결과: summary + structured_data 표시
```

### 프론트엔드 표시 영역

```
┌─────────────────┬──────────────────────┐
│ 채팅창           │ 실시간 라이브러리      │
│                 │                      │
│ 사용자 메시지    │ [에이전트명] 실행 중   │
│ AI 응답 메시지   │                      │
│                 │ ✅ step1 — detail     │
│                 │ ✅ step2 — detail     │
│                 │ 🔄 step3 — detail    │
│                 │ ⏳ step4 — detail    │
│                 │                      │
│                 │ ─── 결과 ───          │
│                 │ summary 텍스트        │
│                 │ structured_data 표시  │
└─────────────────┴──────────────────────┘
```

## 5. 에이전트 카테고리별 progress_steps 예시

### HR (휴가 신청)

```json
[
    {"step": "직원 정보 확인", "status": "done", "detail": "이종근 (CEO)"},
    {"step": "잔여 연차 확인", "status": "done", "detail": "15일 중 12일 남음"},
    {"step": "날짜 확인", "status": "done", "detail": "4/1~4/2, 공휴일 없음"},
    {"step": "휴가 신청서 생성", "status": "done", "detail": "연차 2일"},
    {"step": "상급자 승인 요청", "status": "waiting", "detail": "김부장님 승인 대기"}
]
```

### 이미지 생성

```json
[
    {"step": "프롬프트 분석", "status": "done", "detail": "커피 포스터 요청"},
    {"step": "프롬프트 최적화", "status": "done", "detail": "스타일: 미니멀"},
    {"step": "이미지 생성 중", "status": "running", "detail": "Gemini로 생성 중..."},
    {"step": "결과 저장", "status": "pending", "detail": ""}
]
```

### PDF 분석

```json
[
    {"step": "파일 업로드 확인", "status": "done", "detail": "report.pdf (2.3MB)"},
    {"step": "텍스트 추출", "status": "done", "detail": "15페이지, 4,200단어"},
    {"step": "테이블 추출", "status": "running", "detail": "3개 테이블 발견"},
    {"step": "요약 생성", "status": "pending", "detail": ""}
]
```

## 6. 새 에이전트 생성 시 체크리스트

- [ ] services.py의 모든 메서드가 `progress_steps`를 반환하는가
- [ ] 모든 step 메시지가 사용자 친화 한국어인가
- [ ] 시스템 용어(변수명, 함수명, 영어 키)가 사용자에게 노출되지 않는가
- [ ] 에러 메시지도 사용자 친화적인가
- [ ] `summary` 필드가 한 줄로 결과를 설명하는가
