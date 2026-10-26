# Install 9arm-skills globally for both Antigravity (Gemini) and Claude Code
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsSource = Join-Path $repoRoot "skills"

$geminiPath = "$env:USERPROFILE\.gemini\config\skills"
$claudePath = "$env:USERPROFILE\.claude\skills"
$targets = @($geminiPath, $claudePath)

$validSkills = Get-ChildItem -Path $skillsSource -Recurse -Filter "SKILL.md" | 
    Where-Object { 
        $_.FullName -notmatch '\\(deprecated|in-progress|personal|node_modules)\\' 
    }

foreach ($target in $targets) {
    if (-not (Test-Path $target)) {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
    }
    
    $targetName = if ($target -match '\.gemini') { "Antigravity" } else { "Claude" }
    Write-Host "Installing skills to $targetName ($target)..." -ForegroundColor Cyan

    foreach ($skillFile in $validSkills) {
        $skillDir = $skillFile.Directory
        $destPath = Join-Path $target $skillDir.Name
        
        Copy-Item -Recurse -Force -Path $skillDir.FullName -Destination $destPath
        Write-Host "  + Installed $($skillDir.Name)" -ForegroundColor Green
    }
}

Write-Host "`nAll skills have been successfully installed globally!" -ForegroundColor Green
