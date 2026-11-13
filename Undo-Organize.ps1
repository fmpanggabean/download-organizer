# Downloads Organizer - Copyright (c) 2026 fmpanggabean
# Licensed under CC BY-NC-SA 4.0 (attribution required, non-commercial, share-alike)
# Original project: https://github.com/fmpanggabean/DownloadsOrganizer
param([int]$Last = 0)  # 0 = undo everything in the log; N = undo the last N moves
$log = Join-Path $PSScriptRoot 'moves.csv'
if (-not (Test-Path $log)) { 'No log.'; return }
$rows = @(Import-Csv $log)
if ($Last -gt 0) { $rows = $rows | Select-Object -Last $Last }
[array]::Reverse($rows)
foreach ($r in $rows) {
    if ((Test-Path -LiteralPath $r.To) -and -not (Test-Path -LiteralPath $r.From)) {
        Move-Item -LiteralPath $r.To -Destination $r.From
        "Restored $($r.From)"
    }
}
