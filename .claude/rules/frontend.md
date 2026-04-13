# Frontend Development Rules (Global)

## 트리거 조건

사용자 요청에 아래 키워드가 포함되면 이 규칙을 적용한다:
- 프론트엔드, 프론트앤드, frontend, UI, 화면, 페이지, 컴포넌트, 디자인, 레이아웃
- 대시보드, 랜딩페이지, 폼, 모달, 사이드바, 테이블, 차트
- 스타일, 미화, 예쁘게, 깔끔하게, 반응형, 다크모드

## 1. 필수 스킬 자동 호출

프론트엔드 작업 시 아래 순서로 스킬을 호출한다. **사용자가 별도로 `/skill`을 입력할 필요 없다.**

### 신규 구현 (새 페이지, 컴포넌트, 앱)

```
1단계: Skill("frontend-design")     — 디자인 방향 수립
2단계: context7에서 shadcn/ui 문서 조회  — 사용할 컴포넌트 확인
3단계: 구현
```

### 디자인 개선 / 미화

```
1단계: Skill("frontend-design")     — 개선 방향 수립
2단계: context7에서 shadcn/ui 문서 조회  — 대체 가능한 컴포넌트 확인
3단계: 개선 적용
```

### 랜딩페이지

```
1단계: Skill("landing-page-guide")  — 11요소 프레임워크 적용
2단계: Skill("frontend-design")     — 디자인 방향
3단계: context7에서 shadcn/ui 문서 조회
4단계: 구현
```

### 복잡한 멀티컴포넌트 아티팩트 (상태관리, 라우팅 필요)

```
1단계: Skill("web-artifacts-builder") — 아티팩트 빌드 워크플로우
2단계: Skill("frontend-design")       — 디자인 방향
3단계: 구현
```

### 코드 리뷰 (프론트엔드 파일)

```
1단계: Skill("frontend-code-review")  — 체크리스트 기반 리뷰
```

## 2. shadcn/ui 최우선 활용 (CRITICAL)

### 원칙

- **모든 UI 컴포넌트는 shadcn/ui를 먼저 확인**한다
- shadcn/ui에 해당 컴포넌트가 있으면 반드시 사용한다
- 커스텀 컴포넌트는 shadcn/ui에 없을 때만 생성한다
- shadcn/ui 설치 전이면 `npx shadcn@latest init` 부터 실행한다

### context7 조회 필수

구현 전 반드시 context7 MCP로 shadcn/ui 최신 문서를 조회한다:

```
1. mcp__context7__resolve-library-id("shadcn/ui")
2. mcp__context7__query-docs(libraryId, "사용할 컴포넌트명")
```

### 컴포넌트 매핑 참고

| 필요한 UI | shadcn/ui 컴포넌트 |
|-----------|-------------------|
| 버튼 | Button |
| 입력폼 | Input, Textarea, Form |
| 선택 | Select, Combobox, RadioGroup, Checkbox |
| 테이블 | Table, DataTable |
| 모달/다이얼로그 | Dialog, AlertDialog, Sheet |
| 내비게이션 | NavigationMenu, Breadcrumb, Tabs |
| 알림 | Toast, Alert, Sonner |
| 카드 | Card |
| 드롭다운 | DropdownMenu, ContextMenu |
| 날짜 | Calendar, DatePicker |
| 차트 | Chart (Recharts 기반) |
| 사이드바 | Sidebar |
| 캐러셀 | Carousel |
| 아코디언 | Accordion, Collapsible |
| 진행률 | Progress, Skeleton |
| 툴팁 | Tooltip, Popover, HoverCard |
| 검색/명령 | Command |
| 파일업로드 | (shadcn/ui에 없음 → 커스텀) |

## 3. 기본 기술 스택

신규 프로젝트에서 프론트엔드 구현 시 기본 스택:

- **React 19** + **TypeScript**
- **Tailwind CSS 4** (유틸리티 퍼스트)
- **shadcn/ui** (컴포넌트 라이브러리)
- **Lucide React** (아이콘)
- 상태관리: Zustand (필요시)
- 데이터 페칭: TanStack Query (필요시)
- 라우팅: React Router 또는 Next.js App Router

## 4. 금지 사항

| 금지 | 이유 |
|------|------|
| shadcn/ui에 있는 컴포넌트를 직접 구현 | 품질, 접근성, 일관성 저하 |
| MUI, Ant Design 등 다른 컴포넌트 라이브러리 사용 | shadcn/ui 우선 원칙 위반 (사용자가 명시적으로 요청한 경우 제외) |
| context7 조회 없이 shadcn/ui 코드 작성 | 최신 API와 다를 수 있음 |
| frontend-design 스킬 없이 UI 구현 시작 | 디자인 방향 없는 구현은 AI 슬롭 |
