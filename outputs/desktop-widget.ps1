param(
  [string]$ApiUrl = "http://127.0.0.1:8766/api/worldcup"
)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$settingsDirectory = Join-Path $env:LOCALAPPDATA "FIFA2026Widget"
$positionPath = Join-Path $settingsDirectory "position.json"

$signature = @"
using System;
using System.Runtime.InteropServices;
public static class NativeWindowTools {
  [StructLayout(LayoutKind.Sequential)]
  public struct RECT {
    public int Left;
    public int Top;
    public int Right;
    public int Bottom;
  }

  [DllImport("user32.dll")]
  public static extern int GetWindowLong(IntPtr hWnd, int nIndex);

  [DllImport("user32.dll")]
  public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);

  [DllImport("user32.dll")]
  public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
}
"@
Add-Type -TypeDefinition $signature

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Width="440" Height="390"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        ResizeMode="NoResize"
        ShowInTaskbar="False"
        ShowActivated="True"
        Topmost="False">
  <Border Background="Transparent" BorderThickness="0" Padding="18">
    <Grid Opacity="0.99">
      <Canvas IsHitTestVisible="False">
        <Canvas.OpacityMask>
          <RadialGradientBrush Center="0.5,0.52" GradientOrigin="0.48,0.48" RadiusX="0.72" RadiusY="0.62">
            <GradientStop Color="#FFFFFFFF" Offset="0"/>
            <GradientStop Color="#FFFFFFFF" Offset="0.42"/>
            <GradientStop Color="#B8FFFFFF" Offset="0.62"/>
            <GradientStop Color="#30FFFFFF" Offset="0.82"/>
            <GradientStop Color="#00FFFFFF" Offset="1"/>
          </RadialGradientBrush>
        </Canvas.OpacityMask>
        <Rectangle Canvas.Left="20" Canvas.Top="24" Width="364" Height="318" RadiusX="34" RadiusY="34" Fill="#B2050506">
          <Rectangle.Effect><BlurEffect Radius="58"/></Rectangle.Effect>
        </Rectangle>
        <Ellipse Canvas.Left="14" Canvas.Top="14" Width="350" Height="166" Fill="#30F1EADB">
          <Ellipse.Effect><BlurEffect Radius="72"/></Ellipse.Effect>
        </Ellipse>
        <Ellipse Canvas.Left="92" Canvas.Top="126" Width="308" Height="206" Fill="#8C040405">
          <Ellipse.Effect><BlurEffect Radius="88"/></Ellipse.Effect>
        </Ellipse>
        <Polygon Points="8,112 118,40 246,70 420,30 430,174 298,226 122,210" Fill="#24F1EADB">
          <Polygon.Effect><BlurEffect Radius="54"/></Polygon.Effect>
        </Polygon>
        <Ellipse Canvas.Left="264" Canvas.Top="220" Width="154" Height="110" Fill="#72030103">
          <Ellipse.Effect><BlurEffect Radius="96"/></Ellipse.Effect>
        </Ellipse>
      </Canvas>
      <Grid Margin="10">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="8"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="10"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <DockPanel Grid.Row="0">
        <StackPanel DockPanel.Dock="Left">
          <TextBlock Text="HARKONNEN MATCH COMMAND" Foreground="#F0E7DF" FontFamily="Bahnschrift SemiCondensed" FontSize="15" FontWeight="Black"/>
          <TextBlock Text="FIFA 2026 // FIELD INTELLIGENCE" Foreground="#9E7772" FontSize="9" FontWeight="Bold" Margin="0,3,0,0"/>
        </StackPanel>
        <TextBlock x:Name="UpdatedText" Text="加载中" Foreground="#D64335" FontFamily="Consolas" FontSize="11" FontWeight="Bold" HorizontalAlignment="Right"/>
      </DockPanel>

      <Grid x:Name="MatchGrid" Grid.Row="2">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="12"/>
          <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0" CornerRadius="12" Background="#58131110" BorderBrush="#405C4B32" BorderThickness="1" Padding="11">
          <StackPanel>
            <TextBlock x:Name="NowLabel" Text="正在进行" Foreground="#D64335" FontSize="10" FontWeight="Bold"/>
            <TextBlock x:Name="NowTitle" Text="暂无进行中比赛" Foreground="#F0E7DF" FontFamily="Bahnschrift SemiCondensed" FontSize="18" FontWeight="Bold" TextWrapping="Wrap" Margin="0,6,0,0"/>
            <TextBlock x:Name="NowMeta" Text="正在检查赛程" Foreground="#9E8E87" FontSize="12" TextWrapping="Wrap" Margin="0,7,0,0"/>
          </StackPanel>
        </Border>

        <Border Grid.Column="2" CornerRadius="12" Background="#58131110" BorderBrush="#405C4B32" BorderThickness="1" Padding="11">
          <StackPanel>
            <TextBlock x:Name="NextLabel" Text="下一场" Foreground="#EEEAE4" FontSize="10" FontWeight="Bold"/>
            <TextBlock x:Name="NextTitle" Text="加载中..." Foreground="#F0E7DF" FontFamily="Bahnschrift SemiCondensed" FontSize="18" FontWeight="Bold" TextWrapping="Wrap" Margin="0,6,0,0"/>
            <TextBlock x:Name="NextMeta" Text="等待开球时间" Foreground="#9E8E87" FontSize="12" TextWrapping="Wrap" Margin="0,7,0,0"/>
          </StackPanel>
        </Border>
      </Grid>

      <Border x:Name="TomorrowPanel" Grid.Row="2" CornerRadius="12" Background="#58131110" BorderBrush="#405C4B32" BorderThickness="1" Padding="11" Visibility="Collapsed">
        <StackPanel>
          <TextBlock Text="MATCH QUEUE" Foreground="#D64335" FontSize="10" FontWeight="Bold"/>
          <TextBlock x:Name="TomorrowTitle" Text="明日赛程" Foreground="#F0E7DF" FontFamily="Bahnschrift SemiCondensed" FontSize="17" FontWeight="Bold" Margin="0,6,0,8"/>
          <StackPanel x:Name="TomorrowList"/>
        </StackPanel>
      </Border>

      <Border Grid.Row="4" CornerRadius="12" Background="#4A100D0E" BorderBrush="#485E3434" BorderThickness="1" Padding="10,7">
        <DockPanel>
          <Ellipse Width="8" Height="8" Fill="#C72920" DockPanel.Dock="Left" Margin="0,0,8,0"/>
          <TextBlock x:Name="StatusText" Text="实时数据，按住空白区域拖动" Foreground="#9E7772" FontSize="11"/>
        </DockPanel>
      </Border>
      </Grid>
    </Grid>
  </Border>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$updatedText = $window.FindName("UpdatedText")
