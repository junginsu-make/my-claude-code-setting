# My Claude Code Setting

비개발자 바이브코딩을 위한 Claude Code 통합 환경 세팅입니다.
기획부터 구현, 코드 리뷰, 테스트, 검증, 배포까지 전체 파이프라인을 지원합니다.

## 빠른 설치

```bash
git clone https://github.com/junginsu-make/my-claude-code-setting.git
cd my-claude-code-setting
bash install.sh
```

## 구성 요약

| 구성요소 | 수량 | 출처 |
|---------|------|------|
| Agents (서브에이전트) | 11개 | Claude Forge |
| Rules (핵심 규칙) | 9개 | Claude Forge |
| Commands (슬래시 명령어) | 41개 | Claude Forge + 커스텀 |
| Skills (스킬) | 40개 | Claude Forge + projeck-skills + my-skills + Anthropic 공식 |
| Hooks (자동화 훅) | 18개 | Claude Forge |
| Plugins (공식 플러그인) | 13개 | Anthropic 공식 + OpenAI Codex |
| MCP 서버 | 1개 | context7 (실시간 라이브러리 문서) |

### 플러그인 목록 (13개)

**Anthropic 공식 (12개)**
- superpowers, frontend-design, context7, code-review, playwright
- feature-dev, typescript-lsp, claude-md-management, commit-commands
- skill-creator, claude-code-setup, playground

**외부 마켓플레이스 (1개)**
- codex (OpenAI) — Codex CLI 연동

### 스킬 출처 상세

**Claude Forge (15개)** — 개발 워크플로우 자동화
- build-system, cache-components, cc-dev-agent, continuous-learning-v2, eval-harness
- frontend-code-review, manage-skills, prompts-chat, security-pipeline, session-wrap
- skill-factory, strategic-compact, team-orchestrator, verification-engine, verify-implementation

**projeck-skills (1개)** — 프로젝트 기획 프레임워크
- project-system: 21개 질문 기반 기획 → PRD/기술설계서/DB스키마 자동 생성

**my-skills (9개)** — 실용 도구
- nextjs15-init, flutter-init, prompt-enhancer, landing-page-guide
- card-news-generator-v2, codex-claude-loop, meta-prompt-generator, code-changelog
- ai-agent-skills (Synapse AI 에이전트 라이프사이클 관리)

**Anthropic 공식 (15개)** — 문서/디자인/개발
- claude-api, frontend-design, webapp-testing, web-artifacts-builder
- skill-creator, mcp-builder, theme-factory, canvas-design, brand-guidelines
- docx, xlsx, pdf, pptx, internal-comms, doc-coauthoring

## 핵심 워크플로우

```
[기획] "새 프로젝트 시작해줘" → 21개 질문으로 요구사항 정리
[셋업] "Next.js 프로젝트 만들어줘" → 프로젝트 스캐폴딩
[구현] /auto [기능 설명] → 계획→TDD→리뷰→검증→커밋 자동
[팀]   "에이전트 팀으로 구현해줘" → 병렬 개발
[검증] /handoff-verify → 빌드/테스트/린트 자동 검증
[배포] /commit-push-pr → GitHub PR 자동 생성
[안내] /my-help → 전체 사용법 확인
```

## 설계 원칙

- **성능과 품질 우선** — 토큰 비용보다 결과물 품질이 중요
- **MCP 최소화** — context7만 사용 (나머지는 내장 기능/Skills로 대체)
- **Plugins 적극 활용** — 공식 플러그인 13개로 MCP/프론트엔드/코드리뷰 강화
- **GitHub** — gh CLI로 연동 (MCP 불필요)
- **Memory** — Claude Code 내장 memory 시스템 사용
- **안전장치** — 53개 deny 규칙 + 18개 자동화 훅

## 요구사항

- Node.js 18+
- Python 3.10+
- Git
- Claude Code CLI (`npm install -g @anthropic-ai/claude-code`)

## 크레딧

- [Claude Forge](https://github.com/sangrokjung/claude-forge) — 베이스 프레임워크
- [projeck-skills](https://github.com/junginsu-make/projeck-skills) — 프로젝트 기획 시스템
- [my-skills](https://github.com/junginsu-make/my-skills) — 실용 스킬 모음
- [claude-skills-official](https://github.com/junginsu-make/claude-skills-official) — Anthropic 공식 스킬
