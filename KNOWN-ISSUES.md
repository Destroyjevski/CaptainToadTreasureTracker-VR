# Known issues

**Alpha 1.11** is intended for early testing. A full playthrough has not
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

- First-person controller touch and enemy stunning now have a dedicated
  world-ray adapter, checked offline but awaiting headset gameplay testing.
  Hand and crosshair surface placement uses the game's collision shapes,
  which may differ from visible geometry, and still needs headset testing.
  Without a fresh hit the direct pointer and crosshair use their reference
  distance; the selected-platform finger is hidden until a matching hit exists.
  Platform selection and minecart aiming retain their existing controls.
- Tested interactions include direct touch on lifts and movable platforms in
  the diorama views, nearby platform selection with Y and the D-pad (gamepad
  or VR-controller D-pad emulation), and controller aiming and firing in the
  minecart. Other touch interactions have not been comprehensively tested.
- In the close diorama, the touch point can sit slightly off the pointed-at
  object, more so towards the edges of the view.
- The GamePad's microphone has no equivalent on a VR controller. A pad button
  that Cemu assigns to blowing keeps working from the pad.

See [Installation: Controls](INSTALL.md#controls) for the required controller
setup and the separate gamepad and VR-controller bindings.

## First person

- The camera can clip into nearby geometry.
- Fixed cameras, rides and cinematics may produce awkward framing.

## Compatibility

Only Cemu 2.6, the European game with update v16 and Virtual Desktop/VDXR
have been validated. Other game revisions, emulator versions, runtimes and
hardware may behave differently.

## Reporting a problem

Include the mode, level, game version, Cemu version, GPU, OpenXR runtime, FPS
preset and steps to reproduce the issue. Screenshots or a short recording can
help explain camera and rendering problems. Remove personal paths or account
information before sharing logs. Do not attach game files or keys.
