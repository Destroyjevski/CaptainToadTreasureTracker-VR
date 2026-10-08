# Creates local-only markers from the user's own unpacked game installation.
# No game files are written into the mod folder. Never distribute this cache.
function Get-ToadMarkerCache {
    param([Parameter(Mandatory=$true)][string] $SettingsFile,
          [Parameter(Mandatory=$true)][string] $CemuDir,
          [string] $CacheRoot = (Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'CemuVR\CaptainToad\marker-icons'))
    $ErrorActionPreference = 'Stop'
    $helper = Join-Path $PSScriptRoot 'MarkerImporter.cs'
    $models = @('MarioHummer', 'Radish', 'SwitchPull', 'Coin')
    $icons = @('stun-hammer.png', 'aim-radish.png', 'touch-switch.png', 'touch-coin.png')
    $settings = New-Object System.Xml.XmlDocument
    $settings.XmlResolver = $null
    $settings.Load($SettingsFile)
    $roots = New-Object 'System.Collections.Generic.List[string]'
    foreach ($node in $settings.SelectNodes('/content/GamePaths/Entry')) {
        $path = $node.InnerText
        if (-not [IO.Path]::IsPathRooted($path)) { $path = Join-Path $CemuDir $path }
        $roots.Add($path)
    }
    $mlcNode = $settings.SelectSingleNode('/content/mlc_path')
    $mlc = if ($mlcNode -and $mlcNode.InnerText) { $mlcNode.InnerText } else { Join-Path $CemuDir 'mlc01' }
    if (-not [IO.Path]::IsPathRooted($mlc)) { $mlc = Join-Path $CemuDir $mlc }
    $roots.Add((Join-Path $mlc 'usr\title\00050000'))
    $queue = New-Object 'System.Collections.Generic.Queue[object]'
    foreach ($path in $roots) { $queue.Enqueue(@($path, 0)) }
    $seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
    $objectData = $null
    $visited = 0
    while ($queue.Count -gt 0 -and $visited -lt 4096) {
        $item = $queue.Dequeue(); $path = [string]$item[0]; $depth = [int]$item[1]
        if (-not $seen.Add($path)) { continue }
        $visited++
        if (-not (Test-Path -LiteralPath $path -PathType Container)) { continue }
        $metaPath = Join-Path $path 'meta\meta.xml'
        if (Test-Path -LiteralPath $metaPath -PathType Leaf) {
            try {
                $meta = New-Object System.Xml.XmlDocument; $meta.XmlResolver = $null; $meta.Load($metaPath)
                $id = $meta.SelectSingleNode('/menu/title_id').InnerText.Trim().ToLowerInvariant()
                if ($id -in @('0005000010180700', '0005000010180600')) {
                    $candidate = Join-Path $path 'content\ObjectData'
                    $complete = $true
                    foreach ($model in $models) {
                        if (-not (Test-Path -LiteralPath (Join-Path $candidate ($model + '.szs')) -PathType Leaf)) { $complete = $false; break }
                    }
                    if ($complete) { $objectData = $candidate; break }
                }
            } catch { }
            # A different game is not a search root for this game's assets.
            continue
        }
        if ($depth -ge 4) { continue }
        foreach ($dir in (Get-ChildItem -LiteralPath $path -Directory -ErrorAction SilentlyContinue | Sort-Object Name)) {
            if (($dir.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            if ($dir.Name -in @('shaderCache', 'save', 'code', 'content', 'meta')) { continue }
            $queue.Enqueue(@($dir.FullName, $depth + 1))
        }
    }
    if (-not $objectData) {
        Write-Host 'Markers: no unpacked Captain Toad installation found in Cemu game paths. Using fallback symbols.'
        return $null
    }
    $fingerprints = @((Get-FileHash -LiteralPath $helper -Algorithm SHA256).Hash)
    foreach ($model in $models) { $fingerprints += (Get-FileHash -LiteralPath (Join-Path $objectData ($model + '.szs')) -Algorithm SHA256).Hash }
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $key = [BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(($fingerprints -join ':')))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
    $cache = Join-Path $CacheRoot $key
    $manifest = Join-Path $cache 'cache.json'
    $mutex = New-Object Threading.Mutex($false, ('Local\CemuVR-ToadMarkers-' + $key))
    $locked = $false
    try {
        try { $locked = $mutex.WaitOne(30000) } catch [Threading.AbandonedMutexException] { $locked = $true }
        if (-not $locked) { throw 'Another marker import is still running.' }
        $valid = Test-Path -LiteralPath $manifest -PathType Leaf
        if ($valid) {
            try {
                $record = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
                $valid = $record.key -eq $key
                foreach ($icon in $icons) {
                    $image = Join-Path $cache $icon
                    if (-not (Test-Path -LiteralPath $image -PathType Leaf) -or
                        (Get-FileHash -LiteralPath $image -Algorithm SHA256).Hash -ne $record.images.$icon) { $valid = $false; break }
                }
            } catch { $valid = $false }
        }
        if ($valid) { Write-Host 'Markers: local game-derived cache verified.'; return $cache }
        Write-Host 'Markers: preparing hammer, turnip, switch and coin from your game...'
        if (-not ('ToadMarkers.Importer' -as [type])) {
            Add-Type -Path $helper -ReferencedAssemblies System.Drawing,System.Numerics,System.Numerics.Vectors
        }
        # Generate all outputs before replacing the cache. A failed import cannot
        # leave a half-valid set in use. Raw models/textures stay in memory only.
        $staging = Join-Path $CacheRoot ($key + '.tmp-' + [guid]::NewGuid().ToString('N'))
        [ToadMarkers.Importer]::Generate($objectData, $staging)
        $images = [ordered]@{}
        foreach ($icon in $icons) { $images[$icon] = (Get-FileHash -LiteralPath (Join-Path $staging $icon) -Algorithm SHA256).Hash }
        $record = [ordered]@{ key = $key; images = $images }
        [IO.File]::WriteAllText((Join-Path $staging 'cache.json'), ($record | ConvertTo-Json), (New-Object Text.UTF8Encoding($false)))
        if (Test-Path -LiteralPath $cache) {
            $cacheFull = [IO.Path]::GetFullPath($cache)
            $rootFull = [IO.Path]::GetFullPath($CacheRoot).TrimEnd('\') + '\'
            if (-not $cacheFull.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid cache destination.' }
            Move-Item -LiteralPath $cache -Destination ($cache + '.old-' + [guid]::NewGuid().ToString('N'))
        }
        Move-Item -LiteralPath $staging -Destination $cache
        Write-Host 'Markers: generated locally. No game assets were downloaded or installed into the mod.'
        return $cache
    } finally {
        if ($locked) { $mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
}