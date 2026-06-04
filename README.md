# MyCld — Claude Code Config & Skill Library

A personal Claude Code configuration packed with **359 skills**, multiple plugins, MCP servers, and scratch-built agents. Copy any command below to start using a skill, plugin, or agent.

---

## Quick Start — Copy Commands

### Run a skill
```bash
/skill-name              # invoke directly by name
```

### Plugins (slash commands)
```bash
/cs:setup                # C-suite onboarding interview
/cs:board               # multi-agent board meeting
/cs:decisions           # review logged decisions
/cs:ai-act-readiness    # EU AI Act readiness check
/cs:a11y-architect      # WCAG 2.2 accessibility audit
/cs:aims-audit          # ISO 42001 AIMS audit
/cs:fda-qsr-audit-prep  # FDA QSR audit readiness
/cs:gdpr-audit-prep     # GDPR audit prep
/cs:compliance-readiness
/cs:iso13485-audit-prep
/cs:iso27001-audit-prep
/cs:soc2-audit-prep
```

### Agents (dispatch focused sub-agents)
```bash
# send a task to a named agent from the Agent tool
# examples shown below under each section
```

---

## Plugins Installed

### `superpowers` (superpowers-dev)
Core workflow engine. Provides brainstorming, TDD, debugging, verification, plan writing/skills, and Git worktree management superpowers.

Use when: any creative or implementation task — the skills route themselves.

### `ecc` — Everything ClaudeCode
Largest plugin install. 100+ skills for engineering, marketing, C-suite advisory, compliance, data, and finance. Active skills are listed below under their category headings. Many expose `/cs:*` commands and `ecc:*` slash commands.

Key slash commands:
```bash
/ecc:plan              # restate requirements, step-by-step plan (asks before coding)
/ecc:plan-prd          # lean PRD generation
/ecc:prp-implement     # execute plan with verification loops
/ecc:prp-pr            # create GitHub PR from branch
/ecc:review-pr         # comprehensive PR review
/ecc:react-build       # fix React/Vite/webpack/Next.js build errors
/ecc:react-review      # React/JSX review
/ecc:react-test        # React TDD (RTL tests first)
/ecc:python-review     # Python PEP 8 review
/ecc:go-review         # idiomatic Go review
/ecc:rust-review       # ownership/lifetimes review
/ecc:cpp-review        # modern C++ review
/ecc:kotlin-review     # Kotlin & coroutine review
/ecc:flutter-review    # Flutter/Dart review
/ecc:go-build           # fix Go build errors
/ecc:react-build       # fix React build errors
/ecc:rust-build         # fix Rust build errors
/ecc:cpp-build          # fix C++ build errors
/ecc:kotlin-build       # fix Kotlin/Gradle build errors
/ecc:python-review     # Python review
/ecc:security-scan     # scan .claude/ for security issues
/ecc:code-review        # code review (local changes or pass PR #/URL)
/ecc:feature-dev        # guided feature dev with architecture focus
/ecc:refactor-clean     # remove dead code safely
/ecc:update-codemaps    # regenerate architecture codemaps
/ecc:update-docs        # sync docs from source-of-truth files
/ecc:hookify:          # create hooks from conversation patterns
/ecc:loop-start        # start managed autonomous loop
/ecc:gan-build         # Generator-Evaluator build loop
/ecc:gan-design        # Generator-Evaluator design loop
/ecc:tdd-workflow      # full TDD (unit/integration/e2e) to 80%+
/ecc:blueprint         # one-line objective -> multi-session plan
/ecc:sessions          # manage session history
/ecc:save-session      # persist session for later resume
/ecc:resume-session    # resume saved session
/ecc:test-coverage     # analyze coverage, generate missing tests
/ecc:deep-research     # firecrawl/exa multi-source research
/ecc:research-ops      # evidence-first research workflow
/ecc:market-research   # market sizing, competitor comparison
/ecc:cost-tracking     # token spend report
/ecc:marketing-campaign
/ecc:agentic-engineering
/ecc:mcp-server-patterns
/ecc:deployment-patterns
/ecc:docker-patterns
/ecc:database-migrations
/ecc:postgres-patterns
/ecc:nextjs-turbopack
/ecc:frontend-patterns
/ecc:frontend-a11y
/ecc:motion-foundations
/ecc:motion-patterns
/ecc:react-performance
/ecc:accessibility      # WCAG 2.2 AA
/ecc:design-system
/ecc:design-review
/ecc:security-review
/ecc:api-design
/ecc:architecture-decision-records
/ecc:module-<name>     # many more — run `/ecc:ecc-guide` for full listing
```

