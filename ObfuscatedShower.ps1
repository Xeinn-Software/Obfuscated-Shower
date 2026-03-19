Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Obfuscated Shower - by XEINN"
    Width="980" Height="680"
    MinWidth="700" MinHeight="450"
    WindowStartupLocation="CenterScreen"
    Background="#050F05"
    FontFamily="Segoe UI">

    <Window.Resources>

        <Style x:Key="ScanButon" TargetType="Button">
            <Setter Property="Background"      Value="#1A6B1A"/>
            <Setter Property="Foreground"      Value="#C8F0C8"/>
            <Setter Property="FontSize"        Value="13"/>
            <Setter Property="FontWeight"      Value="SemiBold"/>
            <Setter Property="Padding"         Value="28,0"/>
            <Setter Property="Height"          Value="38"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="7" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#228B22"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#0F4A0F"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bg" Property="Background" Value="#1A2A1A"/>
                                <Setter Property="Foreground"                 Value="#3A5A3A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="TemizleButon" TargetType="Button">
            <Setter Property="Background"      Value="#0D1F0D"/>
            <Setter Property="Foreground"      Value="#4A7A4A"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="Padding"         Value="18,0"/>
            <Setter Property="Height"          Value="38"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush"     Value="#1E3A1E"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg2" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="7" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg2" Property="Background"  Value="#142A14"/>
                                <Setter TargetName="bg2" Property="BorderBrush" Value="#2A5A2A"/>
                                <Setter Property="Foreground"                   Value="#6AAA6A"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg2" Property="Background" Value="#080F08"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="ScrollBar">
            <Setter Property="Width"      Value="6"/>
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="ScrollBar">
                        <Grid>
                            <Track x:Name="PART_Track" IsDirectionReversed="True">
                                <Track.Thumb>
                                    <Thumb>
                                        <Thumb.Template>
                                            <ControlTemplate TargetType="Thumb">
                                                <Border Background="#1A5A1A" CornerRadius="3" Margin="1,0"/>
                                            </ControlTemplate>
                                        </Thumb.Template>
                                    </Thumb>
                                </Track.Thumb>
                            </Track>
                        </Grid>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="54"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="42"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#080F08" BorderBrush="#0F2A0F" BorderThickness="0,0,0,1" Padding="28,0">
            <StackPanel VerticalAlignment="Center">
                <TextBlock Text="Obfuscated Shower"
                           Foreground="#39D439"
                           FontSize="26"
                           FontWeight="Bold"/>
                <TextBlock Text="by X E I N N"
                           Foreground="#1E7A1E"
                           FontSize="13"
                           FontStyle="Italic"
                           Margin="2,4,0,0"/>
            </StackPanel>
        </Border>

        <Border Grid.Row="1" Background="#060D06" BorderBrush="#0F2A0F" BorderThickness="0,0,0,1" Padding="28,0">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Button x:Name="scanButon"   Content="Tum Diskleri Tara" Style="{StaticResource ScanButon}" Margin="0,0,10,0"/>
                    <Button x:Name="temizleButon" Content="Temizle"           Style="{StaticResource TemizleButon}"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <TextBlock x:Name="durumMetni" Foreground="#2A5A2A" FontSize="11" VerticalAlignment="Center" Margin="0,0,16,0"/>
                    <TextBlock x:Name="sayacMetni" Foreground="#2A5A2A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
            </Grid>
        </Border>

        <Grid Grid.Row="2" Background="#050F05">
            <Grid.RowDefinitions>
                <RowDefinition Height="32"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Border Grid.Row="0" Background="#080F08" BorderBrush="#0F2A0F" BorderThickness="0,0,0,1" Padding="16,0">
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="2*"/>
                        <ColumnDefinition Width="3*"/>
                        <ColumnDefinition Width="160"/>
                        <ColumnDefinition Width="120"/>
                        <ColumnDefinition Width="100"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="Dosya Adi"        Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                    <TextBlock Grid.Column="1" Text="Yol"              Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                    <TextBlock Grid.Column="2" Text="Yuklenme Tarihi"  Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                    <TextBlock Grid.Column="3" Text="Boyut"            Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                    <TextBlock Grid.Column="4" Text="Risk"             Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                </Grid>
            </Border>

            <ScrollViewer Grid.Row="1"
                          VerticalScrollBarVisibility="Auto"
                          HorizontalScrollBarVisibility="Disabled"
                          Background="#050F05"
                          Padding="0,4,6,4">
                <StackPanel x:Name="sonucPanel"/>
            </ScrollViewer>
        </Grid>

        <Border Grid.Row="3" Background="#080F08" BorderBrush="#0F2A0F" BorderThickness="0,1,0,0" Padding="28,0">
            <Grid>
                <TextBlock x:Name="altMetni" Text="Hazir — Tara butonuna basin"
                           Foreground="#1A4A1A" FontSize="11" VerticalAlignment="Center"/>
                <TextBlock x:Name="kullaniciBilgi" Foreground="#1A3A1A" FontSize="11"
                           VerticalAlignment="Center" HorizontalAlignment="Right"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader  = New-Object System.Xml.XmlNodeReader $xaml
