Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

Add-Type @"
using System;
using System.IO;
using System.IO.Compression;
using System.Collections.Generic;
using System.Text;

public class JarAnalyzer {

    static readonly string[] HILE_ISARETLERI = {
        "instrument","Instrumentation","premain","agentmain",
        "defineClass","ClassLoader","loadClass",
        "com/sun/jna","NativeLibrary","NativeLibrary",
        "VirtualAllocEx","WriteProcessMemory","CreateRemoteThread",
        "ReadProcessMemory","OpenProcess","NtWriteVirtualMemory",
        "aimbot","killaura","esp","wallhack","scaffold","bhop",
        "autoclicker","reach","criticals","velocity","nofall",
        "triggerbot","xray","fly","speed","noclip","blink",
        "antikb","antiknockback","fullbright","tracers","radar",
        "inject","hook","bypass","stealer","dumper","keylog",
        "EventBus","ModuleManager","HackClient","CheatClient",
        "obfuscate","deobf","RuntimeAgent","JavaAgent",
        "ReflectionUtils","MethodHandle","Unsafe","sun/misc/Unsafe"
    };

    static readonly string[] OBFUSCATED_ISARETLER = {
        "defineClass","ClassLoader","loadClass","instrument",
        "NativeLibrary","com/sun/jna","Unsafe","sun/misc"
    };

