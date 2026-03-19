Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

Add-Type @"
using System;
using System.IO;
using System.IO.Compression;
using System.Collections.Generic;
using System.Text;

public class JarSonuc {
    public string JarYolu    = "";
    public string JarAdi     = "";
    public string ClassAdi   = "";
    public string Tespit     = "";
    public string Risk       = "GUV";
    public string Isaretler  = "";
    public long   Boyut      = 0;
}

public static class Analizci {
    static string[] INJ = new string[]{
        "Instrumentation","premain","agentmain","ClassFileTransformer",
        "VirtualAllocEx","WriteProcessMemory","CreateRemoteThread",
        "NtWriteVirtualMemory","LoadLibraryA","LoadLibraryW","GetProcAddress",
        "com/sun/jna","NativeLibrary","sun/misc/Unsafe","allocateMemory",
        "defineClass","defineAnonymousClass","java/lang/instrument"
    };
    static string[] HIL = new string[]{
        "killaura","KillAura","aimbot","AimBot","scaffold","Scaffold",
        "bhop","BHop","autoclicker","AutoClicker","antiknockback","AntiKB",
        "velocity","Velocity","nofall","NoFall","triggerbot","TriggerBot",
        "wallhack","WallHack","xray","XRay","noclip","NoClip","blink","Blink",
        "fullbright","FullBright","nuker","Nuker","freecam","FreeCam",
        "criticals","Criticals","fastplace","FastPlace","liquidwalk",
        "EventBus","ModuleManager","HackClient","CheatClient","ClickGUI",
        "RotationUtils","MovementUtils","RenderUtils","HackModule"
    };
    static string[] LDR = new string[]{
        "5GFV7P3VIM5AK","readFully","DataInputStream","ByteArrayInputStream",
        "javax/crypto","AES/","SecretKeySpec","Cipher","IvParameterSpec"
    };
    static string[] OBF = new string[]{
        "ClassLoader","loadClass","findLoadedClass","setAccessible",
        "getDeclaredMethod","MethodHandles","LambdaMetafactory"
    };

