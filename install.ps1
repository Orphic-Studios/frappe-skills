<#
.SYNOPSIS
    Frappe Skills Pack - Universal Windows PowerShell Installer for AI Agents
.DESCRIPTION
    Installs frappe-docs and frappe-course-generator skills into supported AI agents
    (Google Antigravity, Gemini CLI, Claude Code, Codex, Cursor, Windsurf, Hermes, OpenCode, Copilot CLI, Command Code, Cline, Roo Code, Kiro).
.PARAMETER All
    Installs to all detected agent directories without prompting.
.PARAMETER Agent
    Installs to a specific agent (e.g. hermes, claude, gemini, antigravity, codex, cursor, windsurf, opencode, cline, roo, kiro, all).
.EXAMPLE
    irm https://raw.githubusercontent.com/Orphic-Studios/frappe-skills/main/install.ps1 | iex
#>

[CmdletBinding()]
param(
    [switch]$All,
    [string]$Agent = ""
)

$ErrorActionPreference = "Stop"

function Write-Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Write-Success($msg) { Write-Host "[OK]    $msg" -ForegroundColor Green }
function Write-WarningMsg($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Write-ErrorMsg($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "      Frappe Skills Pack - Windows Agent Installer  " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

$HomeDir = $env:USERPROFILE
$TempFolder = Join-Path $env:TEMP "frappe-skills-install-$([System.Guid]::NewGuid().ToString('N'))"
$SourceDir = ""

$LocalScriptDir = ""
if ($MyInvocation.MyCommand.Path) {
    $LocalScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
elseif (Test-Path "skills\frappe-docs\SKILL.md") {
    $LocalScriptDir = (Get-Location).Path
}

if ($LocalScriptDir -and (Test-Path (Join-Path $LocalScriptDir "skills\frappe-docs\SKILL.md"))) {
    $SourceDir = $LocalScriptDir
    Write-Info "Using local files from: $SourceDir"
}
else {
    Write-Info "Downloading latest skills package from GitHub..."
    New-Item -ItemType Directory -Force -Path $TempFolder | Out-Null
    $ZipFile = Join-Path $TempFolder "frappe-skills.zip"
    $ZipUrl = "https://github.com/Orphic-Studios/frappe-skills/archive/refs/heads/main.zip"

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile -UseBasicParsing
        Expand-Archive -Path $ZipFile -DestinationPath $TempFolder -Force
        $SourceDir = Join-Path $TempFolder "frappe-skills-main"
        Write-Success "Package downloaded and unpacked."
    }
    catch {
        Write-ErrorMsg "Failed to download from GitHub: $_"
        if (Test-Path $TempFolder) { Remove-Item -Recurse -Force $TempFolder }
        exit 1
    }
}

$AgentPaths = @(
    @{ Key = "antigravity"; Name = "Google Antigravity"; Path = "$HomeDir\.gemini\antigravity\skills"; Detect = "$HomeDir\.gemini\antigravity" },
    @{ Key = "gemini"; Name = "Gemini CLI"; Path = "$HomeDir\.gemini\skills"; Detect = "$HomeDir\.gemini" },
    @{ Key = "claude"; Name = "Claude Code"; Path = "$HomeDir\.claude\skills"; Detect = "$HomeDir\.claude" },
    @{ Key = "codex"; Name = "OpenAI Codex"; Path = "$HomeDir\.codex\skills"; Detect = "$HomeDir\.codex" },
    @{ Key = "cursor"; Name = "Cursor"; Path = "$HomeDir\.cursor\skills"; Detect = "$HomeDir\.cursor" },
    @{ Key = "windsurf"; Name = "Windsurf"; Path = "$HomeDir\.codeium\windsurf\skills"; Detect = "$HomeDir\.codeium\windsurf" },
    @{ Key = "hermes"; Name = "Hermes"; Path = "$HomeDir\.config\hermes\skills"; Detect = "$HomeDir\.config\hermes" },
    @{ Key = "opencode"; Name = "OpenCode"; Path = "$HomeDir\.config\opencode\skills"; Detect = "$HomeDir\.config\opencode" },
    @{ Key = "copilot"; Name = "GitHub Copilot CLI"; Path = "$HomeDir\.copilot\skills"; Detect = "$HomeDir\.copilot" },
    @{ Key = "commandcode"; Name = "Command Code"; Path = "$HomeDir\.commandcode\skills"; Detect = "$HomeDir\.commandcode" },
    @{ Key = "cline"; Name = "Cline"; Path = "$HomeDir\.cline\skills"; Detect = "$HomeDir\.cline" },
    @{ Key = "roo"; Name = "Roo Code"; Path = "$HomeDir\.roo\skills"; Detect = "$HomeDir\.roo" },
    @{ Key = "kiro"; Name = "Kiro"; Path = "$HomeDir\.kiro\skills"; Detect = "$HomeDir\.kiro" },
    @{ Key = "generic"; Name = "Generic Skills"; Path = "$HomeDir\.skills"; Detect = "$HomeDir\.skills" }
)

if ($Agent -eq "all") {
    $All = $true
    $Agent = ""
}

$Targets = @()
foreach ($a in $AgentPaths) {
    if (Test-Path $a.Detect) {
        $Targets += $a
    }
}

function Install-ToPath($targetPath) {
    if (-not (Test-Path $targetPath)) {
        New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
    }

    $docsTarget = Join-Path $targetPath "frappe-docs"
    $courseTarget = Join-Path $targetPath "frappe-course-generator"

    if (Test-Path $docsTarget) { Remove-Item -Recurse -Force $docsTarget }
    if (Test-Path $courseTarget) { Remove-Item -Recurse -Force $courseTarget }

    Copy-Item -Recurse -Force -Path (Join-Path $SourceDir "skills\frappe-docs") -Destination $targetPath
    Copy-Item -Recurse -Force -Path (Join-Path $SourceDir "skills\frappe-course-generator") -Destination $targetPath

    Write-Success "Installed to: $targetPath"
}

try {
    if ($Agent) {
        $matched = $AgentPaths | Where-Object { $_.Key -eq $Agent.ToLower() }
        if (-not $matched) {
            Write-ErrorMsg "Unknown agent '$Agent'."
            exit 1
        }
        Install-ToPath $matched.Path
    }
    elseif ($Targets.Count -eq 0) {
        Write-WarningMsg "No standard AI agent directories detected. Using default ~/.skills/"
        Install-ToPath "$HomeDir\.skills"
    }
    elseif ($All -or [Console]::IsInputRedirected) {
        Write-Info "Installing to all detected AI agents..."
        foreach ($a in $Targets) {
            Install-ToPath $a.Path
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

        $choice = Read-Host "Select option [1-$($Targets.Count + 2)] (Press Enter for ALL)"
        if (-not $choice) {
            $choice = "$($Targets.Count + 1)"
        }

        $choiceInt = 0
        [int]::TryParse($choice, [ref]$choiceInt) | Out-Null

        if ($choiceInt -ge 1 -and $choiceInt -le $Targets.Count) {
            $selected = $Targets[$choiceInt - 1]
            Install-ToPath $selected.Path
        }
        elseif ($choiceInt -eq ($Targets.Count + 1)) {
            foreach ($a in $Targets) {
                Install-ToPath $a.Path
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
    Write-Success "Installation completed successfully!"
    Write-Host "Restart your AI agent to begin using frappe-docs and frappe-course-generator."
    Write-Host ""
}
finally {
    if (Test-Path $TempFolder) {
        Remove-Item -Recurse -Force $TempFolder -ErrorAction SilentlyContinue
    }
}
