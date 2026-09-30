<#
    Captain Toad: Treasure Tracker VR - session start script (Windows x64, PowerShell 5.1)

    Started by Start-VR.cmd. One VR session, then everything Cemu-side is put
    back. In order, it

      * finds Cemu.exe (asked once, remembered in cemu-path.txt beside this file),
      * uses the Cemu data folder that Cemu itself would use - the portable
        folder if one exists next to Cemu.exe, otherwise %APPDATA%\Cemu, so you
        never have to create a portable installation,
      * copies the graphic packs into that folder's graphicPacks directory,
      * backs up settings.xml, enables the packs, selects Vulkan with
        asynchronous shader compilation and GX2DrawDone synchronisation and
        switches VSync off,
      * starts Cemu with the VR layer enabled for that one process,
      * after you quit Cemu switches those packs off again (unless you asked
        otherwise) and restores the graphics settings.

    Start-VR.cmd starts in Diorama. X switches camera mode in gameplay.
    Only this release's packs are enabled for the session.

    Cemu settings and packs are stored in its data folder; launcher preferences
    are stored beside this script. No system-wide layer is installed.
#>

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$packs = @('CaptainToad_VR', 'CaptainToad_FPS')
# Captain Toad patch packs that must not run together with this release.
$otherPacks = @('CaptainToad_RenderFlow120', 'CaptainToad_YFirstPerson120', 'CaptainToad_StickWheel',
                'CaptainToad_Diag', 'CaptainToad_RawUnlock', 'CaptainToad_PoolProbe', 'CaptainToad_RenderProbe')
$defaultPreset = '120 FPS (60 Hz gameplay)'
$stereoPack = 'CaptainToad_VR'
$modeName = 'Diorama / Close / First Person (X)'
# Graphics settings the stereo render flow needs, restored after the session.
$graphicWanted = [ordered]@{ 'api' = '1'; 'GX2DrawdoneSync' = 'true'; 'AsyncCompile' = 'true'; 'VSync' = '0' }

function Say([string] $text) { Write-Host $text }

function Fail([string] $text) {
    Write-Host ''
    Write-Host ('Stopped: ' + $text)
    Write-Host ''
    exit 1
}

function EnsureNode($parent, [string] $name, $document) {
    $node = $parent.SelectSingleNode($name)
    if (-not $node) { $node = $parent.AppendChild($document.CreateElement($name)) }
    return $node
}

function IsOurEntry($entry) {
    $file = $entry.GetAttribute('filename')
    foreach ($pack in ($packs + $otherPacks)) {
        if ($file -match ([regex]::Escape($pack) + '[\\/]rules\.txt$')) { return $true }
    }
    return $false
}

Say ''
Say ('Captain Toad: Treasure Tracker VR - Alpha 1.11 - ' + $modeName)
Say '-----------------------------------------------'

# --- the package itself -----------------------------------------------------
$layer = Join-Path $root 'layer'
foreach ($needed in @((Join-Path $layer 'cemuvr_layer.dll'), (Join-Path $layer 'VK_LAYER_CEMUVR_core.json'))) {
    if (Test-Path $needed) { continue }
    $hint = ''
    if (Test-Path (Join-Path $root 'core')) {
        $hint = [Environment]::NewLine +
                '       This looks like the source folder. Use the installation ZIP instead:' +
                [Environment]::NewLine +
                '       it is the one that contains layer\cemuvr_layer.dll.'
    }
    Fail ('The package is incomplete, missing: ' + $needed + $hint)
}

# --- where is Cemu? ---------------------------------------------------------
$pathFile = Join-Path $root 'cemu-path.txt'
$cemuExe = $null
if (Test-Path $pathFile) {
    $remembered = (Get-Content $pathFile -Raw).Trim()
    if ($remembered -and (Test-Path $remembered)) { $cemuExe = $remembered }
}
if (-not $cemuExe) {
    foreach ($guess in @((Join-Path (Split-Path -Parent $root) 'Cemu.exe'), (Join-Path $root 'Cemu.exe'))) {
        if (Test-Path $guess) { $cemuExe = $guess; break }
    }
}
if (-not $cemuExe) {
    Say 'This folder is meant to sit in your Cemu folder, next to Cemu.exe.'
    Say 'It does not, so please point me at Cemu.exe once (a file dialog opens).'
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = New-Object System.Windows.Forms.OpenFileDialog
        $dialog.Title = 'Select Cemu.exe'
        $dialog.Filter = 'Cemu (Cemu.exe)|Cemu.exe|All files (*.*)|*.*'
        if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $cemuExe = $dialog.FileName }
    } catch {
        $cemuExe = (Read-Host 'Full path to Cemu.exe').Trim('"')
    }
}
if (-not $cemuExe -or -not (Test-Path $cemuExe)) { Fail 'No Cemu.exe selected.' }
Set-Content -Path $pathFile -Value $cemuExe -Encoding ASCII
$cemuDir = Split-Path -Parent $cemuExe

