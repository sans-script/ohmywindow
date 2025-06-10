# Oh My Windows - Windows Resizer & Positioner

Oh My Windows aka WRP (Windows Resizer & Positioner) is a project that allows you to interactively resize and reposition any open window on Windows 10/11 using PowerShell. It provides an interface to select a window, view its current size and position, and apply custom or preset geometries. Presets are loaded from a JSON file and can be easily extended.

## Features

- Select any open window to modify
- Enter custom position and size values
- Apply predefined size/position presets (e.g., Mobile Portrait, Mobile Landscape)
- Maximize windows
- Works on Windows 10/11 with PowerShell 5.1+

## How to use

1. Clone this repository.
2. Make sure `windows_presets.json` is in the same folder as `windows_manager.ps1`.
3. Run `windows_manager.ps1` with PowerShell.
4. Follow the on-screen instructions to select a window and apply changes.

## Requirements

- Windows 10 or later
- PowerShell 5.1 or newer

## Presets

Presets are defined in `windows_presets.json`. Example:

```json
{
  "Mobile Portrait Size": {
    "X": -6,
    "Y": 0,
    "Width": 480,
    "Height": 1080
  },
  "Mobile Landscape Size": {
    "X": -6,
    "Y": 0,
    "Width": 1080,
    "Height": 480
  }
}
```

You can add more presets by editing this file.

## Contribution

Contributions are welcome! Feel free to open issues or submit pull requests.
