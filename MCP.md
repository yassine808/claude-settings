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
