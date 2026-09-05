# LOOP brand assets

Empty on purpose. This is where the official icon and splash art go when they
exist, and it is here now so that adding them is a drop-in rather than a
decision about where things live.

Nothing in this folder is bundled into the app. The platform projects read
their icons from their own locations (below); these are the **sources** those
are generated from.

## What to put here

| File | What it is | Constraints |
| --- | --- | --- |
| `icon-1024.png` | The app icon, square, full bleed | 1024×1024. **No alpha channel** — iOS rejects an icon with one. No rounded corners; both platforms round it themselves. |
| `icon-foreground.png` | The Android adaptive foreground | 1024×1024 with transparency. Everything that must survive cropping has to sit inside the centre **66 of 108** parts — roughly the middle 61%. |
| `splash.png` | The launch image | Centred mark on a transparent ground; the colour behind it is `#03050C` (`LoopColors.backgroundBottom`). |

Read at whatever size it will actually be seen: an icon is judged at 48px on a
home screen, where fine detail reads as a smudge. The studio learned this on
VOID STRIKER — its icon is drawn from vector paths for exactly that reason,
and did *not* follow the game onto its raster art.

## Where they end up

- iOS — `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Android — `android/app/src/main/res/mipmap-*/`
- Web — `web/icons/`, `web/favicon.png`
- Splash — generated per platform

All four currently hold Flutter's placeholder, which is the Flutter logo.

## Generating

Two tools do this from a single source, and neither is a dependency yet — no
package is added to `pubspec.yaml` for something that runs once and produces
committed files:

```bash
dart run flutter_launcher_icons        # after adding flutter_launcher_icons config
dart run flutter_native_splash:create  # after adding flutter_native_splash config
```

The alternative, and the one this repository already has a precedent for, is a
script that draws the icon and writes every size itself — see
`scripts/render/app-icon.mjs` at the repository root, which does this for VOID
STRIKER, including stripping the alpha channel iOS forbids and honouring the
Android safe zone.

Colours, if the mark is drawn rather than supplied: `LoopColors.ai` `#7C5CFF`
into `LoopColors.aiAlt` `#22D3EE`, on `#03050C`.
