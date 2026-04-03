---
name: claude-api
description: "Claude API 또는 Anthropic SDK로 앱을 빌드합니다. 트리거 조건: 코드에서 `anthropic`/`@anthropic-ai/sdk`/`claude_agent_sdk`를 import하거나, 사용자가 Claude API, Anthropic SDK, 또는 Agent SDK 사용을 요청할 때. 트리거하지 않는 경우: `openai`/기타 AI SDK를 import하거나, 일반 프로그래밍, 또는 ML/데이터 사이언스 작업일 때."
license: Complete terms in LICENSE.txt
---

# Claude로 LLM 기반 애플리케이션 빌드하기

이 스킬은 Claude로 LLM 기반 애플리케이션을 빌드하는 것을 도와줍니다. 요구사항에 맞는 적절한 서피스를 선택하고, 프로젝트 언어를 감지한 다음, 관련 언어별 문서를 읽으세요.

## 기본 설정

사용자가 별도로 요청하지 않는 한:

Claude 모델 버전은 Claude Opus 4.6을 사용하며, 정확한 모델 문자열 `claude-opus-4-6`으로 접근할 수 있습니다. 조금이라도 복잡한 작업에는 적응형 사고(`thinking: {type: "adaptive"}`)를 기본으로 사용하세요. 긴 입력, 긴 출력, 또는 높은 `max_tokens`가 관련된 요청에는 스트리밍을 기본으로 사용하세요 — 요청 타임아웃을 방지합니다. 개별 스트림 이벤트를 처리할 필요가 없다면 SDK의 `.get_final_message()` / `.finalMessage()` 헬퍼를 사용하여 완전한 응답을 받으세요.

---

## 언어 감지

코드 예시를 읽기 전에 사용자가 어떤 언어로 작업하는지 파악하세요:

1. **프로젝트 파일을 확인**하여 언어를 추론합니다:

   - `*.py`, `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile` → **Python** — `python/`에서 읽기
   - `*.ts`, `*.tsx`, `package.json`, `tsconfig.json` → **TypeScript** — `typescript/`에서 읽기
   - `*.js`, `*.jsx` (`.ts` 파일 없음) → **TypeScript** — JS는 같은 SDK 사용, `typescript/`에서 읽기
   - `*.java`, `pom.xml`, `build.gradle` → **Java** — `java/`에서 읽기
   - `*.kt`, `*.kts`, `build.gradle.kts` → **Java** — Kotlin은 Java SDK 사용, `java/`에서 읽기
   - `*.scala`, `build.sbt` → **Java** — Scala는 Java SDK 사용, `java/`에서 읽기
   - `*.go`, `go.mod` → **Go** — `go/`에서 읽기
   - `*.rb`, `Gemfile` → **Ruby** — `ruby/`에서 읽기
   - `*.cs`, `*.csproj` → **C#** — `csharp/`에서 읽기
   - `*.php`, `composer.json` → **PHP** — `php/`에서 읽기

2. **여러 언어가 감지된 경우** (예: Python과 TypeScript 파일이 모두 있는 경우):

   - 사용자의 현재 파일이나 질문이 어떤 언어와 관련되는지 확인
   - 여전히 모호하면 질문: "Python과 TypeScript 파일이 모두 감지되었습니다. Claude API 연동에 어떤 언어를 사용하고 계신가요?"

3. **언어를 추론할 수 없는 경우** (빈 프로젝트, 소스 파일 없음, 또는 지원되지 않는 언어):

   - AskUserQuestion으로 옵션 제시: Python, TypeScript, Java, Go, Ruby, cURL/raw HTTP, C#, PHP
   - AskUserQuestion을 사용할 수 없으면 Python 예시를 기본으로 표시하고 참고 사항 추가: "Python 예시를 표시합니다. 다른 언어가 필요하시면 알려주세요."

