Add-Type -AssemblyName System.Drawing

$basePath = "C:\Users\rnjsr\.gemini\antigravity\scratch\ace-wedding\images\mobile"

$images = @(
    @{File="18.jpg"; Section="init"},
    @{File="2.jpg"; Section="2"},
    @{File="4.jpg"; Section="4"},
    @{File="7.jpg"; Section="7"},
    @{File="8.jpg"; Section="8"},
    @{File="10.jpg"; Section="10"},
    @{File="11.jpg"; Section="11"},
    @{File="12.jpg"; Section="12"},
    @{File="13.jpg"; Section="13"},
    @{File="14.jpg"; Section="14"},
    @{File="15.jpg"; Section="15"},
    @{File="16.jpg"; Section="16"}
)

foreach ($item in $images) {
    $imgPath = Join-Path $basePath $item.File
    $img = [System.Drawing.Bitmap]::new($imgPath)
    $w = $img.Width
    $h = $img.Height
    
    # Scan the bottom 15% of image for the button
    # The buttons are typically rounded rectangles with a border/outline
    # They appear as darker elements on a light background near the bottom
    
    # Count dark-ish pixels in each row from bottom 20%
    $scanStart = [int]($h * 0.85)
    $centerX = [int]($w / 2)
    $scanWidth = [int]($w * 0.6) # scan center 60%
    $startX = [int](($w - $scanWidth) / 2)
    
    $buttonTop = -1
    $buttonBottom = -1
    $buttonLeft = -1
    $buttonRight = -1
    
    # Scan from bottom to find button region
    for ($y = $h - 1; $y -ge $scanStart; $y--) {
        $darkCount = 0
        for ($x = $startX; $x -lt ($startX + $scanWidth); $x += 5) {
            $pixel = $img.GetPixel($x, $y)
            $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
            # Button outline/border is typically darker than background
            if ($brightness -lt 150) {
                $darkCount++
            }
        }
        
        $threshold = $scanWidth / 5 * 0.15  # at least 15% of sampled pixels are dark
        
        if ($darkCount -gt $threshold) {
            if ($buttonBottom -eq -1) {
                $buttonBottom = $y
            }
            $buttonTop = $y
        } elseif ($buttonBottom -ne -1 -and ($buttonBottom - $y) -gt 20) {
            # We've passed the button
            break
        }
    }
    
    # Now scan horizontally at the button center to find left/right edges
    if ($buttonTop -ne -1 -and $buttonBottom -ne -1) {
        $buttonCenterY = [int](($buttonTop + $buttonBottom) / 2)
        
        # Find left edge
        for ($x = 0; $x -lt $w; $x++) {
            $pixel = $img.GetPixel($x, $buttonCenterY)
            $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
            if ($brightness -lt 150) {
                $buttonLeft = $x
                break
            }
        }
        
        # Find right edge
        for ($x = $w - 1; $x -ge 0; $x--) {
            $pixel = $img.GetPixel($x, $buttonCenterY)
            $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
            if ($brightness -lt 150) {
                $buttonRight = $x
                break
            }
        }
    }
    
    $btnW = if ($buttonLeft -ne -1 -and $buttonRight -ne -1) { $buttonRight - $buttonLeft } else { 0 }
    $btnH = if ($buttonTop -ne -1 -and $buttonBottom -ne -1) { $buttonBottom - $buttonTop } else { 0 }
    $distFromBottom = if ($buttonBottom -ne -1) { $h - $buttonBottom } else { 0 }
    $bottomPct = if ($h -gt 0 -and $distFromBottom -gt 0) { [math]::Round($distFromBottom / $h * 100, 2) } else { 0 }
    $widthPct = if ($w -gt 0 -and $btnW -gt 0) { [math]::Round($btnW / $w * 100, 2) } else { 0 }
    $heightPct = if ($h -gt 0 -and $btnH -gt 0) { [math]::Round($btnH / $h * 100, 2) } else { 0 }
    $leftPct = if ($w -gt 0 -and $buttonLeft -gt 0) { [math]::Round($buttonLeft / $w * 100, 2) } else { 0 }
    
    Write-Output "Section $($item.Section) ($($item.File)): img=${w}x${h}"
    Write-Output "  Button: top=$buttonTop bottom=$buttonBottom left=$buttonLeft right=$buttonRight"
    Write-Output "  Size: ${btnW}x${btnH}px, distFromBottom=${distFromBottom}px"
    Write-Output "  CSS: bottom=${bottomPct}%, width=${widthPct}%, height=${heightPct}%, left=${leftPct}%"
    Write-Output "  ---"
    
    $img.Dispose()
}
