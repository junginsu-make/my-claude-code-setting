---
name: update-docs
description: Update Documentation
---

# Update Documentation

소스 기준 문서와 동기화합니다:

1. package.json scripts 섹션 읽기
   - 스크립트 참조 테이블 생성
   - 주석의 설명 포함

2. .env.example 읽기
   - 모든 환경 변수 추출
   - 용도와 형식 문서화

3. docs/CONTRIB.md 생성:
   - 개발 워크플로우
   - 사용 가능한 스크립트
   - 환경 설정
   - 테스트 절차

4. docs/RUNBOOK.md 생성:
   - 배포 절차
   - 모니터링 및 알림
   - 일반적인 이슈와 해결법
   - 롤백 절차

5. 오래된 문서 식별:
   - 90일 이상 수정되지 않은 문서 찾기
   - 수동 검토 목록 생성

6. 변경 요약 표시

단일 정보 소스: package.json 및 .env.example