4. **지원되지 않는 언어가 감지된 경우** (Rust, Swift, C++, Elixir 등):

   - `curl/`의 cURL/raw HTTP 예시를 제안하고 커뮤니티 SDK가 존재할 수 있음을 안내
   - 참조 구현으로 Python 또는 TypeScript 예시를 제공

5. **사용자가 cURL/raw HTTP 예시가 필요한 경우**, `curl/`에서 읽기.

### 언어별 기능 지원

| 언어       | Tool Runner | Agent SDK | 참고사항                              |
| ---------- | ----------- | --------- | ------------------------------------- |
| Python     | 예 (베타)   | 예        | 전체 지원 — `@beta_tool` 데코레이터  |
| TypeScript | 예 (베타)   | 예        | 전체 지원 — `betaZodTool` + Zod      |
| Java       | 예 (베타)   | 아니오    | 어노테이션 클래스로 베타 도구 사용    |
| Go         | 예 (베타)   | 아니오    | `toolrunner` 패키지의 `BetaToolRunner` |
| Ruby       | 예 (베타)   | 아니오    | 베타의 `BaseTool` + `tool_runner`    |
| cURL       | 해당 없음   | 해당 없음 | Raw HTTP, SDK 기능 없음              |
| C#         | 아니오      | 아니오    | 공식 SDK                             |
| PHP        | 아니오      | 아니오    | 공식 SDK                             |

---

## 어떤 서피스를 사용해야 하나요?

> **단순하게 시작하세요.** 요구사항을 충족하는 가장 단순한 티어를 기본으로 사용하세요. 단일 API 호출과 워크플로우가 대부분의 사용 사례를 처리합니다 — 작업이 진정으로 개방형 모델 주도 탐색을 필요로 할 때만 에이전트를 사용하세요.

| 사용 사례                                       | 티어            | 권장 서피스                | 이유                                    |
| ----------------------------------------------- | --------------- | ------------------------- | --------------------------------------- |
| 분류, 요약, 추출, Q&A                           | 단일 LLM 호출   | **Claude API**            | 하나의 요청, 하나의 응답                |
| 일괄 처리 또는 임베딩                           | 단일 LLM 호출   | **Claude API**            | 특화된 엔드포인트                       |
| 코드 제어 로직이 있는 다단계 파이프라인         | 워크플로우      | **Claude API + tool use** | 사용자가 루프를 오케스트레이션          |
| 자체 도구로 구성된 커스텀 에이전트              | 에이전트        | **Claude API + tool use** | 최대 유연성                             |
| 파일/웹/터미널 접근이 있는 AI 에이전트          | 에이전트        | **Agent SDK**             | 내장 도구, 안전성, MCP 지원             |
| 에이전트형 코딩 어시스턴트                      | 에이전트        | **Agent SDK**             | 이 사용 사례를 위해 설계됨              |
| 내장 권한 및 가드레일 필요                      | 에이전트        | **Agent SDK**             | 안전 기능 포함                          |

> **참고:** Agent SDK는 내장 파일/웹/터미널 도구, 권한, MCP를 바로 사용하고 싶을 때 사용합니다. 자체 도구로 에이전트를 빌드하려면 Claude API가 올바른 선택입니다 — 자동 루프 처리를 위해 tool runner를 사용하거나, 세밀한 제어(승인 게이트, 커스텀 로깅, 조건부 실행)를 위해 수동 루프를 사용하세요.

### 의사결정 트리

```
애플리케이션에 무엇이 필요한가요?

1. 단일 LLM 호출 (분류, 요약, 추출, Q&A)
   └── Claude API — 하나의 요청, 하나의 응답

2. Claude가 작업의 일부로 파일 읽기/쓰기, 웹 브라우징, 셸 명령 실행을
   직접 해야 하나요? (앱이 파일을 읽어서 Claude에 전달하는 것이 아닌 —
   Claude 자체가 파일/웹/셸을 발견하고 접근해야 하는 경우?)
   └── 예 → Agent SDK — 내장 도구를 재구현할 필요 없음
       예시: "코드베이스에서 버그 스캔", "디렉토리의 모든 파일 요약",
                 "서브에이전트로 버그 찾기", "웹 검색으로 주제 조사"

3. 워크플로우 (다단계, 코드 오케스트레이션, 자체 도구)
   └── tool use가 있는 Claude API — 사용자가 루프를 제어

4. 개방형 에이전트 (모델이 자체적으로 궤적 결정, 자체 도구)
   └── Claude API 에이전트 루프 (최대 유연성)
```