$pencere = [Windows.Markup.XamlReader]::Load($reader)

$scanButon     = $pencere.FindName("scanButon")
$temizleButon  = $pencere.FindName("temizleButon")
$sonucPanel    = $pencere.FindName("sonucPanel")
$durumMetni    = $pencere.FindName("durumMetni")
$sayacMetni    = $pencere.FindName("sayacMetni")
$altMetni      = $pencere.FindName("altMetni")
$kullaniciBilgi = $pencere.FindName("kullaniciBilgi")

$kullaniciBilgi.Text = "Kullanici: $env:USERNAME"

$obfuscatedUzantilar = @(
    ".vmp", ".themida", ".confuser", ".obf",
    ".packed", ".crypt", ".crypted", ".enc",
    ".protected", ".guard"
)

$obfuscatedKaliplar = @(
    "*.vmp.*", "*.obf.*", "*.packed.*", "*.crypt.*"
)

$riskliDizinler = @(
    "$env:TEMP",
    "$env:APPDATA",
    "$env:LOCALAPPDATA",
    (Join-Path $env:USERPROFILE "Downloads"),
    (Join-Path $env:USERPROFILE "Desktop")
)

function Risk-Hesapla {
    param($DosyaYolu, $DosyaAdi)

    $puan = 0

    $riskliUzantilar = @(".exe", ".dll", ".sys", ".bat", ".cmd", ".vbs", ".js", ".scr")
    $uzanti = [System.IO.Path]::GetExtension($DosyaAdi).ToLower()
    if ($riskliUzantilar -contains $uzanti) { $puan += 2 }

    foreach ($riskliDizin in $riskliDizinler) {
        if ($DosyaYolu.ToLower().StartsWith($riskliDizin.ToLower())) {
            $puan += 3
            break
        }
    }

    $rastgeleKalip = [System.Text.RegularExpressions.Regex]::IsMatch(
        [System.IO.Path]::GetFileNameWithoutExtension($DosyaAdi),
        "^[a-zA-Z0-9]{8,}$"
    )
    if ($rastgeleKalip) { $puan += 1 }

    if    ($puan -ge 5) { return "YUKSEK" }
    elseif ($puan -ge 3) { return "ORTA" }
    else                 { return "DUSUK" }
}

function Boyut-Formatla {
    param($Bayt)
    if    ($Bayt -ge 1GB) { return "{0:N1} GB" -f ($Bayt / 1GB) }
    elseif ($Bayt -ge 1MB) { return "{0:N1} MB" -f ($Bayt / 1MB) }
    elseif ($Bayt -ge 1KB) { return "{0:N1} KB" -f ($Bayt / 1KB) }
    else                   { return "$Bayt B" }
}

