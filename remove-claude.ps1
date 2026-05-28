# remove-claude.ps1 — full Claude removal with per-step confirmation
# Run as Admin for system env vars + Machine-scope cleanup

function Ask($msg) {
    $r = Read-Host "$msg [y/N]"
    return $r -match '^[Yy]$'
}

function TryRemovePath($p) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force
        Write-Host "  ✓ Removed: $p"
    } else {
        Write-Host "  – Not found: $p"
    }
}

Write-Host "`n=== Claude Complete Removal Script ===" -ForegroundColor Cyan

# 1. Winget uninstall
if (Ask "`n[1/6] Uninstall Claude desktop app via winget?") {
    winget uninstall --id Anthropic.ClaudeCode --silent
    Write-Host "  ✓ Done"
}

# 2. NPM global package
if (Ask "`n[2/6] Uninstall @anthropic-ai/claude-code npm package?") {
    npm uninstall -g @anthropic-ai/claude-code
    # clean up leftover bin
    $npmRoot = npm root -g 2>$null
    if ($npmRoot) {
        $leftover = Join-Path (Split-Path $npmRoot) "claude-code"
        if (Test-Path $leftover) { Remove-Item $leftover -Recurse -Force }
    }
    Write-Host "  ✓ Done"
}

# 3. Config & data dirs
if (Ask "`n[3/6] Delete Claude config/data folders?") {
    $paths = @(
        "$env:APPDATA\Claude",
        "$env:LOCALAPPDATA\Claude",
        "$env:LOCALAPPDATA\AnthropicClaude",
        "$env:USERPROFILE\.claude",
        "$env:USERPROFILE\.claude.json",
        "$env:USERPROFILE\.config\claude"
    )
    foreach ($p in $paths) { TryRemovePath $p }
}

# 4. Temp/cache files
if (Ask "`n[4/6] Delete Claude temp/cache files?") {
    $cachePaths = @(
        "$env:LOCALAPPDATA\Temp\claude*",
        "$env:LOCALAPPDATA\Temp\anthropic*"
    )
    foreach ($p in $cachePaths) {
        Get-Item $p -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Host "  ✓ Removed: $($_.FullName)"
        }
    }
}

# 5. User env vars
if (Ask "`n[5/6] Remove Claude/Anthropic user environment variables?") {
    [System.Environment]::GetEnvironmentVariables("User").Keys |
        Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" } |
        ForEach-Object {
            [System.Environment]::SetEnvironmentVariable($_, $null, "User")
            Write-Host "  ✓ Cleared [User]: $_"
        }
}

# 6. System (Machine) env vars — needs admin
if (Ask "`n[6/6] Remove Claude/Anthropic SYSTEM environment variables? (requires admin)") {
    try {
        [System.Environment]::GetEnvironmentVariables("Machine").Keys |
            Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" } |
            ForEach-Object {
                [System.Environment]::SetEnvironmentVariable($_, $null, "Machine")
                Write-Host "  ✓ Cleared [Machine]: $_"
            }
    } catch {
        Write-Host "  ✗ Failed — re-run script as Administrator" -ForegroundColor Red
    }
}

Write-Host "`n=== Done. Restart your terminal to apply env changes. ===" -ForegroundColor Green