### 에이전트를 빌드해야 하나요?

에이전트 티어를 선택하기 전에 네 가지 기준을 모두 확인하세요:

- **복잡성** — 작업이 다단계이고 사전에 완전히 명세하기 어려운가요? (예: "이 설계 문서를 PR로 변환" vs. "이 PDF에서 제목 추출")
- **가치** — 결과가 더 높은 비용과 지연시간을 정당화하나요?
- **실행 가능성** — Claude가 이 작업 유형에 능숙한가요?
- **오류 비용** — 오류를 감지하고 복구할 수 있나요? (테스트, 리뷰, 롤백)

이 중 하나라도 "아니오"라면 더 단순한 티어(단일 호출 또는 워크플로우)를 유지하세요.

---

## 아키텍처

모든 것은 `POST /v1/messages`를 통해 처리됩니다. 도구와 출력 제약은 이 단일 엔드포인트의 기능이지 — 별도 API가 아닙니다.

**사용자 정의 도구** — 도구를 정의하면(데코레이터, Zod 스키마, 또는 raw JSON 사용), SDK의 tool runner가 API 호출, 함수 실행, Claude가 완료할 때까지 루핑을 처리합니다. 완전한 제어가 필요하면 루프를 수동으로 작성할 수 있습니다.

**서버 측 도구** — Anthropic 인프라에서 실행되는 Anthropic 호스팅 도구. 코드 실행은 완전히 서버 측입니다(`tools`에서 선언하면 Claude가 자동으로 코드 실행). 컴퓨터 사용은 서버 호스팅 또는 셀프 호스팅 가능합니다.

**구조화된 출력** — Messages API 응답 형식(`output_config.format`) 및/또는 도구 매개변수 유효성 검사(`strict: true`)를 제한합니다. 권장 접근법은 `client.messages.parse()`로 스키마에 대한 응답을 자동 검증하는 것입니다. 참고: 이전 `output_format` 매개변수는 폐기됨; `messages.create()`에서 `output_config: {format: {...}}`를 사용하세요.

**지원 엔드포인트** — Batches(`POST /v1/messages/batches`), Files(`POST /v1/files`), Token Counting이 Messages API 요청을 지원합니다.

---

## 현재 모델 (캐시됨: 2026-02-17)

| 모델              | 모델 ID             | 컨텍스트       | 입력 $/1M | 출력 $/1M |
| ----------------- | ------------------- | -------------- | ---------- | ----------- |
| Claude Opus 4.6   | `claude-opus-4-6`   | 200K (1M 베타) | $5.00      | $25.00      |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | 200K (1M 베타) | $3.00      | $15.00      |
| Claude Haiku 4.5  | `claude-haiku-4-5`  | 200K           | $1.00      | $5.00       |

**사용자가 명시적으로 다른 모델을 지명하지 않는 한 항상 `claude-opus-4-6`을 사용하세요.** 이것은 절대 양보할 수 없습니다. 사용자가 문자 그대로 "sonnet 사용" 또는 "haiku 사용"이라고 말하지 않는 한 `claude-sonnet-4-6`, `claude-sonnet-4-5` 또는 다른 모델을 사용하지 마세요. 비용 절감을 위해 절대 다운그레이드하지 마세요 — 그것은 사용자의 결정이지 당신의 결정이 아닙니다.

