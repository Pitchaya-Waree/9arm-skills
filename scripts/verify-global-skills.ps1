# Verify Global Skills Installation and Frontmatter Validity
$ErrorActionPreference = "Continue"

function Test-SkillsRoot {
    param(
        [string]$Title,
        [string]$Path
    )

    Write-Host "`n==================================================" -ForegroundColor Cyan
    Write-Host " Testing $Title Global Skills" -ForegroundColor Cyan
    Write-Host " Path: $Path" -ForegroundColor Gray
    Write-Host "==================================================" -ForegroundColor Cyan

    if (-not (Test-Path $Path)) {
        Write-Host "[FAIL] Root directory does not exist: $Path" -ForegroundColor Red
        return
    }

    $skillDirs = Get-ChildItem -Path $Path -Directory
    if ($skillDirs.Count -eq 0) {
        Write-Host "[WARN] No skill directories found in $Path" -ForegroundColor Yellow
        return
    }

    $allPassed = $true
    foreach ($dir in $skillDirs) {
        $skillMd = Join-Path $dir.FullName "SKILL.md"
        if (-not (Test-Path $skillMd)) {
            Write-Host " [FAIL] $($dir.Name): Missing SKILL.md" -ForegroundColor Red
            $allPassed = $false
            continue
        }

        # Check frontmatter
        $content = Get-Content $skillMd -Raw
        $hasFrontmatter = $content -match "(?s)^---\s*\r?\n(.*?)\r?\n---"
        if ($hasFrontmatter) {
            $fm = $Matches[1]
            $nameMatch = $fm -match "name:\s*(.+)"
            $name = if ($nameMatch) { $Matches[1].Trim() } else { "<none>" }
            $descMatch = $fm -match "description:\s*(.+)"
            $desc = if ($descMatch) { $Matches[1].Trim().Substring(0, [System.Math]::Min(50, $Matches[1].Trim().Length)) + "..." } else { "<none>" }

            Write-Host " [PASS] $($dir.Name)" -ForegroundColor Green
            Write-Host "        name: $name" -ForegroundColor Gray
            Write-Host "        desc: $desc" -ForegroundColor DarkGray
        } else {
            Write-Host " [WARN] $($dir.Name): SKILL.md exists but YAML frontmatter (--- ... ---) not found" -ForegroundColor Yellow
        }
    }

    if ($allPassed) {
        Write-Host "`nAll skills verified successfully in $Title!" -ForegroundColor Green
    }
}

Test-SkillsRoot -Title "Antigravity (Gemini)" -Path "$env:USERPROFILE\.gemini\config\skills"
Test-SkillsRoot -Title "Claude Code" -Path "$env:USERPROFILE\.claude\skills"

# Also check npx skills list if npx is available
Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " Checking npx skills cli (if installed)" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
try {
    $npxCheck = Get-Command npx -ErrorAction SilentlyContinue
    if ($npxCheck) {
        Write-Host "Running: npx skills list" -ForegroundColor Gray
        npx skills list 2>&1
    } else {
        Write-Host "npx is not in PATH." -ForegroundColor Gray
    }
} catch {
    Write-Host "npx skills check skipped." -ForegroundColor Gray
}
