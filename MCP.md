# ============================================= MCP =======================================================

claude mcp add --scope user playwright npx @playwright/mcp@latest
claude mcp add --scope user github npx @modelcontextprotocol/server-github
claude mcp add --scope user filesystem npx @modelcontextprotocol/server-filesystem
claude mcp add --scope user context7 npx @upstash/context7-mcp
claude mcp add --scope user memory npx @modelcontextprotocol/server-memory
claude mcp add --scope user sequential-thinking npx @modelcontextprotocol/server-sequential-thinking

# ============================================= PLUGINS =======================================================

npx claudepluginhub obra/superpowers --plugin superpowers
npx claudepluginhub affaan-m/ecc --plugin ecc
npx claudepluginhub pbakaus/impeccable --plugin impeccable

ui-ux-pro-max-skill:
  - /plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
  - /plugin install ui-ux-pro-max@ui-ux-pro-max-skill

npx claudepluginhub dashed/claude-marketplace --plugin skill-creator
npx claudepluginhub upstash/context7 --plugin context7-plugin
npx claudepluginhub addyosmani/agent-skills --plugin agent-skills
npx claudepluginhub anthropics/claude-plugins-official --plugin frontend-design
npx claudepluginhub anthropics/claude-plugins-official --plugin claude-md-management
npx claudepluginhub anthropics/claude-plugins-official --plugin code-review
npx claudepluginhub anthropics/claude-plugins-official --plugin github
npx claudepluginhub anthropics/claude-plugins-official --plugin playwright

npx claudepluginhub affaan-m/ecc --plugin ecc

# ============================================= AGENTS =======================================================




# ============================================ HEAVY ONES ====================================================

**heavy** npx claudepluginhub sickn33/antigravity-awesome-skills

npx claudepluginhub thedotmack/claude-mem --plugin claude-mem (removed)
  -  powershell -c "irm bun.sh/install.ps1 | iex"
  -  [System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_GIT_BASH_PATH", "C:\Program Files\Git\bin\bash.exe", "User")

npx claudepluginhub jarrodwatts/claude-hud --plugin claude-hud