### `ui-ux-pro-max` (ui-ux-pro-max-skill)
UI/UX design intelligence: 67 styles, 96 palettes, 57 font pairings, 10 stacks.

```bash
/ui-ux-pro-max:ui-ux-pro-max   # full design mode
```

### `impeccable` (impeccable)
Premium frontend design skill for redesigning existing UIs to high-end agency quality.

```bash
/impeccable:impeccable         # design/critique/audit frontend interfaces
```

### `claude-mem` (thedotmack)
Persistent memory for Claude Code sessions.

### `skill-creator` (alberto-marketplace)
Create or contribute skills — includes evals, testing, and tier benchmarking.

### `context7-plugin` (context7-marketplace)
Live library/framework docs via Context7 MCP.

### `agent-skills` (addy-osmani)
Code quality agents: code-reviewer, build-error-resolver, security-auditor, test-engineer, code-simplifier.

### `code-review`, `github`, `playwright` (claude-plugins-official)
PR review, `gh` CLI GitHub operations, and browser automation MCP respectively.

### LSP servers (claude-plugins-official)
`typescript-lsp` · `pyright-lsp` · `rust-analyzer-lsp` · `gopls-lsp`

### `frontend-design`, `claude-md-management`, `supabase` (claude-plugins-official)
Official frontend design plugin, CLAUDE.md audit tool, and Supabase MCP.

### `antigravity-awesome-skills` + 36 bundles (antigravity-awesome-skills)
Role-specific skill bundles covering: web wizard, web designer, full-stack developer, agent architect, LLM application developer, indie game dev, Python pro, TS/JS, systems programming, startup founder, business analyst, marketing growth, DevOps, observability, data analytics, creative director, QA, mobile, integrations, architecture, DDD, automation, revops, commerce, Odoo ERP, Azure AI, Expo/RN, Apple platforms, Makepad, SEO specialist, docs/presentations, OSS maintainer, security engineer, security developer, essentials.

---

## Available Agents (sub-agents you can dispatch)

Use the **Agent** tool with `subagent_type: "<name>"` to dispatch.

### Engineering agents
```bash
Agent(subagent_type="agent-skills:code-reviewer")
Agent(subagent_type="agent-skills:security-auditor")
Agent(subagent_type="agent-skills:test-engineer")
Agent(subagent_type="ecc:build-error-resolver")
Agent(subagent_type="ecc:react-reviewer")
Agent(subagent_type="ecc:typescript-reviewer")
Agent(subagent_type="ecc:python-reviewer")
Agent(subagent_type="ecc:go-reviewer")
Agent(subagent_type="ecc:rust-reviewer")
Agent(subagent_type="ecc:cpp-reviewer")
Agent(subagent_type="ecc:kotlin-reviewer")
Agent(subagent_type="ecc:flutter-reviewer")
Agent(subagent_type="ecc:java-reviewer")
Agent(subagent_type="ecc:fastapi-reviewer")
Agent(subagent_type="ecc:django-reviewer")
Agent(subagent_type="ecc:database-reviewer")
Agent(subagent_type="ecc:security-reviewer")
Agent(subagent_type="ecc:react-build-resolver")
Agent(subagent_type="ecc:go-build-resolver")
Agent(subagent_type="ecc:rust-build-resolver")
Agent(subagent_type="ecc:cpp-build-resolver")
Agent(subagent_type="ecc:kotlin-build-resolver")
Agent(subagent_type="ecc:flutter-build-resolver")
Agent(subagent_type="ecc:java-build-resolver")
Agent(subagent_type="ecc:dart-build-resolver")
Agent(subagent_type="ecc:django-build-resolver")
Agent(subagent_type="ecc:swift-build-resolver")
Agent(subagent_type="ecc:pytorch-build-resolver")
Agent(subagent_type="ecc:refactor-cleaner")
Agent(subagent_type="ecc:code-explorer")
Agent(subagent_type="ecc:code-architect")
Agent(subagent_type="ecc:architect")
Agent(subagent_type="ecc:planner")
Agent(subagent_type="ecc:code-simplifier")
Agent(subagent_type="ecc:comment-analyzer")
Agent(subagent_type="ecc:doc-updater")
Agent(subagent_type="ecc:docs-lookup")
Agent(subagent_type="ecc:harness-optimizer")
Agent(subagent_type="ecc:homelab-architect")
Agent(subagent_type="ecc:chief-of-staff")
Agent(subagent_type="ecc:loop-operator")
Agent(subagent_type="ecc:gan-planner")
Agent(subagent_type="ecc:gan-generator")
Agent(subagent_type="ecc:gan-evaluator")
Agent(subagent_type="ecc:e2e-runner")
Agent(subagent_type="ecc:performance-optimizer")
Agent(subagent_type="ecc:type-design-analyzer")
Agent(subagent_type="ecc:healthcare-reviewer")
Agent(subagent_type="ecc:mle-reviewer")
Agent(subagent_type="ecc:pr-test-analyzer")
Agent(subagent_type="ecc:silent-failure-hunter")
Agent(subagent_type="ecc:network-troubleshooter")
Agent(subagent_type="ecc:network-config-reviewer")
Agent(subagent_type="ecc:network-architect")
Agent(subagent_type="ecc:conversation-analyzer")
Agent(subagent_type="autonomous-loops")
```

