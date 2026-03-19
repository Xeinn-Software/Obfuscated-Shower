Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName Microsoft.Win32.OpenFileDialog -ErrorAction SilentlyContinue

Add-Type @"
using System;
using System.IO;
using System.IO.Compression;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

public class JarSonuc {
    public string JarYolu;
    public string JarAdi;
    public string ClassAdi;
    public string TespitTipi;
    public string Risk;
    public string Isaretler;
    public long   JarBoyut;
    public DateTime JarTarih;
}

public class JarAnalyzer {

    static readonly string[] INJECT_ISARETLERI = {
        "instrument", "Instrumentation", "premain", "agentmain",
        "java/lang/instrument", "ClassFileTransformer",
        "retransformClasses", "redefineClasses",
        "VirtualAllocEx", "WriteProcessMemory", "CreateRemoteThread",
        "ReadProcessMemory", "OpenProcess", "NtWriteVirtualMemory",
        "NtAllocateVirtualMemory", "RtlMoveMemory",
        "LoadLibraryA", "LoadLibraryW", "GetProcAddress",
        "com/sun/jna", "NativeLibrary", "com/sun/jna/Function",
        "com/sun/jna/Memory", "com/sun/jna/Pointer",
        "sun/misc/Unsafe", "allocateMemory", "putLong", "putInt",
        "defineClass", "defineAnonymousClass",
        "java/lang/reflect/Proxy", "InvocationHandler"
    };

    static readonly string[] HILE_ISARETLERI = {
        "killaura", "kill_aura", "KillAura",
        "aimbot", "AimBot", "aim_bot",
        "scaffold", "Scaffold",
        "bhop", "BHop", "bunnyHop",
        "autoclicker", "AutoClicker", "auto_clicker",
        "reach", "Reach",
        "velocity", "Velocity", "antiKnockback", "AntiKB",
        "nofall", "NoFall", "antifall",
        "triggerbot", "TriggerBot",
        "esp", "ESP", "wallhack", "WallHack",
        "xray", "XRay", "x_ray",
        "fly", "Fly", "flight",
        "speed", "Speed",
        "noclip", "NoClip",
        "blink", "Blink",
        "fullbright", "FullBright",
        "tracers", "Tracers",
        "radar", "Radar",
        "chest", "ChestESP",
        "criticals", "Criticals",
        "timer", "Timer",
        "freecam", "FreeCam",
        "nuker", "Nuker",
        "fastplace", "FastPlace",
        "fastbreak", "FastBreak",
        "phase", "Phase",
        "liquidwalk", "LiquidWalk",
        "antiafk", "AntiAFK",
        "EventBus", "ModuleManager", "HackClient",
        "CheatClient", "Cheat", "cheat",
        "HackModule", "CheatModule",
        "ClickGUI", "clickgui",
        "CommandManager", "FriendManager",
        "RotationUtils", "MathUtils",
        "PlayerUtils", "MovementUtils",
        "RenderUtils", "drawESP"
    };

    static readonly string[] OBF_ISARETLERI = {
        "ClassLoader", "loadClass", "findLoadedClass",
        "ByteArrayClassLoader", "URLClassLoader",
        "java/security/SecureClassLoader",
        "ProtectionDomain", "CodeSource",
        "ReflectionFactory", "getDeclaredMethod",
        "setAccessible", "invoke",
        "MethodHandles", "MethodHandle",
        "LambdaMetafactory"
    };

    static readonly string[] LOADER_ISARETLERI = {
        "5GFV7P3VIM5AK", "000",
        "/net/java/a", "/net/java/b", "/net/java/c",
        "readFully", "readUTF", "readInt",
        "DataInputStream", "ByteArrayInputStream",
        "ZipInputStream", "JarInputStream",
        "decrypt", "Decrypt", "deobf", "decode",
        "Base64", "javax/crypto", "AES", "DES",
        "SecretKeySpec", "Cipher", "IvParameterSpec"
    };

