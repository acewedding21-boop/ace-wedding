Add-Type -AssemblyName System.Drawing

$images = @(
    @{Name="18.jpg"; Desc="init - 무료초대권 신청하기"},
    @{Name="2.jpg"; Desc="section 2 - 스드메 상담하기"},
    @{Name="4.jpg"; Desc="section 4 - 혜택 문의하기"},
    @{Name="7.jpg"; Desc="section 7 - 다이렉트 웨딩 견적 문의"},
    @{Name="8.jpg"; Desc="section 8 - 다이렉트 상담 신청하기"},
    @{Name="10.jpg"; Desc="section 10 - 웨딩홀 상담하기"},
    @{Name="11.jpg"; Desc="section 11 - 드레스 상담하기"},
    @{Name="12.jpg"; Desc="section 12 - 스튜디오 상담하기"},
    @{Name="13.jpg"; Desc="section 13 - 메이크업 상담하기"},
    @{Name="14.jpg"; Desc="section 14 - 제휴 특가 상담하기"},
    @{Name="15.jpg"; Desc="section 15 - 제휴 업체 상담하기"},
    @{Name="16.jpg"; Desc="section 16 - 혼수 가전 상담하기"}
)

foreach ($item in $images) {
    $path = "C:\Users\rnjsr\.gemini\antigravity\scratch\ace-wedding\images\mobile\$($item.Name)"
    $img = [System.Drawing.Image]::FromFile($path)
    $w = $img.Width
    $h = $img.Height
    $ratio = [math]::Round($h / $w, 4)
    Write-Output "$($item.Name) ($($item.Desc)): ${w}x${h}, aspect=$ratio"
    $img.Dispose()
}