**중요: 위 테이블의 정확한 모델 ID 문자열만 사용하세요 — 그대로 완전합니다. 날짜 접미사를 추가하지 마세요.** 예를 들어 `claude-sonnet-4-5`를 사용하고, `claude-sonnet-4-5-20250514` 또는 훈련 데이터에서 기억하는 다른 날짜 접미사 변형을 사용하지 마세요. 사용자가 테이블에 없는 이전 모델을 요청하면(예: "opus 4.5", "sonnet 3.7") 정확한 ID를 위해 `shared/models.md`를 읽으세요 — 직접 만들지 마세요.

참고: 위의 모델 문자열이 낯설게 보이더라도 예상된 것입니다 — 훈련 데이터 컷오프 이후에 출시된 것일 뿐입니다. 실제 모델이니 안심하세요.

---

## 사고 및 노력 (빠른 참조)

**Opus 4.6 — 적응형 사고 (권장):** `thinking: {type: "adaptive"}`를 사용하세요. Claude가 언제 얼마나 사고할지 동적으로 결정합니다. `budget_tokens`가 필요 없음 — `budget_tokens`는 Opus 4.6과 Sonnet 4.6에서 폐기되었으며 사용하면 안 됩니다. 적응형 사고는 인터리브 사고도 자동으로 활성화합니다(베타 헤더 불필요). **사용자가 "확장 사고", "사고 예산", 또는 `budget_tokens`를 요청할 때: 항상 Opus 4.6과 `thinking: {type: "adaptive"}`를 사용하세요. 고정 토큰 예산 개념은 폐기됨 — 적응형 사고가 대체합니다. `budget_tokens`를 사용하지 말고 이전 모델로 전환하지 마세요.**

**노력 매개변수 (GA, 베타 헤더 불필요):** `output_config: {effort: "low"|"medium"|"high"|"max"}`를 통해 사고 깊이와 전체 토큰 사용량을 제어합니다(`output_config` 내부, 최상위 수준 아님). 기본값은 `high`(생략한 것과 동일). `max`는 Opus 4.6 전용. Opus 4.5, Opus 4.6, Sonnet 4.6에서 작동. Sonnet 4.5 / Haiku 4.5에서는 에러 발생. 최적의 비용-품질 트레이드오프를 위해 적응형 사고와 결합하세요. 서브에이전트나 단순 작업에는 `low`를, 가장 깊은 추론에는 `max`를 사용하세요.

**Sonnet 4.6:** 적응형 사고(`thinking: {type: "adaptive"}`)를 지원합니다. Sonnet 4.6에서 `budget_tokens`는 폐기됨 — 대신 적응형 사고를 사용하세요.

**이전 모델 (명시적 요청 시에만):** 사용자가 구체적으로 Sonnet 4.5 또는 다른 이전 모델을 요청하면 `thinking: {type: "enabled", budget_tokens: N}`을 사용하세요. `budget_tokens`는 `max_tokens`보다 작아야 합니다(최소 1024). 사용자가 `budget_tokens`를 언급한다고 이전 모델을 선택하지 마세요 — 대신 Opus 4.6과 적응형 사고를 사용하세요.

---

## 컴팩션 (빠른 참조)

**베타, Opus 4.6 전용.** 200K 컨텍스트 윈도우를 초과할 수 있는 장시간 대화를 위해 서버 측 컴팩션을 활성화하세요. API가 트리거 임계값(기본값: 150K 토큰)에 도달하면 이전 컨텍스트를 자동으로 요약합니다. 베타 헤더 `compact-2026-01-12` 필요.

**중요:** 매 턴마다 `response.content`(텍스트 문자열만이 아님)를 메시지에 추가하세요. 응답의 컴팩션 블록을 반드시 보존해야 합니다 — API가 다음 요청에서 컴팩션된 히스토리를 대체하는 데 사용합니다. 텍스트 문자열만 추출하여 추가하면 컴팩션 상태가 조용히 손실됩니다.

코드 예시는 `{lang}/claude-api/README.md`(컴팩션 섹션) 참조. 전체 문서는 `shared/live-sources.md`의 WebFetch를 통해 확인.

