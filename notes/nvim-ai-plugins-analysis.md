# Neovim AI Plugins Analysis

@repos/dot/nvim 에서 발견한 AI 플러그인 분석 및 적용 계획

## 📊 발견된 AI 플러그인

### 1. sidekick.nvim (folke)
**상태**: repos/dot/nvim에서 활성화됨
**GitHub**: https://github.com/folke/sidekick.nvim
**Stars**: ~1.3k
**최신 릴리스**: v1.2.0 (2025-10-02)

#### 주요 기능
- **Next Edit Suggestions (NES)**: Copilot LSP의 "Next Edit Suggestions" 통합
  - 타이핑 멈추거나 커서 이동 시 자동으로 제안
  - Treesitter 기반 문법 하이라이팅으로 rich diff 시각화
  - 단어/문자 단위까지 세밀한 diff
  - Hunk별 네비게이션으로 변경사항 검토

- **AI CLI 통합**: Neovim을 떠나지 않고 AI CLI와 상호작용
  - Claude, Copilot, Gemini 등 지원
  - 자동 파일 감시 - AI 도구가 수정한 파일 자동 리로드

- **커스터마이징**
  - 플러그인 친화적 API
  - UI 커스터마이징 가능 (diff, signs 등)

#### repos/dot/nvim 설정
```lua
{
  "folke/sidekick.nvim",
  opts = {
    cli = {
      mux = {
        enabled = true,
      },
      tools = {
        debug = {
          cmd = { "bash", "-c", "env | sort | bat -l env" },
        },
      },
    },
  },
}
```

#### 평가
**장점**:
- Folke의 고품질 플러그인 (lazy.nvim, noice.nvim 제작자)
- Copilot LSP 통합으로 자연스러운 제안
- 세밀한 diff 시각화
- 활발한 개발 (최근 릴리스)

**단점**:
- Copilot 구독 필요 (Next Edit Suggestions 사용 시)
- 상대적으로 새로운 플러그인

**권장사항**: ⭐⭐⭐⭐⭐ 강력 추천
- Copilot 구독자라면 필수
- AI CLI 통합으로 claude-code와 시너지
- 코드 리뷰/적용 워크플로우 개선

---

### 2. codecompanion.nvim (olimorris)
**상태**: repos/dot/nvim에서 **비활성화** (`enabled = false`)
**GitHub**: https://github.com/olimorris/codecompanion.nvim
**버전**: v12.0.0 (Agentic Workflows 추가)

#### 주요 기능
- **다중 LLM 지원**: Anthropic, Copilot, Gemini, Ollama, OpenAI, Azure OpenAI, xAI
  - 커스텀 어댑터 추가 가능

- **Inline Transformations**: 인라인 코드 변환, 생성, 리팩토링

- **변수, 슬래시 커맨드, 에이전트**: LLM 출력 개선 도구
  - @editor, @cmd_runner 등 도구 사용

- **내장 프롬프트 라이브러리**: LSP 오류 조언, 코드 설명 등

- **커스터마이징**: 커스텀 프롬프트, 변수, 슬래시 커맨드 생성

- **다중 채팅 세션**: 여러 채팅 동시 진행

- **비동기 실행**: 빠른 성능

- **Agentic Workflows** (v12.0.0): 자동화된 루프 워크플로우

#### repos/dot/nvim 설정
```lua
{
  "olimorris/codecompanion.nvim",
  enabled = false,  -- 비활성화됨
  cmd = { "CodeCompanion" },
  opts = {
    strategies = {
      chat = {
        adapter = "openai",
      },
      inline = {
        adapter = "openai",
      },
    },
  },
}
```

#### 평가
**장점**:
- Copilot Chat 스타일 경험
- 다양한 LLM 지원 (Anthropic Claude 포함!)
- Agentic workflows로 자동화 가능
- 활발한 개발 (최근 v12.0.0 릴리스)

**단점**:
- claude-code와 기능 중복 가능
- 원본 설정에서도 비활성화됨

**권장사항**: ⭐⭐⭐ 조건부 추천
- claude-code 사용 중이라면 불필요할 수 있음
- 하지만 Neovim 내 채팅 UI를 원한다면 유용
- Anthropic Claude 지원이 강점

---

