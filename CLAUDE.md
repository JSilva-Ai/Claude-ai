# Working on this repo

Read this first. It exists so a new session starts with the state of play
instead of rediscovering it, and so the decisions below are not quietly
reversed by someone who was not in the room when they were made.

The site: an independent app studio, **New AI Vision Labs LLC**, publishing to
the App Store and Google Play. One product so far, VOID STRIKER.

## The rules that are not mine to change

These came from the owner and hold until he says otherwise.

- **Nothing invented.** No metrics, no team counts, no testimonials, no
  release dates. Where a real fact is missing the value is a visible `[TODO]`,
  so it fails loudly in review instead of shipping as though it were true.
  The testimonials component exists and is deliberately empty and disabled.
- **English only.** No i18n, no language switcher. Natural American English,
  independent-studio tone, no inflated marketing language.
- **The EIN never enters this repo.** It is required nowhere and is useful to
  anyone attempting fraud in the company's name. Same for formation documents
  and the D-U-N-S number — the latter is not secret, it is simply not needed
  by a website.
- **The privacy policy may not assert what an app collects** without that
  being verified against the software. The current claims were checked: no
  route contacts a third-party host, sets a cookie, or writes to storage.

## Decisions already taken, with the reasoning

Do not "fix" these without asking.

- **The home address is published**, in `site.postalAddress` and in the
  privacy policy. This was decided with the trade-off stated: Google Play
  displays the developer address on the listing and the EU trader rules
  oblige Apple to publish it, so withholding it from the site would not have
  kept it private. A registered agent was offered and declined.
- **`deploy.yml` names `main` literally.** It used to follow
  `repository.default_branch`, the default was moved off main, and every push
  reported "skipped" — a green tick, no deploy — while the live site served a
  branch build four commits behind. Do not make this clever again.
- **Multi-page build, not an SPA.** The legal routes have to be real files
  answering 200 because store reviewers open them directly.
- **The legal pages carry a `<noscript>` block** built from the same content
  module. Google Play's check on the privacy policy URL does not run scripts,
  and those pages served zero characters of body text without JavaScript.
- **The game sits in a phone frame, fitted to width, on `#00020f`** — the
  measured colour of the game frame's own edges, so the letterbox is
  invisible. Filling the screen would crop 56% of the play area.
- **Media is 520x720** everywhere, the game's canvas size, so a clip, a still
  and an empty slot are interchangeable.

## Capacitor

Done, in `mobile/void-striker/` — a separate npm project holding the iOS and
Android projects, so there is now something to submit. Read its README before
touching it; the reasoning is there rather than here. Three things from it
belong in this file:

- **The bundle id is `com.newaivisionlabs.voidstriker`**, derived from the
  domain rather than chosen. It is permanent once a build has been uploaded
  under it, and it is the one value to confirm before that happens.
- **The game's source is never modified to suit the app.** The two things the
  native platforms need — suspending the audio when backgrounded, and a back
  button that closes a modal, pauses a run, or minimises rather than exiting —
  are done from outside by `src/native.js`, so a new build of the game drops in
  with one command. The shim reads `#modal`, `#modal-close`, `window.popModal`
  and `window.pauseGame`; renaming any of those means editing it in the same
  commit.
- **The app icon is drawn by `scripts/render/app-icon.mjs`**, which replaced
  Capacitor's placeholder on his instruction to propose one. It draws the same
  hull and wing paths the game's ship used to be drawn with — now kept in the
  game as `drawShipVector()`, the fallback for the few frames before the
  game's own raster ship art decodes — on the game's own violet. The icon
  deliberately did not follow the game onto that raster art: at 48px it read
  as a blob where the vector paths still read as a clean silhouette. Re-run
  that script rather than editing the PNGs; it writes the iOS 1024 (with its
  alpha channel stripped, which iOS requires), both Android legacy sets and
  the adaptive foreground inside its 66-of-108dp safe zone.

Nothing has run on a physical device. What has been checked is that the
packaged build makes no request off the device, throws nothing on load, and
draws a frame — `npm run verify` there, in Chromium.

## State

Everything is committed and pushed to `main`, which is both the default
branch and what deploys. The site is at `https://newaivisionlabs.com/`; the
`github.io` URL now redirects there. Every page carries
`<meta name="build-sha">` — that settles which build a browser is showing,
which is not hypothetical.

Verify with: `npm run check`, `npm run qa`, and `node scripts/a11y.mjs --url=…`
per route. All were passing at the last commit.

## The Apple enrollment, and the domain

Apple rejected the Developer Program enrollment (ID TZRBLU4CMC) because the
website they were given "directs me to a domain placeholder page rather than an
active website". This was not a fault in the site: `newaivisionlabs.com`
resolved to `2.57.91.91`, Hostinger's parking page, while the built site sat at
`https://jsilva-ai.github.io/Claude-ai/` and had never been connected to the
domain. Apple looked at the domain.

