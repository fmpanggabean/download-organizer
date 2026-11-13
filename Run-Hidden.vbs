' Downloads Organizer - Copyright (c) 2026 fmpanggabean
' Licensed under CC BY-NC-SA 4.0 (attribution required, non-commercial, share-alike)
' Original project: https://github.com/fmpanggabean/DownloadsOrganizer
' Launches the tray controller without a console window.
Set fso = CreateObject("Scripting.FileSystemObject")
dir = fso.GetParentFolderName(WScript.ScriptFullName)
CreateObject("Wscript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & dir & "\Tray-Controller.ps1""", 0, False