    public static List<string[]> AnalizeJar(string jarYolu) {
        var sonuclar = new List<string[]>();
        try {
            using (var zip = ZipFile.OpenRead(jarYolu)) {
                var classlar   = new List<string>();
                var tumIsimler = new List<string>();
                int toplamClass = 0;
                int tekHarfClass = 0;

                foreach (var entry in zip.Entries) {
                    tumIsimler.Add(entry.FullName);
                    if (entry.FullName.EndsWith(".class")) {
                        toplamClass++;
                        string ad = Path.GetFileNameWithoutExtension(entry.Name);
                        if (ad.Length == 1) tekHarfClass++;
                        classlar.Add(entry.FullName);
                    }
                }

                foreach (var entry in zip.Entries) {
                    if (!entry.FullName.EndsWith(".class")) continue;

                    try {
                        using (var stream = entry.Open())
                        using (var ms = new MemoryStream()) {
                            stream.CopyTo(ms);
                            string icerik = Encoding.Latin1.GetString(ms.ToArray());
                            string kucuk  = icerik.ToLower();

                            var bulunan  = new List<string>();
                            var kategori = new List<string>();

                            foreach (var isaret in HILE_ISARETLERI) {
                                if (icerik.Contains(isaret) || kucuk.Contains(isaret.ToLower())) {
                                    bulunan.Add(isaret);
                                }
                            }

                            if (bulunan.Count == 0) continue;

                            bool isInject   = false;
                            bool isObf      = false;
                            bool isHile     = false;
                            bool isNative   = false;

                            foreach (var b in bulunan) {
                                string bl = b.ToLower();
                                if (bl.Contains("instrument") || bl.Contains("agent") || bl.Contains("defineclass") || bl.Contains("premain")) isInject = true;
                                if (bl.Contains("classloader") || bl.Contains("defineclass") || bl.Contains("loadclass")) isObf = true;
                                if (bl.Contains("jna") || bl.Contains("nativelibrary") || bl.Contains("virtualalloc") || bl.Contains("unsafe") || bl.Contains("sun/misc")) isNative = true;
                                if (bl.Contains("killaura") || bl.Contains("aimbot") || bl.Contains("scaffold") || bl.Contains("velocity") || bl.Contains("esp") || bl.Contains("reach") || bl.Contains("bhop") || bl.Contains("fly") || bl.Contains("xray") || bl.Contains("autoclicker")) isHile = true;
                            }

                            string tip = "";
                            string risk = "ORTA";

                            if (isInject && isNative) { tip = "INJECT + NATIVE MEMORY"; risk = "KRITIK"; }
                            else if (isInject)        { tip = "JAVA AGENT INJECT";       risk = "KRITIK"; }
                            else if (isNative)        { tip = "NATIVE MEMORY OP";        risk = "YUKSEK"; }
                            else if (isObf)           { tip = "OBFUSCATED LOADER";       risk = "YUKSEK"; }
                            else if (isHile)          { tip = "HILE MODULU";             risk = "KRITIK"; }
                            else                      { tip = "SUPHE";                   risk = "ORTA";   }

                            string tekHarfNot = "";
                            string classAd = Path.GetFileNameWithoutExtension(entry.Name);
                            if (classAd.Length == 1) tekHarfNot = " [OBFUSCATED-ISIM]";

                            sonuclar.Add(new string[] {
                                entry.FullName + tekHarfNot,
                                tip,
                                risk,
                                string.Join(", ", bulunan.GetRange(0, Math.Min(4, bulunan.Count)))
                            });
                        }
                    } catch {}
                }

                bool cokTekHarf = toplamClass > 0 && ((double)tekHarfClass / toplamClass) > 0.3;
                if (cokTekHarf) {
                    sonuclar.Insert(0, new string[] {
                        "[GENEL] " + Path.GetFileName(jarYolu),
                        "OBFUSCATED JAR",
                        "YUKSEK",
                        "Tek harfli class orani yuksek: " + tekHarfClass + "/" + toplamClass
                    });
                }
            }
        } catch (Exception ex) {
            sonuclar.Add(new string[] { jarYolu, "OKUMA HATASI", "BILINMIYOR", ex.Message });
        }
        return sonuclar;
    }
}
"@ -ReferencedAssemblies System.IO.Compression, System.IO.Compression.FileSystem

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Obfuscated Shower"
    Width="1050" Height="700"
    MinWidth="750" MinHeight="480"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    ResizeMode="CanResizeWithGrip"
    Background="#050F05"
    FontFamily="Segoe UI">

    <Window.Resources>

        <Style x:Key="TitleButon" TargetType="Button">
            <Setter Property="Background"      Value="Transparent"/>
            <Setter Property="Foreground"      Value="#3A6A3A"/>
            <Setter Property="FontSize"        Value="14"/>
            <Setter Property="Width"           Value="40"/>
            <Setter Property="Height"          Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#0D1F0D"/>
                                <Setter Property="Foreground"                 Value="#39D439"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#050F05"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="KapatButon" TargetType="Button" BasedOn="{StaticResource TitleButon}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="0">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#3A0A0A"/>
                                <Setter Property="Foreground"                 Value="#FF4444"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#1A0505"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ScanButon" TargetType="Button">
            <Setter Property="Background"      Value="#1A6B1A"/>
            <Setter Property="Foreground"      Value="#C8F0C8"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="FontWeight"      Value="SemiBold"/>
            <Setter Property="Padding"         Value="22,0"/>
            <Setter Property="Height"          Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
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

        <Style x:Key="IkincilButon" TargetType="Button">
            <Setter Property="Background"      Value="#0D1F0D"/>
            <Setter Property="Foreground"      Value="#4A7A4A"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="Padding"         Value="16,0"/>
            <Setter Property="Height"          Value="36"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush"     Value="#1E3A1E"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg2" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
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
            <RowDefinition Height="36"/>
            <RowDefinition Height="72"/>
            <RowDefinition Height="50"/>
            <RowDefinition Height="30"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="38"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" x:Name="titleBar">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="14,0,0,0">
                    <TextBlock Text="Obfuscated Shower" Foreground="#2A5A2A" FontSize="12" VerticalAlignment="Center"/>
                    <TextBlock Text="  —  JAR Hile Analiz Araci" Foreground="#1A3A1A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button x:Name="kucultButon"  Content="&#x2212;" Style="{StaticResource TitleButon}" ToolTip="Kucult"/>
                    <Button x:Name="tamEkranButon" Content="&#x25A1;" Style="{StaticResource TitleButon}" ToolTip="Tam Ekran"/>
                    <Button x:Name="kapatButon"    Content="&#x2715;" Style="{StaticResource KapatButon}" ToolTip="Kapat"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Row="1" Background="#080F08" BorderBrush="#0F2A0F" BorderThickness="0,0,0,1" Padding="24,0">
            <StackPanel VerticalAlignment="Center">
                <TextBlock Text="Obfuscated Shower"
                           Foreground="#39D439"
                           FontSize="24"
                           FontWeight="Bold"/>
                <TextBlock Text="by  X E I N N"
                           Foreground="#1A5A1A"
                           FontSize="12"
                           FontStyle="Italic"
                           Margin="2,5,0,0"/>
            </StackPanel>
        </Border>

        <Border Grid.Row="2" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" Padding="20,0">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Button x:Name="diskScanButon"  Content="Tum Diskleri Tara (JAR)"  Style="{StaticResource ScanButon}"   Margin="0,0,10,0"/>
                    <Button x:Name="dosyaScanButon" Content="Tek JAR Sec ve Analiz Et" Style="{StaticResource IkincilButon}" Margin="0,0,10,0"/>
                    <Button x:Name="temizleButon"   Content="Temizle"                  Style="{StaticResource IkincilButon}"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <TextBlock x:Name="sayacMetni" Foreground="#2A5A2A" FontSize="11" VerticalAlignment="Center" Margin="0,0,16,0"/>
                    <TextBlock x:Name="kullaniciBilgi" Foreground="#1A3A1A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Row="3" Background="#080F08" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" Padding="16,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="2.5*"/>
                    <ColumnDefinition Width="1.5*"/>
                    <ColumnDefinition Width="110"/>
                    <ColumnDefinition Width="3*"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="Class Dosyasi"    Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center" Margin="16,0,0,0"/>
                <TextBlock Grid.Column="1" Text="Tespit Tipi"      Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="2" Text="Risk"             Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="3" Text="Bulunan Isaretler" Foreground="#1E6A1E" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
            </Grid>
        </Border>

        <ScrollViewer Grid.Row="4"
                      VerticalScrollBarVisibility="Auto"
                      HorizontalScrollBarVisibility="Disabled"
                      Background="#050F05"
                      Padding="0,4,6,4">
            <StackPanel x:Name="sonucPanel"/>
        </ScrollViewer>

        <Border Grid.Row="5" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,1,0,0" Padding="20,0">
            <TextBlock x:Name="altMetni" Text="Hazir — Tara butonuna basin"
                       Foreground="#1A4A1A" FontSize="11" VerticalAlignment="Center"/>
        </Border>
    </Grid>
