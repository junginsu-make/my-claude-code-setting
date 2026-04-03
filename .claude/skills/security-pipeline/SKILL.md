---
name: security-pipeline
description: 보안 파이프라인 - CWE Top 25 + STRIDE 자동 검증
version: 2.0.0
---

## 개요

보안 파이프라인 스킬은 코드 변경 시 자동으로 CWE Top 25 기반 보안 검증을 수행한다.
`/handoff-verify --security`, `/commit-push-pr` 실행 시 통합 동작한다.
보안 체크리스트 참조: `~/.claude/skills/security-pipeline/_reference/security-checklist.md`

effort:max가 항상 강제 적용된다. 보안 검증은 축약하지 않는다.

---

## 트리거 조건

### 파일 패턴 기반 자동 트리거

다음 패턴을 포함하는 파일이 변경되면 보안 파이프라인이 자동으로 실행된다:

| 패턴 | 트리거 수준 | 설명 |
|------|-------------|------|
| `**/auth/**` | 전체 스캔 | 인증 관련 모듈 |
| `**/payment/**` | 전체 스캔 | 결제 처리 모듈 |
| `**/api/**` | CWE 스캔 | API 엔드포인트 |
| `**/middleware/**` | CWE 스캔 | 미들웨어 |
| `**/session*` | CWE 스캔 | 세션 관리 |
| `**/token*` | CWE 스캔 | 토큰 처리 |
| `**/crypto*` | CWE 스캔 | 암호화 로직 |
| `**/admin/**` | 전체 + STRIDE | 관리자 기능 |
| `**/upload*` | CWE 스캔 | 파일 업로드 |
| `**/.env*` | 인증정보 스캔 | 환경변수 파일 |
| `**/config/secret*` | 인증정보 스캔 | 시크릿 설정 |

### 커밋 기반 자동 트리거

`/commit-push-pr` 실행 시 staged 파일 목록에서 위 패턴이 감지되면,
커밋 전 보안 파이프라인이 자동으로 실행된다.

---

## CWE 스캔 규칙

### Critical (커밋 차단)

| CWE ID | 규칙 | Grep 패턴 |
|--------|------|-----------|
| CWE-89 | SQL 인젝션 | `query\(.*\$\{`, `query\(.*\+` |
| CWE-79 | XSS | `innerHTML`, `dangerouslySetInnerHTML`, `v-html` |
| CWE-78 | OS 명령어 인젝션 | `exec\(.*\$\{`, `spawn\(.*req\.` |
| CWE-77 | 명령어 인젝션 | 셸 명령어 내 템플릿 문자열 |
| CWE-798 | 하드코딩된 인증정보 | `apiKey\s*=\s*['"]`, `secret\s*=\s*['"]` |

### High (경고, 커밋 허용)

| CWE ID | 규칙 | Grep 패턴 |
|--------|------|-----------|
| CWE-22 | 경로 탐색 | `\.\.\/` 사용자 입력과 함께 |
| CWE-352 | CSRF | csrf 검사 없는 POST 핸들러 |
| CWE-287 | 부적절한 인증 | auth 미들웨어 없는 라우트 |
| CWE-862 | 인가 누락 | 역할/권한 검사 없는 핸들러 |
| CWE-502 | 안전하지 않은 역직렬화 | `eval\(`, `new Function\(` |
| CWE-918 | SSRF | `fetch\(.*req\.`, `axios.*req\.` |
| CWE-434 | 무제한 업로드 | 검증 없는 업로드 |
| CWE-269 | 권한 상승 | 검증 없는 역할 변경 |

### Medium (정보 제공)

| CWE ID | 규칙 | Grep 패턴 |
|--------|------|-----------|
| CWE-200 | 정보 노출 | `console\.log.*password\|token\|secret` |
| CWE-20 | 입력 검증 | 스키마 검증 없는 엔드포인트 |
| CWE-327 | 취약한 암호화 | `md5\(`, `sha1\(`, `Math\.random\(\)` |
| CWE-276 | 잘못된 권한 | `origin:\s*['"]?\*`, `0o?777` |

---

## 자동 수정 규칙

자동 수정은 사용자 승인 후 적용한다. 신뢰도가 High인 항목만 자동 수정 대상이다.

### 매개변수화 쿼리 (CWE-89)

```
Before: db.query(`SELECT * FROM users WHERE id = '${id}'`)
After:  db.query('SELECT * FROM users WHERE id = $1', [id])
```

### 환경 변수 (CWE-798)

```
Before: const apiKey = 'sk-proj-abc123'
After:  const apiKey = process.env.API_KEY
+ .env.example에 API_KEY= 추가
```

### 안전한 DOM 조작 (CWE-79)

```
Before: element.innerHTML = userInput
After:  element.textContent = userInput
```

### 민감 로그 제거 (CWE-200)

```
Before: console.log('Token:', token)
After:  // (라인 제거됨)
```

### 안전한 해시 (CWE-327)

```
Before: const hash = md5(data)
After:  const hash = crypto.createHash('sha256').update(data).digest('hex')
```

---

## 통합 지점

### /handoff-verify (v6)

`/handoff-verify` 커맨드의 검증 단계에서 보안 검사가 포함된다.
verify-agent가 민감 파일 변경을 감지하면 이 스킬을 자동 호출한다.

### /commit-push-pr

커밋 전 자동 보안 게이트로 동작한다:
- Critical 발견 시: 커밋 차단 (BLOCKED)
- High 발견 시: 경고 표시 후 사용자 확인 (WARN)
- Medium 이하만 존재: 통과 (PASS)

### /security-review (통합됨)

이전 security-review 스킬의 OWASP 체크리스트는 스킬 내 `_reference/security-checklist.md`로 전환.
전체 보안 리뷰 시 이 스킬의 CWE Top 25 매핑 + STRIDE + 의존성 검사가 수행되며,
체크리스트 참조 파일을 함께 로드한다.

---

## effort:max 강제 적용

이 스킬은 항상 effort:max로 실행된다.
보안 검증에서 분석 깊이를 줄이는 것은 허용하지 않는다.

적용 범위:
- CWE 패턴 매칭 시 false positive 최소화를 위한 컨텍스트 분석
- STRIDE 분류 시 전체 데이터 흐름 추적
- 자동 수정 제안 시 사이드 이펙트 검증
- 의존성 검사 시 transitive dependency 포함