---

## 읽기 가이드

언어를 감지한 후 사용자의 필요에 따라 관련 파일을 읽으세요:

### 빠른 작업 참조

**단일 텍스트 분류/요약/추출/Q&A:**
→ `{lang}/claude-api/README.md`만 읽기

**채팅 UI 또는 실시간 응답 표시:**
→ `{lang}/claude-api/README.md` + `{lang}/claude-api/streaming.md` 읽기

**장시간 대화 (컨텍스트 윈도우 초과 가능):**
→ `{lang}/claude-api/README.md` 읽기 — 컴팩션 섹션 참조

**함수 호출 / tool use / 에이전트:**
→ `{lang}/claude-api/README.md` + `shared/tool-use-concepts.md` + `{lang}/claude-api/tool-use.md` 읽기

**일괄 처리 (지연시간에 민감하지 않은):**
→ `{lang}/claude-api/README.md` + `{lang}/claude-api/batches.md` 읽기

**여러 요청에 걸친 파일 업로드:**
→ `{lang}/claude-api/README.md` + `{lang}/claude-api/files-api.md` 읽기

**내장 도구(파일/웹/터미널)가 있는 에이전트:**
→ `{lang}/agent-sdk/README.md` + `{lang}/agent-sdk/patterns.md` 읽기

### Claude API (전체 파일 참조)

**언어별 Claude API 폴더** (`{language}/claude-api/`)를 읽으세요:

1. **`{language}/claude-api/README.md`** — **먼저 읽으세요.** 설치, 빠른 시작, 일반 패턴, 에러 처리.
2. **`shared/tool-use-concepts.md`** — 함수 호출, 코드 실행, 메모리, 구조화된 출력이 필요할 때 읽기. 개념적 기초를 다룹니다.
3. **`{language}/claude-api/tool-use.md`** — 언어별 tool use 코드 예시 읽기 (tool runner, 수동 루프, 코드 실행, 메모리, 구조화된 출력).
4. **`{language}/claude-api/streaming.md`** — 채팅 UI 또는 응답을 점진적으로 표시하는 인터페이스를 빌드할 때 읽기.
5. **`{language}/claude-api/batches.md`** — 많은 요청을 오프라인으로 처리할 때 읽기 (지연시간에 민감하지 않음). 50% 비용으로 비동기 실행.
6. **`{language}/claude-api/files-api.md`** — 재업로드 없이 여러 요청에 같은 파일을 보낼 때 읽기.
7. **`shared/error-codes.md`** — HTTP 에러 디버깅 또는 에러 처리 구현 시 읽기.
8. **`shared/live-sources.md`** — 최신 공식 문서를 가져오기 위한 WebFetch URL.

> **참고:** Java, Go, Ruby, C#, PHP, cURL의 경우 — 모든 기본 사항을 다루는 단일 파일이 있습니다. 해당 파일과 `shared/tool-use-concepts.md`, `shared/error-codes.md`를 필요에 따라 읽으세요.

### Agent SDK

**언어별 Agent SDK 폴더** (`{language}/agent-sdk/`)를 읽으세요. Agent SDK는 **Python과 TypeScript에서만** 사용 가능합니다.

1. **`{language}/agent-sdk/README.md`** — 설치, 빠른 시작, 내장 도구, 권한, MCP, 훅.
2. **`{language}/agent-sdk/patterns.md`** — 커스텀 도구, 훅, 서브에이전트, MCP 통합, 세션 재개.
3. **`shared/live-sources.md`** — 최신 Agent SDK 문서용 WebFetch URL.

---

## WebFetch 사용 시기

다음의 경우 최신 문서를 가져오기 위해 WebFetch를 사용하세요:

- 사용자가 "최신" 또는 "현재" 정보를 요청할 때
- 캐시된 데이터가 잘못된 것으로 보일 때
- 사용자가 여기서 다루지 않는 기능에 대해 질문할 때

