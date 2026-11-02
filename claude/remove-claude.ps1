# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "⚠️  Running without administrator privileges. Some items may not be fully removable." -ForegroundColor Yellow
    Write-Host "   For complete removal, restart PowerShell as Administrator." -ForegroundColor Yellow
    Write-Host ""
}

function Ask($msg) {
    $r = Read-Host "$msg [y/N]"
    return $r -match '^[Yy]$'
}

function Select-ItemsInteractive {
    param([array]$Items, [string]$Title)
    
    if ($Items.Count -eq 0) {
        Write-Host "  No items found." -ForegroundColor Gray
        return @()
    }
    
    Write-Host "`n$Title" -ForegroundColor Cyan
    Write-Host "Found $($Items.Count) item(s):" -ForegroundColor Yellow
    
    for ($i = 0; $i -lt $Items.Count; $i++) {
        Write-Host "  [$i] $($Items[$i])" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  - Enter specific numbers (e.g., '0,2,5')" -ForegroundColor Gray
    Write-Host "  - Enter 'all' to select all" -ForegroundColor Gray
    Write-Host "  - Enter 'none' or press Enter to skip" -ForegroundColor Gray
    
    $choice = Read-Host "Select items to remove"
    
    if ($choice -eq 'all') {
        return $Items
    }
    elseif ($choice -eq 'none' -or [string]::IsNullOrWhiteSpace($choice)) {
        return @()
    }
    else {
        $selected = @()
        $numbers = $choice -split ',' | ForEach-Object { $_.Trim() }
        foreach ($num in $numbers) {
            if ([int]::TryParse($num, [ref]$null) -and [int]$num -ge 0 -and [int]$num -lt $Items.Count) {
                $selected += $Items[[int]$num]
            }
        }
        return $selected
    }
}

# ====================================================================
# STEP 1: Kill Claude process
# ====================================================================
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 1/10: Kill Claude Process ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Kill any running Claude processes?") {
    $processes = Get-Process -Name "*claude*" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "Found $($processes.Count) Claude process(es):" -ForegroundColor Yellow
        $processes | ForEach-Object { Write-Host "  - $($_.ProcessName) (PID: $($_.Id))" }
        Stop-Process -Name "*claude*" -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Processes terminated" -ForegroundColor Green
    } else {
        Write-Host "No Claude processes running" -ForegroundColor Gray
    }
}

# ====================================================================
# STEP 2: WinGet uninstall
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 2/10: Uninstall via WinGet ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Uninstall Claude via winget?") {
    Write-Host "Running winget uninstall..." -ForegroundColor Yellow
    winget uninstall --id Anthropic.ClaudeCode --silent 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Uninstalled via winget" -ForegroundColor Green
    } else {
        Write-Host "⚠ Winget uninstall completed (may not have been installed via winget)" -ForegroundColor Yellow
    }
}

# ====================================================================
# STEP 3: NPM package
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 3/10: Remove NPM Package ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Uninstall Claude NPM package?") {
    Write-Host "Uninstalling npm package..." -ForegroundColor Yellow
    npm uninstall -g @anthropic-ai/claude-code 2>$null
    
    $npmPath = "$env:APPDATA\npm\node_modules\@anthropic-ai"
    if (Test-Path $npmPath) {
        Remove-Item $npmPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Removed: $npmPath" -ForegroundColor Green
    } else {
        Write-Host "NPM package not found" -ForegroundColor Gray
    }
}

# ====================================================================
# STEP 4: Config/data folders
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 4/10: Delete Config/Data Folders ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Delete Claude configuration and data folders?") {
    $folders = @(
        "$env:APPDATA\Claude",
        "$env:LOCALAPPDATA\Claude",
        "$env:LOCALAPPDATA\AnthropicClaude",
        "$env:LOCALAPPDATA\claude-cli-nodejs",
        "$env:USERPROFILE\.claude",
        "$env:USERPROFILE\.claude.json",
        "$env:USERPROFILE\.config\claude"
    )
    
    $removed = 0
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Removed: $folder" -ForegroundColor Green
            $removed++
        } else {
            Write-Host "  Not found: $folder" -ForegroundColor Gray
        }
    }
    Write-Host "✓ Removed $removed folder(s)" -ForegroundColor Green
}

