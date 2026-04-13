---
allowed-tools: Bash(git:*), Bash(npm:*), Bash(pnpm:*), Bash(npx:*), Bash(python:*), Read, Write, Edit, Glob, Grep, Task
description: shadcn/ui 기반 프론트엔드 통합 파이프라인. 디자인 → 컴포넌트 선택 → 구현 → 시각 검증 → 코드 리뷰까지 원스톱 실행.
argument-hint: [작업 설명] [--mode page|component|improve|landing]
---

# /frontend - shadcn/ui 기반 프론트엔드 통합 워크플로우

프론트엔드 작업의 전체 파이프라인을 한 번에 자동 실행합니다.
디자인 방향 수립 → shadcn/ui 컴포넌트 선택 → 구현 → Playwright 시각 검증 → 코드 리뷰.

---

## IRON RULE: 파이프라인 규칙

```
[1~5단계]   필수 자동 진행 — 스킵 불가, 예외 없음
[6~7단계]   사용자 확인 후 진행
```

---

## 0단계: 인자 파싱

$ARGUMENTS에서 옵션을 추출한다:

| 인자 | 기본값 | 설명 |
|------|--------|------|
| `--mode` | page | 실행 모드: page / component / improve / landing |
| 나머지 텍스트 | - | 작업 설명 (필수) |

작업 설명이 없으면 에러를 출력하고 종료한다:

```
사용법: /frontend [작업 설명]

예시:
  /frontend 대시보드 페이지 만들기
  /frontend --mode component 데이터 테이블 컴포넌트
  /frontend --mode improve 로그인 페이지 디자인 개선
  /frontend --mode landing SaaS 제품 랜딩페이지
```

---

## 1단계: 모드별 파이프라인 결정

### page 모드 (기본) — 새 페이지 생성

```
[필수] design → shadcn-select → implement → visual-verify → code-review → [확인] commit
```

### component 모드 — 재사용 컴포넌트 생성

```
[필수] design → shadcn-select → implement → visual-verify → code-review → [확인] commit
```

### improve 모드 — 기존 UI 개선/미화

```
[필수] analyze → shadcn-select → improve → visual-verify → code-review → [확인] commit
```

### landing 모드 — 랜딩페이지 (11요소 프레임워크)

```
[필수] landing-framework → design → shadcn-select → implement → visual-verify → code-review → [확인] commit
```

---

## 2단계: 환경 확인

### 2-1. 프로젝트 감지

```bash
# React/Next.js 프로젝트인지 확인
ls package.json tsconfig.json 2>/dev/null
```

- `next.config.*` 존재 → Next.js 프로젝트
- `vite.config.*` 존재 → Vite + React 프로젝트
- 둘 다 없음 → 사용자에게 프레임워크 확인

### 2-2. shadcn/ui 설치 확인

```bash
# components.json 또는 ui 디렉토리 존재 여부
ls components.json 2>/dev/null || ls src/components/ui/ 2>/dev/null
```

- 있으면: 기존 설정 사용
- 없으면: 사용자에게 `npx shadcn@latest init` 실행 여부를 묻는다

### 2-3. 패키지 매니저 감지

pnpm-lock.yaml → pnpm / yarn.lock → yarn / bun.lockb → bun / 기본 → npm

### 2-4. 기존 디자인 시스템 파악

프로젝트의 기존 스타일을 파악한다:
- `tailwind.config.*` → 커스텀 색상, 폰트 확인
- `globals.css` → CSS 변수, 테마 확인
- 기존 컴포넌트 → 사용 중인 패턴 확인

**기존 프로젝트의 디자인 시스템이 있으면 그것을 존중한다. 새로 덮어쓰지 않는다.**

---

## 3단계: 파이프라인 실행

### [필수 1] Design — 디자인 방향 수립

코딩 전에 디자인 방향을 확정한다.

#### 신규 (page/component/landing 모드)

1. **목적 파악**: 이 UI가 해결하는 문제, 대상 사용자
2. **톤 결정**: 아래에서 선택하되 프로젝트 기존 톤이 있으면 그것을 따른다
   - 미니멀 / 맥시멀리스트 / 레트로 퓨처리스틱 / 럭셔리 / 플레이풀 / 에디토리얼 / 브루탈리스트 / 소프트 파스텔 / 인더스트리얼
3. **레이아웃 스케치**: 섹션 구성을 텍스트로 정리
4. **차별점**: 이 UI의 기억에 남을 포인트 1가지