### 3. minuet-ai.nvim (milanglacier)
**상태**: repos/dot/nvim에서 **비활성화** (`enabled = false`)
**GitHub**: https://github.com/milanglacier/minuet-ai.nvim
**태그라인**: "💃 Dance with Intelligence in Your Code"

#### 주요 기능
- **타이핑 중 코드 완성**: OpenAI, Gemini, Claude, Ollama, Llama.cpp, Codestral

- **특화 프롬프트**: 채팅 기반 LLM의 코드 완성 향상

- **FIM 완성**: Fill-in-the-middle 지원 (DeepSeek, Codestral, Qwen 등)

- **다중 프론트엔드 지원**:
  - virtual-text
  - nvim-cmp
  - blink-cmp
  - built-in
  - mini.completion

- **스트리밍 지원**: 느린 LLM도 완성 제공

- **순수 Lua + curl**: 독점 바이너리 없음

- **LSP 서버 모드**: In-process LSP 서버로 작동 (opt-in)

#### repos/dot/nvim 설정
```lua
{
  "milanglacier/minuet-ai.nvim",
  enabled = false,  -- 비활성화됨
  event = "BufReadPre",
  opts = {
    provider = "codestral",
    notify = "debug",
    n_completions = 1,
    add_single_line_entry = false,
    virtualtext = {
      auto_trigger_ft = { "lua" },
      keymap = {
        accept = "<Tab>",
        accept_line = "<A-a>",
        accept_n_lines = "<A-z>",
        prev = "<A-[>",
        next = "<A-]>",
        dismiss = "<A-e>",
      },
    },
    provider_options = {
      codestral = {
        optional = {
          max_tokens = 256,
          stop = { "\n\n" },
        },
      },
      gemini = {
        optional = {
          generationConfig = {
            maxOutputTokens = 256,
          },
          safetySettings = {
            {
              category = "HARM_CATEGORY_DANGEROUS_CONTENT",
              threshold = "BLOCK_ONLY_HIGH",
            },
          },
        },
      },
    },
  },
}
```

#### 평가
**장점**:
- Claude 지원 (Anthropic API 사용 가능)
- 순수 Lua + curl (의존성 적음)
- 다양한 프론트엔드 지원
- 스트리밍으로 느린 모델도 사용 가능

**단점**:
- Copilot 스타일 완성과 키맵 충돌 가능 (Tab)
- 원본 설정에서도 비활성화됨
- API 토큰 관리 필요

**권장사항**: ⭐⭐ 선택적
- Copilot 없이 AI 완성 원한다면 고려
- Claude API 직접 사용하고 싶다면 유용
- 하지만 현재 claude-code 사용 중이므로 불필요할 수 있음

---

### 4. copilot.lua (zbirenbaum)
**상태**: 주석 처리됨 (`-- { "zbirenbaum/copilot.lua" }`)

#### 평가
**권장사항**: ⭐ Skip
- 이미 sidekick.nvim이 Copilot LSP 사용
- 중복 구현

---

## 🔗 Claude Code 직접 연동 플러그인

### 5. claudecode.nvim (coder) ⭐⭐⭐⭐⭐
**GitHub**: https://github.com/coder/claudecode.nvim
**상태**: Claude Code CLI 공식 프로토콜 구현

#### 주요 기능
- **WebSocket 서버**: Claude Code CLI가 연결하는 WebSocket 서버 생성
- **VS Code Extension 프로토콜 호환**: 공식 VS Code extension과 100% 프로토콜 호환
- **순수 Lua**: 외부 의존성 없음 (vim.loop, vim.api, vim.json만 사용)
- **RFC 6455 WebSocket**: 표준 WebSocket + JSON-RPC 2.0
- **자동 감지**: Claude Code 실행 시 Neovim 자동 감지
- **완전한 편집기 접근**: Claude가 Neovim에 완전 접근 가능

#### 평가
**장점**:
- **현재 사용 중인 claude-code와 직접 연동!**
- 공식 프로토콜 100% 호환
- 순수 Lua (의존성 없음)
- VS Code와 동일한 경험

**단점**:
- 상대적으로 새로운 프로젝트
- 문서가 아직 발전 중

**권장사항**: ⭐⭐⭐⭐⭐ **최우선 추천!**
- 현재 claude-code 사용자라면 필수
- VS Code extension과 동일한 기능
- 추가 API 키 불필요