</Window>
"@

$reader  = New-Object System.Xml.XmlNodeReader $xaml
$pencere = [Windows.Markup.XamlReader]::Load($reader)

$diskScanButon  = $pencere.FindName("diskScanButon")
$dosyaScanButon = $pencere.FindName("dosyaScanButon")
$temizleButon   = $pencere.FindName("temizleButon")
$sonucPanel     = $pencere.FindName("sonucPanel")
$sayacMetni     = $pencere.FindName("sayacMetni")
$altMetni       = $pencere.FindName("altMetni")
$kullaniciBilgi = $pencere.FindName("kullaniciBilgi")
$titleBar       = $pencere.FindName("titleBar")
$kapatButon     = $pencere.FindName("kapatButon")
$kucultButon    = $pencere.FindName("kucultButon")
$tamEkranButon  = $pencere.FindName("tamEkranButon")

$kullaniciBilgi.Text = $env:USERNAME

$titleBar.Add_MouseLeftButtonDown({ param($s,$e); $pencere.DragMove() })

$kapatButon.Add_Click({ $pencere.Close() })

$kucultButon.Add_Click({ $pencere.WindowState = [System.Windows.WindowState]::Minimized })

$script:tamEkranDurumu = $false
$tamEkranButon.Add_Click({
    if ($script:tamEkranDurumu) {
        $pencere.WindowState = [System.Windows.WindowState]::Normal
        $tamEkranButon.Content = [char]0x25A1
        $script:tamEkranDurumu = $false
    } else {
        $pencere.WindowState = [System.Windows.WindowState]::Maximized
        $tamEkranButon.Content = [char]0x2750
        $script:tamEkranDurumu = $true
    }
})

