Add-Type -AssemblyName System.Drawing
Get-ChildItem "C:\Users\rnjsr\.gemini\antigravity\scratch\ace-wedding\images\mobile\*.jpg" | Sort-Object { [int]($_.BaseName -replace '\D','') } | ForEach-Object {
    $img = [System.Drawing.Image]::FromFile($_.FullName)
    Write-Output "$($_.Name): $($img.Width)x$($img.Height)"
    $img.Dispose()
}