    public static List<JarSonuc> AnalizeJar(string jarYolu) {
        var sonuclar = new List<JarSonuc>();
        try {
            var dosyaBilgi = new FileInfo(jarYolu);
            long boyut   = dosyaBilgi.Length;
            DateTime tar = dosyaBilgi.CreationTime;
            string jarAdi = Path.GetFileName(jarYolu);

            using (var zip = ZipFile.OpenRead(jarYolu)) {
                int toplamClass  = 0;
                int tekHarfClass = 0;
                var classlar     = new List<string>();
                bool hasManifestAgent = false;

                foreach (var entry in zip.Entries) {
                    if (entry.FullName.EndsWith(".class")) {
                        toplamClass++;
                        string ad = Path.GetFileNameWithoutExtension(entry.Name);
                        if (ad.Length <= 2) tekHarfClass++;
                        classlar.Add(entry.FullName);
                    }
                    if (entry.FullName == "META-INF/MANIFEST.MF") {
                        try {
                            using (var sr = new StreamReader(entry.Open())) {
                                string manifest = sr.ReadToEnd();
                                if (manifest.Contains("Premain-Class") ||
                                    manifest.Contains("Agent-Class") ||
                                    manifest.Contains("Can-Redefine-Classes") ||
                                    manifest.Contains("Can-Retransform-Classes")) {
                                    hasManifestAgent = true;
                                }
                            }
                        } catch {}
                    }
                }

                if (hasManifestAgent) {
                    sonuclar.Add(new JarSonuc {
                        JarYolu   = jarYolu,
                        JarAdi    = jarAdi,
                        ClassAdi  = "META-INF/MANIFEST.MF",
                        TespitTipi = "JAVA AGENT (MANIFEST)",
                        Risk      = "HIL",
                        Isaretler = "Premain-Class veya Agent-Class tespit edildi",
                        JarBoyut  = boyut,
                        JarTarih  = tar
                    });
                }

                double tekHarfOran = toplamClass > 0 ? (double)tekHarfClass / toplamClass : 0;
                if (tekHarfOran > 0.25 && toplamClass > 3) {
                    sonuclar.Add(new JarSonuc {
                        JarYolu    = jarYolu,
                        JarAdi     = jarAdi,
                        ClassAdi   = "[GENEL]",
                        TespitTipi = "OBFUSCATED JAR",
                        Risk       = "ORT",
                        Isaretler  = string.Format("Tek/cift harfli class orani: {0}/{1} (%{2:F0})",
                                        tekHarfClass, toplamClass, tekHarfOran * 100),
                        JarBoyut   = boyut,
                        JarTarih   = tar
                    });
                }

                foreach (var entry in zip.Entries) {
                    if (!entry.FullName.EndsWith(".class")) continue;
                    try {
                        byte[] bytes;
                        using (var s = entry.Open())
                        using (var ms = new MemoryStream()) {
                            s.CopyTo(ms);
                            bytes = ms.ToArray();
                        }
                        string icerik = Encoding.Latin1.GetString(bytes);

                        var injectBulunan  = new List<string>();
                        var hileBulunan    = new List<string>();
                        var obfBulunan     = new List<string>();
                        var loaderBulunan  = new List<string>();

                        foreach (var i in INJECT_ISARETLERI)
                            if (icerik.Contains(i)) injectBulunan.Add(i);
                        foreach (var i in HILE_ISARETLERI)
                            if (icerik.Contains(i)) hileBulunan.Add(i);
                        foreach (var i in OBF_ISARETLERI)
                            if (icerik.Contains(i)) obfBulunan.Add(i);
                        foreach (var i in LOADER_ISARETLERI)
                            if (icerik.Contains(i)) loaderBulunan.Add(i);

                        if (injectBulunan.Count == 0 && hileBulunan.Count == 0 &&
                            obfBulunan.Count == 0    && loaderBulunan.Count == 0) continue;

                        string tip  = "";
                        string risk = "GUV";
                        var allBulunan = new List<string>();

                        if (injectBulunan.Count > 0 && hileBulunan.Count > 0) {
                            tip  = "INJECT + HILE MODULU";
                            risk = "HIL";
                            allBulunan.AddRange(injectBulunan);
                            allBulunan.AddRange(hileBulunan);
                        } else if (injectBulunan.Count > 0 && loaderBulunan.Count > 0) {
                            tip  = "INJECT + ENCRYPTED LOADER";
                            risk = "HIL";
                            allBulunan.AddRange(injectBulunan);
                            allBulunan.AddRange(loaderBulunan);
                        } else if (injectBulunan.Count > 0) {
                            tip  = "INJECT";
                            risk = "HIL";
                            allBulunan.AddRange(injectBulunan);
                        } else if (hileBulunan.Count > 0) {
                            tip  = "HILE MODULU";
                            risk = "HIL";
                            allBulunan.AddRange(hileBulunan);
                        } else if (loaderBulunan.Count > 0 && obfBulunan.Count > 0) {
                            tip  = "ENCRYPTED OBFUSCATED LOADER";
                            risk = "ORT";
                            allBulunan.AddRange(loaderBulunan);
                            allBulunan.AddRange(obfBulunan);
                        } else if (loaderBulunan.Count > 0) {
                            tip  = "ENCRYPTED LOADER";
                            risk = "ORT";
                            allBulunan.AddRange(loaderBulunan);
                        } else if (obfBulunan.Count > 0) {
                            tip  = "REFLECTION / LOADER";
                            risk = "ORT";
                            allBulunan.AddRange(obfBulunan);
                        }

                        if (tip == "") continue;

                        int max = Math.Min(5, allBulunan.Count);
                        string isaretStr = string.Join(", ", allBulunan.GetRange(0, max));
                        if (allBulunan.Count > max) isaretStr += " +" + (allBulunan.Count - max) + " daha";

                        sonuclar.Add(new JarSonuc {
                            JarYolu    = jarYolu,
                            JarAdi     = jarAdi,
                            ClassAdi   = entry.FullName,
                            TespitTipi = tip,
                            Risk       = risk,
                            Isaretler  = isaretStr,
                            JarBoyut   = boyut,
                            JarTarih   = tar
                        });
                    } catch {}
                }
            }

            if (sonuclar.Count == 0) {
                sonuclar.Add(new JarSonuc {
                    JarYolu    = jarYolu,
                    JarAdi     = jarAdi,
                    ClassAdi   = "[TEMIZ]",
                    TespitTipi = "Suphe bulunamadi",
                    Risk       = "GUV",
                    Isaretler  = "Hile isaretcisi tespit edilmedi",
                    JarBoyut   = boyut,
                    JarTarih   = tar
                });
            }
        } catch (Exception ex) {
            sonuclar.Add(new JarSonuc {
                JarYolu    = jarYolu,
                JarAdi     = Path.GetFileName(jarYolu),
                ClassAdi   = "HATA",
                TespitTipi = "Okunamadi",
                Risk       = "GUV",
                Isaretler  = ex.Message,
                JarBoyut   = 0,
                JarTarih   = DateTime.MinValue
            });
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
    Width="1100" Height="720"
    MinWidth="800" MinHeight="500"
    WindowStartupLocation="CenterScreen"
    WindowStyle="None"
    ResizeMode="CanResizeWithGrip"
    Background="#050F05"
    FontFamily="Segoe UI">

    <Window.Resources>

        <Style x:Key="TitleButon" TargetType="Button">
            <Setter Property="Background"      Value="Transparent"/>
            <Setter Property="Foreground"      Value="#3A6A3A"/>
            <Setter Property="FontSize"        Value="15"/>
            <Setter Property="Width"           Value="42"/>
            <Setter Property="Height"          Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor"          Value="Hand"/>
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
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#050F05"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="KapatButon" TargetType="Button">
            <Setter Property="Background"      Value="Transparent"/>
            <Setter Property="Foreground"      Value="#3A6A3A"/>
            <Setter Property="FontSize"        Value="15"/>
            <Setter Property="Width"           Value="42"/>
            <Setter Property="Height"          Value="36"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor"          Value="Hand"/>
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
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#1A0505"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="AnaButon" TargetType="Button">
            <Setter Property="Background"      Value="#1A6B1A"/>
            <Setter Property="Foreground"      Value="#C8F0C8"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="FontWeight"      Value="SemiBold"/>
            <Setter Property="Padding"         Value="20,0"/>
            <Setter Property="Height"          Value="34"/>
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
                                <Setter Property="Foreground" Value="#3A5A3A"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="IkincilButon" TargetType="Button">
            <Setter Property="Background"      Value="#0D1A0D"/>
            <Setter Property="Foreground"      Value="#4A7A4A"/>
            <Setter Property="FontSize"        Value="12"/>
            <Setter Property="Padding"         Value="16,0"/>
            <Setter Property="Height"          Value="34"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush"     Value="#1A3A1A"/>
            <Setter Property="Cursor"          Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="bg" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="bg" Property="Background"  Value="#142A14"/>
                                <Setter TargetName="bg" Property="BorderBrush" Value="#2A5A2A"/>
                                <Setter Property="Foreground" Value="#6AAA6A"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="bg" Property="Background" Value="#080F08"/>
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
                    <Button x:Name="kucultButon"  Style="{StaticResource TitleButon}" Content="&#x2212;" ToolTip="Kucult"/>
                    <Button x:Name="tamEkranButon" Style="{StaticResource TitleButon}" Content="&#x25A1;" ToolTip="Tam Ekran"/>
                    <Button x:Name="kapatButon"    Style="{StaticResource KapatButon}" Content="&#x2715;" ToolTip="Kapat"/>
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
                    <Button x:Name="diskScanButon"  Content="Tum Diskleri Tara"   Style="{StaticResource AnaButon}"     Margin="0,0,8,0"/>
                    <Button x:Name="dosyaSecButon"  Content="JAR Dosyasi Sec"     Style="{StaticResource IkincilButon}" Margin="0,0,8,0"/>
                    <Button x:Name="temizleButon"   Content="Temizle"             Style="{StaticResource IkincilButon}"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <TextBlock x:Name="sayacMetni"    Foreground="#2A5A2A" FontSize="11" VerticalAlignment="Center" Margin="0,0,20,0"/>
                    <TextBlock x:Name="kullaniciBilgi" Foreground="#1A3A1A" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Row="3" Background="#080F08" BorderBrush="#0A1A0A" BorderThickness="0,0,0,1" Padding="14,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="180"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="200"/>
                    <ColumnDefinition Width="90"/>
                    <ColumnDefinition Width="80"/>
                    <ColumnDefinition Width="240"/>
                </Grid.ColumnDefinitions>
                <TextBlock Grid.Column="0" Text="JAR Dosyasi"      Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center" Margin="4,0,0,0"/>
                <TextBlock Grid.Column="1" Text="Class"            Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="2" Text="Tespit"           Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="3" Text="Boyut"            Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="4" Text="Risk"             Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="5" Text="Isaretler"        Foreground="#1A6A1A" FontSize="11" FontWeight="SemiBold" VerticalAlignment="Center"/>
            </Grid>
        </Border>

        <ScrollViewer Grid.Row="4"
                      VerticalScrollBarVisibility="Auto"
                      HorizontalScrollBarVisibility="Disabled"
                      Background="#050F05"
                      Padding="0,2,6,2">
            <StackPanel x:Name="sonucPanel"/>
        </ScrollViewer>

        <Border Grid.Row="5" Background="#060D06" BorderBrush="#0A1A0A" BorderThickness="0,1,0,0" Padding="18,0">
            <Grid>
                <TextBlock x:Name="altMetni" Text="Hazir — Tara butonuna basin"
                           Foreground="#1A4A1A" FontSize="11" VerticalAlignment="Center"/>
                <TextBlock x:Name="progressMetni" Foreground="#2A5A2A" FontSize="11"
                           VerticalAlignment="Center" HorizontalAlignment="Right" Margin="0,0,8,0"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader  = New-Object System.Xml.XmlNodeReader $xaml
$pencere = [Windows.Markup.XamlReader]::Load($reader)

$diskScanButon  = $pencere.FindName("diskScanButon")
$dosyaSecButon  = $pencere.FindName("dosyaSecButon")
$temizleButon   = $pencere.FindName("temizleButon")
$sonucPanel     = $pencere.FindName("sonucPanel")
$sayacMetni     = $pencere.FindName("sayacMetni")
$altMetni       = $pencere.FindName("altMetni")
$progressMetni  = $pencere.FindName("progressMetni")
$kullaniciBilgi = $pencere.FindName("kullaniciBilgi")
$titleBar       = $pencere.FindName("titleBar")
$kapatButon     = $pencere.FindName("kapatButon")
$kucultButon    = $pencere.FindName("kucultButon")
$tamEkranButon  = $pencere.FindName("tamEkranButon")

$kullaniciBilgi.Text = "Kullanici: $env:USERNAME"

$titleBar.Add_MouseLeftButtonDown({ param($s,$e); if ($e.ClickCount -eq 2) {
    if ($pencere.WindowState -eq "Maximized") { $pencere.WindowState = "Normal" }
    else { $pencere.WindowState = "Maximized" }
} else { $pencere.DragMove() } })

$kapatButon.Add_Click({ $pencere.Close() })
$kucultButon.Add_Click({ $pencere.WindowState = [System.Windows.WindowState]::Minimized })

$script:tamEkran = $false
$tamEkranButon.Add_Click({
    if ($script:tamEkran) {
        $pencere.WindowState   = [System.Windows.WindowState]::Normal
        $tamEkranButon.Content = [char]0x25A1
        $script:tamEkran       = $false
    } else {
        $pencere.WindowState   = [System.Windows.WindowState]::Maximized
        $tamEkranButon.Content = [char]0x2750
        $script:tamEkran       = $true
    }
})

function Boyut-Formatla {
    param($b)
    if    ($b -ge 1GB) { "{0:N1} GB" -f ($b/1GB) }
    elseif ($b -ge 1MB) { "{0:N1} MB" -f ($b/1MB) }
    elseif ($b -ge 1KB) { "{0:N1} KB" -f ($b/1KB) }
    else                { "$b B" }
}

function Yeni-SonucSatiri {
    param($S, $Index)

    $bgRenk = if ($Index % 2 -eq 0) { "#080F08" } else { "#060D06" }

    $renkler = switch ($S.Risk) {
        "HIL" { @{ Fg="#FF5555"; Bg="#2A0808"; Bo="#7A1515"; Label="HILE" } }
        "ORT" { @{ Fg="#FFD700"; Bg="#2A1E00"; Bo="#7A6000"; Label="ORTA" } }
        "GUV" { @{ Fg="#4A9EFF"; Bg="#08142A"; Bo="#1A4A7A"; Label="GUVENLI" } }
        default { @{ Fg="#888888"; Bg="#1A1A1A"; Bo="#333333"; Label="?" } }
    }

    $kart = New-Object System.Windows.Controls.Border
    $kart.Background      = $bgRenk
    $kart.BorderBrush     = "#0A1A0A"
    $kart.BorderThickness = "0,0,0,1"
    $kart.Padding         = "14,7"
    $kart.Cursor          = "Hand"
    $kart.Tag             = $S.JarYolu

    $kart.Add_MouseEnter({ param($s,$e); $s.Background = "#0D1F0D" })
    $kart.Add_MouseLeave({ param($s,$e); $s.Background = $bgRenk  })
    $kart.Add_MouseDoubleClick({
        param($s,$e)
        try { Start-Process "explorer.exe" -ArgumentList "/select,`"$($s.Tag)`"" } catch {}
    })

    $ic = New-Object System.Windows.Controls.Grid
    foreach ($w in @("180","*","200","90","80","240")) {
        $col = New-Object System.Windows.Controls.ColumnDefinition
        $col.Width = $w
        $ic.ColumnDefinitions.Add($col)
    }

    function Metin {
        param($t, $fg, $fs=11, $ff="Segoe UI", $fw="Normal", $trim=$true)
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text              = $t
        $tb.Foreground        = $fg
        $tb.FontSize          = $fs
        $tb.FontFamily        = $ff
        $tb.FontWeight        = $fw
        $tb.VerticalAlignment = "Center"
        $tb.ToolTip           = $t
        if ($trim) { $tb.TextTrimming = "CharacterEllipsis" }
        return $tb
    }

    $jarM    = Metin $S.JarAdi    "#8ACA8A" 11 "Consolas"
    $classM  = Metin $S.ClassAdi  "#3A6A3A" 10 "Consolas"
    $tespitM = Metin $S.TespitTipi $renkler.Fg 11 "Segoe UI" "SemiBold"
    $boyutM  = Metin (Boyut-Formatla $S.JarBoyut) "#2E5A2E"
    $isaretM = Metin $S.Isaretler "#2A4A2A" 10 "Consolas"

    $riskPanel = New-Object System.Windows.Controls.Border
    $riskPanel.Background         = $renkler.Bg
    $riskPanel.BorderBrush        = $renkler.Bo
    $riskPanel.BorderThickness    = "1"
    $riskPanel.CornerRadius       = "4"
    $riskPanel.Padding            = "8,2"
    $riskPanel.VerticalAlignment  = "Center"
    $riskPanel.HorizontalAlignment = "Left"
    $riskTb = New-Object System.Windows.Controls.TextBlock
    $riskTb.Text       = $renkler.Label
    $riskTb.Foreground = $renkler.Fg
    $riskTb.FontSize   = 10
    $riskTb.FontWeight = "Bold"
    $riskPanel.Child   = $riskTb

    $cols = @($jarM, $classM, $tespitM, $boyutM, $riskPanel, $isaretM)
    for ($i = 0; $i -lt $cols.Count; $i++) {
        [System.Windows.Controls.Grid]::SetColumn($cols[$i], $i)
        $ic.Children.Add($cols[$i]) | Out-Null
    }

    $kart.Child = $ic
    return $kart
}

function Sonuclari-Goster {
    param($Liste)
    $sonucPanel.Children.Clear()
    $hile = ($Liste | Where-Object { $_.Risk -eq "HIL" }).Count
    $orta = ($Liste | Where-Object { $_.Risk -eq "ORT" }).Count
    $guv  = ($Liste | Where-Object { $_.Risk -eq "GUV" }).Count

    $sirali = $Liste | Sort-Object { switch($_.Risk){"HIL"{0}"ORT"{1}"GUV"{2}default{3}} }

    $idx = 0
    foreach ($s in $sirali) {
        $satir = Yeni-SonucSatiri -S $s -Index $idx
        $sonucPanel.Children.Add($satir) | Out-Null
        $idx++
    }

    $sayacMetni.Text     = "$($Liste.Count) sonuc  |  Hile: $hile  Orta: $orta  Guvenli: $guv"
    $altMetni.Text       = "Tamamlandi — Cift tikla: JAR konumunu goster"
    $altMetni.Foreground = "#39D439"
    $progressMetni.Text  = ""
}

function Diskleri-Tara {
    $diskScanButon.IsEnabled = $false
    $dosyaSecButon.IsEnabled = $false
    $sonucPanel.Children.Clear()
    $sayacMetni.Text     = ""
    $altMetni.Text       = "Diskler taranıyor..."
    $altMetni.Foreground = "#39D439"
    $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

    $tumSonuclar = [System.Collections.Generic.List[object]]::new()

    $diskler = [System.IO.DriveInfo]::GetDrives() | Where-Object {
        $_.IsReady -and ($_.DriveType -eq "Fixed" -or $_.DriveType -eq "Removable")
    }

    foreach ($disk in $diskler) {
        try {
            $progressMetni.Text = "Disk: $($disk.Name)"
            $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

            $jarlar = Get-ChildItem -Path $disk.RootDirectory.FullName -Recurse -Filter "*.jar" -ErrorAction SilentlyContinue -Force

            $toplam = @($jarlar).Count
            $sayac  = 0

            foreach ($jar in $jarlar) {
                $sayac++
                $progressMetni.Text = "$sayac / $toplam  |  $($jar.Name)"
                $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

                try {
                    $sonuclar = [JarAnalyzer]::AnalizeJar($jar.FullName)
                    foreach ($s in $sonuclar) { $tumSonuclar.Add($s) }
                } catch {}
            }
        } catch {}
    }

    Sonuclari-Goster -Liste $tumSonuclar
    $diskScanButon.IsEnabled = $true
    $dosyaSecButon.IsEnabled = $true
}

$diskScanButon.Add_Click({ Diskleri-Tara })

$dosyaSecButon.Add_Click({
    $dialog = New-Object Microsoft.Win32.OpenFileDialog
    $dialog.Title       = "JAR Dosyasi Sec"
    $dialog.Filter      = "JAR Dosyalari (*.jar)|*.jar"
    $dialog.Multiselect = $true
    $dialog.InitialDirectory = [System.Environment]::GetFolderPath("UserProfile")

    if ($dialog.ShowDialog($pencere) -eq $true) {
        $diskScanButon.IsEnabled = $false
        $dosyaSecButon.IsEnabled = $false
        $sonucPanel.Children.Clear()
        $altMetni.Text       = "Analiz ediliyor..."
        $altMetni.Foreground = "#39D439"
        $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)

        $tumSonuclar = [System.Collections.Generic.List[object]]::new()
        foreach ($f in $dialog.FileNames) {
            $progressMetni.Text = $([System.IO.Path]::GetFileName($f))
            $pencere.Dispatcher.Invoke([System.Action]{}, [System.Windows.Threading.DispatcherPriority]::Background)
            try {
                $sonuclar = [JarAnalyzer]::AnalizeJar($f)
                foreach ($s in $sonuclar) { $tumSonuclar.Add($s) }
            } catch {}
        }

        Sonuclari-Goster -Liste $tumSonuclar
        $diskScanButon.IsEnabled = $true
        $dosyaSecButon.IsEnabled = $true
    }
})

$temizleButon.Add_Click({
    $sonucPanel.Children.Clear()
    $sayacMetni.Text     = ""
    $progressMetni.Text  = ""
    $altMetni.Text       = "Hazir — Tara butonuna basin"
    $altMetni.Foreground = "#1A4A1A"
})

$pencere.ShowDialog() | Out-Null
