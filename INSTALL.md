# Installation

## Before you start

- Set up Cemu 2.6 and confirm that your Captain Toad: Treasure
  Tracker with update v16 runs normally with a gamepad.
- Select an OpenXR runtime for your headset. The tested runtime is Virtual
  Desktop/VDXR.
- For the default 120 FPS preset, use a 120 Hz headset refresh rate.
- Close Cemu before starting a VR session.

## Install Alpha 1.1

1. Extract `CaptainToadTreasureTracker-VR-Alpha-1.1-install.zip`.
2. Copy its **`CaptainToad-VR`** folder into your Cemu folder, beside `Cemu.exe`.
3. Open that folder and run **`Start-VR.cmd`**. The game starts in diorama mode.
4. Launch the game from Cemu's game list.
5. Keep the launcher window open. Quit Cemu normally to end the session.

If the launcher cannot find Cemu, it asks you to select `Cemu.exe` once.
The installation ZIP includes the VR layer. The source ZIP requires a build;
see [BUILD.md](BUILD.md).

## Graphics and frame rate

The launcher enables Vulkan, asynchronous shader compilation and GX2DrawDone
synchronisation, switches VSync off, and enables the VR pack and the FPS
pack. It uses your existing Cemu configuration and saves; it does not create
a separate game profile.

For a sharper image, enable Cemu's community resolution graphic pack for the
game and select **3840×2160**, if your GPU can sustain it. That pack is not
bundled.

The initial FPS preset is **120 FPS (60 Hz gameplay)**. To change it, select
a different preset in Cemu's graphic-pack settings during a session. Quit
Cemu normally; the launcher remembers the selection for the next start.
The available presets are 60, 90, 120 and 144 FPS. Start with 60 if 120 is unstable.

## Controls

### Gamepad

Keep your existing Cemu gamepad mapping. **Button names below are the
emulated Wii U GamePad buttons**, as shown in Cemu's input settings; the
labels on your physical gamepad may differ. The controls below add camera
switching and touch interaction. Other buttons keep their standard actions.

| Gamepad input | Action |
| --- | --- |
| X (zoom button) | Cycle Diorama → Close diorama → First Person → Diorama |
| R3 (right stick click), first person | Recenter and straighten the view |
| Hold Y + D-pad left/right | Select a nearby lift or movable platform |
| Release Y | Touch the selected object; a short press touches the nearest |
| Right stick | Aim in the minecart or turn a Spinwheel |
| Hold Y + right stick, first person | Aim in the minecart or turn a Spinwheel instead of turning the camera |
| Y or ZR, minecart | Fire |

The hand marks the selected touch object. Selection stays local to Toad.
The gamepad uses its normal D-pad; the controller gesture below is not
needed when playing with a gamepad.

### VR controllers (motion controllers)

**No Cemu button mapping is needed for VR controllers.** Set emulated
controller 1 to **Wii U GamePad**; other emulated controller types do not
receive this input. A configured gamepad can still be used alongside them.

The button names below refer to **Quest / Oculus Touch controllers**.
They are separate from the gamepad bindings above. Other controller layouts
have not been validated.

| VR controller input | Wii U input / action |
| --- | --- |
| Left stick | Move |
| Right stick | Camera turning; aim in the minecart or turn a Spinwheel |
| Left X or right stick click | X: cycle camera modes |
| Left stick click | R3: recenter and straighten the view in first person |
| Left Y | Y: touch selection; hold for stick aiming or Spinwheel control in first person |
| Right A | A |
| Right B | B |
| Left trigger | ZL |
| Left grip | L |
| Right grip | R |
| Left menu button | Plus |
| Right controller direction | Aim the touch hand in diorama or first person; aim in the minecart |
| Right trigger | Touch at the pointer; fire in the minecart |

**D-pad gesture (VR controllers only):** hold the left controller near your
head. A short vibration confirms activation; the right stick now sends
D-pad directions instead of turning the camera. Move the left controller
away to resume camera turning.