# ====================================================================
# STEP 5: Temp/cache files
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 5/10: Delete Temp/Cache Files ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Delete Claude temporary and cache files?") {
    $tempPaths = @(
        "$env:LOCALAPPDATA\Temp\claude*",
        "$env:TEMP\claude*",
        "$env:APPDATA\Code\CachedExtensionVSIXs\*claude*",
        "$env:APPDATA\Code\CachedExtensionVSIXs\.trash\*claude*"
    )
    
    $removed = 0
    foreach ($pattern in $tempPaths) {
        $items = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            Remove-Item $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Removed: $($item.FullName)" -ForegroundColor Green
            $removed++
        }
    }
    
    if ($removed -eq 0) {
        Write-Host "No temp/cache files found" -ForegroundColor Gray
    } else {
        Write-Host "✓ Removed $removed temp/cache item(s)" -ForegroundColor Green
    }
}

# ====================================================================
# STEP 6: VS Code extensions
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 6/10: Remove VS Code Extensions ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Remove Claude-related VS Code extensions?") {
    $extensions = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -match "claude|anthropic" }
    
    if ($extensions.Count -gt 0) {
        foreach ($ext in $extensions) {
            Write-Host "Extension found: $($ext.Name)" -ForegroundColor Yellow
            Remove-Item $ext.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Removed: $($ext.FullName)" -ForegroundColor Green
        }
        Write-Host "✓ Removed $($extensions.Count) VS Code extension(s)" -ForegroundColor Green
    } else {
        Write-Host "No Claude-related VS Code extensions found" -ForegroundColor Gray
    }
}

# ====================================================================
# STEP 7: WinGet package folder
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 7/10: Clean WinGet Package Folders ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Delete Claude WinGet package folders?") {
    $packages = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Directory -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "claude|anthropic" }
    
    if ($packages.Count -gt 0) {
        foreach ($pkg in $packages) {
            Remove-Item $pkg.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "✓ Removed: $($pkg.FullName)" -ForegroundColor Green
        }
        Write-Host "✓ Removed $($packages.Count) WinGet package folder(s)" -ForegroundColor Green
    } else {
        Write-Host "No Claude WinGet packages found" -ForegroundColor Gray
    }
}

# ====================================================================
# STEP 8: Registry cleanup
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 8/10: Clean Registry ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Clean Claude-related registry entries?") {
    $regPaths = @(
        "HKCU:\Software\Classes\claude-cli",
        "HKCU:\Software\Anthropic",
        "HKCU:\Software\Claude",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\Anthropic.ClaudeCode*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Cloud\*claude*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\DefaultAccount\Current\*claude*",
        "HKLM:\Software\Anthropic",
        "HKLM:\Software\Claude",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.claude"
    )
    
    $removed = 0
    foreach ($regPath in $regPaths) {
        try {
            if (Test-Path $regPath) {
                Remove-Item $regPath -Recurse -Force -ErrorAction Stop
                Write-Host "✓ Removed registry: $regPath" -ForegroundColor Green
                $removed++
            } else {
                Write-Host "  Not found: $regPath" -ForegroundColor Gray
            }
        } catch {
            Write-Host "✗ Failed to remove: $regPath" -ForegroundColor Red
            Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor DarkRed
        }
    }
    Write-Host "✓ Removed $removed registry entr(y/ies)" -ForegroundColor Green
}

# ====================================================================
# STEP 9: Environment variables and PATH
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 9/10: Clean Environment Variables and PATH ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Clean Claude-related environment variables and PATH entries?") {
    # Remove ANTHROPIC_*/CLAUDE_* vars
    $scopes = @("User", "Machine")
    $cleared = 0
    
    foreach ($scope in $scopes) {
        $vars = [System.Environment]::GetEnvironmentVariables($scope).Keys |
                Where-Object { $_ -match "^(ANTHROPIC|CLAUDE)_" }
        
        foreach ($var in $vars) {
            [System.Environment]::SetEnvironmentVariable($var, $null, $scope)
            Write-Host "✓ Cleared [$scope] environment variable: $var" -ForegroundColor Green
            $cleared++
        }
    }
    
    # Clean PATH
    $path = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($path) {
        $originalEntries = $path -split ";"
        $cleaned = ($originalEntries | Where-Object { $_ -notmatch "claude|anthropic" }) -join ";"
        
        if ($cleaned -ne $path) {
            [System.Environment]::SetEnvironmentVariable("PATH", $cleaned, "User")
            $removedEntries = ($originalEntries | Where-Object { $_ -match "claude|anthropic" })
            Write-Host "✓ Removed from PATH:" -ForegroundColor Green
            $removedEntries | ForEach-Object { Write-Host "  - $_" -ForegroundColor DarkGray }
            $cleared += $removedEntries.Count
        } else {
            Write-Host "No Claude entries found in PATH" -ForegroundColor Gray
        }
    }
    
    if ($cleared -eq 0) {
        Write-Host "No Claude environment variables found" -ForegroundColor Gray
    } else {
        Write-Host "✓ Cleaned $cleared environment variable/PATH entr(y/ies)" -ForegroundColor Green
    }
}

