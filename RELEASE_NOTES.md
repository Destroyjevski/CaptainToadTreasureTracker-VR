# Alpha 1.2

## Touch preview and target symbols

- Hold the right grip to show the blue touch preview and aim with the right
  controller. The right trigger activates the touch; grip alone does not.
- Uses a hammer for enemy stunning, a pull-switch for lifts and platforms,
  and a coin for hidden-coin surfaces. Symbols follow the current target,
  without retaining the preceding target's identity after a level change.
- Shows an action symbol only when a matching interaction target is found.
  The minecart turnip marker appears only while riding.
- Places the preview ring and action symbol at the same reported collision
  point in all three camera modes, correcting their first-person mismatch.

## First-person headlamp

- The lamp follows the headset's horizontal and vertical look direction,
  independently of the character's facing direction and idle animation.
- Preserves the native lamp position, brightness, range, activation and wall
  collision. Other camera modes keep their normal lighting.

## Menus and startup

- Menu stick navigation advances one item per deliberate deflection, avoiding
  repeated jumps while the stick remains held.
- Finds the correct Cemu data folder when settings.xml is stored beside
  Cemu.exe, as well as portable and AppData installations.

## Locally prepared interaction symbols

- The launcher automatically prepares hammer, turnip, pull-switch and coin
  markers from the user's own unpacked game installation. The mod does not
  distribute Nintendo graphics, models or game code.
- Stores the generated images in a local cache outside the mod, verifies them
  on subsequent starts and regenerates damaged images.
- Keeps the project's own hand, fist and crosshair as fallbacks. If the game
  is available only as a WUA/WUD/WUX container, the fallback symbols are used.
- No additional software installation is required. Complete source and license
  notices for the separate launcher-side importer are included.

The interaction and lamp changes have been tested locally in the headset.
Collision shapes can still differ from visible geometry. All previous features
and the Alpha 1.11 long-session pose-token hotfix remain included.

---

# Alpha 1.11 Hotfix

- Fixes VR stopping after roughly ten minutes, depending on the refresh rate.
- Keeps rendered frames matched to their original headset poses when the internal
  pose tokens wrap, and rejects expired pose-history entries.
- Keeps the touch hand, stun fist and crosshair matched to their frames after
  the token wrap.

Offline regression tests passed for 24 simulated hours each at 60, 90, 120 and
144 Hz, including 544 token wraps.

---

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