    public static List<JarSonuc> Analiz(string yol) {
        var liste = new List<JarSonuc>();
        try {
            var fi  = new FileInfo(yol);
            long boy = fi.Exists ? fi.Length : 0;
            string ad = fi.Name;

            using (var zip = ZipFile.OpenRead(yol)) {
                bool agent = false;
                int topCls = 0, tekCls = 0;

                foreach (var e in zip.Entries) {
                    if (e.FullName.EndsWith(".class")) {
                        topCls++;
                        if (Path.GetFileNameWithoutExtension(e.Name).Length <= 2) tekCls++;
                    }
                    if (e.FullName == "META-INF/MANIFEST.MF") {
                        try {
                            using (var sr = new StreamReader(e.Open())) {
                                string m = sr.ReadToEnd();
                                if (m.Contains("Premain-Class") || m.Contains("Agent-Class") ||
                                    m.Contains("Can-Redefine-Classes") || m.Contains("Can-Retransform-Classes"))
                                    agent = true;
                            }
                        } catch {}
                    }
                }

                if (agent)
                    liste.Add(new JarSonuc { JarYolu=yol,JarAdi=ad,ClassAdi="MANIFEST.MF",
                        Tespit="JAVA AGENT",Risk="HIL",
                        Isaretler="Premain-Class / Agent-Class",Boyut=boy });

                if (topCls > 3 && tekCls > 0 && (double)tekCls/topCls > 0.25)
                    liste.Add(new JarSonuc { JarYolu=yol,JarAdi=ad,ClassAdi="[GENEL]",
                        Tespit="OBFUSCATED JAR",Risk="ORT",
                        Isaretler=string.Format("Tek harfli class: {0}/{1}",tekCls,topCls),Boyut=boy });

                foreach (var e in zip.Entries) {
                    if (!e.FullName.EndsWith(".class")) continue;
                    try {
                        byte[] buf;
                        using (var s = e.Open())
                        using (var ms = new MemoryStream()) { s.CopyTo(ms); buf = ms.ToArray(); }
                        string ic = Encoding.Latin1.GetString(buf);

                        var inj = new List<string>();
                        var hil = new List<string>();
                        var ldr = new List<string>();
                        var obf = new List<string>();

                        foreach (var x in INJ) if (ic.Contains(x)) inj.Add(x);
                        foreach (var x in HIL) if (ic.Contains(x)) hil.Add(x);
                        foreach (var x in LDR) if (ic.Contains(x)) ldr.Add(x);
                        foreach (var x in OBF) if (ic.Contains(x)) obf.Add(x);

                        if (inj.Count==0&&hil.Count==0&&ldr.Count==0&&obf.Count==0) continue;

                        string tip, risk;
                        var tum = new List<string>();

                        if      (inj.Count>0&&hil.Count>0) { tip="INJECT+HILE"; risk="HIL"; tum.AddRange(inj); tum.AddRange(hil); }
                        else if (inj.Count>0&&ldr.Count>0) { tip="INJECT+LOADER"; risk="HIL"; tum.AddRange(inj); tum.AddRange(ldr); }
                        else if (inj.Count>0)               { tip="INJECT"; risk="HIL"; tum.AddRange(inj); }
                        else if (hil.Count>0)               { tip="HILE MODULU"; risk="HIL"; tum.AddRange(hil); }
                        else if (ldr.Count>0&&obf.Count>0) { tip="ENCRYPTED LOADER"; risk="ORT"; tum.AddRange(ldr); tum.AddRange(obf); }
                        else if (ldr.Count>0)               { tip="LOADER"; risk="ORT"; tum.AddRange(ldr); }
                        else                                { tip="REFLECTION"; risk="ORT"; tum.AddRange(obf); }

                        int mx = Math.Min(5,tum.Count);
                        string isa = string.Join(", ",tum.GetRange(0,mx));
                        if (tum.Count>mx) isa += " +"+(tum.Count-mx)+" daha";

                        liste.Add(new JarSonuc { JarYolu=yol,JarAdi=ad,ClassAdi=e.FullName,
                            Tespit=tip,Risk=risk,Isaretler=isa,Boyut=boy });
                    } catch {}
                }

                if (liste.Count==0)
                    liste.Add(new JarSonuc { JarYolu=yol,JarAdi=ad,ClassAdi="[TEMIZ]",
                        Tespit="Suphe bulunamadi",Risk="GUV",
                        Isaretler="Hile isaretcisi yok",Boyut=boy });
            }
        } catch (Exception ex) {
            liste.Add(new JarSonuc { JarYolu=yol,JarAdi=Path.GetFileName(yol),
                ClassAdi="HATA",Tespit="Okunamadi",Risk="GUV",
                Isaretler=ex.Message.Length>60?ex.Message.Substring(0,60):ex.Message,Boyut=0 });
        }
        return liste;
    }
}
"@ -ReferencedAssemblies System.IO.Compression,System.IO.Compression.FileSystem

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Obfuscated Shower"
    Width="1100" Height="720"
    MinWidth="800" MinHeight="500"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    ResizeMode="CanResizeWithGrip"
    Background="#050F05"
    FontFamily="Segoe UI">
    <Window.Resources>
        <Style x:Key="TB" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#3A6A3A"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Width" Value="42"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#0D1F0D"/>
                                <Setter Property="Foreground" Value="#39D439"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="KB" TargetType="Button">
            <Setter Property="Background" Value="Transparent"/>
            <Setter Property="Foreground" Value="#3A6A3A"/>
            <Setter Property="FontSize" Value="15"/>
            <Setter Property="Width" Value="42"/>
            <Setter Property="Height" Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#3A0A0A"/>
                                <Setter Property="Foreground" Value="#FF5555"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="AB" TargetType="Button">
            <Setter Property="Background" Value="#1A6B1A"/>
            <Setter Property="Foreground" Value="#C8F0C8"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="20,0"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
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
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="bg" Property="Background" Value="#1A2A1A"/>
                                <Setter Property="Foreground" Value="#3A5A3A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style x:Key="IB" TargetType="Button">
            <Setter Property="Background" Value="#0D1A0D"/>
            <Setter Property="Foreground" Value="#4A7A4A"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="16,0"/>
            <Setter Property="Height" Value="34"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#1A3A1A"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#142A14"/>
                                <Setter TargetName="bg" Property="BorderBrush" Value="#2A5A2A"/>
                                <Setter Property="Foreground" Value="#6AAA6A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="6"/>
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
            <RowDefinition Height="68"/>
            <RowDefinition Height="48"/>
            <RowDefinition Height="28"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="36"/>
        </Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" x:Name="titleBar">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center" Margin="14,0">
                    <TextBlock Text="Obfuscated Shower" Foreground="#2A5A2A" FontSize="12" VerticalAlignment="Center"/>
                    <TextBlock Text="  —  JAR Hile Analiz Araci" Foreground="#1A3A1A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                    <Button x:Name="btnMin"   Style="{StaticResource TB}" Content="&#x2212;"/>
                    <Button x:Name="btnMax"   Style="{StaticResource TB}" Content="&#x25A1;"/>
                    <Button x:Name="btnClose" Style="{StaticResource KB}" Content="&#x2715;"/>
                </StackPanel>
            </Grid>
        </Border>
        <Border Grid.Row="1" Background="#080F08" BorderBrush="#0F2A0F" BorderThickness="0,0,0,1" Padding="24,0">
            <StackPanel VerticalAlignment="Center">
                <TextBlock Text="Obfuscated Shower" Foreground="#39D439" FontSize="22" FontWeight="Bold"/>
                <TextBlock Text="by  X E I N N" Foreground="#1A5A1A" FontSize="12" FontStyle="Italic" Margin="2,4,0,0"/>
            </StackPanel>
        </Border>
        <Border Grid.Row="2" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" Padding="18,0">
            <Grid>
                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <Button x:Name="btnDisk"    Content="Tum Diskleri Tara" Style="{StaticResource AB}" Margin="0,0,8,0"/>
                    <Button x:Name="btnSec"     Content="JAR Dosyasi Sec"   Style="{StaticResource IB}" Margin="0,0,8,0"/>
                    <Button x:Name="btnTemizle" Content="Temizle"            Style="{StaticResource IB}"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <TextBlock x:Name="txtSayac"    Foreground="#2A5A2A" FontSize="11" VerticalAlignment="Center" Margin="0,0,20,0"/>
                    <TextBlock x:Name="txtKullanici" Foreground="#1A3A1A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
            </Grid>
        </Border>
        <Border Grid.Row="3" Background="#080F08" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" Padding="14,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="170"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="170"/>
                    <ColumnDefinition Width="80"/>
                    <ColumnDefinition Width="90"/>
                    <ColumnDefinition Width="200"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="JAR Dosyasi"  Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center" Margin="4,0"/>
                <TextBlock Grid.Column="1" Text="Class"        Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="2" Text="Tespit"       Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="3" Text="Boyut"        Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="4" Text="Risk"         Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="5" Text="Isaretler"    Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
            </Grid>
        </Border>
        <ScrollViewer Grid.Row="4" x:Name="sv" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Background="#050F05" Padding="0,2,6,2">
            <StackPanel x:Name="sonucPanel"/>
        </ScrollViewer>
        <Border Grid.Row="5" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,1,0,0" Padding="18,0">
            <Grid>
                <TextBlock x:Name="txtAlt"      Foreground="#1A4A1A" FontSize="11" VerticalAlignment="Center" Text="Hazir — Tara butonuna basin"/>
                <TextBlock x:Name="txtProgress" Foreground="#2A6A2A" FontSize="11" VerticalAlignment="Center" HorizontalAlignment="Right" Margin="0,0,8,0"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader  = New-Object System.Xml.XmlNodeReader $xaml
