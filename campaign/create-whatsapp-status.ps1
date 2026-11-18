Add-Type -AssemblyName System.Drawing

$base = Split-Path -Parent $PSScriptRoot
$products = Join-Path $base 'assets\products'
$out = Join-Path $PSScriptRoot 'whatsapp-status'
New-Item -ItemType Directory -Path $out -Force | Out-Null

$script:W = 1080
$script:H = 1920
$script:ink = [Drawing.Color]::FromArgb(23,59,50)
$script:cream = [Drawing.Color]::FromArgb(248,245,236)
$script:sage = [Drawing.Color]::FromArgb(221,233,222)
$script:gold = [Drawing.Color]::FromArgb(224,179,94)
$script:muted = [Drawing.Color]::FromArgb(77,103,91)
$script:white = [Drawing.Color]::FromArgb(255,254,249)

function New-Font([float]$size, [bool]$bold = $false) {
  $style = if ($bold) { [Drawing.FontStyle]::Bold } else { [Drawing.FontStyle]::Regular }
  return [Drawing.Font]::new('Segoe UI', $size, $style, [Drawing.GraphicsUnit]::Pixel)
}

function Fill-Rounded($g, [Drawing.RectangleF]$rect, [float]$radius, [Drawing.Brush]$brush) {
  $path = [Drawing.Drawing2D.GraphicsPath]::new()
  $d = $radius * 2
  $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
  $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
  $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
  $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brush, $path)
  $path.Dispose()
}

function Draw-Text($g, [string]$value, [float]$x, [float]$y, [float]$w, [float]$h, [float]$size, [Drawing.Color]$color, [bool]$bold = $false, [string]$align = 'Near') {
  $font = New-Font $size $bold
  $brush = [Drawing.SolidBrush]::new($color)
  $format = [Drawing.StringFormat]::new()
  if ($align -eq 'Center') { $format.Alignment = [Drawing.StringAlignment]::Center }
  elseif ($align -eq 'Far') { $format.Alignment = [Drawing.StringAlignment]::Far }
  else { $format.Alignment = [Drawing.StringAlignment]::Near }
  $format.LineAlignment = [Drawing.StringAlignment]::Near
  $format.Trimming = [Drawing.StringTrimming]::Word
  $format.FormatFlags = [Drawing.StringFormatFlags]::LineLimit
  $g.DrawString($value, $font, $brush, [Drawing.RectangleF]::new($x,$y,$w,$h), $format)
  $format.Dispose(); $brush.Dispose(); $font.Dispose()
}

function Draw-ImageFit($g, [string]$path, [Drawing.RectangleF]$dest, $crop = $null) {
  $img = [Drawing.Image]::FromFile($path)
  try {
    if ($null -ne $crop) {
      $g.DrawImage($img, $dest, $crop, [Drawing.GraphicsUnit]::Pixel)
    } else {
      $scale = [Math]::Min($dest.Width / $img.Width, $dest.Height / $img.Height)
      $dw = $img.Width * $scale; $dh = $img.Height * $scale
      $dx = $dest.X + ($dest.Width - $dw) / 2; $dy = $dest.Y + ($dest.Height - $dh) / 2
      $g.DrawImage($img, [Drawing.RectangleF]::new($dx,$dy,$dw,$dh))
    }
  } finally { $img.Dispose() }
}

