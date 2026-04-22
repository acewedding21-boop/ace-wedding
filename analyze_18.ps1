Add-Type -AssemblyName System.Drawing

$imgPath = "C:\Users\rnjsr\.gemini\antigravity\scratch\ace-wedding\images\mobile\18.jpg"
$img = [System.Drawing.Bitmap]::new($imgPath)
$w = $img.Width
$h = $img.Height

Write-Output "Image: ${w}x${h}"

# For image 18, the button is a dark GREEN rounded rectangle
# Scan center column looking for dark green pixels (R<100, G>60, B<80)
$centerX = [int]($w / 2)

Write-Output "`nScanning center column for dark pixels in bottom 40%..."

$scanStart = [int]($h * 0.60)
$buttonRows = @()

for ($y = $scanStart; $y -lt $h; $y++) {
    # Sample 20 pixels across the center 40% of the image
    $darkGreenCount = 0
    $darkCount = 0
    $sampleStart = [int]($w * 0.3)
    $sampleEnd = [int]($w * 0.7)
    $step = [int](($sampleEnd - $sampleStart) / 20)
    
    for ($x = $sampleStart; $x -lt $sampleEnd; $x += $step) {
        $pixel = $img.GetPixel($x, $y)
        $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
        
        # Dark green: R around 60-90, G around 70-100, B around 55-80
        if ($pixel.R -lt 120 -and $pixel.G -gt 50 -and $pixel.G -lt 130 -and $brightness -lt 100) {
            $darkGreenCount++
        }
        if ($brightness -lt 130) {
            $darkCount++
        }
    }
    
    if ($darkGreenCount -ge 5 -or $darkCount -ge 8) {
        $pixel = $img.GetPixel($centerX, $y)
        Write-Output ("Y={0} darkGreen={1} dark={2} centerPixel=RGB({3},{4},{5})" -f $y, $darkGreenCount, $darkCount, $pixel.R, $pixel.G, $pixel.B)
        $buttonRows += $y
    }
}

if ($buttonRows.Count -gt 0) {
    # Find button boundaries - look for the main cluster
    $clusters = @()
    $clusterStart = $buttonRows[0]
    $clusterEnd = $buttonRows[0]
    
    for ($i = 1; $i -lt $buttonRows.Count; $i++) {
        if ($buttonRows[$i] - $buttonRows[$i-1] -le 5) {
            $clusterEnd = $buttonRows[$i]
        } else {
            $clusters += @{Start=$clusterStart; End=$clusterEnd; Size=($clusterEnd - $clusterStart)}
            $clusterStart = $buttonRows[$i]
            $clusterEnd = $buttonRows[$i]
        }
    }
    $clusters += @{Start=$clusterStart; End=$clusterEnd; Size=($clusterEnd - $clusterStart)}
    
    Write-Output "`nClusters found:"
    foreach ($c in $clusters) {
        $distFromBottom = $h - $c.End
        $bottomPct = [math]::Round($distFromBottom / $h * 100, 2)
        $heightPct = [math]::Round($c.Size / $h * 100, 2)
        Write-Output "  Y: $($c.Start) - $($c.End), size=$($c.Size)px, fromBottom=${distFromBottom}px (${bottomPct}%), height=${heightPct}%"
    }
    
    # The button cluster should be the one with reasonable size (80-250px height)
    $buttonCluster = $clusters | Where-Object { $_.Size -ge 50 -and $_.Size -le 300 } | Select-Object -First 1
    if ($buttonCluster) {
        Write-Output "`nLikely button cluster: Y=$($buttonCluster.Start)-$($buttonCluster.End)"
        
        # Find left/right edges
        $midY = [int](($buttonCluster.Start + $buttonCluster.End) / 2)
        $btnLeft = -1
        $btnRight = -1
        
        for ($x = 0; $x -lt $w; $x++) {
            $pixel = $img.GetPixel($x, $midY)
            $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
            if ($brightness -lt 120) {
                $btnLeft = $x
                break
            }
        }
        for ($x = $w - 1; $x -ge 0; $x--) {
            $pixel = $img.GetPixel($x, $midY)
            $brightness = ($pixel.R * 0.299 + $pixel.G * 0.587 + $pixel.B * 0.114)
            if ($brightness -lt 120) {
                $btnRight = $x
                break
            }
        }
        
        $btnW = $btnRight - $btnLeft
        $distBot = $h - $buttonCluster.End
        
        Write-Output "  Left=$btnLeft Right=$btnRight Width=${btnW}px"
        Write-Output "  CSS: bottom=$([math]::Round($distBot/$h*100, 2))%"
        Write-Output "  CSS: left=$([math]::Round($btnLeft/$w*100, 2))%"
        Write-Output "  CSS: width=$([math]::Round($btnW/$w*100, 2))%"
        Write-Output "  CSS: height=$([math]::Round($buttonCluster.Size/$h*100, 2))%"
    }
}

$img.Dispose()