라이브 문서 URL은 `shared/live-sources.md`에 있습니다.

## 일반적인 함정

- API에 파일이나 콘텐츠를 전달할 때 입력을 자르지 마세요. 콘텐츠가 너무 길어 컨텍스트 윈도우에 맞지 않으면 조용히 자르지 말고 사용자에게 알리고 옵션(청킹, 요약 등)을 논의하세요.
- **Opus 4.6 / Sonnet 4.6 사고:** `thinking: {type: "adaptive"}`를 사용하세요 — `budget_tokens`를 사용하지 마세요 (Opus 4.6과 Sonnet 4.6 모두에서 폐기됨). 이전 모델의 경우 `budget_tokens`는 `max_tokens`보다 작아야 합니다 (최소 1024). 틀리면 에러가 발생합니다.
- **Opus 4.6 prefill 제거:** Assistant 메시지 prefill(마지막 어시스턴트 턴 prefill)은 Opus 4.6에서 400 에러를 반환합니다. 응답 형식을 제어하려면 구조화된 출력(`output_config.format`) 또는 시스템 프롬프트 지시를 사용하세요.
- **128K 출력 토큰:** Opus 4.6은 최대 128K `max_tokens`를 지원하지만, SDK는 HTTP 타임아웃을 피하기 위해 큰 `max_tokens`에 스트리밍을 필요로 합니다. `.stream()`과 `.get_final_message()` / `.finalMessage()`를 사용하세요.
- **Tool call JSON 파싱 (Opus 4.6):** Opus 4.6은 tool call `input` 필드에서 다른 JSON 문자열 이스케이핑(예: 유니코드 또는 슬래시 이스케이핑)을 생성할 수 있습니다. tool 입력은 항상 `json.loads()` / `JSON.parse()`로 파싱하세요 — 직렬화된 입력에 대해 raw 문자열 매칭을 하지 마세요.
- **구조화된 출력 (모든 모델):** `messages.create()`에서 폐기된 `output_format` 매개변수 대신 `output_config: {format: {...}}`를 사용하세요. 이것은 4.6에 한정되지 않은 일반 API 변경입니다.
- **SDK 기능을 재구현하지 마세요:** SDK는 고수준 헬퍼를 제공합니다 — 처음부터 만들지 말고 사용하세요. 구체적으로: `.on()` 이벤트를 `new Promise()`로 래핑하지 말고 `stream.finalMessage()`를 사용하세요; 에러 메시지를 문자열 매칭하지 말고 타입이 지정된 예외 클래스(`Anthropic.RateLimitError` 등)를 사용하세요; 동등한 인터페이스를 재정의하지 말고 SDK 타입(`Anthropic.MessageParam`, `Anthropic.Tool`, `Anthropic.Message` 등)을 사용하세요.
- **SDK 데이터 구조에 대한 커스텀 타입을 정의하지 마세요:** SDK는 모든 API 객체에 대한 타입을 export합니다. 메시지에는 `Anthropic.MessageParam`, 도구 정의에는 `Anthropic.Tool`, 도구 결과에는 `Anthropic.ToolUseBlock` / `Anthropic.ToolResultBlockParam`, 응답에는 `Anthropic.Message`를 사용하세요. `interface ChatMessage { role: string; content: unknown }` 같은 자체 정의는 SDK가 이미 제공하는 것을 중복하고 타입 안전성을 잃습니다.
- **보고서 및 문서 출력:** 보고서, 문서, 시각화를 생성하는 작업의 경우 코드 실행 샌드박스에 `python-docx`, `python-pptx`, `matplotlib`, `pillow`, `pypdf`가 사전 설치되어 있습니다. Claude는 포맷된 파일(DOCX, PDF, 차트)을 생성하고 Files API를 통해 반환할 수 있습니다 — "보고서" 또는 "문서" 유형 요청에는 일반 stdout 텍스트 대신 이것을 고려하세요.