$matchGrid = $window.FindName("MatchGrid")
$nowLabel = $window.FindName("NowLabel")
$nowTitle = $window.FindName("NowTitle")
$nowMeta = $window.FindName("NowMeta")
$nextLabel = $window.FindName("NextLabel")
$nextTitle = $window.FindName("NextTitle")
$nextMeta = $window.FindName("NextMeta")
$tomorrowPanel = $window.FindName("TomorrowPanel")
$tomorrowTitle = $window.FindName("TomorrowTitle")
$tomorrowList = $window.FindName("TomorrowList")
$statusText = $window.FindName("StatusText")
$script:games = @()
$script:sourceUpdated = $null
$script:hoverMode = $false
$script:hwnd = [IntPtr]::Zero
$script:teamNamesZh = @{
  "ALG" = "阿尔及利亚"
  "ARG" = "阿根廷"
  "AUS" = "澳大利亚"
  "AUT" = "奥地利"
  "BEL" = "比利时"
  "BIH" = "波黑"
  "BRA" = "巴西"
  "CAN" = "加拿大"
  "CIV" = "科特迪瓦"
  "COD" = "刚果民主共和国"
  "COL" = "哥伦比亚"
  "CPV" = "佛得角"
  "CRO" = "克罗地亚"
  "CUW" = "库拉索"
  "CZE" = "捷克"
  "ECU" = "厄瓜多尔"
  "EGY" = "埃及"
  "ENG" = "英格兰"
  "ESP" = "西班牙"
  "FRA" = "法国"
  "GER" = "德国"
  "GHA" = "加纳"
  "HAI" = "海地"
  "IRN" = "伊朗"
  "IRQ" = "伊拉克"
  "JOR" = "约旦"
  "JPN" = "日本"
  "KOR" = "韩国"
  "KSA" = "沙特阿拉伯"
  "MAR" = "摩洛哥"
  "MEX" = "墨西哥"
  "NED" = "荷兰"
  "NOR" = "挪威"
  "NZL" = "新西兰"
  "PAN" = "巴拿马"
  "PAR" = "巴拉圭"
  "POR" = "葡萄牙"
  "QAT" = "卡塔尔"
  "RSA" = "南非"
  "SCO" = "苏格兰"
  "SEN" = "塞内加尔"
  "SUI" = "瑞士"
  "SWE" = "瑞典"
  "TUN" = "突尼斯"
  "TUR" = "土耳其"
  "URU" = "乌拉圭"
  "USA" = "美国"
  "UZB" = "乌兹别克斯坦"
}