**구현 방법**:
```lua
-- plugins/claudecode.lua
return {
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    opts = {
      -- 기본 설정으로 충분
    },
  },
}
```

---

### 6. claude-code.nvim (greggh) ⭐⭐⭐⭐
**GitHub**: https://github.com/greggh/claude-code.nvim
**상태**: 터미널 통합 방식

#### 주요 기능
- **터미널 토글**: 단일 키로 Claude Code 터미널 토글
- **자동 파일 리로드**: Claude가 수정한 파일 자동 리로드
- **실시간 버퍼 업데이트**: 파일 변경 즉시 반영
- **커스텀 윈도우**: floating, split 등 다양한 포지셔닝
- **명령줄 인자 지원**: --continue, 커스텀 variants 등

#### 평가
**장점**:
- 간단한 터미널 통합
- 파일 변경 자동 감지
- 커스텀 윈도우 레이아웃
- Claude Code 자체로 개발됨

**단점**:
- claudecode.nvim보다 낮은 통합 수준
- 터미널 기반 (프로토콜 기반 아님)

**권장사항**: ⭐⭐⭐⭐ 추천
- 간단한 통합 선호한다면
- 터미널 워크플로우 선호한다면

**구현 방법**:
```lua
-- plugins/claude-code.lua
return {
  {
    "greggh/claude-code.nvim",
    keys = {
      { "<leader>cc", "<cmd>ClaudeCodeToggle<cr>", desc = "Toggle Claude Code" },
    },
    opts = {
      window = {
        position = "right",
        size = 80,
      },
      auto_reload = true,
    },
  },
}
```

---

### 7. avante.nvim (yetone) - Cursor 스타일 ⭐⭐⭐⭐
**GitHub**: https://github.com/yetone/avante.nvim
**태그라인**: "Use your Neovim like using Cursor AI IDE!"

#### 주요 기능
- **Cursor 에뮬레이션**: Cursor IDE와 유사한 AI 코드 제안
- **원클릭 적용**: AI 제안을 한 번에 소스에 적용
- **다중 AI 프로바이더**: claude, openai, azure, gemini, cohere, copilot
- **프로젝트 커스터마이징**: avante.md로 프로젝트별 AI 동작 설정
- **Neovim 0.10.1+**: 최신 Neovim 기능 활용

#### 평가
**장점**:
- Cursor 스타일 워크플로우
- Claude 지원
- 빠른 코드 적용

**단점**:
- claude-code와 워크플로우 중복
- Cursor 스타일 선호해야 함
- 추가 설정 필요

**권장사항**: ⭐⭐⭐ 선택적
- Cursor 경험 원한다면
- 하지만 claude-code 사용 중이므로 불필요할 수 있음

---

### 8. MCP 기반 통합 (mcp-neovim-server) ⭐⭐⭐⭐
**GitHub**: https://github.com/bigcodegen/mcp-neovim-server
**설명**: Model Context Protocol로 Claude Desktop과 Neovim 연결

#### 주요 기능
- **MCP 서버**: Claude Desktop이 Neovim에 연결
- **19개 도구**: 버퍼 탐색, 검색, 편집, 매크로, 탭, 폴드 등
- **완전한 워크플로우**: Claude가 개발 워크플로우 전체 처리
- **공식 node-client**: neovim/node-client 사용

#### 평가
**장점**:
- Claude Desktop과 직접 통합
- 표준 MCP 프로토콜
- 19개 도구로 강력한 제어

**단점**:
- Node.js 의존성
- Claude Desktop 필요 (CLI 아님)
- 설정 복잡도

**권장사항**: ⭐⭐⭐⭐ 추천
- Claude Desktop 사용자라면
- 가장 깊은 통합 원한다면

---

## 📝 종합 권장사항

### 🏆 최우선 추천 - Claude Code 사용자

#### claudecode.nvim ⭐⭐⭐⭐⭐
- **현재 사용 중인 claude-code CLI와 직접 연동!**
- VS Code extension과 동일한 프로토콜
- 순수 Lua (의존성 없음)
- 추가 API 키 불필요

#### claude-code.nvim ⭐⭐⭐⭐
- 터미널 통합 (간단한 방식 선호 시)
- 파일 변경 자동 리로드
- 커스텀 윈도우 레이아웃

