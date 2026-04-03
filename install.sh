#!/bin/bash
set -e

cat << 'BANNER'

  ╔══════════════════════════════════════════════════════╗
  ║     My Claude Code Setting - Installer              ║
  ║     고품질 바이브코딩을 위한 통합 환경                  ║
  ╚══════════════════════════════════════════════════════╝

BANNER

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# ─── 1. Check dependencies ───
echo "▸ 의존성 확인..."
missing=()
command -v node >/dev/null || missing+=("node")
command -v git >/dev/null || missing+=("git")
command -v python3 >/dev/null || missing+=("python3")

if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${RED}  ✗ 필요한 도구가 없습니다: ${missing[*]}${NC}"
    echo "  설치 후 다시 실행해주세요."
    exit 1
fi
echo -e "${GREEN}  ✓ node, git, python3${NC}"

# ─── 2. Install jq ───
echo ""
echo "▸ jq 설치 확인..."
if ! command -v jq >/dev/null 2>&1; then
    echo "  jq를 설치합니다..."
    mkdir -p "$HOME/bin"
    JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-arm64"
        if [[ "$(uname -m)" == "x86_64" ]]; then
            JQ_URL="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-macos-amd64"
        fi
    fi
    curl -sL "$JQ_URL" -o "$HOME/bin/jq" && chmod +x "$HOME/bin/jq"
    export PATH="$HOME/bin:$PATH"

    # Add to shell profile
    for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
        if [ -f "$rc" ] && ! grep -q 'HOME/bin' "$rc" 2>/dev/null; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
        fi
    done
fi
echo -e "${GREEN}  ✓ jq $(jq --version 2>/dev/null)${NC}"

# ─── 3. Install gh CLI ───
echo ""
echo "▸ GitHub CLI 설치 확인..."
if ! command -v gh >/dev/null 2>&1; then
    echo "  gh CLI를 설치합니다..."
    mkdir -p "$HOME/bin"
    GH_VERSION="2.67.0"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        GH_ARCH="macOS_amd64"
        [[ "$(uname -m)" == "arm64" ]] && GH_ARCH="macOS_arm64"
        curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_${GH_ARCH}.tar.gz" -o /tmp/gh.tar.gz
    else
        curl -sL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" -o /tmp/gh.tar.gz
    fi
    tar -xzf /tmp/gh.tar.gz -C /tmp/
    cp /tmp/gh_${GH_VERSION}_*/bin/gh "$HOME/bin/gh"
    chmod +x "$HOME/bin/gh"
    rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION}_*
    export PATH="$HOME/bin:$PATH"
fi
echo -e "${GREEN}  ✓ gh $(gh --version 2>/dev/null | head -1)${NC}"

# ─── 4. Backup existing config ───
echo ""
echo "▸ 기존 설정 백업..."
if [ -d "$CLAUDE_DIR/agents" ] || [ -d "$CLAUDE_DIR/skills" ]; then
    backup_dir="$CLAUDE_DIR.backup.$(date +%Y%m%d_%H%M%S)"
    cp -r "$CLAUDE_DIR" "$backup_dir" 2>/dev/null
    echo -e "${YELLOW}  → 백업 완료: $backup_dir${NC}"
else
    echo "  → 기존 설정 없음, 백업 건너뜀"
fi

# ─── 5. Copy files ───
echo ""
echo "▸ 설정 파일 복사..."
mkdir -p "$CLAUDE_DIR"

for dir in agents rules commands scripts skills hooks cc-chips cc-chips-custom; do
    if [ -d "$REPO_DIR/.claude/$dir" ]; then
        rm -rf "$CLAUDE_DIR/$dir" 2>/dev/null
        cp -r "$REPO_DIR/.claude/$dir" "$CLAUDE_DIR/$dir"
        count=$(find "$CLAUDE_DIR/$dir" -type f | wc -l)
        echo -e "  ${GREEN}✓${NC} $dir/ ($count files)"
    fi
done

# Settings & metadata
cp "$REPO_DIR/.claude/settings.json" "$CLAUDE_DIR/settings.json"
echo -e "  ${GREEN}✓${NC} settings.json"

cp "$REPO_DIR/.claude/.forge-meta.json" "$CLAUDE_DIR/.forge-meta.json" 2>/dev/null
chmod 600 "$CLAUDE_DIR/.forge-meta.json" 2>/dev/null

# Make hooks executable
chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null
chmod +x "$CLAUDE_DIR/cc-chips/"*.sh 2>/dev/null
chmod +x "$CLAUDE_DIR/cc-chips-custom/"*.sh 2>/dev/null

