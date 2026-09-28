# Known issues

**Alpha 1.0** is intended for early testing. A full playthrough has not
been validated, and compatibility testing covers one Windows/Cemu/VDXR setup.

## Shadows

- Shadows can be misplaced or perspectivally wrong.

## Rendering and performance

- Geometry outside the original camera view may be missing, exposed or visibly
  incomplete. Some effects, particles and visibility transitions can look
  wrong. Depth of field, glare and god rays are switched off in VR.
- The closer near clip plane in first person is a compromise. The game's
  depth-reading passes work from the original plane, so their depth is
  slightly off.
- Higher render rates do not interpolate animation between the game's 60 Hz
  updates. 90 and 144 FPS presets are experimental.
- Death, respawn and scene transitions may cause instability at 120 FPS.
  If a crash occurs, try the 60 FPS reference preset and report the location
  and steps that trigger it.

## Controls

- In first person, the touch-hand marker for the right VR controller's pointing
  direction is not visible, so enemies cannot be targeted for touch-stunning
  with the right trigger. A first-person touch-aiming interaction is still needed.
- Touch has been tested on lifts and movable platforms: pointing with the
  right VR controller, and choosing with Y and the D-pad, on the pad or with
  the VR controllers' D-pad emulation; other touch interactions are
  untested. The pointer is off in first person. In the close diorama the
  touch point can sit slightly off the pointed-at object, more so towards the
  edges of the view.
- The GamePad's microphone has no equivalent on a VR controller. A pad button
  that Cemu assigns to blowing keeps working from the pad.
- Emulated controller 1 has to be a Wii U GamePad. With a Pro Controller or a
  Wii Remote profile the game reads its input through a different path, which
  the VR controllers do not reach.
- On Oculus Touch controllers the menu button exists only on the left
  controller, so Plus comes from there.

## First person

- HUD elements stay anchored in the room and can move out of view as you turn.
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
