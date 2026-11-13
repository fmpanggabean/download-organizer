Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# single instance
$created = $false
$mutex = New-Object Threading.Mutex($true, 'Local\DownloadsOrganizerTray', [ref]$created)
if (-not $created) { return }

$Script = Join-Path $PSScriptRoot 'Organize-Downloads.ps1'
$script:proc = $null

function New-DotIcon($color) {
    $bmp = New-Object Drawing.Bitmap 32, 32
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([Drawing.Color]::Transparent)
    $g.FillEllipse((New-Object Drawing.SolidBrush $color), 3, 3, 26, 26)
    $g.Dispose()
    [Drawing.Icon]::FromHandle($bmp.GetHicon())
}
$IconOn  = New-DotIcon ([Drawing.Color]::FromArgb(46, 160, 67))
$IconOff = New-DotIcon ([Drawing.Color]::FromArgb(140, 140, 140))

function Test-Running { $script:proc -and -not $script:proc.HasExited }

function Start-Organizer {
    if (Test-Running) { return }
    $psi = New-Object Diagnostics.ProcessStartInfo
    $psi.FileName = 'powershell.exe'
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$Script`""
    $psi.CreateNoWindow = $true
    $psi.UseShellExecute = $false
    $script:proc = [Diagnostics.Process]::Start($psi)
    Update-UI
}

function Stop-Organizer {
    if (Test-Running) { $script:proc.Kill(); $script:proc.WaitForExit(3000) | Out-Null }
    Update-UI
}

$tray = New-Object Windows.Forms.NotifyIcon
$menu = New-Object Windows.Forms.ContextMenuStrip
$miToggle = $menu.Items.Add('Start')
$miOnce   = $menu.Items.Add('Sort now (once)')
$null     = $menu.Items.Add('-')
$miFolder = $menu.Items.Add('Open Downloads')
$miIndex  = $menu.Items.Add('Open index.html')
$null     = $menu.Items.Add('-')
$miExit   = $menu.Items.Add('Exit')
$tray.ContextMenuStrip = $menu

function Update-UI {
    if (Test-Running) {
        $tray.Icon = $IconOn;  $tray.Text = 'Downloads Organizer: ON'
        $miToggle.Text = 'Stop'
    } else {
        $tray.Icon = $IconOff; $tray.Text = 'Downloads Organizer: OFF'
        $miToggle.Text = 'Start'
    }
}

$toggle = { if (Test-Running) { Stop-Organizer } else { Start-Organizer } }
$miToggle.add_Click($toggle)
$tray.add_DoubleClick($toggle)
$miOnce.add_Click({
    $psi = New-Object Diagnostics.ProcessStartInfo 'powershell.exe', "-NoProfile -ExecutionPolicy Bypass -File `"$Script`" -Once"
    $psi.CreateNoWindow = $true; $psi.UseShellExecute = $false
    [Diagnostics.Process]::Start($psi) | Out-Null
})
$miFolder.add_Click({ Start-Process (Join-Path $env:USERPROFILE 'Downloads') })
$miIndex.add_Click({
    $i = Join-Path $env:USERPROFILE 'Downloads\index.html'
    if (Test-Path $i) { Start-Process $i }
})
$miExit.add_Click({
    Stop-Organizer
    $tray.Visible = $false
    [Windows.Forms.Application]::Exit()
})

# keep icon state right if the child dies on its own
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 5000
$timer.add_Tick({ Update-UI })
$timer.Start()

Start-Organizer
$tray.Visible = $true
Update-UI
[Windows.Forms.Application]::Run()

Stop-Organizer
$tray.Dispose()
$mutex.ReleaseMutex()
