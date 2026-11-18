Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Runtime

$basePath = Split-Path -Parent $PSScriptRoot
$productPath = Join-Path $basePath 'assets\products'
$staticDir = Join-Path $PSScriptRoot 'whatsapp-status'
$outputDir = Join-Path $PSScriptRoot 'whatsapp-status\animated'
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$width = 720; $height = 1280; $fps = 8; $frames = 32
$codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/gif' } | Select-Object -First 1
$saveFlag = [System.Drawing.Imaging.Encoder]::SaveFlag

function New-FrameBitmap($sourceImage, $productImage, [int]$frameIndex) {
  $b = [Drawing.Bitmap]::new($width,$height,[Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [Drawing.Graphics]::FromImage($b)
  $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.DrawImage($sourceImage,0,0,$width,$height)

  # Gently enlarge the real product photo inside its existing frame.
  $wave = (1 - [Math]::Cos(2 * [Math]::PI * $frameIndex / ($frames - 1))) / 2
  $zoom = 1.0 + 0.105 * $wave
  $clip = [Drawing.RectangleF]::new(50.7,419,608,387)
  $state = $g.Save()
  $g.SetClip($clip)
  $dw = $clip.Width * $zoom; $dh = $clip.Height * $zoom
  $dx = $clip.X + ($clip.Width - $dw)/2; $dy = $clip.Y + ($clip.Height - $dh)/2
  $g.DrawImage($productImage,[Drawing.RectangleF]::new($dx,$dy,$dw,$dh))
  $g.Restore($state)

  # Pulse the existing Order Now CTA to make it easy to notice.
  $pulse = (1 - [Math]::Cos(2 * [Math]::PI * $frameIndex / 10)) / 2
  $scale = 0.97 + 0.08*$pulse
  $bw = 181.3*$scale; $bh = 62*$scale
  $bx = 551.3 + (181.3-$bw)/2; $by = 1096.7 + (62-$bh)/2
  $path = [Drawing.Drawing2D.GraphicsPath]::new(); $r=18*$scale; $d=2*$r
  $path.AddArc($bx,$by,$d,$d,180,90); $path.AddArc($bx+$bw-$d,$by,$d,$d,270,90)
  $path.AddArc($bx+$bw-$d,$by+$bh-$d,$d,$d,0,90); $path.AddArc($bx,$by+$bh-$d,$d,$d,90,90); $path.CloseFigure()
  $gold = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(240,205,132)); $g.FillPath($gold,$path); $gold.Dispose(); $path.Dispose()
  $font = [Drawing.Font]::new('Segoe UI',20*$scale,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
  $brush = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(23,59,50)); $fmt=[Drawing.StringFormat]::new()
  $fmt.Alignment=[Drawing.StringAlignment]::Center; $fmt.LineAlignment=[Drawing.StringAlignment]::Center
  $g.DrawString('ORDER NOW',$font,$brush,[Drawing.RectangleF]::new($bx,$by,$bw,$bh),$fmt)
  $font.Dispose();$brush.Dispose();$fmt.Dispose()

  # 3-2-1 is a visual intro only, not a false promotion deadline.
  if($frameIndex -lt 12) {
    $digit = 3 - [Math]::Floor($frameIndex/4)
    $diameter=112; $cx=360; $cy=612
    $circle = [Drawing.SolidBrush]::new([Drawing.Color]::FromArgb(220,23,59,50))
    $g.FillEllipse($circle,$cx-$diameter/2,$cy-$diameter/2,$diameter,$diameter); $circle.Dispose()
    $pen=[Drawing.Pen]::new([Drawing.Color]::FromArgb(240,224,179,94),4);$g.DrawEllipse($pen,$cx-$diameter/2,$cy-$diameter/2,$diameter,$diameter);$pen.Dispose()
    $numFont=[Drawing.Font]::new('Segoe UI',70,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
    $numBrush=[Drawing.SolidBrush]::new([Drawing.Color]::White);$numFormat=[Drawing.StringFormat]::new()
    $numFormat.Alignment=[Drawing.StringAlignment]::Center;$numFormat.LineAlignment=[Drawing.StringAlignment]::Center
    $g.DrawString([string]$digit,$numFont,$numBrush,[Drawing.RectangleF]::new($cx-$diameter/2,$cy-$diameter/2,$diameter,$diameter),$numFormat)
    $numFont.Dispose();$numBrush.Dispose();$numFormat.Dispose()
  }
  $g.Dispose()
  return $b
}

$assets = @(
  @{ static='01-choose-your-bundle.png'; product='package-three.jpg'; output='01-choose-your-bundle.gif' },
  @{ static='02-fresh-start.png'; product='package-one.jpg'; output='02-fresh-start.gif' },
  @{ static='03-double-refresh.png'; product='package-two.jpg'; output='03-double-refresh.gif' },
  @{ static='04-ultimate-refresh.png'; product='package-three.jpg'; output='04-ultimate-refresh.gif' }
)

foreach($asset in $assets) {
  $source=[Drawing.Image]::FromFile((Join-Path $staticDir $asset.static))
  $product=[Drawing.Image]::FromFile((Join-Path $productPath $asset.product))
  $path=Join-Path $outputDir $asset.output
  try {
    $first=New-FrameBitmap $source $product 0
    $prop=[System.Runtime.Serialization.FormatterServices]::GetUninitializedObject([Drawing.Imaging.PropertyItem])
    $prop.Id=0x5100; $prop.Type=4; $prop.Len=$frames*4
    $delay=[byte[]]::new($frames*4)
    for($i=0;$i -lt $frames;$i++) { [Array]::Copy([BitConverter]::GetBytes([int](100/$fps)),0,$delay,$i*4,4) }
    $prop.Value=$delay; $first.SetPropertyItem($prop)
    $params=[Drawing.Imaging.EncoderParameters]::new(1)
    $params.Param[0]=[Drawing.Imaging.EncoderParameter]::new($saveFlag,[long][Drawing.Imaging.EncoderValue]::MultiFrame)
    $first.Save($path,$codec,$params)
    $params.Param[0].Dispose()
    $params.Param[0]=[Drawing.Imaging.EncoderParameter]::new($saveFlag,[long][Drawing.Imaging.EncoderValue]::FrameDimensionTime)
    for($i=1;$i -lt $frames;$i++) {
      $frame=New-FrameBitmap $source $product $i
      try { $first.SaveAdd($frame,$params) } finally { $frame.Dispose() }
    }
    $params.Param[0].Dispose()
    $params.Param[0]=[Drawing.Imaging.EncoderParameter]::new($saveFlag,[long][Drawing.Imaging.EncoderValue]::Flush)
    $first.SaveAdd($params)
    $params.Dispose();$first.Dispose()
  } finally { $source.Dispose();$product.Dispose() }
  Write-Output "Created $path"
}
