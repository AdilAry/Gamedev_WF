# Install the Gamedev-WF kit for Claude Code on Windows (PowerShell).
#   powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# Needs the short-loop workflow installed first (its WORKFLOW.md section 3):
# that puts /start /wrap /judge and the "How I work" file in place and sets the
# user environment variable WORKFLOW_DIR. This script then
# - copies the game commands to %USERPROFILE%\.claude\commands\
#   (copies: run this again after a git pull of the kit)
# - sets the user environment variable GAMEDEV_WF to this kit's folder
# - moves aside the skills that kit versions before 1.4 copied to .claude\skills
$ErrorActionPreference = "Stop"
$Kit    = Split-Path -Parent $PSScriptRoot
$Claude = Join-Path $env:USERPROFILE ".claude"
$Cmds   = Join-Path $Claude "commands"

# A variable set in another window is not in this one's environment yet; the
# user setting is the same variable.
$Wf = $env:WORKFLOW_DIR
if (-not $Wf) { $Wf = [Environment]::GetEnvironmentVariable("WORKFLOW_DIR", "User") }
if (-not $Wf -or -not (Test-Path (Join-Path $Wf "templates\commands"))) {
    Write-Host "WORKFLOW_DIR is not set, or is not the workflow folder: '$Wf'."
    Write-Host "Install the short-loop workflow first (its WORKFLOW.md section 3 sets WORKFLOW_DIR), then run this again."
    exit 1
}

New-Item -ItemType Directory -Force -Path $Cmds | Out-Null

$Old   = Join-Path $Claude "skills"
$Aside = Join-Path $Claude "skills-replaced-by-gamedev-wf"
foreach ($name in "asset","balance","build","change-request","commission","define","harness","judge","pitch","playtest","qa","review","spec","start","style-guide","wrap","wrap-up") {
    $f = Join-Path $Old "$name\SKILL.md"
    if ((Test-Path $f) -and (Select-String -Quiet -Path $f -Pattern 'gw\.sh|PROGRESS\.md|docs/GDD\.md|docs/LOG\.md|STYLE_GUIDE|ideas/|docs/playtests|docs/changes')) {
        New-Item -ItemType Directory -Force -Path $Aside | Out-Null
        $target = Join-Path $Aside $name
        if (Test-Path $target) { Remove-Item -Recurse -Force $target }
        Move-Item (Join-Path $Old $name) $target
        Write-Host "moved old skill /$name to $Aside"
    }
}

Copy-Item (Join-Path $Kit "commands\*.md") "$Cmds\"
Get-ChildItem -File -Filter *.md (Join-Path $Kit "commands") | ForEach-Object { Write-Host "installed /$($_.BaseName)" }
if (-not (Test-Path (Join-Path $Cmds "start.md"))) {
    Write-Host "/start is not installed: run the workflow's WORKFLOW.md section 3 steps in $Wf"
}

[Environment]::SetEnvironmentVariable("GAMEDEV_WF", $Kit, "User")
Write-Host "GAMEDEV_WF set to $Kit (restart Claude Desktop / terminals to pick it up)"
Write-Host "Reminder: set GODOT to your Godot *_console.exe, e.g."
Write-Host '  [Environment]::SetEnvironmentVariable("GODOT", "C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe", "User")'
