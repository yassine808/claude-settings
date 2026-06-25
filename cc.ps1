# --- Claude Code key rotation -------------------------------------------
# Add to your PowerShell profile:
#   . "$HOME\.claude\cc.ps1"
#
# Setup once:
#   1. Create ~/.claude/Keys.json:
#      {
#        "keys": [
#          { "ID": 1, "API": "sk-or-v1-...", "DESC": "primary account" },
#          { "ID": 2, "API": "sk-or-v1-...", "DESC": "backup account" }
#        ]
#      }
#   2. ~/.claude/settings.json must already exist with your other env vars.
#
# Usage:
#   cc          -> rotates to the NEXT key (wraps to first after last), no launch
#   cc 1        -> switches directly to key with ID 1, no launch
#   cc -l       -> interactive arrow-key picker, no launch

$ClaudeDir    = Join-Path $HOME ".claude"
$KeysFile     = Join-Path $ClaudeDir "Keys.json"
$SettingsFile = Join-Path $ClaudeDir "settings.json"
$StateFile    = Join-Path $ClaudeDir ".cc-state.json"

function Get-CcKeys {
    if (-not (Test-Path $KeysFile)) {
        throw "No Keys.json found at $KeysFile"
    }
    $data = Get-Content $KeysFile -Raw | ConvertFrom-Json
    if (-not $data.keys -or $data.keys.Count -eq 0) {
        throw "Keys.json has no entries."
    }
    return $data.keys
}

function Get-CcLastId {
    if (Test-Path $StateFile) {
        try {
            return (Get-Content $StateFile -Raw | ConvertFrom-Json).lastId
        } catch { return $null }
    }
    return $null
}

function Set-CcLastId {
    param($Id)
    @{ lastId = $Id } | ConvertTo-Json | Set-Content $StateFile
}

function Mask-CcKey {
    param([string]$Key)
    if ($Key.Length -le 18) { return $Key }
    $head = $Key.Substring(0, 12)
    $tail = $Key.Substring($Key.Length - 3)
    return "$head...$tail"
}

function Set-CcActiveKey {
    param($Entry)

    if (-not (Test-Path $SettingsFile)) {
        throw "No settings.json found at $SettingsFile"
    }

    $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
    if (-not $settings.env) {
        $settings | Add-Member -NotePropertyName env -NotePropertyValue (@{}) -Force
    }
    $settings.env.ANTHROPIC_AUTH_TOKEN = $Entry.API
    $settings | ConvertTo-Json -Depth 20 | Set-Content $SettingsFile

    Set-CcLastId -Id $Entry.ID

    Write-Host "Switched to key ID " -NoNewline -ForegroundColor Gray
    Write-Host $Entry.ID -NoNewline -ForegroundColor Cyan
    Write-Host " [" -NoNewline -ForegroundColor Gray
    Write-Host $Entry.DESC -NoNewline -ForegroundColor Magenta
    Write-Host "] -> " -NoNewline -ForegroundColor Gray
    Write-Host (Mask-CcKey $Entry.API) -ForegroundColor Green
}

function Select-CcKeyInteractive {
    $keys = Get-CcKeys
    $lastId = Get-CcLastId
    $selectedIndex = 0

    # start cursor on current key if known
    for ($i = 0; $i -lt $keys.Count; $i++) {
        if ($keys[$i].ID -eq $lastId) { $selectedIndex = $i }
    }

    function Write-CcRow {
        param($Entry, [bool]$IsCurrent, [bool]$IsSelected)

        $marker = if ($IsCurrent) { "*" } else { " " }
        $cursor = if ($IsSelected) { ">" } else { " " }
        $idText  = "{0,4}" -f $Entry.ID
        $apiText = Mask-CcKey $Entry.API
        $descText = $Entry.DESC

        $idColor    = if ($IsSelected) { "Yellow" } else { "Cyan" }
        $apiColor   = if ($IsSelected) { "Yellow" } else { "Green" }
        $descColor  = if ($IsSelected) { "Yellow" } else { "Magenta" }
        $punctColor = if ($IsSelected) { "Yellow" } else { "DarkGray" }

        Write-Host "$cursor$marker " -NoNewline -ForegroundColor $punctColor
        Write-Host $idText -NoNewline -ForegroundColor $idColor
        Write-Host " ; " -NoNewline -ForegroundColor $punctColor
        Write-Host $apiText -NoNewline -ForegroundColor $apiColor
        Write-Host " ; " -NoNewline -ForegroundColor $punctColor
        Write-Host $descText -ForegroundColor $descColor
    }

    while ($true) {
        Clear-Host
        Write-Host "Select a key (Up/Down + Enter, Esc to cancel)" -ForegroundColor Cyan
        Write-Host ("     {0,4} ; {1,-18} ; {2}" -f "ID", "API", "DESC") -ForegroundColor DarkGray
        for ($i = 0; $i -lt $keys.Count; $i++) {
            $isCurrent = ($keys[$i].ID -eq $lastId)
            $isSelected = ($i -eq $selectedIndex)
            Write-CcRow -Entry $keys[$i] -IsCurrent $isCurrent -IsSelected $isSelected
        }

        $key = [System.Console]::ReadKey($true)
        switch ($key.Key) {
            "UpArrow"   { $selectedIndex = ($selectedIndex - 1 + $keys.Count) % $keys.Count }
            "DownArrow" { $selectedIndex = ($selectedIndex + 1) % $keys.Count }
            "Enter"     { return $keys[$selectedIndex] }
            "Escape"    { return $null }
        }
    }
}

function cc {
    # Use $args directly instead of a typed param block so that
    # "-l" is treated as a literal string argument, not an attempt
    # to bind a named parameter called "-l" (which doesn't exist).
    $Arg = if ($args.Count -gt 0) { $args[0] } else { $null }

    try {
        $keys = Get-CcKeys
    } catch {
        Write-Warning $_
        return
    }

    if ($Arg -eq "-l") {
        $picked = Select-CcKeyInteractive
        Clear-Host
        if ($null -eq $picked) {
            Write-Host "Cancelled, no change made." -ForegroundColor DarkGray
            return
        }
        Set-CcActiveKey -Entry $picked
        return
    }

    if ($Arg) {
        # cc <id>
        $idNum = $null
        if (-not [int]::TryParse($Arg, [ref]$idNum)) {
            Write-Warning "Argument must be a numeric ID, -l, or empty."
            return
        }
        $match = $keys | Where-Object { $_.ID -eq $idNum }
        if (-not $match) {
            Write-Warning "No key found with ID $idNum"
            return
        }
        Set-CcActiveKey -Entry $match
        return
    }

    # cc with no args -> rotate to next, wrap at end
    $lastId = Get-CcLastId
    $currentIndex = -1
    for ($i = 0; $i -lt $keys.Count; $i++) {
        if ($keys[$i].ID -eq $lastId) { $currentIndex = $i; break }
    }
    $nextIndex = ($currentIndex + 1) % $keys.Count
    Set-CcActiveKey -Entry $keys[$nextIndex]
}