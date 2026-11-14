# Install the Gamedev-WF kit for Claude Code on Windows (PowerShell).
#   powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# - copies the workflow commands (/start /wrap /judge) and the game commands
#   to %USERPROFILE%\.claude\commands\   (copies: run this again after a git pull)
# - installs the user-level "How I work" file if there is none yet
# - sets the user environment variable GAMEDEV_WF to this kit's folder
# - moves aside the skills that kit versions before 1.4 copied to .claude\skills
# pi on Windows is not set up here: run pi on the Linux box (docs\10-pi.md).
$ErrorActionPreference = "Stop"
$Kit    = Split-Path -Parent $PSScriptRoot
$Claude = Join-Path $env:USERPROFILE ".claude"
$Cmds   = Join-Path $Claude "commands"
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

foreach ($dir in (Join-Path $Kit "workflow\templates\commands"), (Join-Path $Kit "commands")) {
    Get-ChildItem -File -Filter *.md $dir | ForEach-Object {
        Copy-Item -Force $_.FullName (Join-Path $Cmds $_.Name)
        Write-Host "installed /$($_.BaseName)"
    }
}

$Global = Join-Path $Claude "CLAUDE.md"
if (-not (Test-Path $Global)) {
    Copy-Item (Join-Path $Kit "workflow\templates\user-level\AGENTS.md") $Global
    Write-Host "installed $Global  <- open it once and fill the one [bracket]"
} else {
    Write-Host "kept your $Global"
}

[Environment]::SetEnvironmentVariable("GAMEDEV_WF", $Kit, "User")
Write-Host "GAMEDEV_WF set to $Kit (restart Claude Desktop / terminals to pick it up)"
Write-Host "Reminder: set GODOT to your Godot *_console.exe, e.g."
Write-Host '  [Environment]::SetEnvironmentVariable("GODOT", "C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe", "User")'