if (Get-Process -Name 'Cemu' -ErrorAction SilentlyContinue) {
    Fail 'Cemu is already running. Close it and start this file again.'
}

# --- the folder Cemu keeps its data in --------------------------------------
$portable = Join-Path $cemuDir 'portable'
if (Test-Path $portable) { $data = $portable } else { $data = Join-Path $env:APPDATA 'Cemu' }
$settingsFile = Join-Path $data 'settings.xml'
if (-not (Test-Path $settingsFile)) {
    Fail ('Cemu has no settings here yet: ' + $settingsFile + [Environment]::NewLine +
          '       Start Cemu once, set up your game and gamepad, close Cemu, then run this file again.')
}
Say ('Cemu:     ' + $cemuExe)
Say ('Settings: ' + $settingsFile)

# --- graphic packs ----------------------------------------------------------
$packRoot = Join-Path $data 'graphicPacks'
New-Item -ItemType Directory -Path $packRoot -Force | Out-Null
foreach ($pack in $packs) {
    $source = Join-Path $root (Join-Path 'graphicPacks' $pack)
    if (-not (Test-Path $source)) { Fail ('The package is incomplete, missing: ' + $source) }
    $target = Join-Path $packRoot $pack
    $parentPath = [IO.Path]::GetFullPath((Split-Path -Parent $target)).TrimEnd('\')
    if ($parentPath -ne [IO.Path]::GetFullPath($packRoot).TrimEnd('\')) { Fail 'Invalid pack destination.' }
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    Copy-Item $source $target -Recurse -Force
}
Say ('Packs:    copied into ' + $packRoot)

# --- settings: backup, enable packs, graphics -------------------------------
$backupDir = Join-Path $data 'CaptainToad-VR-backups'
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
$backup = Join-Path $backupDir ('settings-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.xml')
Copy-Item $settingsFile $backup
Get-ChildItem $backupDir -Filter 'settings-*.xml' | Sort-Object Name -Descending |
    Select-Object -Skip 5 | Remove-Item -Force -ErrorAction SilentlyContinue

$presetFile = Join-Path $root 'fps-preset.txt'
$preset = $defaultPreset
if (Test-Path $presetFile) {
    $remembered = (Get-Content $presetFile -Raw).Trim()
    if ($remembered) { $preset = $remembered }
}

$xml = New-Object System.Xml.XmlDocument
$xml.PreserveWhitespace = $true
$xml.Load($settingsFile)
$content = $xml.DocumentElement

$previousLogging = @{}
foreach ($name in @('logflag', 'advanced_ppc_logging')) {
    $node = $content.SelectSingleNode($name)
    $previousLogging[$name] = if ($node) { $node.InnerText } else { $null }
    $node = EnsureNode $content $name $xml
    $node.InnerText = if ($name -eq 'logflag') { '0' } else { 'false' }
}

$graphic = EnsureNode $content 'Graphic' $xml
$previousGraphic = @{}
foreach ($name in $graphicWanted.Keys) {
    $node = $graphic.SelectSingleNode($name)
    $previousGraphic[$name] = if ($node) { $node.InnerText } else { $null }
    $node = EnsureNode $graphic $name $xml
    if ($node.InnerText -ne $graphicWanted[$name]) {
        $node.InnerText = $graphicWanted[$name]
        if ($name -eq 'api') {
            Say ('Graphics: switched to Vulkan for this session (was ' + $previousGraphic[$name] + ').')
        } else {
            Say ('Graphics: ' + $name + ' set to ' + $graphicWanted[$name] + ' for this session (was ' + $previousGraphic[$name] + ').')
        }
    }
}

$graphicPack = EnsureNode $content 'GraphicPack' $xml
foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
    if (IsOurEntry $entry) { [void] $graphicPack.RemoveChild($entry) }
}
$vrEntry = $xml.CreateElement('Entry')
$vrEntry.SetAttribute('filename', 'graphicPacks/' + $stereoPack + '/rules.txt')
[void] $graphicPack.AppendChild($vrEntry)
$fpsEntry = $xml.CreateElement('Entry')
$fpsEntry.SetAttribute('filename', 'graphicPacks/CaptainToad_FPS/rules.txt')
$presetGroup = $xml.CreateElement('Preset')
$presetName = $xml.CreateElement('preset')
$presetName.InnerText = $preset
[void] $presetGroup.AppendChild($presetName)
[void] $fpsEntry.AppendChild($presetGroup)
[void] $graphicPack.AppendChild($fpsEntry)
$xml.Save($settingsFile)
Say ('Enabled:  Captain Toad: Treasure Tracker VR ' + $modeName + ' + FPS Unlock (' + $preset + ')')
Say ('Backup:   ' + $backup)

# --- run --------------------------------------------------------------------
$env:VK_LAYER_PATH = $layer
$env:VK_INSTANCE_LAYERS = 'VK_LAYER_CEMUVR_core'
$env:VK_LOADER_LAYERS_ENABLE = 'VK_LAYER_CEMUVR_core'
$env:CEMUVR_ENABLE = '1'
# Both camera modes derive their eye translations from the same pose mailbox.
$env:CEMUVR_TOAD_WORLD_SIZE = '2'
# Other implicit Vulkan layers - another Cemu VR layer such as BetterVR, or a
# screen overlay - would fight over the same frames. They are switched off for
# this one process only; that is the tested configuration.
if ($env:VR_KEEP_OTHER_LAYERS -ne '1') { $env:VK_LOADER_LAYERS_DISABLE = '~implicit~' }

Say ''
Say 'Starting Cemu with the VR layer. Put the headset on.'
Say 'Starts in Diorama. Press X in a level to step to the close diorama, to First Person and back.'
Say 'This window stays open until you quit Cemu, then it tidies up.'
Say ''
$cemu = Start-Process -FilePath $cemuExe -WorkingDirectory $cemuDir -PassThru
$cemu.WaitForExit()

# --- put Cemu back the way it was -------------------------------------------
Start-Sleep -Milliseconds 500
$keep = ($env:VR_KEEP_PACKS -eq '1')
try {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($settingsFile)
    $content = $xml.DocumentElement
    $changed = $false

    $graphicPack = $content.SelectSingleNode('GraphicPack')
    if ($graphicPack) {
        foreach ($entry in @($graphicPack.SelectNodes('Entry'))) {
            if (-not (IsOurEntry $entry)) { continue }
            if ($entry.GetAttribute('filename') -match 'CaptainToad_FPS') {
                $chosen = $entry.SelectSingleNode('Preset/preset')
                if ($chosen -and $chosen.InnerText -and $chosen.InnerText -ne $preset) {
                    Set-Content -Path $presetFile -Value $chosen.InnerText -Encoding UTF8
                    Say ('Remembered your FPS preset: ' + $chosen.InnerText)
                }
            }
            if (-not $keep) { [void] $graphicPack.RemoveChild($entry); $changed = $true }
        }
    }
    if (-not $keep) {
        $graphic = $content.SelectSingleNode('Graphic')
        if ($graphic) {
            foreach ($name in $graphicWanted.Keys) {
                $node = $graphic.SelectSingleNode($name)
                if (-not $node) { continue }
                if ($null -eq $previousGraphic[$name]) {
                    [void] $graphic.RemoveChild($node); $changed = $true
                } elseif ($node.InnerText -ne $previousGraphic[$name]) {
                    $node.InnerText = $previousGraphic[$name]; $changed = $true
                }
            }
        }
    }
    foreach ($name in @('logflag', 'advanced_ppc_logging')) {
        $node = $content.SelectSingleNode($name)
        if ($null -eq $previousLogging[$name]) {
            if ($node) { [void] $content.RemoveChild($node); $changed = $true }
        } else {
            $node = EnsureNode $content $name $xml
            $node.InnerText = $previousLogging[$name]
            $changed = $true
        }
    }
    if ($changed) { $xml.Save($settingsFile) }
} catch {
    Say ('Could not tidy up settings.xml: ' + $_.Exception.Message)
    Say ('A backup of the original file is here: ' + $backup)
    exit 1
}

Say ''
if ($keep) {
    Say 'Done. The VR packs stay switched on in Cemu (VR_KEEP_PACKS=1).'
} else {
    Say 'Done. The VR packs are switched off again, so ordinary 2D play is unaffected.'
}
Say ''
exit 0