function Format-MatchTime($isoValue) {
  if (-not $isoValue) { return "时间待定" }
  try {
    $dt = [DateTimeOffset]::Parse($isoValue).LocalDateTime
    return $dt.ToString("M月d日 ddd h:mm tt", [System.Globalization.CultureInfo]::GetCultureInfo("zh-CN"))
  } catch {
    return "时间待定"
  }
}

function Format-TeamNameZh($team) {
  if (-not $team) { return "" }
  $abbr = [string]$team.abbr
  if ($abbr -and $script:teamNamesZh.ContainsKey($abbr)) { return $script:teamNamesZh[$abbr] }
  $name = [string]$team.name
  $groupWinner = [regex]::Match($name, '^Group ([A-L]) Winner$')
  if ($groupWinner.Success) { return "$($groupWinner.Groups[1].Value)组第一" }
  $groupSecond = [regex]::Match($name, '^Group ([A-L]) 2nd Place$')
  if ($groupSecond.Success) { return "$($groupSecond.Groups[1].Value)组第二" }
  $thirdPlace = [regex]::Match($name, '^Third Place Group (.+)$')
  if ($thirdPlace.Success) { return "$($thirdPlace.Groups[1].Value)组第三名" }
  if ($name) { return $name }
  if ($team.shortName) { return [string]$team.shortName }
  return ""
}

function Format-MatchName($match) {
  $homeName = Format-TeamNameZh $match.home
  $awayName = Format-TeamNameZh $match.away
  if ($homeName -and $awayName) { return "$homeName vs $awayName" }
  if ($match.shortName) { return [string]$match.shortName }
  if ($match.name) { return [string]$match.name }
  return "世界杯比赛"
}

function Format-Meta($match) {
  if (-not $match) { return "" }
  $bits = @()
  $bits += Format-MatchTime $match.date
  if ($match.status) { $bits += [string]$match.status }
  if ($match.venue) { $bits += [string]$match.venue }
  return ($bits | Where-Object { $_ }) -join " | "
}

function Format-CompactMatchTime($isoValue) {
  if (-not $isoValue) { return "待定" }
  try {
    $dt = [DateTimeOffset]::Parse($isoValue).LocalDateTime
    return $dt.ToString("h:mm tt", [System.Globalization.CultureInfo]::GetCultureInfo("zh-CN"))
  } catch {
    return "待定"
  }
}

function Get-UpcomingMatch($gameList) {
  $now = Get-Date
  return $gameList |
    Where-Object {
      if (-not $_.date) { $false }
      else {
        try { [DateTimeOffset]::Parse($_.date).LocalDateTime -ge $now } catch { $false }
      }
    } |
    Sort-Object { [DateTimeOffset]::Parse($_.date).LocalDateTime } |
    Select-Object -First 1
}

function Get-TomorrowMatches($gameList) {
  $start = (Get-Date).Date.AddDays(1)
  $end = $start.AddDays(1)
  return @($gameList |
    Where-Object {
      if (-not $_.date) { $false }
      else {
        try {
          $kickoff = [DateTimeOffset]::Parse($_.date).LocalDateTime
          $kickoff -ge $start -and $kickoff -lt $end
        } catch { $false }
      }
    } |
    Sort-Object { [DateTimeOffset]::Parse($_.date).LocalDateTime })
}

