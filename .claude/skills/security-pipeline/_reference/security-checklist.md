# Security Checklist (OWASP + CWE Top 25)

보안 파이프라인에서 참조하는 통합 보안 체크리스트.

---

## Critical (커밋 차단)

- [ ] **CWE-89** SQL Injection: 모든 DB 쿼리가 파라미터화되어 있는가?
- [ ] **CWE-79** XSS: `innerHTML`, `dangerouslySetInnerHTML`, `v-html` 사용 없는가?
- [ ] **CWE-78** OS Command Injection: 사용자 입력이 shell 명령에 포함되지 않는가?
- [ ] **CWE-77** Command Injection: 템플릿 문자열이 shell 명령에 사용되지 않는가?
- [ ] **CWE-798** Hardcoded Credentials: API 키, 시크릿이 하드코딩되지 않았는가?

## High (경고)

- [ ] **CWE-22** Path Traversal: 사용자 입력 기반 파일 경로에 `../` 방어가 있는가?
- [ ] **CWE-352** CSRF: POST 핸들러에 CSRF 토큰 검증이 있는가?
- [ ] **CWE-287** Improper Authentication: 모든 라우트에 인증 미들웨어가 적용되어 있는가?
- [ ] **CWE-862** Missing Authorization: 핸들러에 역할/권한 검사가 있는가?
- [ ] **CWE-502** Unsafe Deserialization: `eval()`, `new Function()` 사용이 없는가?
- [ ] **CWE-918** SSRF: 외부 요청 URL이 사용자 입력에서 직접 오지 않는가?
- [ ] **CWE-434** Unrestricted Upload: 파일 업로드에 타입/크기 검증이 있는가?
- [ ] **CWE-269** Privilege Escalation: 역할 변경에 검증 로직이 있는가?

## Medium (정보 제공)

- [ ] **CWE-200** Info Disclosure: 로그에 password/token/secret이 출력되지 않는가?
- [ ] **CWE-20** Input Validation: 엔드포인트에 스키마 검증이 있는가?
- [ ] **CWE-327** Broken Crypto: `md5()`, `sha1()`, `Math.random()` 대신 안전한 대안을 사용하는가?
- [ ] **CWE-276** Incorrect Permissions: `origin: '*'`, `0o777` 등 과도한 권한이 없는가?

---

## STRIDE 위협 모델링 체크리스트

| 위협 | 질문 | 검증 |
|------|------|------|
| **S**poofing | 인증을 우회할 수 있는가? | 인증 미들웨어 확인 |
| **T**ampering | 데이터를 변조할 수 있는가? | 입력 검증, 무결성 검사 |
| **R**epudiation | 행위를 부인할 수 있는가? | 감사 로그 존재 여부 |
| **I**nfo Disclosure | 민감 정보가 노출되는가? | 에러 메시지, 로그 검토 |
| **D**enial of Service | 서비스를 중단시킬 수 있는가? | Rate limiting, 리소스 제한 |
| **E**levation of Privilege | 권한을 상승시킬 수 있는가? | 역할 기반 접근 제어 |

---

## 의존성 보안

- [ ] `npm audit` / `pnpm audit` 결과에 critical/high 취약점이 없는가?
- [ ] 알려진 취약 버전의 패키지를 사용하지 않는가?
- [ ] 불필요한 의존성이 포함되지 않았는가?

## 환경 변수 및 시크릿

- [ ] `.env` 파일이 `.gitignore`에 포함되어 있는가?
- [ ] 시크릿이 환경변수를 통해서만 접근되는가?
- [ ] 시크릿 미설정 시 즉시 에러를 발생시키는가?
