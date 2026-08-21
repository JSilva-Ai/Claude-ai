# VOID STRIKER — the native app

The game, wrapped with [Capacitor](https://capacitorjs.com) so there is
something to submit to the App Store and Google Play. Until this existed there
was no iOS project and no Android project: the game was one HTML file, and
every other piece of store preparation — the privacy policy, the terms, the
support page, the developer address — was preparation for a submission that
could not happen.

This is a **separate npm project** from the website. Nothing at the repo root
depends on it, `npm run build` up there does not touch it, and installing the
mobile toolchain is not a prerequisite for working on the site.

## What it actually is

Capacitor puts the web app in a native web view — WKWebView on iOS, Android's
System WebView — and gives it a bridge to native APIs. There is no port and no
rewrite: the game that runs on the phone is byte-for-byte the game that runs on
the website, plus one file.

```
game/void_striker.html            the game, as authored
  └─ npm run demo   (repo root)   self-hosts the Google Fonts faces
public/demo/void-striker/         → what the website serves
  └─ npm run build  (here)        + src/native.js
www/                              → what the app ships
  └─ npx cap sync                 → ios/App/App/public/
                                  → android/app/src/main/assets/public/
```

`www/` is generated and is not in the repository. Build it before opening
either native project.

## Working on it

```sh
npm install                 # once
npm run build               # www/ from the site's demo build
npm run verify              # drive the built game in Chromium (see below)
npm run sync                # build + copy into both native projects
npm run open:ios            # Xcode
npm run open:android        # Android Studio
```

`npm run verify` loads `www/` in Chromium and fails if anything requested an
address off the device, if a script errored on load, if the canvas never drew a
frame, or if the game stopped exposing the one function the shim calls. It
needs the root project's `node_modules` (Playwright lives there), so run
`npm ci` at the repo root first. It is not a substitute for running the thing on
a phone — it cannot tell you how it feels in the hand — but the four things it
checks are the four that look fine on a desk and fail on a device.

Building and signing need a Mac with Xcode for iOS, and Android Studio with a
JDK for Android. Neither runs in CI here.

## The shim

`src/native.js` is the whole difference between the browser and the app. It
never reaches into the game — VOID STRIKER is one self-contained file with an
IIFE around it, and it stays that way so a new build drops in with one command
— so everything it does is done from outside, by wrapping a browser constructor
or reading the DOM the game already renders. It does two things:

- **Suspends the audio when the app is backgrounded.** The music is built from
  live oscillators rather than a streamed file, so there is no `pause()` to
  call. iOS suspends the context by itself; Android's WebView does not reliably,
  which is how a phone in a pocket keeps playing the title theme.
- **Makes Android's back button behave.** Capacitor's default is to exit. Back
  now closes an open modal — the menu, the leaderboard and the achievements list
  all live in one — and otherwise minimises rather than exits, because the game
  has no pause and no save, so exiting mid-run would silently destroy the run.

## Decisions taken here

- **The bundle id is `com.newaivisionlabs.voidstriker`**, derived from the
  domain rather than chosen. It is the app's permanent identity on both stores
  and cannot be changed after the first upload, so it is the one value to
  confirm before then.
- **Portrait only**, on phone and tablet, iOS and Android. The game is a fixed
  520x720 canvas scaled to fit its viewport; rotated to landscape it is limited
  by height and becomes a narrow column between two wide black bars, with the
  touch controls squeezed into the middle.
- **Both launch screens are plain black**, replacing Capacitor's splash art.
  The game's first paint is its own black `<body>`, so the least visible launch
  is the one where nothing changes colour.
- **The status bar is hidden on iOS.** The clock and battery would sit on the
  starfield with nothing to read them against, and the game already draws its
  own state across the top of the canvas.
- **The web view's background is black** on both platforms, or the letterbox
  around the canvas flashes white on every launch.
- **`www/` is built from the site's demo build, not from the game source.**
  The demo build already self-hosts the two Google Fonts faces; doing it again
  here would be a second implementation of the same thing, drifting from the
  first. `scripts/build-www.mjs` does not assume that build is self-contained —
  it checks for remote references and refuses to build if it finds any. A
  packaged game with no server and no account has no business contacting anyone,
  the privacy policy says it contacts nobody, and a live font import renders
  perfectly on wifi and fails on a plane.

## Not done

- **The app icon is still Capacitor's placeholder**, on both platforms
  (`ios/App/App/Assets.xcassets/AppIcon.appiconset/`,
  `android/app/src/main/res/mipmap-*/`). It is left obviously wrong rather than
  filled with something plausible: both stores reject a placeholder icon, so it
  fails loudly instead of shipping. Designing it is a decision for the studio,
  not for a build script.
- **Store listing assets** — screenshots at each required size, feature
  graphic, description — none of it exists yet.
- **Signing**: no keystore for Android, no team or provisioning profile for
  iOS.
- **Nothing has run on a physical device.** It has been verified in Chromium
  only.

## Known, in the game rather than here

- The modal close button has **two** click listeners bound to it, both calling
  `popModal()`, so tapping ✕ pops two levels of modal instead of one. The shim
  calls `popModal()` directly and is not affected; a player tapping the button
  is. Raised, not fixed — the game's source is not modified from here.
