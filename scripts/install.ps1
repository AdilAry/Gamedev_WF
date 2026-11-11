# Install the Gamedev-WF skills for Claude Code and pi on Windows (PowerShell).
#   powershell -ExecutionPolicy Bypass -File scripts\install.ps1
# - copies .claude\skills\* to %USERPROFILE%\.claude\skills\
# - sets the user environment variable GAMEDEV_WF to this kit's folder
$ErrorActionPreference = "Stop"
$Kit  = Split-Path -Parent $PSScriptRoot
$Dest = Join-Path $env:USERPROFILE ".claude\skills"
New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Get-ChildItem -Directory (Join-Path $Kit ".claude\skills") | ForEach-Object {
    $target = Join-Path $Dest $_.Name
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    Copy-Item -Recurse $_.FullName $target
    Write-Host "installed skill /$($_.Name)"
}
[Environment]::SetEnvironmentVariable("GAMEDEV_WF", $Kit, "User")
Write-Host "GAMEDEV_WF set to $Kit (restart Claude Desktop / terminals to pick it up)"
if (Get-Command pi -ErrorAction SilentlyContinue) {
    pi install $Kit
    Write-Host "registered the kit as a pi package (skills are /skill:<name> in pi)"
} else {
    Write-Host "pi not found - skipped. After installing pi, run: pi install `"$Kit`""
}
Write-Host "Reminder: set GODOT to your Godot *_console.exe, e.g."
Write-Host '  [Environment]::SetEnvironmentVariable("GODOT", "C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe", "User")'