function Yeni-SonucSatiri {
    param($Sonuc, $Index)

    $bgRenk = if ($Index % 2 -eq 0) { "#080F08" } else { "#060D06" }

    $riskRenk = switch ($Sonuc[2]) {
        "KRITIK"    { "#FF4444" }
        "YUKSEK"    { "#FFB800" }
        "ORTA"      { "#39D439" }
        default     { "#888888" }
    }

    $kart = New-Object System.Windows.Controls.Border
    $kart.Background      = $bgRenk
    $kart.BorderBrush     = "#0A1A0A"
    $kart.BorderThickness = "0,0,0,1"
    $kart.Padding         = "16,7"

    $kart.Add_MouseEnter({ param($s,$e); $s.Background = "#0D1F0D" })
    $kart.Add_MouseLeave({ param($s,$e); $s.Background = $bgRenk  })

    $ic = New-Object System.Windows.Controls.Grid
    $c0 = New-Object System.Windows.Controls.ColumnDefinition; $c0.Width = "2.5*"
    $c1 = New-Object System.Windows.Controls.ColumnDefinition; $c1.Width = "1.5*"
    $c2 = New-Object System.Windows.Controls.ColumnDefinition; $c2.Width = "110"
    $c3 = New-Object System.Windows.Controls.ColumnDefinition; $c3.Width = "3*"
    $ic.ColumnDefinitions.Add($c0)
    $ic.ColumnDefinitions.Add($c1)
    $ic.ColumnDefinitions.Add($c2)
    $ic.ColumnDefinitions.Add($c3)

    $classMetni = New-Object System.Windows.Controls.TextBlock
    $classMetni.Text              = $Sonuc[0]
    $classMetni.Foreground        = "#8ACA8A"
    $classMetni.FontSize          = 11
    $classMetni.FontFamily        = "Consolas"
    $classMetni.TextTrimming      = "CharacterEllipsis"
    $classMetni.VerticalAlignment = "Center"
    $classMetni.ToolTip           = $Sonuc[0]

    $tipMetni = New-Object System.Windows.Controls.TextBlock
    $tipMetni.Text              = $Sonuc[1]
    $tipMetni.Foreground        = $riskRenk
    $tipMetni.FontSize          = 11
    $tipMetni.FontWeight        = "SemiBold"
    $tipMetni.TextTrimming      = "CharacterEllipsis"
    $tipMetni.VerticalAlignment = "Center"

    $riskPanel = New-Object System.Windows.Controls.Border
    $riskPanel.CornerRadius       = "4"
    $riskPanel.Padding            = "8,3"
    $riskPanel.BorderThickness    = "1"
    $riskPanel.VerticalAlignment  = "Center"
    $riskPanel.HorizontalAlignment = "Left"

    switch ($Sonuc[2]) {
        "KRITIK" { $riskPanel.Background = "#2A0A0A"; $riskPanel.BorderBrush = "#8A1A1A" }
        "YUKSEK" { $riskPanel.Background = "#2A1E00"; $riskPanel.BorderBrush = "#7A5A00" }
        "ORTA"   { $riskPanel.Background = "#0A2A0A"; $riskPanel.BorderBrush = "#1A5A1A" }
        default  { $riskPanel.Background = "#1A1A1A"; $riskPanel.BorderBrush = "#3A3A3A" }
    }

    $riskMetni = New-Object System.Windows.Controls.TextBlock
    $riskMetni.Text       = $Sonuc[2]
    $riskMetni.Foreground = $riskRenk
    $riskMetni.FontSize   = 10
    $riskMetni.FontWeight = "Bold"
    $riskPanel.Child = $riskMetni

    $isaretMetni = New-Object System.Windows.Controls.TextBlock
    $isaretMetni.Text              = $Sonuc[3]
    $isaretMetni.Foreground        = "#2E5A2E"
    $isaretMetni.FontSize          = 10
    $isaretMetni.FontFamily        = "Consolas"
    $isaretMetni.TextTrimming      = "CharacterEllipsis"
    $isaretMetni.VerticalAlignment = "Center"
    $isaretMetni.ToolTip           = $Sonuc[3]

    [System.Windows.Controls.Grid]::SetColumn($classMetni,  0)
    [System.Windows.Controls.Grid]::SetColumn($tipMetni,    1)
    [System.Windows.Controls.Grid]::SetColumn($riskPanel,   2)
    [System.Windows.Controls.Grid]::SetColumn($isaretMetni, 3)

    $ic.Children.Add($classMetni)  | Out-Null
    $ic.Children.Add($tipMetni)    | Out-Null
    $ic.Children.Add($riskPanel)   | Out-Null
    $ic.Children.Add($isaretMetni) | Out-Null

    $kart.Child = $ic
    return $kart
}

