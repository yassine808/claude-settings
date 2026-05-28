function Ask($msg) {
    $r = Read-Host "$msg [y/N]"
    return $r -match '^[Yy]$'
}

function TryRemovePath($p) {
    if (Test-Path $p) {
        Remove-Item $p -Recurse -Force
        Write-Host "  Removed: $p"
    } else {
        Write-Host "  Not found: $p"
    }
}

Write-Host "=== Claude Complete Removal Script ==="

if (Ask "[1/6] Uninstall Claude desktop app via winget?") {
    winget uninstall --id Anthropic.ClaudeCode --silent
    Write-Host "  Done"
}

if (Ask "[2/6] Uninstall npm package?") {
    npm uninstall -g @anthropic-ai/claude-code
    $npmRoot = npm root -g 2>$null
    if ($npmRoot) {
        $leftover = Join-Path (Split-Path $npmRoot) "claude-code"
        if (Test-Path $leftover) { Remove-Item $leftover -Recurse -Force }
    }
    Write-Host "  Done"
}

if (Ask "[3/6] Delete config/data folders?") {
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

if (Ask "[4/6] Delete temp/cache files?") {
    $cachePaths = @(
        "$env:LOCALAPPDATA\Temp\claude*",
        "$env:LOCALAPPDATA\Temp\anthropic*"
    )
    foreach ($p in $cachePaths) {
        Get-Item $p -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item $_.FullName -Recurse -Force
            Write-Host "  Removed: $($_.FullName)"
        }
    }
}

if (Ask "[5/6] Remove user environment variables?") {
    [System.Environment]::GetEnvironmentVariables("User").Keys |
        Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" } |
        ForEach-Object {
            [System.Environment]::SetEnvironmentVariable($_, $null, "User")
            Write-Host "  Cleared [User]: $_"
        }
}

if (Ask "[6/6] Remove SYSTEM environment variables? (requires admin)") {
    try {
        [System.Environment]::GetEnvironmentVariables("Machine").Keys |
            Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" } |
            ForEach-Object {
                [System.Environment]::SetEn