**Done.** The site now serves from `newaivisionlabs.com`:

```
@     A       185.199.108.153 .109.153 .110.153 .111.153
www   CNAME   jsilva-ai.github.io.
```

and `public/CNAME` names the domain, which is what makes the deploy build for
the domain root rather than the `/Claude-ai/` subpath. The MX, SPF and DMARC
records came through the change untouched — that was the one thing that could
have broken silently, and it was checked before and after.

Two things about that cutover are worth keeping, because they are not obvious
and the second one cost a confused ten minutes:

- **The order is load-bearing.** With a CNAME in the artifact, Pages redirects
  the `github.io` URL to the custom domain. Merge before the DNS is pointed and
  that redirect lands on the registrar's parking page — the original problem,
  with the working URL gone too. DNS first, then merge, then Enforce HTTPS.
- **The `www` record did not survive.** Removing the apex `A` record at
  Hostinger also took the existing `www` CNAME with it, so `www` had to be
  created rather than edited. Worth checking for by name after any change to
  that zone.

What is left is his: resubmit the enrollment with `https://newaivisionlabs.com`,
replying against ID TZRBLU4CMC so it reaches the same reviewer.

The `[TODO]` markers below are the other half of this. They render as loud
orange boxes on `/privacy` and `/terms`, and `Last updated: [TODO — date of
publication]` sits directly under the `<h1>` on both — the pages a store
reviewer opens first. They are deliberate and they are his; they are also the
first thing anyone assessing whether this is a real company will read.

## Open, and whose they are

His:
- DKIM at Hostinger publishes an **empty key** (`v=DKIM1;p=`), which reads as
  revoked and is worse than absent. MX, SPF and DMARC are fine.
- Age rating, once the store questionnaires are filled — closes the `[TODO]`
  in the policy's "Children" section.
- A lawyer to read the terms; the publication date.
- Resubmitting the Apple enrollment now that the domain serves the site.
- Any future change to the DNS zone: **only the `A` records and the `www`
  CNAME.** Touching nameservers, or any "connect a website" / "reset DNS"
  button the registrar offers, takes the MX with them and support email dies
  silently.
- D-U-N-S is issued. Apple validates against the D&B record, so the address
  and phone there must match what goes into App Store Connect.

Mine, when asked:
- Design changes he still has in mind.
- A mid-run save. Closing the tab still destroys a run, which is the last thing
  the pause screen does not solve.
- The leaderboard is still local-only.

Done, on his instruction to improve the game, then to make it as good as it can
be for the App Store, then that it needed to look dramatically better, then to
use a specific supplied image as the ship's own art, then to build a pilot
hub — persistent progression — from a reference image of one, then to use a
set of sixteen more reference renders (his own art) as the model for enemy
ships. The detail is in `game/VOID_STRIKER.md`. Most recent:

- **The game ran at 6.7fps on a phone, and the main menu was never the one he
  asked for.** Both on his report; both measured before being touched.

  **Performance.** `canvas.width = W * DPR` sized the backing store from the
  game's *logical* 520x720 with DPR capped at 3 — but the canvas is letterboxed
  down to fit, so a 390pt iPhone was rendering 1560x2160 into a box the device
  shows with 1170x1620 physical pixels. A third of every frame was drawn and
  thrown away. On a CPU throttled to phone class that measured **6.7 fps**, and
  neutralising `shadowBlur` entirely bought 0.8 — it was never the shadows, it
  was the pixel count. The buffer is now sized from the box the canvas actually
  occupies, and a dynamic-resolution step gives pixels back when a device
  cannot keep up: **30 fps** on the same throttled run, full 1.9 MP at 60 fps
  where there is headroom.

  Two wrong turns are recorded at the code, because both looked right. Timing
  `update()+draw()` does not measure a frame — Canvas 2D work is deferred, so a
  device visibly at 10 fps reported a comfortable 3 ms and nothing adapted. And
  the frame *interval* is floored by vsync at 16.7 ms, so a naive "is there
  headroom" test of `avg < 13` can never be true on a 60 Hz screen: the first
  version ratcheted down on one slow second at load and never came back.

  **Apple.** `viewport-fit=cover` and the web-app meta tags; `100dvh` beside
  the `100vh` fallback, because on iOS Safari `100vh` is the height with the
  address bar hidden, so the flex box was taller than the visible area and the
  canvas centred below the middle; and `image-rendering:auto` in place of
  `crisp-edges`, which would have rendered a stepped-down buffer as hard blocky
  pixels rather than a slightly softer picture.

  **The main menu** is now the layout from his two reference images — pilot
  card and scrap across the top, the skewed wordmark over `DEEP SPACE
  EDITION`, three decks (weapons with their real bullet colours, the hangar
  drawing the equipped ship, the daily reward), a clipped mission bar with
  bracket marks, and a five-tile nav. It had only ever been built as a
  standalone mockup; the game itself still had the plain modal. The volume
  controls moved behind the nav's SOUND tile, which is what let the rest fit.

  Worth noting: `.hb-mark span` outranking `.hb-m3` flattened the rules either
  side of the subtitle into a stray dash at the margin — the **identical**
  specificity trap already hit and fixed once on the mockup. Name the elements
  that want `display:block` rather than reaching for a descendant selector.