### Design & frontend agents
```bash
Agent(subagent_type="ecc:design-review")
Agent(subagent_type="ecc:frontend-design-direction")
Agent(subagent_type="impeccable")
Agent(subagent_type="context7-plugin:docs-researcher")
Agent(subagent_type="claude-code-guide")
```

### Workflow orchestration agents
```bash
Agent(subagent_type="ecc:conversation-analyzer")   # for /hookify
Agent(subagent_type="general-purpose")             # catch-all
Agent(subagent_type="Explore")                     # read-only search
Agent(subagent_type="Plan")                        # architecture planning
```

---

## MCP Servers

Configured in `claude.json` under `mcpServers`:

| Server | Command | Purpose |
|---|---|---|
| **github** | `npx -y @modelcontextprotocol/server-github` | GitHub operations via gh CLI |
| **supabase** | `npx -y @supabase/mcp-server-supabase` | Supabase backend |
| **firecrawl** | `npx -y firecrawl-mcp` | Web scraping / crawling |
| **context7** | `npx -y @upstash/context7-mcp` | Live library/framework docs |
| **playwright** | `npx -y @playwright/mcp@latest` | Browser automation + testing |
| **shadcn** | `npx -x shadcn-ui-mcp-server` | shadcn/ui component examples |
| **magicui** | `npx -y @magicuidesign/mcp` | Magic UI components |
| **21st** | `npx -y @21st-dev/magic@latest` | 21st dev components (needs `TWENTY_FIRST_API_KEY`) |

---

## Skills Browser (358 total)

Use this section as a searchable index. Each entry is the **folder name** — use it as the skill name when invoking.

### Engineering & Code Quality
`adversarial-reviewer` · `code-reviewer` · `codebase-onboarding` · `dependency-auditor` · `env-secrets-manager` · `feature-flags-architect` · `focused-fix` · `kubernetes-operator` · `monorepo-navigator` · `performance-profiler` · `security-pen-testing` · `ship-gate` · `tech-debt-tracker` · `tdd-guide`

### Frontend & Design
`frontend-design` · `frontend-dev` · `frontend-developer` · `frontend-skill` · `frontend-slides` · `impeccable` · `ui-ux-pro-max` · `high-end-visual-design` · `design-taste-frontend` · `minimalist-skill` · `minimalist-ui` · `industrial-brutalist-ui` · `brutalist-skill` · `design-consultation` · `design-brief` · `design-md` · `design-review` · `design-system` · `epic-design` · `redesign-existing-projects` · `redesign-skill` · `soft-skill` · `taste-skill` · `gpt-taste` · `gpt-tasteskill` · `ui-design-system` · `web-design-guidelines` · `canvas-design` · `algorithmic-art` · `d3-visualization` · `threejs` · `webgpu-threejs-tsl` · `shader-dev` · `mockup-device-3d` · `imagegen` · `imagen` · `image-to-code` · `image-to-code-skill` · `article-magazine`

