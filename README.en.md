# Duo Motion

**Let the angle of your MacBook lid move your desktop.**

[简体中文](README.md) · [MIT License](LICENSE)

A native macOS menu bar utility that reads a compatible MacBook's real hinge angle and applies a reversible perspective, frosted-glass and dimming effect to its built-in display. Built with Swift, AppKit, Metal, Metal Performance Shaders, ScreenCaptureKit and C, without third-party runtime dependencies.

This is an independent folding-animation experiment, unaffiliated with Apple. It does not include Apple's original animation assets or shaders.

## Features

- Live hinge angle and all controls in the menu bar.
- Adjustable activation angle, blur, dimming and perspective.
- Transparent entry/exit, presentation synchronization and brief sensor-dropout tolerance.
- Screen-access diagnostics and an immediate stop shortcut: **Control + Option + Command + D**.
- Local processing only: no audio capture, saved frames, uploads, networking or telemetry.

## Requirements and build

Apple Silicon MacBook, macOS 14+, Xcode Command Line Tools and a compatible IOHID hinge sensor are required. Not every MacBook exposes the supported sensor report. The integer-degree readout is not an accuracy guarantee, and the report format is not a stable Apple measurement API. Hardware coverage is limited; no notarized installer is provided.

From this directory:

```sh
zsh build.sh
open "build/Duo Motion.app"
```

Click the laptop angle icon in the menu bar and choose **启用桌面动画** (Enable desktop animation). Grant the app Screen & System Audio Recording access when macOS requests it. The default activation angle is 100°. Animation starts disabled on launch; no login item is installed.

There is no demo mode or separate settings window. The menu contains the effect controls, permission diagnostics, System Settings link, Reveal App in Finder, stop and quit actions.

## Signing and permission recovery

An ad-hoc signature identifies a particular build. Recompiling can invalidate a previous Screen Recording grant even when System Settings still shows an enabled switch. The build script therefore blocks accidental ad-hoc replacement of an existing app.

Use a stable installed signing identity for updates:

```sh
DUO_SIGNING_IDENTITY="certificate name or fingerprint" zsh build.sh
```

For an intentional local ad-hoc update that may require fresh authorization:

```sh
DUO_ALLOW_ADHOC_UPDATE=1 zsh build.sh
```

If access fails, choose **重新检测屏幕权限** (Recheck screen permission), then quit and reopen. If macOS still rejects the current build, remove the old entry from System Settings → Privacy & Security → Screen & System Audio Recording, add the exact current `.app` again, and relaunch as requested. The menu's **在访达中显示当前 App** locates that bundle. Changing certificates may also require reauthorization.

A successful display enumeration is reported separately from a verified complete desktop frame. No automatic TCC reset or direct permission-database modification is performed.

## Checks

```sh
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --self-test
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --renderer-test
"build/Duo Motion.app/Contents/MacOS/Duo Motion" --probe
```

The first checks angle mapping, permission states and animation timing. The second uses synthetic pixels for offscreen GPU checks without capturing the desktop. The third reads the actual hinge once. These do not replace manual testing of lid movement, desktop composition or hardware compatibility.

## How it works and limitations

The sensor reader requests HID feature report 1 on usage page `0x20`, usage `0x8A`. Little-endian bytes 1–2 supply integer degrees. ScreenCaptureKit excludes this app from capture to prevent feedback. Frames remain in memory, use SDR and are capped at 1920 pixels wide.

The renderer overlays the built-in display through a click-through window. It does not modify other apps, disable sleep or change screen brightness. Protected content may be blank, and strong perspective transforms can make displayed controls differ from their actual click positions. Reopening the lid clears the effect; keep the hinge within its normal range.

Capture validates access on activation, then warms up near the threshold and stops after leaving the effect range. Sustained sensor loss, capture errors, sleep and session changes hide the overlay.

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidance and the [Chinese README](README.md#项目结构) for the source layout.

## Acknowledgments

- [LidAngleSensor](https://github.com/samhenrigold/LidAngleSensor): hinge-sensor research reference.
- [iphone-duo-macos-animation](https://github.com/lqSky7/iphone-duo-macos-animation): visual research reference.
- [Apple ScreenCaptureKit documentation](https://developer.apple.com/documentation/screencapturekit).

No source code, audio or visual assets from the referenced projects are bundled here. Licensed under [MIT](LICENSE).
