---
name: update-codemaps
description: Update Codemaps
---

# Update Codemaps

코드베이스 구조를 분석하고 아키텍처 문서를 업데이트합니다:

1. 모든 소스 파일에서 import, export, 의존성을 스캔
2. 다음 형식으로 토큰 효율적인 코드맵을 생성:
   - codemaps/architecture.md - 전체 아키텍처
   - codemaps/backend.md - 백엔드 구조
   - codemaps/frontend.md - 프론트엔드 구조
   - codemaps/data.md - 데이터 모델 및 스키마

3. 이전 버전과의 변경 비율 계산
4. 변경이 30% 초과 시 업데이트 전 사용자 승인 요청
5. 각 코드맵에 최신 타임스탬프 추가
6. 보고서를 .reports/codemap-diff.txt에 저장

TypeScript/Node.js로 분석. 구현 세부사항이 아닌 고수준 구조에 집중.