# ─── 6. Install Python dependencies ───
echo ""
echo "▸ Python 의존성 설치..."
if ! python3 -c "import openpyxl" 2>/dev/null; then
    python3 -m pip install --user --break-system-packages \
        openpyxl pypdf reportlab Pillow pdfplumber python-docx python-pptx 2>/dev/null || \
    python3 -m pip install --user \
        openpyxl pypdf reportlab Pillow pdfplumber python-docx python-pptx 2>/dev/null || \
    echo -e "${YELLOW}  ⚠ Python 패키지 수동 설치 필요: pip install openpyxl pypdf reportlab Pillow pdfplumber python-docx python-pptx${NC}"
fi
echo -e "${GREEN}  ✓ Python 문서 스킬 의존성${NC}"

# ─── 7. Install MCP server (context7 only) ───
echo ""
echo "▸ MCP 서버 설치..."
if command -v claude >/dev/null 2>&1; then
    claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp 2>/dev/null && \
        echo -e "  ${GREEN}✓${NC} context7 MCP" || \
        echo -e "  ${YELLOW}⚠${NC} context7 (이미 설치됨 또는 실패)"
else
    echo -e "${YELLOW}  ⚠ Claude CLI 미설치. MCP 서버 수동 설치 필요:${NC}"
    echo "    claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp"
fi

# ─── 8. Shell aliases ───
echo ""
echo "▸ 셸 alias 설정..."
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] && ! grep -q "Claude Code aliases" "$rc" 2>/dev/null; then
        cat >> "$rc" << 'ALIASES'

# Claude Code aliases
alias cc='claude'
alias ccr='claude --resume'
ALIASES
        echo -e "  ${GREEN}✓${NC} $(basename $rc)에 alias 추가"
    fi
done

# ─── 9. Install Plugins ───
echo ""
echo "▸ 플러그인 설치..."
if command -v claude >/dev/null 2>&1; then
    PLUGINS=(
        "frontend-design@claude-plugins-official"
        "superpowers@claude-plugins-official"
        "context7@claude-plugins-official"
        "code-review@claude-plugins-official"
        "playwright@claude-plugins-official"
        "feature-dev@claude-plugins-official"
        "typescript-lsp@claude-plugins-official"
        "claude-md-management@claude-plugins-official"
        "commit-commands@claude-plugins-official"
        "skill-creator@claude-plugins-official"
        "claude-code-setup@claude-plugins-official"
        "playground@claude-plugins-official"
    )
    for plugin in "${PLUGINS[@]}"; do
        name="${plugin%%@*}"
        claude plugin install "$plugin" 2>/dev/null && \
            echo -e "  ${GREEN}✓${NC} $name" || \
            echo -e "  ${YELLOW}⚠${NC} $name (이미 설치됨 또는 실패)"
    done

    # Codex plugin (external marketplace)
    claude plugin install "codex@openai-codex" --marketplace-source "github:openai/codex-plugin-cc" 2>/dev/null && \
        echo -e "  ${GREEN}✓${NC} codex (OpenAI)" || \
        echo -e "  ${YELLOW}⚠${NC} codex (이미 설치됨 또는 실패)"
else
    echo -e "${YELLOW}  ⚠ Claude CLI 미설치. 플러그인 수동 설치 필요${NC}"
    echo "    claude plugin install superpowers@claude-plugins-official"
fi

# ─── 10. GitHub auth check ───
echo ""
echo "▸ GitHub 인증 확인..."
if command -v gh >/dev/null 2>&1; then
    if gh auth status >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} GitHub 인증 완료"
    else
        echo -e "  ${YELLOW}⚠${NC} GitHub 미인증. 아래 명령어로 인증하세요:"
        echo "    gh auth login"
    fi
fi

# ─── Done ───
echo ""
cat << DONE

  ${GREEN}╔══════════════════════════════════════════════════════╗
  ║           설치 완료!                                  ║
  ╠══════════════════════════════════════════════════════╣
  ║  11 agents · 41 commands · 40 skills · 18 hooks     ║
  ║  13 plugins · Agent Teams · context7 MCP            ║
  ╚══════════════════════════════════════════════════════╝${NC}

  시작하기:
    1. 새 터미널 열기
    2. ${GREEN}claude${NC} 실행
    3. ${GREEN}/my-help${NC} 입력 → 전체 사용법 안내
    4. ${GREEN}/guide${NC} 입력 → 3분 온보딩 가이드

  핵심 명령어:
    /auto [설명]       원버튼 자동 개발
    /plan              구현 계획 수립
    /handoff-verify    빌드/테스트 자동 검증
    /commit-push-pr    GitHub PR 자동 생성
    /my-help           전체 사용법

DONE