function Yeni-SonucSatiri {
    param($Dosya, $Index)

    $bgRenk = if ($Index % 2 -eq 0) { "#080F08" } else { "#060D06" }

    $risk = Risk-Hesapla -DosyaYolu $Dosya.FullName -DosyaAdi $Dosya.Name

    $riskRenk = switch ($risk) {
        "YUKSEK" { "#FF4444" }
        "ORTA"   { "#FFB800" }
        "DUSUK"  { "#39D439" }
    }

    $kart = New-Object System.Windows.Controls.Border
    $kart.Background      = $bgRenk
    $kart.BorderBrush     = "#0A1A0A"
    $kart.BorderThickness = "0,0,0,1"
    $kart.Padding         = "16,8"

    $kart.Add_MouseEnter({ param($s,$e); $s.Background = "#0D1F0D" })
    $kart.Add_MouseLeave({ param($s,$e); $s.Background = $bgRenk  })

    $ic = New-Object System.Windows.Controls.Grid
    $ic.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width="2*"}))
    $ic.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width="3*"}))
    $ic.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width="160"}))
    $ic.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width="120"}))
    $ic.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width="100"}))

    $adMetni = New-Object System.Windows.Controls.TextBlock
    $adMetni.Text         = $Dosya.Name
    $adMetni.Foreground   = "#8ACA8A"
    $adMetni.FontSize     = 12
    $adMetni.FontFamily   = "Consolas"
    $adMetni.TextTrimming = "CharacterEllipsis"
    $adMetni.VerticalAlignment = "Center"
    $adMetni.ToolTip      = $Dosya.Name

    $yolMetni = New-Object System.Windows.Controls.TextBlock
    $yolMetni.Text         = $Dosya.DirectoryName
    $yolMetni.Foreground   = "#2E5A2E"
    $yolMetni.FontSize     = 11
    $yolMetni.FontFamily   = "Consolas"
    $yolMetni.TextTrimming = "CharacterEllipsis"
    $yolMetni.VerticalAlignment = "Center"
    $yolMetni.ToolTip      = $Dosya.FullName

    $tarihMetni = New-Object System.Windows.Controls.TextBlock
    $tarihMetni.Text              = $Dosya.CreationTime.ToString("dd.MM.yyyy HH:mm")
    $tarihMetni.Foreground        = "#3A7A3A"
    $tarihMetni.FontSize          = 11
    $tarihMetni.VerticalAlignment = "Center"

    $boyutMetni = New-Object System.Windows.Controls.TextBlock
    $boyutMetni.Text              = Boyut-Formatla -Bayt $Dosya.Length
    $boyutMetni.Foreground        = "#3A7A3A"
    $boyutMetni.FontSize          = 11
    $boyutMetni.VerticalAlignment = "Center"

    $riskPanel = New-Object System.Windows.Controls.Border
    $riskPanel.CornerRadius    = "4"
    $riskPanel.Padding         = "8,3"
    $riskPanel.BorderThickness = "1"
    $riskPanel.VerticalAlignment = "Center"
    $riskPanel.HorizontalAlignment = "Left"

    switch ($risk) {
        "YUKSEK" {
            $riskPanel.Background  = "#2A0A0A"
            $riskPanel.BorderBrush = "#7A1A1A"
        }
        "ORTA" {
            $riskPanel.Background  = "#2A1E00"
            $riskPanel.BorderBrush = "#7A5A00"
        }
        "DUSUK" {
            $riskPanel.Background  = "#0A2A0A"
            $riskPanel.BorderBrush = "#1A5A1A"
        }
    }

    $riskMetni = New-Object System.Windows.Controls.TextBlock
    $riskMetni.Text       = $risk
    $riskMetni.Foreground = $riskRenk
    $riskMetni.FontSize   = 10
    $riskMetni.FontWeight = "SemiBold"

    $riskPanel.Child = $riskMetni

    [System.Windows.Controls.Grid]::SetColumn($adMetni,    0)
    [System.Windows.Controls.Grid]::SetColumn($yolMetni,   1)
    [System.Windows.Controls.Grid]::SetColumn($tarihMetni, 2)
    [System.Windows.Controls.Grid]::SetColumn($boyutMetni, 3)
    [System.Windows.Controls.Grid]::SetColumn($riskPanel,  4)

    $ic.Children.Add($adMetni)    | Out-Null
    $ic.Children.Add($yolMetni)   | Out-Null
    $ic.Children.Add($tarihMetni) | Out-Null
    $ic.Children.Add($boyutMetni) | Out-Null
    $ic.Children.Add($riskPanel)  | Out-Null

    $kart.Child = $ic
    return $kart
}