**Selecting a nearby lift or platform:** hold left Y while the D-pad gesture
is active, then move the right stick left/right. The hand marks the selected
object. Release left Y to touch it. This selection method also works in
first person.

**Direct touch:** point the right controller at the level and
hold its trigger. In first person the hand is already visible while aiming,
including when aiming at an enemy for touch-stunning. Release the trigger to
end the touch. In the minecart, point the right controller to aim and press
its trigger to fire, including in first person.

### Camera behaviour with either input device

Head movement controls your viewpoint. In first person, the right stick
turns freely through 360 degrees and the left stick moves relative to that
stick-turned view. Hold the touch button (gamepad Y or left VR Y) to use the
right stick for minecart aiming or Spinwheel control instead.

### The touch hand and the crosshair

On the Wii U the GamePad screen shows the same view as the TV, and a touch on
it is a touch on the level. A headset has no such screen, so this mod gives
the touch two symbols of its own, drawn by the VR layer as flat images in the
room. Both sit at the depth of the spot they mark, are placed at one common
point for both eyes, pulse slightly, and appear only while they are in use.

**The touch hand** (`docs/touch-hand.png`) is the touch itself. In the
diorama, point the right controller at the level and hold the trigger: the
hand appears where the controller points, the game receives a touch at that
spot for as long as the trigger is held, and the touch ends when you let go.
It moves lifts and movable platforms. The game picks the touched object
along a ray. This test build places the hand at the nearest reported collision
point, with a reference-distance fallback when no hit is available.
From the pad, hold Y and switch between the nearby
lifts and movable platforms with D-pad left or right; the hand marks the
chosen one, and releasing Y touches it. The VR controllers do the same with
the D-pad emulation: hold the left controller to your head and Y, and push
the right stick left or right. In first person direct pointing uses the
VR camera position and right-controller direction for the game's touch
collision query. Aim with the visible hand, then hold the right trigger.
This first-person path still needs an in-headset gameplay test.

In this test build, the pointer uses a fist only when its nearest target is
recognized as an enemy, in every camera mode. Lifts, platforms and other
targets use the pointing hand. The symbol does not confirm stun success.
The minecart retains its crosshair.
The selected-platform hand now uses a collision point on that platform instead
of floating above its origin. It is hidden when no matching surface is found
or closer geometry blocks it. This placement awaits headset testing.

**The crosshair** (`docs/crosshair.png`) is the minecart's aim. It shows
the nearest reported collision point along the shot's initial direction.
Without a hit it uses the existing distant aim point. It does not predict
the projectile's curved trajectory. Collision shapes may differ from visible
models; this surface placement still needs headset testing.
Aim with the right stick as the game intends, or point the right controller:
the crosshair follows it, and the trigger fires (Y on the pad, or ZR). In
first person hold Y to aim with the right stick.

Both symbols are this project's own artwork. The originals are embedded in
the layer from `core/assets/`; the copies under `docs/` are reduced for the
documents.

## Switching camera modes

Press the zoom button, **X**, on the pad, or click the right controller's
stick: the first press moves to the close diorama, the same view from half the distance, the
second to first person, the third back to the diorama. Entering first person
recentres head position; **R3** on the pad or the left controller's stick
click does it again and straightens the view. Title screen, level book and
menus use the room-fixed screen, and a menu or a scene without the player
returns to the diorama.

`Start-VR.cmd` is the only launcher.

## What the launcher changes

For the session, it copies the included graphic packs into Cemu's data folder,
enables them, switches to Vulkan with asynchronous shader compilation,
GX2DrawDone synchronisation and VSync off, and loads the VR layer for the
Cemu process. Verbose Cemu debug logging is disabled for the session.
Existing unrelated graphic packs remain enabled.

Settings backups are kept in `CaptainToad-VR-backups` inside Cemu's data folder.
After a normal exit, the launcher disables its packs and restores the previous
graphics and debug-logging settings. The copied pack files remain installed.

If Cemu or the launcher is forcibly closed, check the enabled graphic packs
before returning to ordinary 2D play. No system-wide Vulkan layer is installed.
