<#
.SYNOPSIS
    Frappe Skills Pack — Windows PowerShell Installer for AI Agents
.DESCRIPTION
    Installs frappe-docs and frappe-course-generator skills into supported AI agents
    (Google Antigravity/Gemini, Claude Code, Cursor, Windsurf, Hermes, Cline, Roo Code).
.PARAMETER All
    Installs to all detected agent directories without prompting.
#>

[CmdletBinding()]
param(
    [switch]$All
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "ℹ  $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "✓  $msg" -ForegroundColor Green }
function Write-WarningMsg($msg) { Write-Host "⚠  $msg" -ForegroundColor Yellow }
function Write-ErrorMsg($msg) { Write-Host "✗  $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "      Frappe Skills Pack — Windows Agent Installer  " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path "$ScriptDir\frappe-docs\SKILL.md")) {
    $ScriptDir = Get-Location
}

$HomeDir = $env:USERPROFILE
$Targets = @()

# Detect Agents
$AgentPaths = @(
    @{ Name = "Google Antigravity & Gemini"; Path = "$HomeDir\.gemini\antigravity\skills"; Detect = "$HomeDir\.gemini" },
    @{ Name = "Claude Code"; Path = "$HomeDir\.claude\skills"; Detect = "$HomeDir\.claude" },
    @{ Name = "Cursor"; Path = "$HomeDir\.cursor\skills"; Detect = "$HomeDir\.cursor" },
    @{ Name = "Windsurf"; Path = "$HomeDir\.windsurf\skills"; Detect = "$HomeDir\.windsurf" },
    @{ Name = "Hermes"; Path = "$HomeDir\.config\hermes\skills"; Detect = "$HomeDir\.config\hermes" },
    @{ Name = "Cline"; Path = "$HomeDir\.cline\skills"; Detect = "$HomeDir\.cline" },
    @{ Name = "Generic Skills"; Path = "$HomeDir\.skills"; Detect = "$HomeDir\.skills" }
)

foreach ($agent in $AgentPaths) {
    if (Test-Path $agent.Detect) {
        $Targets += $agent
    }
}

function Install-ToPath($targetPath) {
    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
    }

    Write-Info "Copying frappe-docs to $targetPath..."
    Copy-Item -Recurse -Force "$ScriptDir\frappe-docs" "$targetPath\"

    Write-Info "Copying frappe-course-generator to $targetPath..."
    Copy-Item -Recurse -Force "$ScriptDir\frappe-course-generator" "$targetPath\"

    Write-Success "Installed successfully to: $targetPath"
}

if ($Targets.Count -eq 0) {
    Write-WarningMsg "No standard AI agent directories detected."
    $defaultPath = "$HomeDir\.skills"
    Write-Info "Installing to default skills path: $defaultPath"
    Install-ToPath $defaultPath
}
elseif ($All) {
    Write-Info "Installing to all detected AI agents..."
    foreach ($agent in $Targets) {
        Install-ToPath $agent.Path
    }
}
else {
    Write-Host "Detected AI Agent Environments:" -ForegroundColor White
    for ($i = 0; $i -lt $Targets.Count; $i++) {
        Write-Host "  $($i + 1). $($Targets[$i].Name) ($($Targets[$i].Path))" -ForegroundColor Cyan
    }
    Write-Host "  $($Targets.Count + 1). Install to ALL detected agents" -ForegroundColor Yellow
    Write-Host "  $($Targets.Count + 2). Custom path" -ForegroundColor Gray
    Write-Host ""

    $choice = Read-Host "Select option [1-$($Targets.Count + 2)]"
    $choiceInt = [int]$choice

    if ($choiceInt -ge 1 -and $choiceInt -le $Targets.Count) {
        $selected = $Targets[$choiceInt - 1]
        Install-ToPath $selected.Path
    }
    elseif ($choiceInt -eq ($Targets.Count + 1)) {
        foreach ($agent in $Targets) {
            Install-ToPath $agent.Path
        }
    }
    else {
        $customPath = Read-Host "Enter custom skills folder path"
        if ($customPath) {
            Install-ToPath $customPath
        }
    }
}

Write-Host ""
Write-Success "🎉 Installation completed!"
Write-Host "Restart your AI agent to begin using frappe-docs and frappe-course-generator."
Write-Host ""

