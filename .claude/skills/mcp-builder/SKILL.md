---
name: mcp-builder
description: LLM이 잘 설계된 도구를 통해 외부 서비스와 상호작용할 수 있게 해주는 고품질 MCP(Model Context Protocol) 서버를 만드는 가이드입니다. Python(FastMCP) 또는 Node/TypeScript(MCP SDK)로 외부 API나 서비스를 통합하는 MCP 서버를 구축할 때 사용하세요.
license: Complete terms in LICENSE.txt
---

# MCP 서버 개발 가이드

## 개요

LLM이 잘 설계된 도구를 통해 외부 서비스와 상호작용할 수 있게 해주는 MCP(Model Context Protocol) 서버를 만듭니다. MCP 서버의 품질은 LLM이 실제 작업을 얼마나 잘 수행할 수 있게 해주는지로 측정됩니다.

---

# 프로세스

## 상위 수준 워크플로우

고품질 MCP 서버를 만드는 데는 네 가지 주요 단계가 있습니다:

### 1단계: 심층 조사 및 계획

#### 1.1 최신 MCP 설계 이해

**API 커버리지 vs. 워크플로우 도구:**
포괄적인 API 엔드포인트 커버리지와 특화된 워크플로우 도구 사이의 균형을 맞추세요. 워크플로우 도구는 특정 작업에 더 편리할 수 있고, 포괄적인 커버리지는 에이전트에게 작업을 조합할 유연성을 줍니다. 클라이언트마다 성능이 다릅니다 — 일부는 기본 도구를 결합하는 코드 실행이 유리하고, 일부는 상위 수준 워크플로우가 더 효과적입니다. 불확실할 때는 포괄적인 API 커버리지를 우선하세요.

**도구 네이밍과 검색 가능성:**
명확하고 설명적인 도구 이름은 에이전트가 적절한 도구를 빠르게 찾는 데 도움이 됩니다. 일관된 접두사(예: `github_create_issue`, `github_list_repos`)와 행동 지향적 네이밍을 사용하세요.

**컨텍스트 관리:**
에이전트는 간결한 도구 설명과 결과 필터링/페이지네이션 기능의 혜택을 받습니다. 집중된 관련 데이터를 반환하는 도구를 설계하세요. 일부 클라이언트는 에이전트가 데이터를 효율적으로 필터링하고 처리하는 데 도움이 되는 코드 실행을 지원합니다.

**실행 가능한 오류 메시지:**
오류 메시지는 구체적인 제안과 다음 단계로 에이전트를 해결 방향으로 안내해야 합니다.

#### 1.2 MCP 프로토콜 문서 학습

**MCP 명세를 탐색하세요:**

사이트맵에서 관련 페이지를 찾으세요: `https://modelcontextprotocol.io/sitemap.xml`

그런 다음 마크다운 형식을 위해 `.md` 접미사로 특정 페이지를 가져오세요 (예: `https://modelcontextprotocol.io/specification/draft.md`).

검토할 주요 페이지:
- 명세 개요 및 아키텍처
- 전송 메커니즘 (streamable HTTP, stdio)
- 도구, 리소스, 프롬프트 정의

#### 1.3 프레임워크 문서 학습

**권장 스택:**
- **언어**: TypeScript (고품질 SDK 지원과 다양한 실행 환경에서의 호환성. AI 모델이 TypeScript 코드 생성을 잘하며, 광범위한 사용, 정적 타이핑, 좋은 린팅 도구의 혜택을 받음)
- **전송**: 원격 서버에는 Streamable HTTP, 상태 없는 JSON 사용 (상태 유지 세션과 스트리밍 응답보다 확장과 유지보수가 간단). 로컬 서버에는 stdio.

**프레임워크 문서 로드:**

- **MCP 모범 사례**: [모범 사례 보기](./reference/mcp_best_practices.md) - 핵심 가이드라인

**TypeScript용 (권장):**
- **TypeScript SDK**: WebFetch로 `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md` 로드
- [TypeScript 가이드](./reference/node_mcp_server.md) - TypeScript 패턴 및 예제

**Python용:**
- **Python SDK**: WebFetch로 `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md` 로드
- [Python 가이드](./reference/python_mcp_server.md) - Python 패턴 및 예제

#### 1.4 구현 계획

**API 이해:**
서비스의 API 문서를 검토하여 주요 엔드포인트, 인증 요구사항, 데이터 모델을 파악하세요. 필요에 따라 웹 검색과 WebFetch를 사용하세요.

**도구 선택:**
포괄적인 API 커버리지를 우선하세요. 가장 일반적인 작업부터 시작하여 구현할 엔드포인트를 나열하세요.

---

### 2단계: 구현

#### 2.1 프로젝트 구조 설정

프로젝트 설정은 언어별 가이드를 참조하세요:
- [TypeScript 가이드](./reference/node_mcp_server.md) - 프로젝트 구조, package.json, tsconfig.json
- [Python 가이드](./reference/python_mcp_server.md) - 모듈 구성, 의존성

#### 2.2 핵심 인프라 구현

공유 유틸리티를 만드세요:
- 인증이 포함된 API 클라이언트
- 오류 처리 헬퍼
- 응답 포맷팅 (JSON/Markdown)
- 페이지네이션 지원

#### 2.3 도구 구현

각 도구에 대해:

**입력 스키마:**
- Zod(TypeScript) 또는 Pydantic(Python) 사용
- 제약 조건과 명확한 설명 포함
- 필드 설명에 예제 추가