#### 개선 (improve 모드)

1. **현재 상태 분석**: 기존 파일을 읽고 문제점 파악
2. **개선 방향**: 구체적으로 무엇을 어떻게 바꿀지 정리
3. **유지할 것**: 기존 기능/로직 중 건드리지 않을 부분 명시

#### AI 슬롭 방지 (CRITICAL)

다음은 금지한다:
- Inter, Roboto, Arial 같은 범용 폰트만 사용
- 흰 배경 + 보라 그라디언트 조합
- 모든 카드가 동일한 둥근 모서리 + 그림자
- 개성 없는 틀에 박힌 레이아웃

다음을 추구한다:
- 프로젝트에 맞는 독특한 폰트 조합
- 강한 악센트 색상
- 의도적인 레이아웃 (비대칭, 여백 활용, 그리드 변형)
- 마이크로 인터랙션 (hover, scroll trigger, page load animation)

### [필수 2] shadcn-select — 컴포넌트 선택 및 문서 조회

**context7 MCP로 shadcn/ui 최신 문서를 반드시 조회한다.**

```
1. mcp__context7__resolve-library-id → libraryName: "shadcn/ui"
2. mcp__context7__query-docs → 필요한 컴포넌트별 최신 사용법 조회
```

#### shadcn/ui 공식 컴포넌트 전체 목록 (58개)

디자인에서 필요한 UI 요소를 아래 목록에서 먼저 찾는다.
**이 목록에 있으면 반드시 shadcn/ui를 사용한다. 직접 구현 금지.**

| 카테고리 | 컴포넌트 | 설명 |
|----------|----------|------|
| **레이아웃** | Aspect Ratio | 비율 유지 컨테이너 |
| | Card | 헤더/콘텐츠/푸터 카드 |
| | Collapsible | 접기/펼치기 패널 |
| | Resizable | 크기 조절 가능한 패널 |
| | Scroll Area | 커스텀 스크롤바 |
| | Separator | 구분선 |
| | Sidebar | 사이드바 (테마/커스터마이징 내장) |
| **내비게이션** | Breadcrumb | 경로 탐색 |
| | Menubar | 데스크톱 메뉴바 |
| | Navigation Menu | 사이트 내비게이션 |
| | Pagination | 페이지네이션 |
| | Tabs | 탭 패널 |
| **버튼/액션** | Button | 버튼 (variant: default/destructive/outline/secondary/ghost/link) |
| | Button Group | 버튼 그룹 컨테이너 |
| | Toggle | 토글 버튼 (on/off) |
| | Toggle Group | 토글 버튼 그룹 |
| **입력/폼** | Checkbox | 체크박스 |
| | Combobox | 자동완성 입력 |
| | Date Picker | 날짜 선택기 |
| | Field | 라벨+입력+도움말 조합 |
| | Input | 텍스트 입력 |
| | Input Group | 입력 + 애드온/버튼 조합 |
| | Input OTP | 일회용 비밀번호 입력 |
| | Label | 접근성 라벨 |
| | Native Select | 네이티브 HTML select |
| | Radio Group | 라디오 버튼 그룹 |
| | Select | 드롭다운 선택 |
| | Slider | 범위 슬라이더 |
| | Switch | 스위치 토글 |
| | Textarea | 멀티라인 입력 |
| **데이터 표시** | Avatar | 사용자 아바타 (이미지+폴백) |
| | Badge | 배지/태그 |
| | Calendar | 달력 |
| | Carousel | 캐러셀 (Embla 기반) |
| | Chart | 차트 (Recharts 기반) |
| | Data Table | 데이터 테이블 (TanStack Table 기반) |
| | Empty | 빈 상태 표시 |
| | Item | 미디어+제목+설명+액션 조합 |
| | Kbd | 키보드 단축키 표시 |
| | Progress | 진행률 바 |
| | Skeleton | 로딩 플레이스홀더 |
| | Spinner | 로딩 인디케이터 |
| | Table | 반응형 테이블 |
| | Typography | 제목/본문/목록 등 타이포그래피 |
| **오버레이/팝업** | Alert Dialog | 확인 다이얼로그 |
| | Command | 검색/명령 메뉴 (⌘K) |
| | Context Menu | 우클릭 메뉴 |
| | Dialog | 모달 다이얼로그 |
| | Drawer | 서랍형 패널 |
| | Dropdown Menu | 드롭다운 메뉴 |
| | Hover Card | 호버 미리보기 카드 |
| | Popover | 팝오버 |
| | Sheet | 사이드 시트 패널 |
| | Tooltip | 툴팁 |
| **피드백** | Alert | 알림 배너 |
| | Sonner | 토스트 알림 (권장) |
| | Toast | 토스트 알림 (레거시) |
| **유틸** | Direction | RTL/LTR 방향 설정 |