# ====================================================================
# STEP 10: Final scan for leftovers on C: drive
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "=== STEP 10/10: Final Scan for Leftovers on C: Drive ===" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if (Ask "Perform final scan for any remaining Claude leftovers on C: drive?") {
    Write-Host "`nSearching for files/folders containing 'claude' or 'anthropic'..." -ForegroundColor Yellow
    Write-Host "This may take a few minutes depending on your drive size...`n" -ForegroundColor Gray
    
    $claudeItems = @()
    
    # Search in common locations (prioritize these for speed)
    $searchPaths = @(
        "C:\Program Files",
        "C:\Program Files (x86)",
        "C:\ProgramData",
        "$env:USERPROFILE\AppData",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\.vscode",
        "$env:USERPROFILE\.config",
        "C:\Users\$env:USERNAME"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            Write-Host "  Scanning: $path" -ForegroundColor DarkGray
            $found = Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | 
                     Where-Object { $_.Name -match "claude|anthropic" } |
                     Select-Object -ExpandProperty FullName
            $claudeItems += $found
        }
    }
    
    # Remove duplicates and sort
    $claudeItems = $claudeItems | Sort-Object -Unique
    
    if ($claudeItems.Count -gt 0) {
        Write-Host "`n⚠️  Found $($claudeItems.Count) remaining Claude-related item(s)" -ForegroundColor Yellow
        Write-Host "These are leftovers that still exist after running the removal steps above.`n" -ForegroundColor Gray
        
        $selectedItems = Select-ItemsInteractive -Items $claudeItems -Title "Remaining Claude Leftovers"
        
        if ($selectedItems.Count -gt 0) {
            Write-Host "`nRemoving selected leftovers..." -ForegroundColor Yellow
            $removed = 0
            $failed = 0
            
            foreach ($item in $selectedItems) {
                try {
                    if (Test-Path $item) {
                        Remove-Item -Path $item -Recurse -Force -ErrorAction Stop
                        Write-Host "  ✓ Removed: $item" -ForegroundColor Green
                        $removed++
                    } else {
                        Write-Host "  ⚠ Not found (may already be removed): $item" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "  ✗ Failed to remove: $item" -ForegroundColor Red
                    Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor DarkRed
                    $failed++
                }
            }
            
            Write-Host "`n✓ Successfully removed $removed leftover(s)" -ForegroundColor Green
            if ($failed -gt 0) {
                Write-Host "⚠ Failed to remove $failed item(s) - try running as Administrator" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No leftovers selected for removal." -ForegroundColor Gray
        }
    } else {
        Write-Host "`n✓ No Claude leftovers found on C: drive!" -ForegroundColor Green
        Write-Host "Your system appears to be completely clean of Claude files." -ForegroundColor Green
    }
}

# ====================================================================
# FINAL: Summary and cleanup
# ====================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Green
Write-Host "=== Claude Removal Complete ===" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green

Write-Host "`nRecommended next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your terminal or PC to apply all changes" -ForegroundColor White
Write-Host "  2. Check your browser for Claude extensions/bookmarks" -ForegroundColor White
Write-Host "  3. Clear your Recycle Bin" -ForegroundColor White
Write-Host "  4. Check these locations manually if needed:" -ForegroundColor White
Write-Host "     - %APPDATA%" -ForegroundColor DarkGray
Write-Host "     - %LOCALAPPDATA%" -ForegroundColor DarkGray
Write-Host "     - %USERPROFILE%" -ForegroundColor DarkGray
Write-Host "     - Browser extensions and saved passwords" -ForegroundColor DarkGray

if (-not $isAdmin) {
    Write-Host "`n⚠️  Reminder: Some items may have been skipped due to lack of admin rights." -ForegroundColor Yellow
    Write-Host "   Run again as Administrator for complete removal." -ForegroundColor Yellow
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