**출력 스키마:**
- 가능한 경우 구조화된 데이터를 위한 `outputSchema` 정의
- 도구 응답에 `structuredContent` 사용 (TypeScript SDK 기능)
- 클라이언트가 도구 출력을 이해하고 처리하는 데 도움

**도구 설명:**
- 기능에 대한 간결한 요약
- 매개변수 설명
- 반환 타입 스키마

**구현:**
- I/O 작업에 Async/await
- 실행 가능한 메시지가 포함된 적절한 오류 처리
- 해당되는 경우 페이지네이션 지원
- 최신 SDK 사용 시 텍스트 콘텐츠와 구조화된 데이터 모두 반환

**어노테이션:**
- `readOnlyHint`: true/false
- `destructiveHint`: true/false
- `idempotentHint`: true/false
- `openWorldHint`: true/false

---

### 3단계: 리뷰 및 테스트

#### 3.1 코드 품질

다음을 검토하세요:
- 중복된 코드 없음 (DRY 원칙)
- 일관된 오류 처리
- 완전한 타입 커버리지
- 명확한 도구 설명

#### 3.2 빌드 및 테스트

**TypeScript:**
- `npm run build`로 컴파일 검증
- MCP Inspector로 테스트: `npx @modelcontextprotocol/inspector`

**Python:**
- 구문 검증: `python -m py_compile your_server.py`
- MCP Inspector로 테스트

상세한 테스트 접근법과 품질 체크리스트는 언어별 가이드를 참조하세요.

---

### 4단계: 평가 생성

MCP 서버를 구현한 후, 효과를 테스트하기 위한 포괄적인 평가를 생성하세요.

**완전한 평가 가이드라인은 [평가 가이드](./reference/evaluation.md)를 로드하세요.**

#### 4.1 평가 목적 이해

LLM이 MCP 서버를 효과적으로 사용하여 현실적이고 복잡한 질문에 답할 수 있는지 테스트하기 위해 평가를 사용하세요.

#### 4.2 10개의 평가 질문 생성

효과적인 평가를 만들려면, 평가 가이드에 설명된 프로세스를 따르세요:

1. **도구 검사**: 사용 가능한 도구를 나열하고 기능을 이해
2. **콘텐츠 탐색**: 읽기 전용 작업으로 사용 가능한 데이터 탐색
3. **질문 생성**: 10개의 복잡하고 현실적인 질문 생성
4. **답변 검증**: 각 질문을 직접 풀어 답변 검증

#### 4.3 평가 요구사항

각 질문이 다음을 충족하는지 확인하세요:
- **독립적**: 다른 질문에 의존하지 않음
- **읽기 전용**: 비파괴적 작업만 필요
- **복잡**: 여러 도구 호출과 심층 탐색 필요
- **현실적**: 사람들이 관심을 가질 실제 사용 사례 기반
- **검증 가능**: 문자열 비교로 검증할 수 있는 단일하고 명확한 답변
- **안정적**: 시간이 지나도 답변이 변하지 않음

#### 4.4 출력 형식

다음 구조의 XML 파일을 생성하세요:

```xml
<evaluation>
  <qa_pair>
    <question>Find discussions about AI model launches with animal codenames. One model needed a specific safety designation that uses the format ASL-X. What number X was being determined for the model named after a spotted wild cat?</question>
    <answer>3</answer>
  </qa_pair>
<!-- More qa_pairs... -->
</evaluation>
```

---

# 참조 파일

## 문서 라이브러리

개발 중 필요에 따라 이 리소스를 로드하세요:

### 핵심 MCP 문서 (먼저 로드)
- **MCP 프로토콜**: `https://modelcontextprotocol.io/sitemap.xml` 사이트맵에서 시작, 그런 다음 `.md` 접미사로 특정 페이지 가져오기
- [MCP 모범 사례](./reference/mcp_best_practices.md) - 다음을 포함하는 범용 MCP 가이드라인:
  - 서버 및 도구 네이밍 규칙
  - 응답 형식 가이드라인 (JSON vs Markdown)
  - 페이지네이션 모범 사례
  - 전송 선택 (streamable HTTP vs stdio)
  - 보안 및 오류 처리 표준

### SDK 문서 (1/2단계에서 로드)
- **Python SDK**: `https://raw.githubusercontent.com/modelcontextprotocol/python-sdk/main/README.md`에서 가져오기
- **TypeScript SDK**: `https://raw.githubusercontent.com/modelcontextprotocol/typescript-sdk/main/README.md`에서 가져오기

### 언어별 구현 가이드 (2단계에서 로드)
- [Python 구현 가이드](./reference/python_mcp_server.md) - 완전한 Python/FastMCP 가이드:
  - 서버 초기화 패턴
  - Pydantic 모델 예제
  - `@mcp.tool`을 사용한 도구 등록
  - 완전한 작동 예제
  - 품질 체크리스트

- [TypeScript 구현 가이드](./reference/node_mcp_server.md) - 완전한 TypeScript 가이드:
  - 프로젝트 구조
  - Zod 스키마 패턴
  - `server.registerTool`을 사용한 도구 등록
  - 완전한 작동 예제
  - 품질 체크리스트

### 평가 가이드 (4단계에서 로드)
- [평가 가이드](./reference/evaluation.md) - 완전한 평가 생성 가이드:
  - 질문 생성 가이드라인
  - 답변 검증 전략
  - XML 형식 명세
  - 예제 질문 및 답변
  - 제공된 스크립트로 평가 실행