- **A recording with sound finally settled the audio argument.** He sent three
  screen recordings; the first two had no audio track at all, the third did.
  Extracting it and measuring rather than guessing:

      band          his recording      after this pass
      20-200 Hz        -33.7 dB            -34.1 dB
      200-800 Hz       -28.1 dB  loudest   -37.7 dB
      800-2500 Hz      -42.2 dB            -48.1 dB
      crest factor      3.65                5.57
      100ms spread      4.7 dB             10.3 dB

  **Rendering my own engine's music alone reproduced his recording band for
  band** — which proved the wall of sound was the music, not the effects, and
  that the effects work of the previous pass had been aimed at the wrong half.
  The fault was a boxy 200-800 Hz drone that never moved. Fixed with a -9 dB
  scoop at 400 Hz on the pad alone (across the whole bus it guts the melody
  too), four pad voices instead of eight, and a per-chord envelope so the bed
  swells and falls back rather than sustaining flat.

  **The method is the reusable part**: capture the real thing, measure it,
  reproduce the measurement from the engine, then change one thing at a time
  and re-measure. `AudioNode.prototype.connect` has to be patched from
  `addInitScript` — patch it after page load and the chain is already wired to
  `destination`, so the tap catches nothing.

- **The audio was rebuilt**, on his word that it "isn't good at all" and is
  "still annoying to listen to". Three faults, in the order they mattered:

  1. **It clipped.** One gain into `destination` and nothing else. At the
     volume slider's top, heavy fire peaked at **1.40** with 301 samples
     hard-clipped — that distortion is what "annoying" sounds like. There are
     three busses now (effects through a compressor and a high shelf, music
     through a duck) into a master into a limiter. Same test: peak **0.73**,
     zero clipped.
  2. **Nothing was ever refused.** Every shot fired three or four oscillators
     with no variation and no ceiling, so a held trigger was the same sound
     eight times a second and twenty simultaneous deaths were sixty voices of
     mud. Every voice is detuned a few percent; a cue repeated inside 0.3 s
     returns quieter each time (a held trigger settles 66% down) and recovers
     fully after half a second of quiet; and 14 voices is the hard ceiling.
  3. **The music never went anywhere.** One chord, held forever, under a fixed
     24-note phrase with no rests, over a kick on every beat. The harmony now
     moves — Am–F–C–G, the pad gliding between chord tones — a six-note hook
     opens each four-bar cycle and **the fourth bar is silent**.

  I cannot hear any of this, so none of it is judged by ear. The engine is
  rendered in a real audio context through a tap on its own output and
  measured: peak, clipped samples, RMS spread, and a spectral centroid
  computed only over bins within 30 dB of each frame's peak. **That last part
  matters** — the naive centroid said the new mix was much darker, which was
  false: it was quieter, so more of its high bins fell under the analyser's
  absolute floor. Measured at matched level the new effects are *brighter*
  than the old (7.0% vs 4.2% of energy above 2.5 kHz). A level-dependent
  metric will lie to you about tone.

  One real bug fell out of the measurement: `AudioBufferSourceNode` fires
  `ended` **twice** in Chrome when an explicit `stop()` lands on the buffer's
  natural end, so the voice counter walked negative — and a negative counter
  silently disables the ceiling, which is the one thing meant to stop the mud.
  The decrement is guarded to fire once per voice.

- **Every menu has a way out pinned to its top.** I had claimed this was done
  and it was not: I asserted the BACK buttons *existed* and that clicking them
  worked, but Playwright scrolls an element into view before clicking, so the
  test passed while the buttons sat below the fold — ACHIEVEMENTS at y=874 on
  an 844-tall screen, WEAPONS at y=799 on a 640-tall one — and the pilot hub
  had no exit at all, since it opens `closeable:false` and never had a BACK.
  **Assert position, not presence.** The exit is now a sticky bar at the top
  of the modal box, 44x91px, so it cannot depend on how tall the content is.