### Image & Media Generation
`fal-3d` · `fal-generate` · `fal-image-edit` · `fal-kling-o3` · `fal-lip-sync` · `fal-realtime` · `fal-restore` · `fal-train` · `fal-tryon` · `fal-upscale` · `fal-video-edit` · `fal-vision` · `image-enhancer` · `pixelbin-media` · `venice-image-generate` · `venice-image-edit` · `screenshot` · `full-page-screenshot` · `screenshots-marketing` · `gif-sticker-maker` · `venice-video` · `venice-audio-music` · `venice-audio-speech` · `sora` · `replicate` · `speech` · `hatch-pet` · `pixelbin-media`

### Slides & Decks
`deck-guizang-editorial` · `deck-open-slide-canvas` · `deck-swiss-international` · `digits-fintech-swiss-template` · `editorial-burgundy-principles-template` · `field-notes-editorial-template` · `html-ppt-retro-quarterly-review` · `ppt-keynote` · `pptx` · `pptx-generator` · `pptx-html-fidelity-audit` · `slides` · `nanobanana-ppt` · `swiss-creative-mode-template` · `swiss-user-research-video-template` · `after-hours-editorial-template` · `8-bit-orbit-video-template`

### Video & Motion
`remotion` · `video-hyperframes` · `frame-data-chart-nyt` · `frame-flowchart-sticky` · `frame-glitch-title` · `frame-light-leak-cinema` · `frame-liquid-bg-hero` · `frame-logo-outro` · `frame-macos-notification` · `vfx-text-cursor` · `manim-video` · `youtube-clipper` · `video-downloader`

### Documents & Reports
`doc` · `docx` · `minimax-docx` · `minimax-pdf` · `pdf` · `data-report` · `card-twitter` · `card-xiaohongshu` · `social-reddit-card` · `social-spotify-card` · `social-x-post-card` · `resume-modern` · `doc-kami-parchment` · `figma-code-connect-components` · `figma-create-design-system-rules` · `figma-create-new-file` · `figma-generate-design` · `figma-generate-library` · `figma-implement-design` · `figma-use`

### Marketing & Growth
`ad-creative` · `ai-seo` · `analytics-tracking` · `app-store-optimization` · `ab-test-setup` · `brand-guidelines` · `brandkit` · `campaign-analytics` · `churn-prevention` · `cold-email` · `competitive-ads-extractor` · `competitive-intel` · `competitive-teardown` · `competitor-alternatives` · `content-creator` · `content-humanizer` · `content-production` · `content-strategy` · `copy-editing` · `copywriting` · `cro-advisor` · `customer-success-manager` · `email-sequence` · `email-template-builder` · `experiment-designer` · `faq-page` · `form-cro` · `free-tool-strategy` · `landing-page-generator` · `launch-strategy` · `marketing-context` · `marketing-demand-acquisition` · `marketing-ideas` · `marketing-ops` · `marketing-psychology` · `marketing-skills` · `marketing-strategy-pmm` · `onboarding-cro` · `page-cro` · `paid-ads` · `paywall-upgrade-cro` · `popup-cro` · `pricing-strategy` · `programmatic-seo` · `referral-program` · `schema-markup` · `seo-audit` · `signup-flow-cro` · `social-content` · `social-media-analyzer` · `social-media-manager` · `x-twitter-growth`

### C-Suite & Company Leadership
`ceo-advisor` · `cfo-advisor` · `chro-advisor` · `chief-ai-officer-advisor` · `chief-customer-officer-advisor` · `chief-data-officer-advisor` · `chief-of-staff` · `cmo-advisor` · `coo-advisor` · `cpo-advisor` · `cro-advisor` · `cto-advisor` · `ciso-advisor` · `c-level-skills` · `company-os` · `culture-architect` · `founder-coach` · `board-deck-builder` · `board-meeting` · `decision-logger` · `general-counsel-advisor` · `vpe-advisor` · `org-health-diagnostic` · `internal-narrative` · `change-management` · `intl-expansion` · `ma-playbook`

### Strategy, Planning & Research
`brainstorming` · `creative-director` · `enhance-prompt` · `plan-design-review` · `product-discovery` · `product-manager-toolkit` · `product-strategist` · `prompt-engineer-toolkit` · `senior-pm` · `senior-prompt-engineer` · `spec-driven-workflow`

