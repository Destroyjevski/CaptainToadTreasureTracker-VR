# Installation

## Before you start

- Set up Cemu 2.6 and confirm that your Captain Toad: Treasure
  Tracker with update v16 runs normally with a gamepad.
- Select an OpenXR runtime for your headset. The tested runtime is Virtual
  Desktop/VDXR.
- For the default 120 FPS preset, use a 120 Hz headset refresh rate.
- Close Cemu before starting a VR session.

## Install Alpha 1.3

1. Extract `CaptainToadTreasureTracker-VR-Alpha-1.3-install.zip`.
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
| Right grip | R; show the blue touch preview while held |
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

### Blowing

Blow into your headset microphone as you would into the GamePad, for example to
raise the propeller platforms. The mod recognises blowing itself, so nothing
needs to be set up in Cemu. It listens on the Windows default recording device,
which is usually the headset microphone while Virtual Desktop or SteamVR is
running. With wireless streaming, enable microphone forwarding in your
streaming software. This works with VR controllers and with a gamepad.

Blow steadily and directly onto the microphone; blowing counts after about a
quarter of a second. Short puffs, speaking, whistling and hissing do not count,
and while you talk, blowing is paused until you have been quiet for a moment.
This strictness is deliberate, so that talking does not blow in the game. If you
find it too strict, please report it, or use the right-controller gesture below.

The audio is analysed in memory in 10 ms steps and then discarded. The mod does
not record, save or send audio. Windows shows Cemu as using the microphone
during the session. To change this, edit `Start-VR.cmd`:

- `set "CEMUVR_BLOW_MIC=0"` switches microphone detection off.
- `set "CEMUVR_BLOW_MIC=Headset"` uses the first recording device whose name
  contains "Headset" instead of the default device.
- Adding `set "CEMUVR_BLOW_MIC_DB=-55"` makes detection more sensitive
  (default -45).

Speech/noise filtering in the headset or streaming software can weaken blowing.
If it is not recognised, switch that filtering off or use the gesture below.
Cemu's own **Microphone (Experimental)** setting is not needed. If it is set, it
keeps working alongside.

As an alternative, hold the **right controller near your headset** for a moment.
A short vibration confirms activation. Keep it there to blow, then move it away
to stop. This works alongside the microphone, without a mapped button.
The left-controller D-pad gesture is unchanged. Tracking/focus loss cancels the
gesture, and it requires a new short hold after tracking returns.

Blowing by microphone and gesture is currently enabled for the locally verified
European v16 game module. Other modules retain their native microphone input.
The same recognition was tested in Super Mario 3D World VR with a Quest 3
through Virtual Desktop; in Captain Toad it has been checked offline so far.

### Camera behaviour with either input device

Head movement controls your viewpoint. In first person, the right stick
turns freely through 360 degrees and the left stick follows the horizontal
headset direction combined with stick turning. Hold the touch button (gamepad Y or left VR Y) to use the
right stick for minecart aiming or Spinwheel control instead.

The headlamp follows your headset's horizontal and vertical look direction
in first person. No extra button is needed; other views keep native lighting.
In menus, return the stick to centre before selecting the next item.

### Locally generated game markers

At startup, the launcher looks for your unpacked Captain Toad installation
in Cemu's game paths or installed titles. It locally generates a hammer for
stunning, a turnip for minecart aim, a pull-switch for lifts/platforms and a
coin for hidden-coin interactions. These pictures come from your game and are
not included in the mod download. No additional software is needed.

The generated pictures are kept in `%LOCALAPPDATA%/CemuVR/CaptainToad/marker-icons/`.
They are verified on subsequent starts and rebuilt if damaged. If your game
is available only as a WUA/WUD/WUX container, or importing is unavailable,
the mod uses the project-created fallback symbols described below.

### The touch hand and the crosshair

The project-created touch hand, stun fist and crosshair remain available as
fallbacks when the local game markers cannot be imported. They are embedded
in the layer from `core/assets/`; the copies under `docs/` illustrate these
fallbacks, not extracted game graphics.

With VR controllers, hold the **right grip** to see the blue touch preview
and move the right controller to point at the level. When the ray finds a
fresh interaction target, its symbol appears: a hammer for enemy stunning,
a pull-switch for lifts/platforms, or a coin for hidden-coin surfaces. Hold
the **right trigger** to activate the touch. Release it to end the touch.
Grip alone only previews the target. Empty space has no action symbol.
Without imported markers, the fist, pointing hand and neutral ring serve
these respective roles. Symbols identify targets, not confirmed success.

This preview and activation work in all three camera modes. The marker and
blue ring use the same collision point for both eyes, including first person.
The game's collision shapes can differ from its visible models.

From the gamepad, hold **Y** and choose a nearby lift or platform with
**D-pad left/right**; releasing Y touches it. With VR controllers, use the
same selection via the D-pad gesture: left controller at your head, left Y
held, and right stick left/right. The selected-platform marker is hidden
when there is no matching surface or closer geometry blocks it.

In the minecart, the imported turnip or fallback crosshair marks the nearest
reported collision point along the shot's initial direction. Without a hit,
it uses the existing distant aim point. It does not predict the curved flight
of the projectile. Aim with the right controller or the game's right stick;
the right trigger fires (Y on the gamepad, or ZR). In first person, hold Y
to aim with the right stick. The minecart marker appears only while riding.

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