function New-Canvas {
  $bmp = [Drawing.Bitmap]::new($script:W,$script:H,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $bg = [Drawing.Drawing2D.LinearGradientBrush]::new([Drawing.Rectangle]::new(0,0,$script:W,$script:H),$script:cream,[Drawing.Color]::FromArgb(239,244,233),35)
  $g.FillRectangle($bg,0,0,$script:W,$script:H); $bg.Dispose()
  $top = [Drawing.SolidBrush]::new($script:ink); $g.FillRectangle($top,0,0,$script:W,300); $top.Dispose()
  $orb = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(35,224,179,94)); $g.FillEllipse($orb,850,-80,340,340); $orb.Dispose()
  Draw-Text $g 'AROMA' 70 45 260 44 29 $script:gold $true
  Draw-Text $g 'MIST & BLOOM' 67 86 820 78 57 $script:white $true
  $offerPill = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(235,199,124))
  Fill-Rounded $g ([Drawing.RectangleF]::new(770,101,250,66)) 25 $offerPill; $offerPill.Dispose()
  Draw-Text $g '24 HOUR OFFER' 780 116 230 38 24 $script:ink $true 'Center'
  Draw-Text $g 'A PLEASANT WAY TO KEEP YOUR SPACE SMELLING FRESH' 72 188 920 50 25 ([Drawing.Color]::FromArgb(222,235,223)) $false
  return @{Bitmap=$bmp;Graphics=$g}
}

function Save-Card([string]$file, [int]$quality = 94) {
  $enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object {$_.MimeType -eq 'image/png'} | Select-Object -First 1
  $script:bitmap.Save($file,[Drawing.Imaging.ImageFormat]::Png)
  $script:graphics.Dispose(); $script:bitmap.Dispose()
}

function Add-ProductPhoto($g, [string]$filename) {
  $shadow = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(30,23,59,50))
  Fill-Rounded $g ([Drawing.RectangleF]::new(64,620,952,620)) 34 $shadow; $shadow.Dispose()
  $card = [Drawing.SolidBrush]::new($script:white)
  Fill-Rounded $g ([Drawing.RectangleF]::new(56,608,952,620)) 34 $card; $card.Dispose()
  Draw-ImageFit $g (Join-Path $products $filename) ([Drawing.RectangleF]::new(76,628,912,580))
}

function Add-OrderFooter($g, [string]$price, [string]$badge) {
  $dark = [Drawing.SolidBrush]::new($script:ink)
  Fill-Rounded $g ([Drawing.RectangleF]::new(56,1570,952,300)) 32 $dark; $dark.Dispose()
  Draw-Text $g $badge.ToUpperInvariant() 91 1592 865 42 24 $script:gold $true
  Draw-Text $g $price 85 1642 580 112 86 $script:white $true
  $btn = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(235,199,124));
  Fill-Rounded $g ([Drawing.RectangleF]::new(690,1645,272,93)) 28 $btn; $btn.Dispose()
  Draw-Text $g 'ORDER NOW' 700 1668 252 54 30 $script:ink $true 'Center'
  Draw-Text $g 'WhatsApp  08088160543' 92 1762 860 44 30 $script:white $true
  Draw-Text $g 'FREE DELIVERY • ENDS 24 HOURS AFTER POSTING' 92 1817 860 34 22 ([Drawing.Color]::FromArgb(220,234,221)) $true
}

function Add-OfferDetails($g, [string[]]$lines, [string]$mango = '', [string]$strawberry = '') {
  $card = [Drawing.SolidBrush]::new($script:sage)
  Fill-Rounded $g ([Drawing.RectangleF]::new(56,1254,952,292)) 28 $card; $card.Dispose()
  Draw-Text $g 'IN THIS PACKAGE' 88 1282 540 36 23 $script:muted $true
  $yy = 1332
  foreach($line in $lines) {
    Draw-Text $g '•' 88 ($yy-2) 34 46 32 $script:ink $true
    Draw-Text $g $line 125 $yy 590 48 30 $script:ink $true
    $yy += 62
  }
  if($mango -or $strawberry) {
    $thumbW=122; $thumbH=178; $thumbY=1336
    if($mango -and $strawberry) {
      Draw-ImageFit $g (Join-Path $products 'mango-oil-product.png') ([Drawing.RectangleF]::new(720,$thumbY,110,$thumbH)) ([Drawing.RectangleF]::new(146,20,175,480))
      Draw-ImageFit $g (Join-Path $products 'strawberry-oil-product.png') ([Drawing.RectangleF]::new(850,$thumbY,110,$thumbH)) ([Drawing.RectangleF]::new(8,30,252,460))
      Draw-Text $g 'MANGO' 720 1505 110 30 16 $script:muted $true 'Center'
      Draw-Text $g 'STRAWBERRY' 834 1505 142 30 15 $script:muted $true 'Center'
    } elseif($mango) {
      Draw-ImageFit $g (Join-Path $products 'mango-oil-product.png') ([Drawing.RectangleF]::new(795,$thumbY-5,130,190)) ([Drawing.RectangleF]::new(146,20,175,480))
      Draw-Text $g 'MANGO OIL' 780 1505 160 30 17 $script:muted $true 'Center'
    }
  }
}

