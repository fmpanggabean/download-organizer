# Downloads Organizer

A small Windows tool that keeps your `Downloads` folder tidy. It watches the folder and moves new files into category subfolders by extension. Pure PowerShell, no dependencies.

## Features

- Sorts into `Images`, `Documents`, `Videos`, `Audio`, `Archives`, `Installers`, `Code` and `Other`
- Skips files still downloading (`.crdownload`, `.part`, `.tmp`, ...), files being written, and hidden/system files
- Never overwrites: name clashes become `name (1).ext`, `name (2).ext`, ...
- Generates a searchable, sortable `index.html` (and `index.csv`) of everything sorted
- Every move is logged to `moves.csv`, so you can undo it
- System tray icon (green = on, grey = off) with Start/Stop, Sort now, Open Downloads, Open index

## Requirements

Windows 10/11 with Windows PowerShell 5.1 (built in).

## Usage

```powershell
# Sort once and exit
.\src\Organize-Downloads.ps1 -Once

# Watch continuously
.\src\Organize-Downloads.ps1

# Use another folder
.\src\Organize-Downloads.ps1 -Root D:\Inbox

# Tray app (no console window)
wscript.exe .\src\Run-Hidden.vbs
```

### Start automatically at login

```powershell
.\src\Install-Startup.ps1           # install
.\src\Install-Startup.ps1 -Remove   # uninstall
```

This registers a per-user scheduled task; no admin rights needed.

### Undo

```powershell
.\src\Undo-Organize.ps1            # undo everything in moves.csv
.\src\Undo-Organize.ps1 -Last 5    # undo the last 5 moves
```

Files are only restored if they are still at the new location and the original path is free.

## Customizing categories

Edit the `$Map` table at the top of `src/Organize-Downloads.ps1`.

## Generated files (not in the repo)

These files are created automatically the first time the tool runs. You don't need to create or configure anything. They are listed in `.gitignore` because they contain the full paths and names of *your* files, so they must never be committed or shared.

| File | Created by | Location | Purpose |
|------|-----------|----------|---------|
| `moves.csv` | `Organize-Downloads.ps1` | in `src/` | Log of every move (`Time`, `From`, `To`). Used by `Undo-Organize.ps1`. |
| `index.csv` | `Organize-Downloads.ps1` | inside your Downloads folder | Spreadsheet-friendly list of all sorted files. |
| `index.html` | `Organize-Downloads.ps1` | inside your Downloads folder | Searchable, sortable list of all sorted files. |

`moves.csv` is the only one that lives in the repo folder (`src/`); the two index files are written to the Downloads folder (or whatever you pass as `-Root`), so they are never in the repo to begin with. The ignore entries are just a safeguard.

If you delete `moves.csv`, sorting still works but you lose the ability to undo earlier moves.

## Notes

- The tray menu's "Open Downloads" and "Open index.html" use the default `%USERPROFILE%\Downloads`.

## License

Copyright (c) 2026 fmpanggabean

Licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/). Full text in [LICENSE](LICENSE).

In plain terms, you may:

- use, copy and **modify** this tool for free

As long as you:

- **give credit** to the original author, link to the license, and indicate what you changed (so a modified copy can't be passed off as the original or as your own work)
- **share alike**: distribute your modified version under this same license
- **don't use it commercially**: no selling it, and no charging for it or for a product built on it

This summary is not legal advice; the LICENSE file is what applies.
