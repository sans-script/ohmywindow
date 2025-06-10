# Oh My Window - Window Resizer & Positioner

Oh My Window aka WRP (Window Resizer & Positioner) is a project that allows you to interactively resize and reposition any open window on Windows 10/11 using PowerShell. It provides an interface to select a window, view its current size and position, and apply custom or preset geometries. Presets are loaded from a JSON file and can be easily extended.

## Why this project?

This project was created because sometimes I need to use WSA (Windows Subsystem for Android) and want to set window sizes to very specific dimensions that resemble a smartphone screen. It's ideal when you need an exact width and height, instead of adjusting manually with the mouse, which can be imprecise. With this tool, you can quickly apply precise dimensions and positions to any window, making it especially useful for testing, development, or simply improving your workflow.

## Features

- Select any open window to modify
- Enter custom position and size values
- Apply predefined size/position presets (e.g., Mobile Portrait, Mobile Landscape)
- Maximize windows
- Works on Windows 10/11 with PowerShell 5.1+

## How to use

1. Clone this repository.
2. Make sure `presets.json` is in the same folder as `window_manager.ps1`.
3. Run `window_manager.ps1` with PowerShell.
4. Follow the on-screen instructions to select a window and apply changes.
5. You can customize all settings by editing the `presets.json` file.

> [!NOTE]
> All presets and configurations were developed on a 1920x1080 screen. For this reason, it is recommended to adjust the presets to match your own screen resolution for best results.

## Requirements

- Windows 10 or later
- PowerShell 5.1 or newer

## Presets

Presets are defined in `presets.json`. Example:

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