function Make-Overview {
  $c=New-Canvas; $script:bitmap=$c.Bitmap; $script:graphics=$c.Graphics; $g=$script:graphics
  Draw-Text $g 'FIND YOUR' 68 340 930 83 72 $script:ink $true
  Draw-Text $g 'FRESH-SPACE SET.' 68 423 940 89 68 $script:ink $true
  Draw-Text $g 'Pick the bundle that fits your home, work or gifting plans.' 72 527 920 72 30 $script:muted $false
  Add-ProductPhoto $g 'package-three.jpg'
  $card=[Drawing.SolidBrush]::new($script:white); Fill-Rounded $g ([Drawing.RectangleF]::new(56,1254,952,292)) 28 $card; $card.Dispose()
  Draw-Text $g '1 DIFFUSER + 1 OIL' 88 1280 590 48 29 $script:ink $true
  Draw-Text $g '2 DIFFUSERS + 2 OILS' 88 1367 590 48 29 $script:ink $true
  Draw-Text $g '3 DIFFUSERS + 3 OILS' 88 1454 590 48 29 $script:ink $true
  Draw-Text $g '₦20,000' 705 1278 260 48 34 $script:ink $true 'Far'
  Draw-Text $g '₦38,000' 705 1365 260 48 34 $script:ink $true 'Far'
  Draw-Text $g '₦55,000' 705 1452 260 48 34 $script:ink $true 'Far'
  Add-OrderFooter $g 'FROM ₦20K' 'Three bundles • oils included'
  Save-Card (Join-Path $out '01-choose-your-bundle.png')
}

function Make-Package([string]$filename,[string]$headline1,[string]$headline2,[string]$sub,[string]$photo,[string[]]$items,[string]$mango,[string]$strawberry,[string]$price,[string]$badge,[string]$outName) {
  $c=New-Canvas; $script:bitmap=$c.Bitmap; $script:graphics=$c.Graphics; $g=$script:graphics
  Draw-Text $g $headline1 68 340 945 90 68 $script:ink $true
  Draw-Text $g $headline2 68 420 945 90 68 $script:ink $true
  Draw-Text $g $sub 72 520 925 76 29 $script:muted $false
  Add-ProductPhoto $g $photo
  Add-OfferDetails $g $items $mango $strawberry
  Add-OrderFooter $g $price $badge
  Save-Card (Join-Path $out $outName)
}

Make-Overview
Make-Package '' 'START WITH ONE.' 'MAKE IT YOURS.' 'A simple first set for the room you use most.' 'package-one.jpg' @('1 mini humidifier','1 Mango fragrance oil') 'yes' '' '₦20,000' 'Fresh Start bundle' '02-fresh-start.png'
Make-Package '' 'ONE FOR HOME.' 'ONE TO SHARE.' 'Refresh two spaces—or keep one ready to gift.' 'package-two.jpg' @('2 mini humidifiers','1 Mango + 1 Strawberry oil') 'yes' 'yes' '₦38,000' 'Save ₦2,000 vs two single sets' '03-double-refresh.png'
Make-Package '' 'MORE ROOMS.' 'MORE TO ENJOY.' 'A generous set for sharing, gifting or multiple spaces.' 'package-three.jpg' @('3 mini humidifiers','2 Mango + 1 Strawberry oil') 'yes' 'yes' '₦55,000' 'Save ₦5,000 vs three single sets' '04-ultimate-refresh.png'
Write-Output "Created 4 WhatsApp Status images in $out"
