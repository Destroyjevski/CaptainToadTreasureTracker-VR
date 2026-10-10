# Build from source

## Requirements

- Windows x64 and Visual Studio 2022 with C++ tools, including the Windows
  resource compiler that comes with the Windows SDK
- CMake 3.20 or later
- Vulkan SDK
- Khronos OpenXR SDK headers and an x64 static OpenXR loader library,
  built with the dynamic MSVC runtime
- Python 3.9 or later for packaging

## Compile the VR layer

```powershell
cmake -S . -B build -A x64 `
  -DOPENXR_INCLUDE_DIR="C:/path/to/OpenXR/include" `
  -DOPENXR_LOADER_LIBRARY="C:/path/to/openxr_loader.lib"
cmake --build build --config Release
```

The include directory must provide `openxr/openxr.h` and
`openxr/openxr_platform.h`. The layer links Windows D3D11/DXGI system
libraries and the Windows Imaging Component and uses the dynamic MSVC
runtime. The Microsoft Visual C++ x64 Redistributable may be needed on the
machine running the mod.

The touch hand, crosshair and stun fist are the three PNG images under `core/assets/`;
`core/touch_icon.rc` embeds them into the DLL as resources, so they have to
stay beside it.

The launcher automatically prepares hammer, turnip, pull-switch and coin
markers from the user's own unpacked Captain Toad installation. It searches
Cemu's configured game folders and installed titles, validates the title ID,
and reads only the four required ObjectData archives. Raw models and textures
stay in memory. Generated PNGs are cached outside the mod under
`%LOCALAPPDATA%/CemuVR/CaptainToad/marker-icons/`.

`tools/marker-import/Prepare-Markers.ps1` and `MarkerImporter.cs` run with
Windows PowerShell 5.1 and the Windows .NET Framework; no Python, download or
extra installation is needed. The cache key includes the importer and archive
hashes; image hashes are checked before reuse. Missing/corrupt images regenerate.
The launcher passes the verified directory to the DLL through
`CEMUVR_MARKER_ICON_DIR`. Old PNG overrides beside the DLL are not loaded.

If no supported unpacked installation is found, or importing fails, the mod
uses the existing project-created fallback artwork (neutral ring for coins).
Direct importing from WUA/WUD/WUX containers is not implemented.

The generated images, original models/textures and game code must never be
packaged. Use `tools/package.py`: it checks approved project artwork by path
and SHA-256, DLL resources and embedded PNGs, and rejects game-data containers
and unreviewed binary files. Never add game-derived images to its allowlist.
Both archives include the complete importer source and its GPL-3.0 notice;
the importer is a separate launcher-side tool, not part of the VR DLL.

Run the offline distribution checks with:

```powershell
$env:CEMUVR_TEST_DLL = (Resolve-Path ../Build/layer/cemuvr_layer.dll).Path
python -m unittest discover -s tools -p test_distribution_assets.py
```

The files under `graphicPacks/` are assembled by Cemu when it starts the game.
No game executable is required to compile the C++ layer.

## Package Alpha 1.3

```powershell
python tools/package.py --dll build/Release/cemuvr_layer.dll
```

The script creates installation and source ZIPs plus `SHA256SUMS.txt` in
`Releases/`. It reads the release name from `VERSION` and checks package
contents for private paths and unexpected file types before writing archives.

The installation ZIP includes the DLL. The source ZIP includes the C++ source,
the marker images, ASM packs, launchers and notices. Build outputs and local
Cemu settings are excluded from Git.

## Pose-token regression tests

Configure with `-DCEMUVR_BUILD_TESTS=ON`, build Release, then run:

```powershell
ctest --test-dir build -C Release --output-on-failure
```

These offline tests exercise the production history and transport-slot code,
including token wrap, stale markers, the mailbox seqlock rollover and 24 simulated
hours each at 60, 90, 120 and 144 Hz. Further tests cover the touch preview,
the blow gesture and the microphone blow detector, which runs on synthetic
audio only. They do not launch Cemu or a headset runtime and do not use a
microphone. `python tools/test_blow_gesture.py` executes the guest blow code
of the graphic pack against synthetic memory.

Normal sessions wrap pose tokens automatically. Each wrap emits one
`reference.token wrap=1` record, even with periodic diagnostics disabled.
For explicitly bounded FakeHMD/diagnostic runs only,
`CEMUVR_REFERENCE_STRICT_TOKEN_LIMIT=1` restores the stop before token reuse.
Leave this variable unset for normal play and long-session testing.
