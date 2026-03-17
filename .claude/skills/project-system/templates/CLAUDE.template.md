# CLAUDE.md

> 이 파일은 Claude Code가 프로젝트 컨텍스트를 빠르게 파악하도록 돕습니다.

## 프로젝트 개요

- **이름**: {{PROJECT_NAME}}
- **설명**: {{PROJECT_DESCRIPTION}}
- **기술 스택**: {{TECH_STACK}}

## 빠른 시작

```bash
# 설치
{{INSTALL_COMMAND}}

# 개발 서버
{{DEV_COMMAND}}

# 테스트
{{TEST_COMMAND}}
```

## 프로젝트 구조

```
{{PROJECT_STRUCTURE}}
```

## 컨벤션

- 커밋 메시지: Conventional Commits
- 브랜치 전략: feature/*, fix/*, phase/*
- 코드 스타일: Prettier (TS), Ruff (Python)

---

## Development History

> 프로젝트 개발 진행 상황과 업데이트 내역을 기록합니다.
> Phase 완료, 주요 기능 추가, 버그 수정 등을 날짜와 함께 기록하여
> 나중에 프로젝트에 재진입할 때 전체 맥락을 파악할 수 있습니다.

### 프로젝트 상태

| 항목 | 상태 | 최종 업데이트 |
|------|------|--------------|
| **현재 버전** | v0.1.0 | YYYY-MM-DD |
| **현재 Phase** | Phase 1 | YYYY-MM-DD |
| **다음 마일스톤** | M1 완료 | YYYY-MM-DD 예정 |

### Phase 진행 현황

| Phase | 상태 | 시작일 | 완료일 | 비고 |
|-------|------|--------|--------|------|
| Phase 0: 셋업 | ✅ 완료 | YYYY-MM-DD | YYYY-MM-DD | 초기 구조 생성 |
| Phase 1: 기능A | 🔄 진행중 | YYYY-MM-DD | - | T1.1~T1.3 |
| Phase 2: 기능B | ⏳ 대기 | - | - | |

### 업데이트 로그

> 최신 항목이 위로 오도록 역순으로 기록합니다.

```markdown
## [YYYY-MM-DD] v0.1.0 - 제목
### Added
- 새로 추가된 기능

### Changed
- 변경된 사항

### Fixed
- 수정된 버그

### Notes
- 특이사항, 다음 작업 계획 등
```

<!-- 아래에 실제 업데이트 로그를 기록합니다 -->

---

## Lessons Learned

> 에이전트가 난관을 극복하며 발견한 교훈을 기록합니다.
> 같은 실수를 반복하지 않도록 짧고 검색 가능하게 작성합니다.

### 작성 형식

```markdown
### [YYYY-MM-DD] 제목 (키워드)
- **상황**: 무엇을 하려다 문제가 발생했는가
- **문제**: 어떤 에러/이슈가 발생했는가
- **원인**: 왜 발생했는가 (root cause)
- **해결**: 어떻게 해결했는가
- **교훈**: 다음에 주의할 점
```

### 예시

```markdown
### [2024-01-09] SQLAlchemy async detached instance (async, session, ORM)
- **상황**: 비동기 세션에서 관계 객체 접근 시도
- **문제**: `DetachedInstanceError: Instance is not bound to a Session`
- **원인**: `expire_on_commit=True`(기본값)로 커밋 후 객체가 만료됨
- **해결**: `async_sessionmaker(expire_on_commit=False)` 설정
- **교훈**: 비동기 ORM에서는 항상 `expire_on_commit=False` 사용

### [2024-01-08] Vite CORS 프록시 설정 (Vite, CORS, proxy)
- **상황**: 프론트에서 백엔드 API 호출
- **문제**: `Access-Control-Allow-Origin` CORS 에러
- **원인**: 개발 서버가 다른 포트에서 실행되어 cross-origin 요청 발생
- **해결**: `vite.config.ts`에 `server.proxy` 설정 추가
- **교훈**: 풀스택 개발 시 프록시 설정 먼저 확인
```

---

<!-- 아래에 실제 교훈을 기록합니다 -->