### Compliance, Security & Legal
`compliance-os` · `compliance-readiness` · `eu-ai-act-specialist` · `ai-act-readiness` · `gdpr-audit-prep` · `gdpr-dsgvo-expert` · `cloud-security` · `ai-security` · `incident-commander` · `incident-response` · `isms-audit-expert` · `iso13485-audit-prep` · `iso27001-audit-prep` · `iso42001-specialist` · `information-security-manager-iso27001` · `hipaa-compliance` · `healthcare-phi-compliance` · `risk-management-specialist` · `capa-officer` · `fda-consultant-specialist` · `fda-qsr-audit-prep` · `mdr-745-specialist` · `contract-and-proposal-writer` · `secrets-vault-manager` · `env-secrets-manager` · `ssl`

### DevOps, Cloud & Infra
`aws-solution-architect` · `azure-cloud-architect` · `gcp-cloud-architect` · `ci-cd-pipeline-builder` · `chaos-engineering` · `observability-designer` · `release-manager` · `runbook-generator` · `slo-architect` · `migration-architect` · `ms365-tenant-manager` · `atlassian-admin` · `atlassian-templates` · `confluence-expert` · `jira-expert` · `git-worktree-manager`

### Data, ML & AI
`database-designer` · `database-schema-designer` · `financial-analyst` · `finance-skills` · `saas-metrics-coach` · `product-analytics` · `revenue-operations` · `senior-data-scientist` · `senior-data-engineer` · `senior-ml-engineer` · `senior-computer-vision` · `rag-architect` · `mcp-builder` · `mcp-server-builder` · `claude-api` · `ai-music-album` · `ml-agents`

### Agents & Multi-Agent Systems
`agent-browser` · `agent-designer` · `agent-protocol` · `agent-workflow-designer` · `hand-drawn-diagrams` · `meeting-analyzer` · `interview-system-designer` · `database`

### Utilities & Misc
`changelog-generator` · `color-expert` · `command-guide` · `context-engine` · `domain-name-brainstormer` · `login-flow` · `full-output-enforcement` · `output-skill` · `browser-automation` · `webapp-testing` · `deep-research` · `roadmap-communicator` · `strategic-alignment` · `team-communications` · `business-growth-skills` · `engineering-skills` · `engineering-advanced-skills`

---

## Habits & Tips (from `settings.json`)

- `cc` instead of `claude` — skip all permission prompts
- Prefix `!` to run bash inline: `!git status`, `!npm test`
- `Esc` stops Claude. `Esc+Esc` rewinds to any checkpoint.
- `ultrathink` — prefix any prompt for harder reasoning
- `@filename` — skip Claude searching, point it directly
- `/btw` — side questions without polluting main context
- `/clear` — between unrelated tasks, fresh context wins
- `Ctrl+S` — stashes draft prompt while you ask something quick
- `Ctrl+B` — backgrounds long bash tasks
- Subagents — use for deep investigations to keep main context clean
- Plan Mode `Shift+Tab` — before any multi-file or unfamiliar work
- `Ctrl+G` — edits Claude's plan before it writes a line
- `/model opus` for hard tasks, `/model haiku` for fast ones
- `.claude/rules/` — file-type-specific rules
- `/permissions` — allowlist safe commands
- `/sandbox` — risky or experimental autonomous work
- `/loop` — poll deploys or CI on an interval

---

## Model & Config Summary

- **Model**: `openrouter/owl-alpha` (via OpenRouter)
- **Effort**: `xhigh`
- **Memory**: auto-enabled (`autoMemoryEnabled`, `autoDreamEnabled`)
- **Output style**: `Explanatory`
- **Theme**: `light-ansi`
- **Permissions**: `bypassPermissions` mode
- **Hooks**: tool-use dashboard logger, failure logger, Stop event logger, StopFailure bell
- **Spinner phrases**: 60+ humorous loading messages (vibes included)
- **Tips**: 25 rotation tips surfaced during loading

---

## Repo Structure

```
MyCld/
├── CLAUDE.md              # global Claude Code protocol (rules)
├── README.md              # <-- this file
├── claude.json            # Claude Code native config (MCP servers, projects, tips)
├── settings.json          # harness config (plugins, hooks, env, model, spinner verbs)
└── skills/                # 358 skill folders
    └── <skill-name>/
        └── SKILL.md       # frontmatter (name, description, triggers) + body
```

To add a new skill: drop a folder with a `SKILL.md` into `skills/`. Claude Code picks it up on the next session.
