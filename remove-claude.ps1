# search for claude left-overs : Get-ChildItem -Path C:\ -Recurse -Filter "*claude*" -ErrorAction SilentlyContinue

function Ask($msg) {
    $r = Read-Host "$msg [y/N]"
    return $r -match '^[Yy]$'
}

Write-Host "=== Full Claude Removal Script ==="

# 1. Kill process
if (Ask "[1/9] Kill Claude process?") {
    Stop-Process -Name "claude" -Force -ErrorAction SilentlyContinue
    Write-Host "  Done"
}

# 2. Winget uninstall
if (Ask "[2/9] Uninstall via winget?") {
    winget uninstall --id Anthropic.ClaudeCode --silent
    Write-Host "  Done"
}

# 3. NPM package
if (Ask "[3/9] Uninstall npm package?") {
    npm uninstall -g @anthropic-ai/claude-code
    Remove-Item "$env:APPDATA\npm\node_modules\@anthropic-ai" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Done"
}

# 4. Config/data folders
if (Ask "[4/9] Delete config/data folders?") {
    @(
        "$env:APPDATA\Claude",
        "$env:LOCALAPPDATA\Claude",
        "$env:LOCALAPPDATA\AnthropicClaude",
        "$env:LOCALAPPDATA\claude-cli-nodejs",
        "$env:USERPROFILE\.claude",
        "$env:USERPROFILE\.claude.json",
        "$env:USERPROFILE\.config\claude"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force; Write-Host "  Removed: $_" }
        else { Write-Host "  Not found: $_" }
    }
}

# 5. Temp/cache
if (Ask "[5/9] Delete temp/cache files?") {
    @(
        "$env:LOCALAPPDATA\Temp\claude",
        "$env:APPDATA\Code\CachedExtensionVSIXs\anthropic.claude-code-2.1.152-win32-x64",
        "$env:APPDATA\Code\CachedExtensionVSIXs\anthropic.claude-code-2.1.153-win32-x64",
        "$env:APPDATA\Code\CachedExtensionVSIXs\.trash\anthropic.claude-code-2.1.153-win32-x64.sigzip"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force; Write-Host "  Removed: $_" }
        else { Write-Host "  Not found: $_" }
    }
}

# 6. VSCode extensions
if (Ask "[6/9] Delete VSCode extensions?") {
    Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Depth 1 -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "claude|anthropic" } |
        ForEach-Object { Remove-Item $_.FullName -Recurse -Force; Write-Host "  Removed: $($_.FullName)" }
}

# 7. WinGet package folder
if (Ask "[7/9] Delete WinGet package folder?") {
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Depth 1 -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "claude|anthropic" } |
        ForEach-Object { Remove-Item $_.FullName -Recurse -Force; Write-Host "  Removed: $($_.FullName)" }
}

# 8. Registry
if (Ask "[8/9] Clean registry?") {
    @(
        "HKCU:\Software\Classes\claude-cli",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Anthropic.ClaudeCode_Microsoft.Winget.Source_8wekyb3d8bbwe",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Cloud\{f6c8a3f5-489a-4c49-ba99-ecd5567311b7}`$windows.data.apps.appmetadata`$appmetadatalist\windows.data.apps.appmetadata`$anthropic.claudecode_microsoft.winget.source_8wekyb3d8bbwe",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\{f6c8a3f5-489a-4c49-ba99-ecd5567311b7}`$windows.data.apps.appmetadata`$appmetadatalist\windows.data.apps.appmetadata`$anthropic.claudecode_microsoft.winget.source_8wekyb3d8bbwe"
    ) | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force; Write-Host "  Removed: $_" }
        else { Write-Host "  Not found: $_" }
    }
}

# 9. Env vars + PATH
if (Ask "[9/9] Clean environment variables and PATH?") {
    # Remove ANTHROPIC_*/CLAUDE_* vars
    @("User","Machine") | ForEach-Object {
        $scope = $_
        [System.Environment]::GetEnvironmentVariables($scope).Keys |
            Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" } |
            ForEach-Object {
                [System.Environment]::SetEnvironmentVariable($_, $null, $scope)
                Write-Host "  Cleared [$scope]: $_"
            }
    }
    # Clean PATH
    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $cleaned = (($path -split ";") | Where-Object { $_ -notmatch "claude|anthropic" }) -join ";"
    [System.Environment]::SetEnvironmentVariable("PATH", $cleaned, "User")
    Write-Host "  PATH cleaned"
}

Write-Host "`n=== Done. Restart terminal to apply changes. ==="
