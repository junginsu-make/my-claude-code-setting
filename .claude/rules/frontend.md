# Frontend Development Rules (Global)

## 트리거 조건

사용자 요청에 아래 키워드가 포함되면 `/frontend` 커맨드의 파이프라인을 자동 적용한다:
- 프론트엔드, 프론트앤드, frontend, UI, 화면, 페이지, 컴포넌트, 디자인, 레이아웃
- 대시보드, 랜딩페이지, 폼, 모달, 사이드바, 테이블, 차트
- 스타일, 미화, 예쁘게, 깔끔하게, 반응형, 다크모드

## 자동 모드 매핑

| 사용자 요청 패턴 | 자동 적용 모드 |
|-----------------|---------------|
| "~~ 페이지 만들어줘" | `/frontend --mode page` |
| "~~ 컴포넌트 만들어줘" | `/frontend --mode component` |
| "디자인 개선해줘", "예쁘게 해줘" | `/frontend --mode improve` |
| "랜딩페이지 만들어줘" | `/frontend --mode landing` |

## shadcn/ui 최우선 원칙

- 모든 UI 컴포넌트는 shadcn/ui를 먼저 확인한다
- context7 MCP로 최신 문서를 반드시 조회한다
- 커스텀 컴포넌트는 shadcn/ui에 없을 때만 생성한다
- 아이콘은 Lucide React 사용