function Get-TodayRemainingMatches($gameList) {
  $now = Get-Date
  $start = $now.Date
  $end = $start.AddDays(1)
  return @($gameList |
    Where-Object {
      if (-not $_.date) { $false }
      else {
        try {
          $kickoff = [DateTimeOffset]::Parse($_.date).LocalDateTime
          ($_.state -eq "in") -or ($kickoff -ge $now -and $kickoff -ge $start -and $kickoff -lt $end)
        } catch { $false }
      }
    } |
    Sort-Object { [DateTimeOffset]::Parse($_.date).LocalDateTime })
}

function Render-MatchList($label, $titleDate, $gameList, $emptyText, $statusPrefix) {
  $matchGrid.Visibility = [System.Windows.Visibility]::Collapsed
  $tomorrowPanel.Visibility = [System.Windows.Visibility]::Visible
  $tomorrowList.Children.Clear()
  $tomorrowTitle.Text = "$label | $titleDate | $($gameList.Count) 场"

  if (-not $gameList -or $gameList.Count -eq 0) {
    $empty = New-Object System.Windows.Controls.TextBlock
    $empty.Text = $emptyText
    $empty.Foreground = "#9E8E87"
    $empty.FontSize = 13
    $empty.Margin = "0,8,0,0"
    $tomorrowList.Children.Add($empty) | Out-Null
    $statusText.Text = "$statusPrefix | 0 场"
    return
  }

  foreach ($game in $gameList) {
    $isLive = $game.state -eq "in"
    $score = "$($game.home.score)-$($game.away.score)"
    $row = New-Object System.Windows.Controls.Border
    $row.CornerRadius = "10"
    $row.Background = if ($isLive) { "#703B1012" } else { "#5A131110" }
    $row.BorderBrush = if ($isLive) { "#70A82D28" } else { "#405C4B32" }
    $row.BorderThickness = "1"
    $row.Padding = "8,5"
    $row.Margin = "0,0,0,5"

    $grid = New-Object System.Windows.Controls.Grid
    $col1 = New-Object System.Windows.Controls.ColumnDefinition
    $col1.Width = "72"
    $col2 = New-Object System.Windows.Controls.ColumnDefinition
    $col2.Width = "*"
    $grid.ColumnDefinitions.Add($col1)
    $grid.ColumnDefinitions.Add($col2)

    $time = New-Object System.Windows.Controls.TextBlock
    $time.Text = if ($isLive) { "LIVE" } else { Format-CompactMatchTime $game.date }
    $time.Foreground = if ($isLive) { "#E44A3E" } else { "#EEEAE4" }
    $time.FontSize = 12
    $time.FontWeight = [System.Windows.FontWeights]::Bold
    $time.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [System.Windows.Controls.Grid]::SetColumn($time, 0)

    $details = New-Object System.Windows.Controls.StackPanel
    [System.Windows.Controls.Grid]::SetColumn($details, 1)

    $name = New-Object System.Windows.Controls.TextBlock
    $name.Text = if ($isLive) { "$(Format-MatchName $game)  $score" } else { Format-MatchName $game }
    $name.Foreground = "#F0E7DF"
    $name.FontFamily = "Bahnschrift SemiCondensed, Segoe UI"
    $name.FontSize = 13
    $name.FontWeight = [System.Windows.FontWeights]::Bold
    $name.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis

    $meta = New-Object System.Windows.Controls.TextBlock
    $venue = if ($game.venue) { [string]$game.venue } else { "场地待定" }
    $detail = if ($isLive -and $game.detail) { [string]$game.detail } elseif ($game.status) { [string]$game.status } else { "赛程待定" }
    $meta.Text = if ($isLive) { "比分 $score | $detail | $venue" } else { "$detail | $venue" }
    $meta.Foreground = "#9E8E87"
    $meta.FontSize = 11
    $meta.TextTrimming = [System.Windows.TextTrimming]::CharacterEllipsis
    $meta.Margin = "0,2,0,0"

    $details.Children.Add($name) | Out-Null
    $details.Children.Add($meta) | Out-Null
    $grid.Children.Add($time) | Out-Null
    $grid.Children.Add($details) | Out-Null
    $row.Child = $grid
    $tomorrowList.Children.Add($row) | Out-Null
  }

  $statusText.Text = "$statusPrefix | $($gameList.Count) 场"
}

