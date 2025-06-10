<#
.SYNOPSIS
    Interactive Window Resizer and Positioner with Default Presets
.DESCRIPTION
    Allows selecting any open window and modifying its size/position on screen
.NOTES
    Version: 2.3
    Works on Windows 10/11 with PowerShell 5.1+
#>

# Load required Win32 API functions
if (-not ("WindowUtils" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class WindowUtils {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    public const int SW_RESTORE = 9;
    public const int SW_MAXIMIZE = 3;
}
"@ -ErrorAction Stop
}

# Carregar presets do arquivo JSON
$presetsPath = ".\windows_presets.json"
if (-not (Test-Path $presetsPath)) {
    Write-Host "Preset file not found: $presetsPath" -ForegroundColor Red
    exit 1
}
$presets = Get-Content $presetsPath | ConvertFrom-Json

# Função para selecionar janela
function Select-Window {
    $windows = @()
    Get-Process | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero -and $_.MainWindowTitle } | ForEach-Object {
        $windows += [PSCustomObject]@{
            ID = $_.Id
            Title = $_.MainWindowTitle
            Handle = $_.MainWindowHandle
            Process = $_.Name
        }
    }

    while ($true) {
        Write-Host "`nAvailable Windows:`n"
        for ($i = 0; $i -lt $windows.Count; $i++) {
            Write-Host "[$($i+1)] [$($windows[$i].Process)] $($windows[$i].Title)"
        }
        Write-Host "[0] [Exit]"
        $selection = Read-Host "`nSelect a window (0-$($windows.Count))"
        if ($selection -eq '0') { return $null }
        if ($selection -match "^\d+$" -and [int]$selection -ge 1 -and [int]$selection -le $windows.Count) {
            return $windows[[int]$selection-1]
        }
    }
}

function Get-WindowGeometry {
    param($window)
    
    $rect = New-Object WindowUtils+RECT
    [WindowUtils]::GetWindowRect($window.Handle, [ref]$rect) | Out-Null
    
    return @{
        X = $rect.Left
        Y = $rect.Top
        Width = $rect.Right - $rect.Left
        Height = $rect.Bottom - $rect.Top
    }
}

function Set-WindowGeometry {
    param($window, $x, $y, $width, $height)
    
    # Ensure window is restored if minimized
    [WindowUtils]::ShowWindow($window.Handle, [WindowUtils]::SW_RESTORE) | Out-Null
    
    $success = [WindowUtils]::MoveWindow($window.Handle, $x, $y, $width, $height, $true)
    
    if (-not $success) {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        Write-Host "Error: Failed to resize window (Code: $errorCode)" -ForegroundColor Red
        return $false
    }
    return $true
}

function Set-WindowMaximize {
    param($window)
    # Use SW_SHOWMAXIMIZED (3) only, sem SW_RESTORE antes, pois SW_RESTORE pode causar problemas em algumas janelas
    [WindowUtils]::ShowWindow($window.Handle, [WindowUtils]::SW_MAXIMIZE) | Out-Null
}

# Main execution loop
while ($true) {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "           Welcome to WRP                " -ForegroundColor Green
    Write-Host "   === Windows Resizer & Positioner ===    " -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Select a window to modify its size and position" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "------------------------------------------" -ForegroundColor Magenta

    $selectedWindow = Select-Window
    if (-not $selectedWindow) {
        Write-Host "`nExiting..." -ForegroundColor Yellow
        break
    }

    $geometry = Get-WindowGeometry $selectedWindow

    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host "Current Window Properties:"
    Write-Host "  Position: ($($geometry.X), $($geometry.Y))"
    Write-Host "  Size: $($geometry.Width)x$($geometry.Height)"
    Write-Host "------------------------------------------"
    Write-Host ""

    # Listar presets dinamicamente
    $presetNames = $presets.PSObject.Properties.Name
    Write-Host "Choose action:"
    Write-Host "[1] Enter custom properties"
    for ($i = 0; $i -lt $presetNames.Count; $i++) {
        Write-Host "[$($i+2)] Apply $($presetNames[$i]) preset"
    }
    Write-Host "[$([int]$presetNames.Count+2)] Maximize window"
    Write-Host "[0] Back"

    while ($true) {
        $maxOption = [int]$presetNames.Count + 2
        $choice = Read-Host "`nSelect option (0-$maxOption)"
        if ($choice -eq '0') { break }
        if ($choice -eq '1') {
            do {
                $newX = Read-Host "Enter new X position [$($geometry.X)]"
                if ([string]::IsNullOrEmpty($newX)) { $newX = $geometry.X }
            } until ($newX -match "^-?\d+$")

            do {
                $newY = Read-Host "Enter new Y position [$($geometry.Y)]"
                if ([string]::IsNullOrEmpty($newY)) { $newY = $geometry.Y }
            } until ($newY -match "^-?\d+$")

            do {
                $newWidth = Read-Host "Enter new width [$($geometry.Width)]"
                if ([string]::IsNullOrEmpty($newWidth)) { $newWidth = $geometry.Width }
            } until ($newWidth -match "^\d+$" -and [int]$newWidth -gt 0)

            do {
                $newHeight = Read-Host "Enter new height [$($geometry.Height)]"
                if ([string]::IsNullOrEmpty($newHeight)) { $newHeight = $geometry.Height }
            } until ($newHeight -match "^\d+$" -and [int]$newHeight -gt 0)
        }
        elseif ($choice -match "^\d+$" -and [int]$choice -ge 2 -and [int]$choice -le ($presetNames.Count+1)) {
            $presetIndex = [int]$choice - 2
            $presetName = $presetNames[$presetIndex]
            $preset = $presets.$presetName
            $newX = $preset.X
            $newY = $preset.Y
            $newWidth = $preset.Width
            $newHeight = $preset.Height
        }
        elseif ($choice -eq "$maxOption") {
            Set-WindowMaximize $selectedWindow
            Write-Host "`nWindow maximized!" -ForegroundColor Green
            Write-Host "`nPress Enter to continue..."
            [void][System.Console]::ReadLine()
            break
        }
        else {
            continue
        }

        Write-Host "`nApplying changes..."
        if (Set-WindowGeometry $selectedWindow $newX $newY $newWidth $newHeight) {
            Write-Host "Window successfully resized and repositioned!" -ForegroundColor Green

            $newGeometry = Get-WindowGeometry $selectedWindow
            Write-Host "`nNew Window Properties:"
            Write-Host "  Position: ($($newGeometry.X), $($newGeometry.Y))"
            Write-Host "  Size: $($newGeometry.Width)x$($newGeometry.Height)"
        }
        Write-Host "`nPress Enter to continue..."
        [void][System.Console]::ReadLine()
        break
    }
}