$pencere = [Windows.Markup.XamlReader]::Load($reader)

$btnDisk     = $pencere.FindName("btnDisk")
$btnSec      = $pencere.FindName("btnSec")
$btnTemizle  = $pencere.FindName("btnTemizle")
$btnMin      = $pencere.FindName("btnMin")
$btnMax      = $pencere.FindName("btnMax")
$btnClose    = $pencere.FindName("btnClose")
$sonucPanel  = $pencere.FindName("sonucPanel")
$txtSayac    = $pencere.FindName("txtSayac")
$txtAlt      = $pencere.FindName("txtAlt")
$txtProgress = $pencere.FindName("txtProgress")
$txtKullanici = $pencere.FindName("txtKullanici")
$titleBar    = $pencere.FindName("titleBar")

$txtKullanici.Text = "Kullanici: $env:USERNAME"

$titleBar.Add_MouseLeftButtonDown({
    param($s,$e)
    if ($e.ClickCount -eq 2) {
        $pencere.WindowState = if ($pencere.WindowState -eq "Maximized") {"Normal"} else {"Maximized"}
    } else { $pencere.DragMove() }
})
$btnClose.Add_Click({ $pencere.Close() })
$btnMin.Add_Click({ $pencere.WindowState = "Minimized" })
$script:maxD = $false
$btnMax.Add_Click({
    if ($script:maxD) { $pencere.WindowState="Normal"; $btnMax.Content=[char]0x25A1; $script:maxD=$false }
    else { $pencere.WindowState="Maximized"; $btnMax.Content=[char]0x2750; $script:maxD=$true }
})