**둘 중 선택**:
- **프로토콜 기반 통합** 원한다면 → `claudecode.nvim` (추천)
- **터미널 기반 통합** 원한다면 → `claude-code.nvim`

---

### Copilot 구독자용

#### sidekick.nvim ⭐⭐⭐⭐⭐
- Copilot LSP Next Edit Suggestions 통합
- 고품질 diff 시각화
- AI CLI 통합 (claude-code와 시너지)
- 원본 설정에서도 활성화됨

---

### 선택적 플러그인

#### codecompanion.nvim ⭐⭐⭐
- Neovim 내 AI 채팅 UI
- Anthropic Claude API 직접 사용
- Agentic workflows
- **단점**: claude-code와 기능 중복

#### avante.nvim ⭐⭐⭐
- Cursor 스타일 워크플로우
- 원클릭 코드 적용
- **단점**: claude-code와 워크플로우 중복

#### mcp-neovim-server ⭐⭐⭐⭐
- Claude Desktop 사용자용
- MCP 프로토콜 기반
- 19개 도구로 강력한 제어
- **단점**: Node.js 의존성, 설정 복잡

---

### Skip ⭐⭐
- **minuet-ai.nvim**: claude-code 사용 중이므로 불필요
- **copilot.lua**: sidekick.nvim으로 대체됨

---

## 🎯 구현 우선순위 (Claude Code 사용자)

### 1순위: claudecode.nvim 또는 claude-code.nvim
**이유**:
- **현재 사용 중인 claude-code CLI와 직접 통합!**
- VS Code와 동일한 경험
- 추가 비용 없음

**추천**: `claudecode.nvim` (프로토콜 기반)

### 2순위: sidekick.nvim (Copilot 구독자)
- Copilot 구독 있다면 추가 구현
- claude-code와 시너지 효과

### 3순위: 선택적 (필요 시)
- AI 채팅 UI 원한다면 → `codecompanion.nvim`
- Cursor 스타일 원한다면 → `avante.nvim`
- Claude Desktop 사용 → `mcp-neovim-server`

---

## 🔑 API 키 관리

AI 플러그인 사용 시 필요한 환경 변수:

```bash
# Copilot (sidekick.nvim)
# GitHub Copilot 구독으로 자동 인증

# Anthropic Claude (codecompanion.nvim, minuet-ai.nvim)
export ANTHROPIC_API_KEY="sk-ant-..."

# OpenAI (codecompanion.nvim, minuet-ai.nvim)
export OPENAI_API_KEY="sk-..."
```

**권장**: sops-nix로 환경 변수 관리
```nix
# secrets.nix
sops.secrets.anthropic_api_key = {
  sopsFile = ./secrets/api-keys.yaml;
};

# home.nix
home.sessionVariables = {
  ANTHROPIC_API_KEY = "$(cat ${config.sops.secrets.anthropic_api_key.path})";
};
```

---

## 📊 요약

| 플러그인 | 우선순위 | Claude Code | Copilot | API 키 | 추천 |
|---------|---------|------------|---------|-------|------|
| **claudecode.nvim** | ⭐⭐⭐⭐⭐ | ✅ 직접 연동 | ❌ | ❌ | **최우선!** |
| **claude-code.nvim** | ⭐⭐⭐⭐ | ✅ 터미널 | ❌ | ❌ | 추천 |
| sidekick.nvim | ⭐⭐⭐⭐⭐ | 시너지 | ✅ | ❌ | Copilot 구독자 |
| codecompanion.nvim | ⭐⭐⭐ | 중복 | ❌ | ✅ | 선택적 |
| avante.nvim | ⭐⭐⭐ | 중복 | ❌ | ✅ | Cursor 선호 시 |
| mcp-neovim-server | ⭐⭐⭐⭐ | Desktop용 | ❌ | ❌ | Desktop 사용자 |
| minuet-ai.nvim | ⭐⭐ | 중복 | ❌ | ✅ | Skip |
| copilot.lua | ⭐ | - | ✅ | ❌ | Skip |

**다음 단계** (Claude Code 사용자):
1. **`claudecode.nvim` 구현** (최우선!)
2. Copilot 구독자라면 `sidekick.nvim` 추가
3. 선택적: AI 채팅 UI 원한다면 `codecompanion.nvim`
