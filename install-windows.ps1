$ErrorActionPreference = 'Stop'

# Find Chrome
$chrome = $null
foreach ($base in $env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA) {
    if (-not $base) { continue }
    $p = Join-Path $base 'Google\Chrome\Application\chrome.exe'
    if (Test-Path $p) { $chrome = $p; break }
}
if (-not $chrome) { Write-Error 'Google Chrome not found in Program Files or LocalAppData'; exit 1 }

$dataDir = Join-Path $env:LOCALAPPDATA 'ChromeDebug'
$arguments = "--remote-debugging-port=9222 --user-data-dir=`"$dataDir`""

# Download icon
$iconDir = Join-Path $env:LOCALAPPDATA 'CDPChrome'
$iconPath = Join-Path $iconDir 'icon.ico'
if (-not (Test-Path $iconDir)) { New-Item -ItemType Directory -Path $iconDir | Out-Null }
$iconUrl = 'https://raw.githubusercontent.com/AnswerDotAI/cdpchrome/main/icons/icon.ico'
Invoke-WebRequest -Uri $iconUrl -OutFile $iconPath

# Create Start Menu shortcut
$startMenu = [Environment]::GetFolderPath('StartMenu')
$lnk = Join-Path $startMenu 'Programs\CDP Chrome.lnk'
$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut($lnk)
$shortcut.TargetPath = $chrome
$shortcut.Arguments = $arguments
$shortcut.IconLocation = $iconPath
$shortcut.Description = 'Launch Chrome with CDP remote debugging'
$shortcut.Save()

Write-Host 'Installed CDP Chrome to Start Menu'
Write-Host "Chrome: $chrome"
Write-Host "Data dir: $dataDir"
