# Alpha 1.0

Initial alpha release of Captain Toad: Treasure Tracker VR for Cemu.

## Included

- Stereoscopic rendering and 6DOF head tracking through OpenXR, on the game's
  own render flow: one simulation step, two eye views, shared shadow state.
- Diorama mode, with the right VR controller as the touch pen.
- A close diorama at half the distance, between diorama and first person;
  X steps through the three views.
- Experimental first-person mode, seated at Toad's head with a levelled
  horizon, the player model hidden, free stick turning and R3 recentring.
- VR controllers as the GamePad with no mapping in Cemu, the D-pad gesture,
  the crosshair on the controller in the minecart, and the choice among
  nearby lifts and movable platforms with a hand marker from the pad.
- Room-anchored HUD, menus, title screen and level book.
- Each eye's own camera and projection for the game's screen-space passes,
  for consistent lighting between the eyes; depth of field, glare and god
  rays off.
- FPS presets for 60, 90, 120 and 144 FPS, with gameplay updates near 60 Hz.
- Windows session launchers, source code, build instructions and license notices.

## Compatibility

Cemu 2.6 on Windows x64 with Vulkan and an OpenXR runtime. Targets the European
Wii U game with update v16: title ID `0005000010180700`, module checksum `1B377483`.

## Limitations

The mod is incomplete. Read [KNOWN-ISSUES.md](KNOWN-ISSUES.md) before use.
