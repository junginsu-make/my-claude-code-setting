---
name: my-help
description: 설치된 모든 기능의 사용법을 안내합니다. 도움이 필요할 때 /my-help를 입력하세요.
---

# Claude Code 사용 가이드

사용자에게 아래 내용을 **한국어**로 보기 좋게 정리하여 안내해주세요.

## 핵심 워크플로우 명령어

### 프로젝트 시작
| 명령/입력 | 설명 |
|-----------|------|
| "새 프로젝트 시작해줘" | project-system 스킬 → 21개 질문 기반 기획 시작 |
| "Next.js 프로젝트 만들어줘" | nextjs15-init 스킬 → 프로젝트 스캐폴딩 |
| "Flutter 프로젝트 만들어줘" | flutter-init 스킬 → 모바일 앱 스캐폴딩 |

### 개발 (가장 자주 사용)
| 명령 | 설명 |
|------|------|
| `/auto [설명]` | **원버튼 자동화** — 계획→TDD→리뷰→검증→커밋 전체 파이프라인 |
| `/plan` | 구현 전 계획 수립 (3개+ 파일 변경 시 자동 권장) |
| `/tdd` | 테스트 먼저 작성 → 코드 구현 → 리팩토링 |
| `/code-review` | 보안 + 품질 코드 리뷰 |

### 검증 & 배포
| 명령 | 설명 |
|------|------|
| `/handoff-verify` | 신선한 컨텍스트에서 빌드/테스트/린트 자동 검증 |
| `/commit-push-pr` | Git 커밋 + 푸시 + GitHub PR 자동 생성 |
| `/quick-commit` | 빠른 커밋만 |

### 에이전트 팀 (대규모 기능)
| 사용법 | 설명 |
|--------|------|
| "에이전트 팀 만들어서 [기능] 구현해줘" | 여러 Claude 인스턴스가 병렬 작업 |
| "3명의 팀원으로 팀 만들어줘" | 팀원 수 지정 가능 |
| Shift+Down | 팀원 간 이동 |
| "팀 정리해줘" | 작업 완료 후 정리 |

### 세션 관리
| 명령 | 설명 |
|------|------|
| `/session-wrap` | 세션 종료 시 문서 업데이트 + 다음 할일 정리 |
| `/sync` | 프로젝트 상태 동기화 |
| `/explore` | 코드베이스 탐색 |

### 유틸리티
| 명령 | 설명 |
|------|------|
| `/guide` | 3분 온보딩 가이드 |
| `/security-review` | 보안 전용 리뷰 |
| `/e2e` | E2E 테스트 실행 |
| `/refactor-clean` | 데드코드 제거 |
| `/update-docs` | 문서 자동 갱신 |
| `/debugging-strategies` | 디버깅 전략 가이드 |

## 설치된 스킬 (자동 트리거 — 필요시 자연어로 요청)

### 프로젝트/개발
- **project-system**: "새 프로젝트 시작" → 5단계 기획 프레임워크
- **nextjs15-init**: Next.js 15 프로젝트 자동 생성
- **flutter-init**: Flutter 프로젝트 자동 생성
- **prompt-enhancer**: 간단한 요청을 상세 요구사항으로 변환
- **codex-claude-loop**: 이중 AI 검증 (Claude 작성 + Codex 검토)

### 디자인/콘텐츠
- **frontend-design**: 프로급 웹 디자인 가이드 (anti-AI slop)
- **theme-factory**: 10개 프리셋 테마 + 커스텀 테마 생성
- **canvas-design**: 시각 디자인 아트워크
- **brand-guidelines**: 브랜드 일관성 가이드
- **landing-page-guide**: 고전환 랜딩페이지 가이드
- **card-news-generator-v2**: 인스타그램 카드뉴스 자동 생성

### 문서
- **docx**: Word 문서 생성/편집
- **xlsx**: Excel 스프레드시트 생성
- **pdf**: PDF 처리 (읽기/생성/병합/암호화)
- **pptx**: PowerPoint 프레젠테이션 생성

### 개발 도구
- **claude-api**: Claude API/SDK 8개 언어 레퍼런스
- **webapp-testing**: Playwright 기반 웹앱 테스트
- **web-artifacts-builder**: React 아티팩트 빌드 (shadcn/ui)
- **skill-creator**: 나만의 스킬 생성/평가
- **mcp-builder**: MCP 서버 개발 가이드
- **code-changelog**: 코드 변경사항 자동 문서화
- **meta-prompt-generator**: 커스텀 슬래시 명령 생성

### 커뮤니케이션
- **internal-comms**: 사내 커뮤니케이션 템플릿
- **doc-coauthoring**: 문서 공동 작성 워크플로우

## 서브에이전트 (자동 위임)
- **planner**: 구현 계획 수립 (Opus)
- **architect**: 시스템 설계/디버깅 (Opus)
- **code-reviewer**: 코드 리뷰 (Opus)
- **security-reviewer**: OWASP 보안 분석 (Opus)
- **tdd-guide**: TDD 워크플로우 (Opus)
- **database-reviewer**: DB 전문 리뷰 (Opus)
- **build-error-resolver**: 빌드 에러 수정 (Sonnet)
- **e2e-runner**: E2E 테스트 (Sonnet)
- **verify-agent**: 검증 (Sonnet)

## GitHub 연동
```
gh auth login          # 최초 1회 인증
gh pr create          # PR 생성
gh issue list         # 이슈 목록
gh pr view [번호]     # PR 확인
```

## 팁
- **대규모 기능**: "에이전트 팀으로 해줘" → 병렬 개발
- **단순 수정**: 그냥 설명하면 됨 → 자동 처리
- **품질 보장**: `/handoff-verify`로 항상 마무리
- **기획 먼저**: 복잡한 건 `/plan` 먼저