> 이 목록에 없는 UI가 필요하면 [shadcn/ui Registry Directory](https://ui.shadcn.com/docs/directory)에서 커뮤니티 컴포넌트를 먼저 확인한다.

#### shadcn/ui 최우선 원칙 (CRITICAL)

1. **위 표에 있는 컴포넌트는 반드시 shadcn/ui를 사용한다**
2. shadcn/ui에 없는 것만 직접 구현한다 (예: 파일 업로드, 커스텀 차트)
3. MUI, Ant Design 등 다른 라이브러리 사용 금지 (사용자 명시 요청 시 제외)
4. context7 조회 없이 shadcn/ui 코드 작성 금지 — API가 변경되었을 수 있음
5. 아이콘은 Lucide React 사용 (`lucide-react`)

#### 미설치 컴포넌트 자동 설치

매핑 결과 미설치 컴포넌트가 있으면:
```bash
npx shadcn@latest add [컴포넌트1] [컴포넌트2] ...
```

### [필수 3] Implement — 구현

#### 기본 기술 스택

| 항목 | 기본값 |
|------|--------|
| 프레임워크 | React 19 + TypeScript |
| 스타일 | Tailwind CSS 4 |
| 컴포넌트 | shadcn/ui |
| 아이콘 | Lucide React |
| 상태관리 | Zustand (필요시) |
| 데이터 페칭 | TanStack Query (필요시) |
| 폼 | react-hook-form + zod (필요시) |
| 애니메이션 | Motion (필요시) |

#### 구현 규칙

1. **파일 구조**: 기존 프로젝트 구조를 따른다. 없으면 feature 기반 구조를 사용한다.
2. **컴포넌트 분리**: 한 파일 200-400줄. 초과하면 분리한다.
3. **타입 안전**: Props에 TypeScript interface 정의. `any` 금지.
4. **반응형**: 모바일 퍼스트. `sm:` → `md:` → `lg:` → `xl:` 순서.
5. **접근성**: 시맨틱 HTML, ARIA 레이블, 키보드 네비게이션, 색상 대비 AA 이상.
6. **cn() 유틸**: 조건부 클래스는 `cn()` 사용. 문자열 연결 금지.
7. **서버/클라이언트 분리** (Next.js): `'use client'`는 필요한 컴포넌트에만 최소 범위로.

#### landing 모드 추가 규칙 (11요소 프레임워크)

landing 모드에서는 다음 11가지 요소를 반드시 포함한다:

1. SEO 최적화된 URL
2. 회사 로고 (좌측 상단)
3. SEO 제목 + 부제목
4. 주요 CTA (히어로 섹션)
5. 소셜 프루프 (리뷰, 통계)
6. 이미지/비디오
7. 핵심 혜택/기능 (3-6개)
8. 고객 후기 (4-6개)
9. FAQ (Accordion, 5-10개)
10. 최종 CTA (하단)
11. 연락처/법적 정보 (Footer)

컴포넌트 매핑:
- Hero CTA → `Button` size="lg"
- Benefits → `Card`
- Testimonials → `Card` + `Avatar` + `Badge`
- FAQ → `Accordion`
- Final CTA → `Button` + `Card`
- Footer → `Separator`

### [필수 4] Visual Verify — 시각 검증

Playwright로 실제 브라우저에서 결과를 검증한다.

```python
# 자동 생성되는 검증 스크립트 패턴
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:PORT')
    page.wait_for_load_state('networkidle')

    # 데스크톱 스크린샷
    page.screenshot(path='/tmp/frontend-desktop.png', full_page=True)

    # 모바일 스크린샷
    page.set_viewport_size({"width": 375, "height": 812})
    page.screenshot(path='/tmp/frontend-mobile.png', full_page=True)

    browser.close()
```

검증 체크리스트:
- [ ] 페이지가 에러 없이 렌더링되는가
- [ ] 데스크톱/모바일 모두 레이아웃이 깨지지 않는가
- [ ] shadcn/ui 컴포넌트가 정상적으로 표시되는가
- [ ] 콘솔에 에러/경고가 없는가

스크린샷을 사용자에게 보여주고 피드백을 받는다.
피드백이 있으면 3단계(Implement)로 돌아가 수정 후 재검증한다.

### [필수 5] Code Review — 프론트엔드 코드 리뷰

변경된 `.tsx`, `.ts`, `.css` 파일에 대해 체크리스트 기반 리뷰를 수행한다.

#### 코드 품질
- [ ] 조건부 클래스에 `cn()` 유틸 사용
- [ ] Tailwind 우선 스타일링 (불필요한 CSS 모듈 금지)
- [ ] className prop이 컴포넌트 자체 클래스 뒤에 위치 (오버라이드 가능)
- [ ] shadcn/ui 컴포넌트 사용 가능한 곳에서 직접 구현하지 않았는가

#### 성능
- [ ] 불필요한 리렌더링 방지 (memo, useMemo, useCallback 적절히 사용)
- [ ] 이미지 최적화 (Next.js Image 또는 lazy loading)
- [ ] 번들 크기 (불필요한 import 없는가)

#### 접근성
- [ ] 시맨틱 HTML 사용
- [ ] alt 텍스트, ARIA 레이블
- [ ] 키보드 네비게이션
- [ ] 색상 대비 AA 이상

#### 출력 형식

```
[Frontend Code Review]
  긴급 이슈: N건
  개선 제안: M건

  ## 긴급 1: [설명]
  FilePath: path:line
  Suggested fix: ...
```

CRITICAL/HIGH 이슈는 자동 수정한다.

### [확인 6] Commit — 커밋 (사용자 승인)

5단계까지 완료 후 사용자에게 묻는다:
- "커밋하시겠습니까? (Y/N)"
- 승인 시 conventional commit 형식으로 커밋

### [확인 7] Feedback Loop — 추가 수정 (선택)

사용자가 스크린샷을 보고 추가 피드백을 줄 수 있다.
피드백이 있으면 3단계(Implement)부터 재실행한다.

---

## 4단계: 결과 요약

### 성공 시

```
======================================================================
  Frontend Complete - [mode] 모드
======================================================================

  작업: [작업 설명]

  실행 결과:
    [1] Design          DONE   톤: [선택된 톤] | 레이아웃: [N]개 섹션
    [2] shadcn-select   DONE   [N]개 컴포넌트 선택 | [M]개 신규 설치
    [3] Implement       DONE   [N]개 파일 생성/수정
    [4] Visual Verify   PASS   데스크톱 + 모바일 스크린샷 확인
    [5] Code Review     DONE   긴급 0 / 제안 [N]건

  사용 컴포넌트: Button, Card, Table, Dialog, ...
  스크린샷: /tmp/frontend-desktop.png, /tmp/frontend-mobile.png

======================================================================
```

### 부분 실패 시

```
======================================================================
  Frontend Incomplete - [mode] 모드
======================================================================

  작업: [작업 설명]

  실행 결과:
    [1] Design          DONE
    [2] shadcn-select   DONE   3개 컴포넌트 설치
    [3] Implement       DONE
    [4] Visual Verify   FAIL   모바일 레이아웃 깨짐
    [5] Code Review     SKIP   (검증 실패)

  실패 상세:
    - 375px 뷰포트에서 사이드바 오버플로우
    - 스크린샷: /tmp/frontend-mobile.png 참조

  수정 후: /frontend --mode improve [설명]

======================================================================
```

---

## 사용 예시

```bash
# 새 페이지 (기본 모드)
/frontend 대시보드 페이지 만들기

# 컴포넌트
/frontend --mode component 사용자 목록 데이터 테이블

# 기존 디자인 개선
/frontend --mode improve 로그인 페이지를 더 세련되게

# 랜딩페이지 (11요소 프레임워크)
/frontend --mode landing AI 기반 주식 분석 서비스 소개 페이지
```

---

## 다른 스킬과의 관계

이 스킬은 다음 기존 스킬들의 핵심을 통합한 것이다:
- `frontend-design` → Design 단계에 흡수
- `frontend-code-review` → Code Review 단계에 흡수
- `webapp-testing` → Visual Verify 단계에 흡수
- `landing-page-guide` → landing 모드에 흡수

`/auto` 파이프라인과 함께 사용 가능:
- `/auto`는 백엔드 중심 (TDD, 빌드 검증, 린트)
- `/frontend`는 프론트엔드 중심 (디자인, shadcn/ui, 시각 검증)
