# tempdel

Polished Windows cleanup script that deletes temporary files from:
- `%TEMP%` (current user temp)
- `C:\Windows\Temp`
- `C:\Windows\Prefetch`

## Features
- Native Command Prompt colorized UI (no ANSI required) with clear sections and status labels
- Per-location cleanup status (done/skip/warnings)
- Auto-elevation prompt (UAC) when not launched as Administrator
- End-of-run summary with totals for deleted files/folders

## Usage
1. Open Command Prompt or Windows Terminal.
2. Run (the script will auto-prompt for Administrator via UAC if needed):
   ```bat
   clean_temp_files.bat
   ```
