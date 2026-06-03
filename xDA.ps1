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

    Write-Host ""

}
catch {
    Write-Host ""
}