function Render-CurrentView {
  $today = Get-TodayRemainingMatches $script:games
  $todayLabel = (Get-Date).Date.ToString("M月d日 ddd", [System.Globalization.CultureInfo]::GetCultureInfo("zh-CN"))
  Render-MatchList "今天" $todayLabel $today "今天没有剩余比赛" "今天剩余；悬停看明天"
}

function Render-TomorrowView {
  $tomorrow = Get-TomorrowMatches $script:games
  $tomorrowLabel = (Get-Date).Date.AddDays(1).ToString("M月d日 ddd", [System.Globalization.CultureInfo]::GetCultureInfo("zh-CN"))
  Render-MatchList "明天" $tomorrowLabel $tomorrow "明天没有比赛" "明日预览"
}

function Render-Widget {
  if ($script:hoverMode) {
    Render-TomorrowView
  } else {
    Render-CurrentView
  }
}

function Update-Widget {
  try {
    $payload = Invoke-RestMethod -Uri $ApiUrl -UseBasicParsing -TimeoutSec 25
    $script:games = @($payload.matches)
    $script:sourceUpdated = if ($payload.source.generatedAt) { $payload.source.generatedAt } else { $null }
    $updatedText.Text = (Get-Date).ToString("h:mm tt")
    Render-Widget
  } catch {
    $statusText.Text = "数据暂时不可用，稍后自动重试"
    $updatedText.Text = "离线"
  }
}

function Test-CursorOverWindow {
  if (-not $window.IsVisible -or $script:hwnd -eq [IntPtr]::Zero) { return $false }
  $point = [System.Windows.Forms.Cursor]::Position
  $rect = New-Object NativeWindowTools+RECT
  if (-not [NativeWindowTools]::GetWindowRect($script:hwnd, [ref]$rect)) { return $false }
  return $point.X -ge $rect.Left -and $point.X -le $rect.Right -and $point.Y -ge $rect.Top -and $point.Y -le $rect.Bottom
}

function Update-HoverMode {
  $isHovering = Test-CursorOverWindow
  if ($isHovering -ne $script:hoverMode) {
    $script:hoverMode = $isHovering
    Render-Widget
  }
}

$window.Add_SourceInitialized({
  $helper = New-Object System.Windows.Interop.WindowInteropHelper($window)
  $hwnd = $helper.Handle
  $script:hwnd = $hwnd
  $style = [NativeWindowTools]::GetWindowLong($hwnd, -20)
  $WS_EX_TOOLWINDOW = 0x80
  [NativeWindowTools]::SetWindowLong($hwnd, -20, $style -bor $WS_EX_TOOLWINDOW) | Out-Null

  $area = [System.Windows.SystemParameters]::WorkArea
  if (Test-Path -LiteralPath $positionPath) {
    try {
      $position = Get-Content -LiteralPath $positionPath -Raw | ConvertFrom-Json
      $window.Left = [Math]::Max($area.Left, [Math]::Min([double]$position.Left, $area.Right - $window.Width))
      $window.Top = [Math]::Max($area.Top, [Math]::Min([double]$position.Top, $area.Bottom - $window.Height))
    } catch {
      $window.Left = $area.Right - $window.Width - 18
      $window.Top = $area.Top + 22
    }
  } else {
    $window.Left = $area.Right - $window.Width - 18
    $window.Top = $area.Top + 22
  }
})

$window.Add_MouseLeftButtonDown({
  if ($_.ChangedButton -eq [System.Windows.Input.MouseButton]::Left) {
    try { $window.DragMove() } catch {}
  }
})

$window.Add_LocationChanged({
  try {
    New-Item -ItemType Directory -Path $settingsDirectory -Force | Out-Null
    @{ Left = $window.Left; Top = $window.Top } | ConvertTo-Json | Set-Content -LiteralPath $positionPath -Encoding UTF8
  } catch {}
})

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromMinutes(3)
$timer.Add_Tick({ Update-Widget })
$timer.Start()

$hoverTimer = New-Object Windows.Threading.DispatcherTimer
$hoverTimer.Interval = [TimeSpan]::FromMilliseconds(220)
$hoverTimer.Add_Tick({ Update-HoverMode })
$hoverTimer.Start()

Update-Widget
$window.ShowDialog() | Out-Null