function Sonuclari-Goster {
    param($Sonuclar)

    $sonucPanel.Children.Clear()
    $index = 0
    foreach ($s in $Sonuclar) {
        $satir = Yeni-SonucSatiri -Sonuc $s -Index $index
        $sonucPanel.Children.Add($satir) | Out-Null
        $index++
    }
    $sayacMetni.Text   = "$index sonuc"
    $altMetni.Text     = "Tarama tamamlandi — $index suphe tespit edildi"
    $altMetni.Foreground = "#39D439"
}

$diskScanButon.Add_Click({
    $diskScanButon.IsEnabled  = $false
    $dosyaScanButon.IsEnabled = $false
    $sonucPanel.Children.Clear()
    $sayacMetni.Text          = ""
    $altMetni.Text            = "Diskler taranıyor..."
    $altMetni.Foreground      = "#39D439"

    $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

    $tumSonuclar = [System.Collections.Generic.List[string[]]]::new()

    $diskler = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady -and ($_.DriveType -eq "Fixed" -or $_.DriveType -eq "Removable") }

    foreach ($disk in $diskler) {
        try {
            $altMetni.Text = "Taraniyor: $($disk.RootDirectory.FullName)"
            $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

            $jarDosyalar = Get-ChildItem -Path $disk.RootDirectory.FullName -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue

            foreach ($jar in $jarDosyalar) {
                $altMetni.Text = "Analiz ediliyor: $($jar.Name)"
                $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

                try {
                    $sonuclar = [JarAnalyzer]::AnalizeJar($jar.FullName)
                    foreach ($s in $sonuclar) {
                        $s[0] = "[$($jar.Name)] " + $s[0]
                        $tumSonuclar.Add($s)
                    }
                } catch {}
            }
        } catch {}
    }

    Sonuclari-Goster -Sonuclar $tumSonuclar
    $diskScanButon.IsEnabled  = $true
    $dosyaScanButon.IsEnabled = $true
})

$dosyaScanButon.Add_Click({
    $dialog = New-Object Microsoft.Win32.OpenFileDialog
    $dialog.Title  = "JAR Dosyası Seç"
    $dialog.Filter = "JAR Dosyaları (*.jar)|*.jar"
    $dialog.Multiselect = $false

    if ($dialog.ShowDialog() -eq $true) {
        $diskScanButon.IsEnabled  = $false
        $dosyaScanButon.IsEnabled = $false
        $sonucPanel.Children.Clear()
        $altMetni.Text       = "Analiz ediliyor: $([System.IO.Path]::GetFileName($dialog.FileName))"
        $altMetni.Foreground = "#39D439"

        $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

        try {
            $sonuclar = [JarAnalyzer]::AnalizeJar($dialog.FileName)
            Sonuclari-Goster -Sonuclar $sonuclar
        } catch {
            $altMetni.Text       = "Hata: $($_.Exception.Message)"
            $altMetni.Foreground = "#FF4444"
        }

        $diskScanButon.IsEnabled  = $true
        $dosyaScanButon.IsEnabled = $true
    }
})

$temizleButon.Add_Click({
    $sonucPanel.Children.Clear()
    $sayacMetni.Text     = ""
    $altMetni.Text       = "Hazir — Tara butonuna basin"
    $altMetni.Foreground = "#1A4A1A"
})

$pencere.ShowDialog() | Out-Null