$script:dp = $pencere.Dispatcher

function BoyutFmt($b) {
    if ($b -ge 1GB) { "{0:N1} GB" -f ($b/1GB) }
    elseif ($b -ge 1MB) { "{0:N1} MB" -f ($b/1MB) }
    elseif ($b -ge 1KB) { "{0:N1} KB" -f ($b/1KB) }
    else { "$b B" }
}

function Satir($s, $idx) {
    $bg = if ($idx%2-eq 0) {"#080F08"} else {"#060D06"}
    $rm = switch ($s.Risk) {
        "HIL" {@{Fg="#FF5555";Bg="#2A0808";Bo="#7A1515";Lb="HILE"}}
        "ORT" {@{Fg="#FFD700";Bg="#2A1E00";Bo="#7A6000";Lb="ORTA"}}
        default {@{Fg="#4A9EFF";Bg="#08142A";Bo="#1A4A7A";Lb="GUVENLI"}}
    }
    $k = New-Object System.Windows.Controls.Border
    $k.Background = $bg; $k.BorderBrush="#0A1A0A"; $k.BorderThickness="0,0,0,1"
    $k.Padding="14,6"; $k.Cursor="Hand"; $k.Tag=$s.JarYolu
    $k.Add_MouseEnter({param($x,$e);$x.Background="#0D1F0D"})
    $k.Add_MouseLeave({param($x,$e);$x.Background=$bg})
    $k.Add_MouseDoubleClick({param($x,$e)
        try{Start-Process "explorer.exe" -ArgumentList "/select,`"$($x.Tag)`""}catch{}
    })

    $g = New-Object System.Windows.Controls.Grid
    foreach ($w in @("170","*","170","80","90","200")) {
        $c=New-Object System.Windows.Controls.ColumnDefinition; $c.Width=$w; $g.ColumnDefinitions.Add($c)
    }

    function T($txt,$fg,$fs=11,$ff="Segoe UI") {
        $t=New-Object System.Windows.Controls.TextBlock
        $t.Text=$txt; $t.Foreground=$fg; $t.FontSize=$fs; $t.FontFamily=$ff
        $t.VerticalAlignment="Center"; $t.TextTrimming="CharacterEllipsis"; $t.ToolTip=$txt
        return $t
    }

    $e0=T $s.JarAdi   "#8ACA8A" 11 "Consolas"
    $e1=T $s.ClassAdi "#3A7A3A" 10 "Consolas"
    $e2=T $s.Tespit   $rm.Fg    11 "Segoe UI"; $e2.FontWeight="SemiBold"
    $e3=T (BoyutFmt $s.Boyut) "#2E5A2E"
    $e5=T $s.Isaretler "#2A4A2A" 10 "Consolas"

    $rb=New-Object System.Windows.Controls.Border
    $rb.Background=$rm.Bg; $rb.BorderBrush=$rm.Bo; $rb.BorderThickness="1"
    $rb.CornerRadius="4"; $rb.Padding="8,2"; $rb.VerticalAlignment="Center"; $rb.HorizontalAlignment="Left"
    $rt=New-Object System.Windows.Controls.TextBlock
    $rt.Text=$rm.Lb; $rt.Foreground=$rm.Fg; $rt.FontSize=10; $rt.FontWeight="Bold"
    $rb.Child=$rt

    $el=@($e0,$e1,$e2,$e3,$rb,$e5)
    for ($i=0;$i -lt $el.Count;$i++) {
        [System.Windows.Controls.Grid]::SetColumn($el[$i],$i)
        $g.Children.Add($el[$i]) | Out-Null
    }
    $k.Child=$g
    return $k
}

function GosterSonuclar($liste) {
    $sonucPanel.Children.Clear()
    $hile=($liste|Where-Object{$_.Risk-eq"HIL"}).Count
    $orta=($liste|Where-Object{$_.Risk-eq"ORT"}).Count
    $guv =($liste|Where-Object{$_.Risk-eq"GUV"}).Count
    $sirali=$liste|Sort-Object{switch($_.Risk){"HIL"{0}"ORT"{1}default{2}}}
    $idx=0
    foreach ($s in $sirali) {
        $satir=Satir $s $idx
        $sonucPanel.Children.Add($satir) | Out-Null
        $idx++
    }
    $txtSayac.Text="$($liste.Count) sonuc  |  Hile: $hile  Orta: $orta  Guvenli: $guv"
    $txtAlt.Text="Tamamlandi — Cift tikla: JAR konumunu goster"
    $txtAlt.Foreground="#39D439"
    $txtProgress.Text=""
    $btnDisk.IsEnabled=$true
    $btnSec.IsEnabled=$true
}

function TaraAsync($jarListesi) {
    $btnDisk.IsEnabled=$false
    $btnSec.IsEnabled=$false
    $sonucPanel.Children.Clear()
    $txtSayac.Text=""
    $txtAlt.Text="Taranıyor..."
    $txtAlt.Foreground="#39D439"

    $dp       = $script:dp
    $pnl      = $sonucPanel
    $altTxt   = $txtAlt
    $proTxt   = $txtProgress
    $sayCTxt  = $txtSayac
    $bD       = $btnDisk
    $bS       = $btnSec

    $thread = New-Object System.Threading.Thread({
        $tumSonuclar = [System.Collections.Generic.List[object]]::new()
        $toplam = $jarListesi.Count
        $sayac  = 0

        foreach ($jar in $jarListesi) {
            $sayac++
            $jarAdi = [System.IO.Path]::GetFileName($jar)
            $sc = $sayac; $to = $toplam; $jn = $jarAdi

            $dp.Invoke([System.Action]{
                $proTxt.Text = "$sc / $to  —  $jn"
            }, [System.Windows.Threading.DispatcherPriority]::Normal)

            try {
                $sonuclar = [Analizci]::Analiz($jar)
                foreach ($s in $sonuclar) { $tumSonuclar.Add($s) }
            } catch {}
        }

        $tS = $tumSonuclar
        $dp.Invoke([System.Action]{
            GosterSonuclar $tS
        }, [System.Windows.Threading.DispatcherPriority]::Normal)
    })
    $thread.IsBackground = $true
    $thread.SetApartmentState([System.Threading.ApartmentState]::STA)
    $thread.Start()
}

$btnDisk.Add_Click({
    $txtAlt.Text="JAR dosyalari aranıyor..."
    $txtAlt.Foreground="#39D439"
    $txtProgress.Text="Diskler taranıyor..."

    $diskler = [System.IO.DriveInfo]::GetDrives() | Where-Object {
        $_.IsReady -and ($_.DriveType -eq "Fixed" -or $_.DriveType -eq "Removable")
    }
    $jarlar = [System.Collections.Generic.List[string]]::new()
    foreach ($disk in $diskler) {
        try {
            Get-ChildItem -Path $disk.RootDirectory.FullName -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue -Force |
                ForEach-Object { $jarlar.Add($_.FullName) }
        } catch {}
    }

    if ($jarlar.Count -eq 0) {
        $txtAlt.Text="Hicbir JAR dosyasi bulunamadi"
        $txtAlt.Foreground="#FFD700"
        return
    }
    $txtProgress.Text="$($jarlar.Count) JAR bulundu"
    TaraAsync $jarlar
})

$btnSec.Add_Click({
    $ofd = New-Object Microsoft.Win32.OpenFileDialog
    $ofd.Title       = "JAR Dosyasi Sec"
    $ofd.Filter      = "JAR Dosyalari (*.jar)|*.jar"
    $ofd.Multiselect = $true
    $ofd.InitialDirectory = [System.Environment]::GetFolderPath("UserProfile")

    if ($ofd.ShowDialog($pencere) -eq $true) {
        $jarlar = [System.Collections.Generic.List[string]]::new()
        foreach ($f in $ofd.FileNames) { $jarlar.Add($f) }
        TaraAsync $jarlar
    }
})

$btnTemizle.Add_Click({
    $sonucPanel.Children.Clear()
    $txtSayac.Text=""; $txtProgress.Text=""
    $txtAlt.Text="Hazir — Tara butonuna basin"
    $txtAlt.Foreground="#1A4A1A"
})

$pencere.ShowDialog() | Out-Null