- **Every enemy in the game is his own art now** — six bosses and six
  regular ships, from the sixteen renders he made. The pass before this one
  had to approximate them as hand-drawn vector hulls, because he pasted the
  images into chat and a pasted image is something to look at, not a file
  with bytes to encode. He then committed the PNGs to the repo, which *is* a
  channel this session can read, and they went in as themselves. **For art,
  the repo is the reliable channel; pasting into chat is not.** The sources
  live in `game/art/enemies/`; twelve are embedded as WebP data URIs (the
  player ship's route), sized to what the game draws rather than to the
  source, which took the file from 258KB to 525KB. The drawn hulls stay as
  the decode-time fallback and as what the app icon is still built from.
  Also fixed in that earlier pass: `capture-game.mjs` had been silently
  broken since the pilot hub renamed its start button.

- **A pilot hub replaced the plain difficulty-select menu**: a rank and level
  derived from lifetime XP, a second currency (SCRAP) earned once at game
  over and kept separate from the run's own credits so the shop economy
  tuned in an earlier pass stayed untouched, a Weapons screen where SCRAP
  buys a permanent fire-rate level per weapon, a Hangar with four ship colour
  skins recoloured from the one raster ship asset via a canvas hue composite,
  and a daily SCRAP claim. The reference he supplied was a landscape desktop
  layout with panels side by side; this game's canvas is fixed at 520x720 by
  the App Store stills, the demo clip and the site's phone frame, so the same
  ideas are stacked into one column instead. It is still architecturally what
  the menu already was — `buildMainHtml()` enriched, a modal over the title
  screen's own animated hero ship — not a new rendering surface. A default
  player who has unlocked nothing sees exactly what shipped before this pass.

- **The player ship's art is now a supplied raster image**, embedded as a
  `data:` URI WebP (~92KB) with the original drawn hull kept intact as
  `drawShipVector()`, the fallback for the handful of frames before it
  decodes — used after he confirmed he holds commercial usage rights to it.
  Its orientation was backwards as supplied (nose toward the player, not away
  from him); that was caught by screenshot, not by reading the code, and
  fixed by rotating the source asset once rather than patching every call
  site. The app icon was deliberately **not** switched to this art — at 48px,
  its own size on a home screen, the detail reads as a blob where the
  existing vector ship still reads as a clean silhouette — so the icon and
  the live ship now draw different art on purpose; see `app-icon.mjs`.

The visual pass before that:

- **A shared background system** — a moon and a drifting nebula behind the
  stars, used by the title and gameplay both, in place of one static nebula
  image that never moved.
- **The title screen was recomposed**: a large hero ship (the player's own,
  reused through a new `drawShipBody()` rather than a separate asset) banked
  in the gap that used to be dead air, a two-depth-band enemy flyby instead of
  one flat line, and the feature list rebuilt as HUD-styled chips instead of a
  centred bulleted list.
- **Enemies and the player ship both gained a reactor core / rim highlight and
  wingtip lights** — flat gradient shapes read as icons; these read as
  machines under power. The app icon's ship art picked up the same wingtip
  lights so it does not drift from what the live ship looks like.

Before that, on his instruction to make it as good as it can be for the App
Store. The ones that mattered most for a phone:

- **The pause, bomb and volume buttons could not be pressed at all on a touch
  device.** Every handler read `e.touches[0]`, the finger that went down first,
  which during play is always the one steering. Driven with real multi-touch,
  not a mouse — a mouse cannot reproduce it.
- **A cancelled touch left the ship stuck firing.** No `touchcancel` listener,
  so Control Centre or an incoming call jammed the controls on.
- **The wave transition fired every frame** for the 1.5s between the last kill
  and the next spawn. Clearing wave 1 landed you on wave 4 with 310 credits;
  it is wave 2 and 89 credits now. This was the largest single distortion of
  the game's pacing and economy.
- **Touch targets were 27pt** against Apple's 44pt minimum. They measure 45pt
  now, which cost 16 units of play area.
- **Backgrounding the app pauses the run** rather than leaving the player to
  come back into an ambush.

The earlier pass:
- The game has a pause screen (`ESC` / `P` / a button), so Android's back button
  now pauses mid-run instead of minimising. `src/native.js` moved with it.
- The music no longer restarts on every new run; it runs continuously and
  changes intensity instead. It also has a low end now, which it never had.
- The modal close button's duplicate listener is gone.
- Three bugs found while confirming those: enemy bullets moved twice per frame
  (double speed on every difficulty), `Q` was a free unlimited screen-clear, and
  the clean-wave credit bonus always paid out because it compared a value
  against itself.

## Egress

The proxy allows GitHub and package registries. It does not allow the live
site or arbitrary domains, so the rendered page cannot be fetched from here —
build locally and drive Chromium instead of trying to load production. DNS
resolution works; there is no `dig`, so query it from Python if needed.
