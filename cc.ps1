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

    $raw = Get-Content $SettingsFile -Raw

    # Validate the file actually has an ANTHROPIC_AUTH_TOKEN key before
    # touching it -- parse read-only, never serialize back from this object,
    # so we never reformat the rest of the file.
    $parsed = $raw | ConvertFrom-Json
    if (-not $parsed.env -or -not ($parsed.env.PSObject.Properties.Name -contains "ANTHROPIC_AUTH_TOKEN")) {
        throw "settings.json has no env.ANTHROPIC_AUTH_TOKEN key to update. Add it manually first."
    }

    # Targeted text replace: only the value after "ANTHROPIC_AUTH_TOKEN":
    # changes. Every other byte in the file (spacing, key order, quoting
    # style) is left exactly as it was. Escape $ in the replacement text
    # since .NET regex treats $ specially there (e.g. $1 backreferences).
    $pattern = '(?<="ANTHROPIC_AUTH_TOKEN"\s*:\s*")[^"]*(?=")'
    $safeReplacement = $Entry.API -replace '\$', '$$$$'
    $newRaw = [Regex]::Replace($raw, $pattern, $safeReplacement)

    if ($newRaw -eq $raw -and $parsed.env.ANTHROPIC_AUTH_TOKEN -ne $Entry.API) {
        throw "Failed to update ANTHROPIC_AUTH_TOKEN -- pattern did not match. File left unchanged."
    }

    Set-Content -Path $SettingsFile -Value $newRaw -NoNewline

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
        param($Entry, [bool]$IsCurrent, [bool]$IsSelected, [int]$Row)

        # Always position explicitly before writing -- never rely on
        # natural cursor advance from a previous write, since writing a
        # string exactly WindowWidth characters long causes the console
        # to auto-wrap and silently shift CursorTop, desyncing every
        # later SetCursorPosition call that assumes fixed row heights.
        [System.Console]::SetCursorPosition(0, $Row)

        $cursor = if ($IsSelected) { "> " } else { "  " }
        $dotChar = "*"
        $dotColor = if ($IsCurrent) { "Green" } else { "DarkGray" }
        $idText  = "ID {0}" -f $Entry.ID
        $apiText = Mask-CcKey $Entry.API
        $descColor = if ($IsSelected) { "White" } else { "DarkGray" }

        Write-Host $cursor -NoNewline -ForegroundColor Green
        Write-Host $dotChar -NoNewline -ForegroundColor $dotColor
        Write-Host " " -NoNewline
        Write-Host $idText -NoNewline -ForegroundColor Blue
        Write-Host "  " -NoNewline
        Write-Host $apiText -NoNewline -ForegroundColor DarkYellow
        Write-Host "  " -NoNewline
        Write-Host $Entry.DESC -NoNewline -ForegroundColor $descColor

        # Clear any leftover characters to the right (e.g. if the previous
        # render at this row was longer), then force cursor to next line
        # ourselves rather than letting the terminal wrap.
        $safeWidth = [Math]::Max(0, [System.Console]::WindowWidth - [System.Console]::CursorLeft - 1)
        if ($safeWidth -gt 0) {
            Write-Host (" " * $safeWidth) -NoNewline
        }
    }

    # initial draw
    Write-Host ""
    $headerTop = [System.Console]::CursorTop
    [System.Console]::SetCursorPosition(0, $headerTop)
    Write-Host "? " -NoNewline -ForegroundColor Green
    Write-Host "Select a key to switch to: " -NoNewline -ForegroundColor White
    Write-Host "(Use arrow keys)" -NoNewline -ForegroundColor DarkGray
    $safeWidth = [Math]::Max(0, [System.Console]::WindowWidth - [System.Console]::CursorLeft - 1)
    if ($safeWidth -gt 0) { Write-Host (" " * $safeWidth) -NoNewline }

    $listTop = $headerTop + 1

    function Collapse-CcMenu {
        param([string]$AnswerText, [string]$AnswerColor = "Cyan")

        # blank out every row the menu used (header + all list rows)
        $blank = " " * ([System.Console]::WindowWidth - 1)
        for ($row = 0; $row -le $keys.Count; $row++) {
            [System.Console]::SetCursorPosition(0, $headerTop + $row)
            Write-Host $blank -NoNewline
        }
        [System.Console]::SetCursorPosition(0, $headerTop)
        Write-Host "? " -NoNewline -ForegroundColor Green
        Write-Host "Select a key to switch to: " -NoNewline -ForegroundColor White
        Write-Host $AnswerText -NoNewline -ForegroundColor $AnswerColor
        [System.Console]::SetCursorPosition(0, $headerTop + 1)
    }

    $originalCursorVisible = [System.Console]::CursorVisible
    try {
        [System.Console]::CursorVisible = $false

        for ($i = 0; $i -lt $keys.Count; $i++) {
            $isCurrent = ($keys[$i].ID -eq $lastId)
            $isSelected = ($i -eq $selectedIndex)
            Write-CcRow -Entry $keys[$i] -IsCurrent $isCurrent -IsSelected $isSelected -Row ($listTop + $i)
        }
        # park cursor below the list so further output (e.g. errors) appears cleanly
        [System.Console]::SetCursorPosition(0, $listTop + $keys.Count)

        while ($true) {
            $key = [System.Console]::ReadKey($true)
            $prevIndex = $selectedIndex
            switch ($key.Key) {
                "UpArrow"   { $selectedIndex = ($selectedIndex - 1 + $keys.Count) % $keys.Count }
                "DownArrow" { $selectedIndex = ($selectedIndex + 1) % $keys.Count }
                "Enter"     {
                    $picked = $keys[$selectedIndex]
                    Collapse-CcMenu -AnswerText ("ID {0} ({1})" -f $picked.ID, $picked.DESC) -AnswerColor "Cyan"
                    return $picked
                }
                "Escape"    {
                    Collapse-CcMenu -AnswerText "cancelled" -AnswerColor "DarkGray"
                    return $null
                }
            }

            if ($selectedIndex -ne $prevIndex) {
                # redraw only the two affected rows, in place
                Write-CcRow -Entry $keys[$prevIndex] -IsCurrent ($keys[$prevIndex].ID -eq $lastId) -IsSelected $false -Row ($listTop + $prevIndex)
                Write-CcRow -Entry $keys[$selectedIndex] -IsCurrent ($keys[$selectedIndex].ID -eq $lastId) -IsSelected $true -Row ($listTop + $selectedIndex)
            }
        }
    } finally {
        # guaranteed restore even on Ctrl+C, an exception, or any other
        # unexpected exit -- never leave the user's terminal cursor hidden
        [System.Console]::CursorVisible = $originalCursorVisible
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
        if ($null -eq $picked) {
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
