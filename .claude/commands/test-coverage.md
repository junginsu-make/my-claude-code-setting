---
name: test-coverage
description: Test Coverage
---

# Test Coverage

테스트 커버리지를 분석하고 누락된 테스트를 생성합니다:

1. 커버리지 포함 테스트 실행: npm test --coverage 또는 pnpm test --coverage

2. 커버리지 보고서 분석 (coverage/coverage-summary.json)

3. 80% 커버리지 임계값 미달 파일 식별

4. 커버리지 미달 파일마다:
   - 테스트되지 않은 코드 경로 분석
   - 함수용 단위 테스트 생성
   - API용 통합 테스트 생성
   - 핵심 플로우용 E2E 테스트 생성

5. 새 테스트 통과 확인

6. 변경 전/후 커버리지 지표 표시

7. 프로젝트 전체 80%+ 커버리지 달성 확인

중점 영역:
- 정상 경로 시나리오
- 에러 처리
- 엣지 케이스 (null, undefined, empty)
- 경계 조건
