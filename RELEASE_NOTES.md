# Alpha 1.1

## SteamVR compatibility

- Integrates Anakins' fix for a black or waiting screen on SteamVR runtimes
  that offer an sRGB swapchain instead of the requested UNORM format.
- Converts eye and HUD colours when the runtime requires sRGB; keeps the
  existing UNORM transfer unchanged. Headset comparison is pending.
- Imports the HUD's shared texture using the format selected by OpenXR.
- Keeps the current start-up and runtime-recovery behavior, with resolution
  and colour-channel-order checks still in place.

The format fix is included in Captain Toad's own layer. Headset validation
of the Captain Toad build on SteamVR/PSVR2 is still pending.

## First-person movement

- The left stick follows the horizontal headset direction with responsive
  smoothing, for gamepads and VR controllers. Stick turning remains available.
- Vertical head tilt does not change movement speed. Diorama and minecart
  controls retain their previous behavior.

## Touch interaction and aiming

- Uses the supplied fist artwork for recognized enemy targets in every camera
  mode. Lifts, platforms and other touch targets use the pointing hand;
  minecart aiming keeps the crosshair. Local headset validation is pending.
- Adds the right-controller touch hand in first person, visible while aiming.
  Hold the right trigger to use the game's touch interaction, including
  enemy stunning. The native collision query now uses the VR ray and includes
  nearby objects. In-headset gameplay validation is pending.
- Places the hand and minecart crosshair at the nearest reported surface
  intersection, with a reference-distance fallback on misses. Removes the
  crosshair's forced minimum distance. This is a local test awaiting headset
  validation; it uses collision shapes, not the rendered depth buffer.
- Extends surface placement to the selected-platform finger in all camera
  modes. Matches the selected actor and hides the finger when closer geometry
  blocks it, replacing the previous fixed height offset. Local test only.

## Tutorial banners

- Hides the GamePad touch, tilt and right-stick camera tutorial banners in VR,
  including the minecart aiming hint. The gameplay HUD and interaction markers
  remain visible; tutorial timing and control logic are unchanged.

## Validation

- Movement math, input-state guards and register preservation have passed
  offline checks. Headset testing of the new movement is pending.

See [CREDITS.md](CREDITS.md) for the contribution and
[KNOWN-ISSUES.md](KNOWN-ISSUES.md) for remaining limitations.

---

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
