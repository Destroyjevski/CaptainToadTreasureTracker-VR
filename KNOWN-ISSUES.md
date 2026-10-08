# Known issues

**Alpha 1.2** is intended for early testing. A full playthrough has not
been validated, and compatibility testing covers one Windows/Cemu/VDXR setup.

## Rendering and performance

- Geometry outside the original camera view may be missing, exposed or visibly
  incomplete. Some effects, particles and visibility transitions can look
  wrong. Depth of field, glare and god rays are switched off in VR.
- Higher render rates do not interpolate animation between the game's 60 Hz
  updates. 90 and 144 FPS presets are experimental.
- Death, respawn and scene transitions have not been sufficiently tested at
  higher frame rates, including 120 FPS.
  If a crash occurs, try the 60 FPS reference preset and report the location
  and steps that trigger it.

## Controls

- Interaction markers use the game's collision shapes, which can differ from
  visible geometry. The grip preview and action symbol share the same surface
  point in first person and both diorama modes.
- Locally tested interactions include grip preview, enemy stunning, hidden-coin
  surfaces, lifts/platforms, platform selection with Y and the D-pad, and
  minecart aiming. Not every interaction in every level has been tested.
- The minecart marker indicates the initial shot direction, not the curved
  projectile trajectory. Without a hit, it uses the existing distant aim point.
- The GamePad's microphone has no equivalent on a VR controller. A pad button
  that Cemu assigns to blowing keeps working from the pad.

See [Installation: Controls](INSTALL.md#controls) for the required controller
setup and the separate gamepad and VR-controller bindings.

## First person

- The camera can clip into nearby geometry.
- Fixed cameras, rides and cinematics may produce awkward framing.

## Locally generated markers

The automatic importer requires an unpacked game installation in Cemu's game
paths or installed titles. WUA/WUD/WUX containers are not read directly.
If importing is unavailable, the project-created fallback symbols remain in
use; hidden-coin targets use the neutral ring. No game assets are downloaded.

## Compatibility

Only Cemu 2.6, the European game with update v16 and Virtual Desktop/VDXR
have been validated. Other game revisions, emulator versions, runtimes and
hardware may behave differently.

## Reporting a problem

Include the mode, level, game version, Cemu version, GPU, OpenXR runtime, FPS
preset and steps to reproduce the issue. Screenshots or a short recording can
help explain camera and rendering problems. Remove personal paths or account
information before sharing logs. Do not attach game files or keys.