$scanButon.Add_Click({
    $scanButon.IsEnabled    = $false
    $sonucPanel.Children.Clear()
    $durumMetni.Text        = "Taranıyor..."
    $durumMetni.Foreground  = "#39D439"
    $sayacMetni.Text        = ""
    $altMetni.Text          = "Lutfen bekleyin, tum diskler taranıyor..."
    $altMetni.Foreground    = "#39D439"

    $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

    $bulunanlar = [System.Collections.Generic.List[object]]::new()

    $diskler = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady -and ($_.DriveType -eq "Fixed" -or $_.DriveType -eq "Removable") }

    foreach ($disk in $diskler) {
        try {
            $altMetni.Text = "Taraniyor: $($disk.RootDirectory.FullName)"
            $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

            $dosyalar = Get-ChildItem -Path $disk.RootDirectory.FullName -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object {
                    $ad     = $_.Name.ToLower()
                    $uzanti = $_.Extension.ToLower()

                    $obfuscatedUzantiKontrol = $false
                    foreach ($u in $obfuscatedUzantilar) {
                        if ($ad.Contains($u)) { $obfuscatedUzantiKontrol = $true; break }
                    }

                    $boyutKontrol  = ($_.Length -gt 0 -and $_.Length -lt 500MB)
                    $uzantiKontrol = ($uzanti -in @(".exe",".dll",".sys",".jar",".py",".js",".vbs",".bat",".cmd",".scr",".pif"))

                    ($obfuscatedUzantiKontrol -or (
                        $uzantiKontrol -and (
                            $ad -match "^[a-z0-9]{6,20}\.(exe|dll|sys)$" -or
                            $ad -match "inject|hook|bypass|loader|dumper|stealer|rat|spy|keylog|cheat|hack|ghost|phantom|shadow" -or
                            $_.FullName -match "\\Temp\\|\\AppData\\Local\\Temp\\|\\AppData\\Roaming\\"
                        )
                    )) -and $boyutKontrol
                }

            foreach ($d in $dosyalar) {
                $bulunanlar.Add($d)
            }
        } catch {
        }
    }

    $index = 0
    foreach ($dosya in ($bulunanlar | Sort-Object CreationTime -Descending)) {
        try {
            $satir = Yeni-SonucSatiri -Dosya $dosya -Index $index
            $sonucPanel.Children.Add($satir) | Out-Null
            $index++

            if ($index % 10 -eq 0) {
                $sayacMetni.Text = "$index dosya bulundu"
                $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
            }
        } catch {
        }
    }

    $sayacMetni.Text       = "$($bulunanlar.Count) sonuc bulundu"
    $durumMetni.Text       = "Tarama tamamlandi"
    $altMetni.Text         = "Tarama tamamlandi — $($bulunanlar.Count) obfuscated/suphe dosya bulundu"
    $altMetni.Foreground   = "#39D439"
    $scanButon.IsEnabled   = $true
})

$temizleButon.Add_Click({
    $sonucPanel.Children.Clear()
    $sayacMetni.Text      = ""
    $durumMetni.Text      = ""
    $altMetni.Text        = "Hazir — Tara butonuna basin"
    $altMetni.Foreground  = "#1A4A1A"
})

$pencere.ShowDialog() | Out-Null
