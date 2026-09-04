# VOID STRIKER — Claude Code Handoff

## Project Overview
VOID STRIKER is a fully functional single-file browser space shooter game (`void_striker.html`). It was built iteratively in Claude.ai and is ready for further development in Claude Code.

---

## Current State of the Game

### Architecture
- **Single HTML file** — all CSS, JS, and game logic in `void_striker.html`
- **Canvas 2D rendering** — `W=520, H=720` logical pixels, scaled to fill the viewport via DPR-aware canvas
- **No external dependencies** — pure Web Audio API, no libraries

### Features Implemented
- **Fullscreen canvas** fills the entire browser window, responsive to resize/orientation
- **Title screen** — animated, enemy flyby, animated VOID / STRIKER titles, TAP/SPACE to open menu
- **Pilot hub menu** — a pilot rank/level derived from lifetime XP, a daily
  SCRAP claim, difficulty select and START MISSION, then WEAPONS (persistent
  per-weapon fire-rate levels), HANGAR (unlockable ship colour skins),
  ACHIEVEMENTS, RANKINGS (leaderboard) and a volume slider + mute — all still
  the one modal system, see "Pilot hub" below
- **3 difficulty levels** — EASY (7 lives, slower enemies), NORMAL (5 lives), HARD (3 lives, faster/tougher enemies). Difficulty affects enemy speed (`spdM`), fire rate (`fireM`), HP (`hpM`), score multiplier (`scM`), and player move speed.
- **6 weapon types** — normal, spread, laser, plasma, missile (homing), beam. Picked up as powerups during play.
- **8 powerup types** — spread, laser, shield, bomb, speed, plasma, missile, beam
- **Pause** — `ESC` / `P`, or the on-canvas button in the bottom bar. Opens a
  real modal (`id:'pause'`) with the run's stats, RESUME and QUIT TO MENU.
  Dismissing that modal is what resumes, so Android's back button resumes too.
- **Enemy formations** — five movement patterns (LINE, WEAVE, MARCH, DIVE,
  ORBIT) cycling by wave via `formationFor(wave)`. Waves 1–2 stay LINE so the
  game teaches itself. MARCH is the one with shared state — the rank turns
  together, stepped once per frame by `_stepMarch()`.
- **Boss battles** — every 5th wave, rage mode at 50% HP. `btype` selects one of
  six hulls (DREADNOUGHT / MANTA / HIVE CORE / WARLORD / VOID CROWN / GILDED
  WARDEN) in `_drawBossBody`, each its own piece of his art, with
  `BOSS_HW` giving each a travel clamp derived from its own drawn width. See
  "Enemy art" below.
- **Wave transition** — a swept banner naming the wave, its sector and the
  incoming formation, plus the credits awarded (`gs.banner`, `drawBanner()`).
- **Bombs** — a consumable, capped at `CAP.bombs`. The BOMB powerup grants one;
  `Q` or the HUD button spends one.
- **Currency/upgrade shop** — opens every 3 waves. Player earns credits per wave (`50 + wave×15`). 8 upgrades available, priced at `basePrice × 1.05^(wave-1)`. Prices shown on cards, greyed out if unaffordable. Skip button available.
- **Combo system** — kill streak multiplies score, small combo text in bottom HUD
- **Float texts** — small score popups above kills
- **Particle system** — burst, ring, trail particles
- **Leaderboard** — localStorage, top 10, name entry on game over
- **Achievements** — 12 unlockable, stored in localStorage. The title screen
  counts `ACHS.length` rather than carrying a hardcoded number.
- **Personal best** — `vs_best` in localStorage, shown on the title screen.
- **Space music** — Web Audio API synthesis, all of it. A pad of four voices
  (sine low, triangle high), convolution reverb, a triangle-bell melody,
  band-limited shimmer,
  a sub-bass layer (root sine + octave triangle, low-passed at 190 Hz) and a
  kick. The bed is continuous — it does not restart between the title screen
  and a run — and `musicIntensity(0..1)` swells it rather than switching it.
  The harmony moves: **Am – F – C – G**, two bars each at 70 BPM, with the pad
  and bass oscillators gliding between chord tones on `setTargetAtTime` rather
  than restarting, so a chord change is felt and not heard as an edit. One
  eighth-note clock drives every part, so nothing can drift out of time with
  anything else.
- **The melody breathes.** A six-note hook opens each four-bar cycle; the two
  bars after it are sparse and semi-random from the pentatonic; the fourth bar
  is **silent**. Verified from outside the engine by counting voice starts per
  bar: 12 on the hook bar (six notes, each with its vibrato oscillator), 4 on
  the sparse bars, 0 on the rest bar.
- **The pad is scooped and it breathes.** Measured off a recording of the
  real game: 200-800 Hz sat 13 dB above everything from 800 Hz to 2.5 kHz and
  never moved — a boxy drone, the band the ear tires of first, masking
  everything above it. Three changes: a -9 dB peaking scoop at 400 Hz **on the
  pad alone** (across the whole music bus it takes the body out of the melody
  with the mud), eight droning triangles cut to four voices, and a per-chord
  envelope that swells the pad in over 1.1 s and lets it fall back before the
  next chord instead of sustaining flat. Result, measured the same way:
  200-800 Hz down 9.6 dB and no longer the loudest band, crest factor
  3.65 → 5.57, and the spread of 100 ms loudness blocks 4.7 dB → 10.3 dB.
- **Music and effects have separate levels**, persisted, on top of the master.
- **`scripts/audio-probe.mjs` measures any of this.** It taps the game's own
  destination node and reports peak, RMS, crest factor, five band means and
  the spread of 100 ms loudness blocks; `--file=` points it at a screen
  recording instead, which is how the drone was found. Two traps are
  documented in its header: the tap must be installed from `addInitScript`,
  and a spectral centroid off `getByteFrequencyData` is level-dependent and
  will tell you a quieter mix is a darker one.
- **Render resolution adapts.** The backing store is sized from the box the
  canvas occupies, not from the logical 520x720 — sizing it from the logical
  size meant a 390pt iPhone drew 1560x2160 for a 1170x1620 display and ran at
  6.7 fps. `_rscale` steps the buffer down when frames are slow and back up
  when there is headroom, judged on the frame interval (Canvas 2D work is
  deferred, so timing update+draw reports a comfortable 3 ms on a device
  visibly running at 10) against a threshold above the 16.7 ms vsync floor.
- **One home screen.** The game used to open on a title card — wordmark,
  feature chips, personal best, TAP TO START — and the hub was a second screen
  behind it, so it cost a tap before showing anything you could act on. The
  card is gone. The hub opens on load and is the game's first screen; the
  canvas behind it draws the scene the reference art shows in the middle (the
  squadron and the player's ship under thrust) and the hub floats over it with
  its middle left open as a window. Nothing on the canvas is tappable there.
- **The pilot hub follows the supplied reference**: pilot card and scrap, the
  skewed wordmark, three decks (weapons at their real bullet colours, the
  hangar drawing the equipped skin, the daily reward), a clipped mission bar,
  and a five-tile nav — weapons, hangar, awards, ranks, sound.
- **Output chain** — `sfx → compressor → high shelf ─┐`, `music → duck ─┴→
  master → limiter → destination`. Explosions, bombs, bosses, wave changes and
  game over duck the music and let it back up.
- **SFX** — shoot (per weapon type), hit, kill, explode, combo, wave start,
  boss, upgrade, game over, shield, bomb. Every voice is detuned a few percent
  so no two are identical; a cue repeated inside 0.3 s comes back progressively
  quieter and recovers after a moment's quiet; and no more than 14 voices may
  sound at once.
- **Volume control** — slider in menu + mute toggle, persisted in localStorage
- **Screen shake** on damage/explosions

---

## File Structure (inside `void_striker.html`)

```
<style>         — All CSS: fullscreen canvas, modal overlay, upgrade shop, HUD
<canvas #c>     — Main game canvas
<div #modal>    — Shared modal overlay (menu, leaderboard, achievements, game over)
<div #toast>    — Achievement toast notification

<script>
  ├── AUDIO ENGINE          — initAC(), _master()/_sfxOut()/_musicOut(), osc(), noise()
  │                           _voice() voice budget, _repGain() repeat damping, duckMusic()
  ├── SPACE MUSIC           — musicStart(), musicStop() — pad + bass + melody + kick + shimmer
  ├── SFX                   — SFX.shoot/hit/kill/explode/upgrade/etc
  ├── ACHIEVEMENTS          — ACHS[], _ach{}, unlock(), renderAchievements()
  ├── LEADERBOARD           — lbLoad/lbSave/lbAdd(), renderLeaderboard()
  ├── MODAL SYSTEM          — openModal/popModal/closeAllModals(), _attachModalEvents()
  ├── UPGRADE SHOP          — ALL_UPG[], _upgBought{}, getUpgradePrice(), drawUpgradeShop(), selectUpgrade()
  ├── MATH HELPERS          — rand, lerp, clamp, dist, rGrad, lGrad
  ├── PARTICLES             — burst(), ring(), trail()
  ├── STARS / NEBULA        — makeStars(), buildNebula()
  ├── DRAW FUNCTIONS        — drawBG, drawShip, drawEnemy, drawBoss, drawBullet, drawPowerup, drawHUD, drawTitle, drawUpgradeShop
  ├── WAVE FACTORY          — makeEnemyWave(wave)
  ├── GAME STATE            — gs{} object
  ├── startGame(diff)       — resets gs, starts music, spawns wave 1
  ├── UPDATE LOOP           — update() — movement, shooting, collisions, powerups, particles
  ├── _nextWave()           — credit award, wave increment, unlock achievements, open upgrade shop
  ├── DRAW LOOP             — draw() — bg → particles → enemies → bullets → ship → HUD
  ├── INPUT                 — keydown/keyup, touchstart/move/end, canvas click
  └── MAIN LOOP             — requestAnimationFrame(loop)
```

---

## Key Variables / Game State (`gs` object)

```js
gs = {
  phase,          // 'title' | 'playing' | 'gameover'
  score, wave, lives, combo, comboTimer,
  credits,        // in-game currency
  difficulty,     // 0=easy, 1=normal, 2=hard
  player: { x, y, inv, shield, speedT },
  weapon,         // 'normal'|'spread'|'laser'|'plasma'|'missile'|'beam'
  weaponT,        // frames remaining on current weapon
  shootCD,        // fire cooldown frames
  bullets[],      // { x, y, vx, vy, type, r, pierce, enemy?, col? }
  enemies[],      // { x, y, ty, type, hp, maxhp, alive, boss, st, ... }
  parts[],        // particles
  powerups[],     // { x, y, vy, type, life, r }
  floats[],       // floating score texts
  upgradePhase,   // bool — upgrade shop open
  upgChoices[],   // current 3 upgrade options
  paused,         // bool — pause screen open; update() returns early
  bombs,          // consumable screen-clears in hand, capped at CAP.bombs
  cleanWave,      // no life lost this wave — drives the credit bonus
  banner,         // wave-transition banner, or null
  marchX/marchDir/marchDrop,  // shared state for the MARCH formation
  weaponTMax,     // denominator for the weapon gauge
  fireBonus,      // multiplier: lower = faster fire (from Rapid Fire upgrade)
  wpnBonus,       // weapon duration multiplier
  scBonus,        // score multiplier
  spdBonus,       // move speed multiplier
  pierce,         // bullet pierce count
  magnet,         // bool — powerups attracted to player
  missileN,       // homing missile count
}
```

---

## Difficulty Config

```js
DCFG = [
  { name:'EASY',   lives:7, spdM:0.7, fireM:0.5, hpM:0.6, scM:0.7, bulletM:0.78 },
  { name:'NORMAL', lives:5, spdM:1.0, fireM:1.0, hpM:1.0, scM:1.0, bulletM:1.00 },
  { name:'HARD',   lives:3, spdM:1.6, fireM:1.8, hpM:1.6, scM:1.6, bulletM:1.25 },
]
```

- `spdM` — enemy AND player move speed multiplier
- `fireM` — enemy fire rate multiplier (higher = enemies shoot more); player fire CD divided by `fireM`
- `hpM` — enemy HP multiplier
- `scM` — score multiplier
- `bulletM` — enemy bullet speed multiplier

### Wave scaling — `BAL`

Difficulty over a run is a set of bounded curves rather than open-ended linear
growth. `waveRamp(wave, per, cap)` approaches `cap` and never passes it:

```js
BAL.enemyDrift(w)    // 1    -> 1.85   horizontal speed multiplier
BAL.enemyFireGap(w)  // 88   -> 36     frames between enemy shots
BAL.enemyBullet(w)   // 2.4  -> 4.6    enemy bullet px/frame
BAL.bossFireGap(w)   // 54   -> 24     frames between boss shots
BAL.bossBullet(w)    // 2.8  -> 5.2    boss bullet px/frame
```

Difficulty scales *where the curve settles*, not how steep it is, so EASY and
HARD differ in their ceiling rather than in whether wave 40 is reachable.

`CAP` holds the ceilings for stacked upgrades:
`{fire:.45, score:3, speed:1.8, pierce:4, wpn:3, lives:8, shield:640, bombs:3}`.

---

## Upgrade Pricing Formula

```js
price = basePrice × 1.05^(wave - 1) × 1.35^(timesBought)
```
Prices grow 5% each wave and 35% per repeat purchase of the same upgrade. The
repeat term used to be computed and then left out of the return, so stacking one
upgrade was strictly the best play.

**Base prices:** Hull Plating 65, Rapid Fire 50, Power Core 40, Magnet 55, Score Surge 40, Chain Shot 70, Overdrive 50, Shield+ 45.

**Credit income per wave:** `CREDITS_BASE + wave×CREDITS_PER_WAVE` (50 + wave×12),
×1.2 if the wave was cleared without losing a life. The clean-wave test used to
compare `gs.lives` against a `prevLives` that had just been set to it, so the
bonus always paid out; it now reads `gs.cleanWave`, which `_hitPlayer` clears
only when a life is actually lost (a shield absorbing a hit does not count).

---

## Fixed

Confirmed by driving the built game in Chromium, not by reading. The touch
findings were driven with real multi-touch through the Chrome DevTools Protocol
in a mobile context, because none of them reproduce with a mouse.

**Nothing in the interface was large enough to read on a phone.** Measured
rather than judged: the canvas is 520 units wide and scales to 0.75 on a 390pt
iPhone, so the game's 6-9px labels rendered at 4.5-6.7pt and its 11-15px values
at 8-11pt, against Apple's 11pt floor. Thirty of thirty-four type declarations
were under it. There is now a stated scale — `TYPE` in the game, and the modal
CSS alongside it — built as a hierarchy rather than a uniform multiplier, since
a multiplier does not fit: the three values a player reads mid-fight get real
size, captions shrink to the smallest thing that still reads as a label, and two
captions were deleted outright because an eight-digit gold number is a score and
a row of ship pips is lives.

Also in that pass:

- The **top bar grew** 48 to 62 units to buy the room, and lives moved under the
  score where they have the left third to themselves.
- The **upgrade shop lost its three-column layout**, which put upgrade names at
  7px and descriptions at 6.5px — 5pt on a phone. One full-width column, always.
- Its **skip control**, a 28-unit strip of 8px text at 35% opacity, became a
  real 56-unit CONTINUE button.
- **"STRIKER" overflowed the canvas.** The wordmark was a fixed `900 72px`, and
  at that size the final R was cut off by the right edge. It is fitted to width
  now, which also survives the first paint before the webfont loads.
- The **title's MENU and mute glyphs** drew on top of the animated corner
  brackets. Both are inset past them.
- The **feature list** centred each line with its own bullet, so the bullets
  zig-zagged. It is measured and left-aligned as a block.

**The wave transition fired every frame.** `allDead` stays true from the frame
the last enemy dies until the next wave spawns 1.5 seconds later, and
`_nextWave()` ran on every one of those ~90 frames. One cleared wave advanced
the counter by dozens, paid dozens of credit awards, and opened the upgrade shop
as soon as one of the phantom waves landed on a multiple of three. Measured
before the fix: clearing wave 1 left the game on **wave 4 with 310 credits**.
After: **wave 2 with 89 credits**. `gs.waveEnding` latches the transition until
the next wave actually exists.

**Three multi-touch defects, all of which made the game worse on a phone than
in a browser:**

- Every touch handler read `e.touches[0]` — the finger that went down *first*,
  which during play is always the one steering the ship. Every later tap was
  evaluated at the steering finger's position, so the pause, bomb and volume
  buttons **could not be pressed at all** on a touch device.
- `touchend` cleared the controls unconditionally, so lifting any second finger
  stopped the ship moving and stopped it firing.
- There was no `touchcancel` listener. A touch cancelled by the system — an
  incoming call, Control Centre — left the ship stuck following and firing with
  nothing to release it.

Each finger is now handled from `changedTouches` on its own terms, and the
steering finger is tracked by identifier.

**Touch targets were 27pt.** The three HUD buttons were 44x36 game units, and
the canvas scales to 0.75 on a 390pt iPhone — 33x27pt against Apple's 44pt
minimum. The bar is 62 units now and the buttons are 60 square, which measures
45x45pt on that phone. The ship's lower travel limit moved up to match so it
never sits underneath a button.

**The lives row ran under the wave counter.** One icon per life at 16px from
x=120 with no cap reached x=248 at 8 lives (an EASY start plus one Hull
Plating); the centred WAVE readout starts near 232.

Earlier findings, from the first pass:

1. **The modal close button had two click listeners**, both calling `popModal()`,
   so the ✕ popped two levels. Opening the leaderboard from the menu and closing
   it landed on the title screen. One bind now.
2. **Enemy bullets moved twice per frame.** The main bullet loop moved every
   bullet, then a second block moved the enemy ones again — so every enemy shot
   travelled at double its nominal speed, on every difficulty.
3. **`Q` was a free, unlimited screen-clear** with no cooldown and no cost:
   three presses cleared any wave. It is a consumable now.
4. **The clean-wave credit bonus always paid out** — see "Credit income" above.
5. **`unlock('')`** was called every wave below 5 (`unlock(gs.wave>=5?'wave5':'')`),
   writing an empty key to localStorage and playing the achievement sound.
6. **The weapon and shield gauges overflowed their tracks** — both were drawn
   against hardcoded maxima that upgrades push past.
7. **The combo counter was drawn over the shield gauge**, both centred in the
   bottom bar.
8. **`window.startGame` did not clear the modal stack**, so calling it any way
   other than the menu's own START button left a modal underneath the run.
9. **The Manta boss hung off the right edge** — the boss travel clamp was a flat
   ±80 for every hull.
10. **No pause**, **no formations**, **one boss visual**, **no wave transition**,
    **thin upgrade-shop cards on a narrow screen**, **thin shot SFX**, **music
    restarting on every new run** — all addressed above.

## Visual overhaul

On his instruction that the game needed to look dramatically better, and that
the title screen specifically read as flat — a centred text stack over a
starfield, no focal point, no sense of scale. Confirmed by screenshot at each
step, not by reading the canvas calls.

**A shared background system**, used by both the title and gameplay:

- `buildNebula()` now bakes a bigger canvas (a margin past every edge) so
  `drawBG()` can drift the draw position a few pixels a frame — a slow sine on
  x and y — without ever exposing a seam. The old nebula was one static image
  and never moved.
- `buildMoon()` bakes a lit moon/planet backdrop once, drawn behind the stars
  at a slower drift than the nebula — the classic parallax cue that something
  in the scene is much further away than the rest. It shows during gameplay
  too, and stayed legible against it in testing: the moon is flat and pale,
  the game's own bullets and enemies are saturated neon, so contrast holds.
- `makeFlareStars()` adds a handful of brighter stars drawn with a four-point
  flare and their own twinkle, rather than every star being the same filled
  square.

**The title screen was recomposed, not just re-skinned:**

- `drawShip()` used to translate straight to `gs.player.x/y` and draw from
  there, so nothing else could reuse it. The body — hull, wings, canopy,
  thruster — is now `drawShipBody()`, callable at any position and scale via
  `ctx.translate`/`ctx.scale`, with `drawShip()` reduced to a thin wrapper.
  That is what let the title screen add a large hero ship — the player's own,
  not a separate asset — banked gently, engine lit, in the gap between the
  tagline and the button that used to be dead air.
- The wordmark gained a breathing hex halo behind it, a holographic sweep
  clipped to its own bounding box, and a slow trickle of embers off its base
  and the hero ship's engine. The embers are a self-contained array
  (`_titleEmbers`) rather than `gs.parts`, because `update()` only advances
  particles while `gs.phase==='playing'` — anything pushed into `gs.parts` on
  the title screen would sit frozen forever.
- The enemy flyby became two depth bands (`_titleEn[].band`) — a near band of
  four, brighter and faster, and a far band of five, dimmer and slower — in
  place of six ships in one line at one speed and size.
- The feature list became five chips styled like the game's own HUD buttons
  (filled panel, coloured stroke, glyph) instead of a centred bulleted list,
  sitting on its own backing panel.
- Getting the vertical budget to fit was its own pass: the first version
  pushed the button and best-score text past the bottom of the 720-unit
  canvas because "YOUR BEST" was drawn below the button. It moved above the
  button instead — a compact single line — and every offset below the
  wordmark was fixed against its measured height (`markBottom`, ~271 of 720)
  rather than guessed.

**Enemies gained a reactor core and a rim highlight** — `drawEnemy()`'s
non-boss branch was a flat gradient wedge/hexagon/disc with a coloured
outline; it now has a small hot point near centre and a highlight along the
upper-left edge, on every enemy on screen, at the cost of one extra clipped
fill per enemy. The player ship picked up matching wingtip lights and thin
panel-line strokes in `drawShipBody()`.

**The app icon's wingtip lights were added to match** — `scripts/render/app-icon.mjs`
keeps its own copy of the ship paths (see the Capacitor section of
`CLAUDE.md`), so the two would otherwise drift. Its panel lines were not
copied over: at 48px the icon's own doc reasons carefully about staying
legible, and thin dark strokes inside a small blue triangle read as mud at
that size, not detail.

Re-verified after: the touch-target and wave-progression Playwright suite (not
committed — same one referenced above), `npm run check`, `npm run demo`, and
in `mobile/void-striker/` `npm run sync` and `npm run verify`. The app store
stills and clip were regenerated; `src/content/site.ts`'s alt text was
rewritten from the new stills.

## Ship art

On his instruction to use a specific supplied image — a detailed painterly
sci-fi fighter render — as the player ship's own art, after confirming he
holds commercial usage rights to it (asked directly before any of this
landed, since the site publishes under a company name).

- **Embedded, not linked.** The game is one file with zero external
  dependencies by design, so the asset had to travel the same way everything
  else in it does: as a `data:` URI. The source PNG (1536×1024, 1.97MB) had
  nothing worth cropping — its alpha bounding box was almost the full frame —
  so the only lever available without visibly softening a detailed painterly
  image was format: re-encoded as WebP at 900×600 it holds up at every size
  the game draws it, including the title screen's large hero shot, at ~92KB —
  roughly a fifth the size of the same dimensions as PNG. The file grew from
  ~99KB to ~238KB.
- **`drawShipBody()` now dispatches**, not draws directly: `drawShipRaster()`
  once the image has decoded, `drawShipVector()` (the previous drawn hull,
  kept intact) for the handful of frames before it has. Both call sites —
  `drawShip()` and the title screen's hero ship — needed no changes, since
  both already went through `drawShipBody()` from the earlier visual-overhaul
  pass.
- **The source art's orientation was backwards, and reading the art missed
  it.** The game's ship convention is nose at negative local y (up, away from
  the player), engine at positive local y (down, toward the player) — the
  title screen's ember spawn point and the live engine trail are both
  positioned on that assumption. Drawn as supplied, the ship's single-cone
  nose pointed down (toward the player) and its twin engine plumes pointed up
  (toward the enemies) — flying backwards. This was not obvious from the
  embers alone: a trail of particles falling away from *any* pointed tip reads
  as plausible exhaust, whether or not that tip is actually the engine. It was
  only confirmed by comparing a cropped, zoomed screenshot of the live ship
  against the documented convention, then double-checked from the icon-scale
  render where the same two ends are unambiguous at full size. Fixed once, by
  rotating the source asset 180° before the WebP re-encode, rather than adding
  a compensating rotation to every draw call.
- **The app icon was deliberately not switched to this art.** Tested at 48px —
  the icon's actual size on a home screen — the detailed raster reads as an
  indistinct glowing blob, where the existing procedural vector ship
  (`scripts/render/app-icon.mjs`) still reads as a clean, recognizable
  silhouette at the same size. The two now draw different ship art on
  purpose; see the updated reasoning at the top of `app-icon.mjs`.

Re-verified after: the touch-target and wave-progression Playwright suite
(confirms `_shipImgReady` actually flips true, not just that the file
parses), `npm run check`, `npm run demo`, and in `mobile/void-striker/`
`npm run sync` and `npm run verify`. The app store stills and clip were
regenerated from the corrected build.

## Pilot hub (persistent meta-progression)

On his instruction to use a supplied reference image — a much busier,
landscape desktop game-hub screen with a pilot profile, permanent weapon
levels, ship customization and a daily reward — as an example for a more
modern home screen. Confirmed first that this meant building the actual
systems the reference implied (rank, persistent currency, weapon and ship
progression), not just its visual language.

The reference itself could not be used as-is: it is a landscape layout with
a pilot panel and a live gameplay panel side by side, and this game's canvas
is 520x720, fixed by the App Store stills, the demo clip and the site's
phone frame. The same ideas are stacked into one column instead — a pilot
identity with rank and level, a daily reward, and two new destinations
(Weapons, Hangar) added to the existing button list — and it is still
exactly what it already was architecturally: `buildMainHtml()` enriched, a
modal over the title screen's own animated hero ship, using the same
`_modalStack`/`openModal`/`popModal` plumbing every other screen already
used, not a second rendering surface.

**A second, persistent currency.** The run's own credits — earned wave to
wave, spent in the shop that opens every third wave, zeroed at game over —
were tuned carefully in an earlier pass and are untouched. SCRAP is separate:
paid out once at game over from that run's score and wave
(`Math.round(score/30)+wave*20`), together with lifetime XP (`_xp+=score`),
both in `localStorage` alongside the achievements/best-score/leaderboard keys
that already lived there.

**Rank and level both read from lifetime XP** rather than storing their own
number, so neither can drift out of sync with it: `pilotLevel()` is
`1+floor(sqrt(xp/300))`, a quadratic curve so early levels come fast, where a
new player notices them, and it stretches out rather than becoming a wall.
Six rank names (ROOKIE through LEGEND) band over the level.

**Weapons screen** — the five special weapon types (spread, laser, plasma,
missile, beam; the always-available base weapon is not one of these) each
have a persistent level, 1 to 5, bought with SCRAP at
`round(120*level^1.7)`. A level is a permanent bonus to that weapon's fire
rate whenever it is active in a run — up to 20% faster at level 5 — layered
on top of the fire-rate stacking the in-run shop already does
(`dc.fireM`, `gs.fireBonus`). It does not change how a weapon is obtained:
still a mid-run pickup, exactly as before. This is worth being explicit about
in the screen's own copy, since "permanent weapon levels" could otherwise
read as permanent possession.

**Hangar / ship skins** — the only ship art that exists is the one supplied
and embedded raster image, so "customize the ship" could not mean choosing
between different ships. Confirmed this meant recolour presets instead: four
skins (Standard Blue, default; Void Violet, unlocked at level 5; Solar Gold
and Crimson Ace, bought with SCRAP), applied by recolouring the raster art
with a canvas `'hue'` composite (keeps the source art's own shading and
metal highlights, shifts only the colour family) then clipped back to the
original silhouette with `'destination-in'` so the tint cannot bleed past the
ship's own edges. Recoloured once per skin onto an offscreen canvas
(`_tintedShipCanvas`, cached in `_shipSkinCache`) rather than per frame.
`drawShipRaster()` draws the cached tinted canvas for the equipped skin, or
the plain decoded image for the default — so a player who has unlocked
nothing sees exactly what shipped before this pass, in the hangar preview,
the title's hero ship and live gameplay alike.

**Daily reward** — a flat timestamp in `localStorage`
(`Date.now()-last>=86400000`), 250+10×level SCRAP, claimable once every 24h.
The hub polls a one-second `setInterval` only while its own countdown is on
screen, cleared at the top of `_attachModalEvents` on every modal render —
regardless of which way the player left the hub — so it cannot keep ticking
in the background after navigating away.

Verified: a new Playwright suite (`hub-suite.mjs`, not committed) seeded a
progression state that exercises every branch — a level-locked skin now
unlocked, a scrap-locked skin both affordable and not, a weapon level
actually spending SCRAP, the daily reward claiming and flipping to its
countdown — plus the existing touch-target and wave-progression suite, to
confirm none of this touched an interaction path outside the new modals. Two
real issues surfaced this way, not by reading the code: the new weapon icons
had no `color` set and were rendering black-on-navy, and disabled hub buttons
(`EQUIPPED`, a locked skin, an unaffordable one) had no `:disabled` styling
and looked identical to active ones. Both fixed in the CSS. `npm run check`,
`npm run demo`, and in `mobile/void-striker/` `npm run sync` and
`npm run verify` all pass; the App Store stills and demo clip were not
regenerated because the default, unlocked-nothing appearance — what those
capture — is pixel-identical to before this pass.

## Enemy roster — the drawn hulls (now the fallback)

> Superseded as what the game actually shows: every hull below is now the
> fallback behind his own art. See "Enemy art" further down. The reasoning is
> kept because the shapes are still what draws for the frames before the art
> decodes, and still what the app icon is built from.

### How they came about

On his instruction to use a set of sixteen reference renders — his own art,
New AI Vision Labs' — as the model for enemy ships, and to create more
himself. Two of the sixteen were pasted into chat rather than attached as
files, and this environment never gave either one a path on disk the way the
player ship's source image had one — no crop, no pixel read, no embed was
possible. Confirmed his rights to the art regardless, since the right way
forward turned out not to need the files: redrawn as new procedural vector
hulls, the same technique `_drawBossBody()` and `drawEnemy()` already used
for every hull in the game, informed by what the sixteen images showed
rather than copied from them pixel for pixel.

- **Three new boss hulls, doubling the roster from three to six**: SPIDER
  QUEEN (molten red/orange, twin-clawed swept wings, three trailing engine
  flames), VOID CROWN (wide violet blade-wings, a single spike trailing
  light) and GILDED WARDEN — the same crown silhouette as Void Crown, in
  blue and gold with a string of small glow-nodes lit along each wing,
  matching how the reference art used the same two hull families in
  different colour palettes. `BOSS_TYPES`, `BOSS_NAMES` and `BOSS_HW` all
  extended to six; `makeEnemyWave()`'s boss selection now cycles
  `%BOSS_TYPES` instead of a hardcoded `%3`.
- **The first draft of all three read as rounded blobs, not bladed hulls** —
  caught by screenshot, not by reading the bezier calls. Smooth
  `bezierCurveTo()` sweeps were softening exactly the sharp claw and wing
  points that make the reference art's silhouettes distinctive. Redrawn as
  zigzag polygons — sharp `lineTo()` points, the same technique
  DREADNOUGHT's dodecagon already used — with a thin stroke along the edge
  to hold the silhouette together at a glance. The difference is visible
  side by side: soft gradient bulge versus a hull with real edges.
  A boss patrols side to side at a fixed height rather than flying toward
  the player the way a normal enemy does, so "which way does it face" isn't
  a real question here the way it was for the player ship — every existing
  hull in this file reads its own core/glow sitting near the top of local
  space and the silhouette tapering toward the bottom (the wedge enemy's
  apex is up, the Manta's core sits at (0,-6)), and the three new ones
  follow that same rule rather than importing a travel-direction convention
  that does not apply to a boss.
- **A fourth regular-enemy shape** — a small radial "reactor orb" (a core
  ringed by four short claws), the fourth family across the reference art
  and a natural fit for the ORBIT formation, which already has no fixed
  facing to get right or wrong. `shapePath()`'s three-way shape switch
  became a four-way one (`e.type%4` instead of `%3`); `EC[]`'s six colours
  still apply independently of shape, so this is 4 shapes × 6 colours now
  rather than 3 × 6. Kept deliberately as plain as the other three: a wave
  can put a dozen of these on screen at once, and the existing shapes are
  simple on purpose so a busy wave stays readable — this follows that same
  rule rather than importing the reference art's full level of detail down
  to a 12px enemy.
- **Boss HP and speed steps per `bt` were rebalanced for the wider range.**
  The old formula (`36+bt*28` HP, `1.6+bt*.5` speed) was calibrated for
  `bt` spanning 0-2; carried unchanged into a 0-5 range it would factor of
  2.5 the spread between the easiest and hardest hull in a single cycle.
  Scaled down to `36+bt*12` and `1.6+bt*.2`, so a full six-hull cycle's
  spread stays close to what the three-hull cycle's already was.
- **A real fight, not just a render**: a Spider Queen was spawned into a
  live run, actually fired on and killed through the game's own damage
  path — confirms the new hulls work as enemies, not only as art.
- **A capture-game.mjs regression, found and fixed while regenerating the
  App Store stills for this pass**: it looked for a button whose *text*
  included "START GAME" to begin a capture run, and the pilot hub (the
  previous pass) renamed that button to "START MISSION" without updating
  this script — it broke silently until the next capture ran, which was
  this one. Fixed to click `#btn-start` by id instead, which survives a
  label rename the way matching the button's own copy cannot.

Verified: the touch-target and wave-progression Playwright suite, plus a new
check that all six `btype` values are actually reachable across two full
30-wave boss cycles rather than trusting the modulo by reading it.
`npm run check`, `npm run demo`, and in `mobile/void-striker/` `npm run
sync` and `npm run verify` all pass. Stills and clip regenerated.

## Enemy art

His own renders — New AI Vision Labs' — finally in the game as themselves
rather than as an approximation of themselves.

**Why the first attempt was not this.** He first sent sixteen reference
renders pasted into chat. Pasted images arrive as something to look at, not as
a file with bytes on disk, and embedding art needs bytes: to crop it, re-encode
it, base64 it into the HTML. So that pass hand-drew vector hulls "in the style
of" what the references showed, which is what shipped, and which he correctly
called out as not matching. The fix was route, not effort: he committed the
sixteen PNGs to the repo, and a file in the repo is a file this session can
actually read. That is worth remembering — **for art, the repo is the reliable
channel; pasting into chat is not.**

- **All sixteen live in `game/art/enemies/`** as the committed source, named
  for their role (`boss-0-dreadnought.png`, `enemy-3-orb-ember.png`, …). Four
  are `spare-*`: good art with no slot yet, kept versioned rather than dropped.
- **Six bosses and six regular enemies** are embedded as WebP data URIs, the
  same route the player's ship takes — this game is one file that makes no
  external request, and the native build's verify step asserts exactly that,
  so art travels inline or not at all.
- **Encoded to what the game draws, not to the source.** A boss is at most
  ~155 units across and a regular enemy 36, which at 2x device pixels is 310
  and 72; bosses are stored at 260 wide and the small ships at 110. 260 was
  measured rather than guessed — rendered at the size a boss actually occupies
  on screen, 260 and 320 are indistinguishable and 260 is a third smaller.
  Lowering the WebP *quality* knob was tried first and barely moved the file
  (37KB → 34KB): with alpha-heavy art at this detail, resolution is the lever
  and quality is not. The twelve come to 195KB, and the game file went from
  258KB to 525KB.
- **None of them needed rotating.** Every one of the sixteen already pointed
  nose-up with its engines trailing down, which is this game's own convention —
  unlike the player ship, whose source art faced backwards and had to be
  rotated 180° before encoding.
- **`BOSS_HW` is now derived from each hull's drawn width** rather than
  hand-tuned per hull, so the travel clamp and the art cannot drift apart. A
  test asserts each boss's edge lands within the screen at both ends of its
  patrol; all six land exactly on the boundary.
- **`EC[]` was recoloured to the art.** Those six colours drive kill bursts and
  hit sparks, so a ship now explodes in its own colour instead of the old
  vector palette's.
- **Rage keeps its tell** without a coloured overlay: the hull is redrawn
  additively onto itself, which confines the brightening to the hull's own
  alpha. A rectangle of red would have lit up the transparent frame around it
  too.
- **Slot 3 was renamed SPIDER QUEEN → WARLORD**, because the art that landed
  there is a red triple-pod gunship and the spider silhouette went to HIVE
  CORE, which it fits better.
- **Hitboxes were not touched.** Enemies stay at `hr=17` and bosses at `hr=42`;
  the art is sized to sit inside what was already tuned, so this is a visual
  swap and not a difficulty change.

Verified: the touch-target and wave-progression suite, plus new checks that all
twelve images actually decode (not merely that the file parses) and that the
boss clamp keeps every hull on screen; a live boss fought and killed through
the real damage path; `npm run check`, `npm run demo`, and in
`mobile/void-striker/` `npm run sync` and `npm run verify` — the last of which
is the one that matters for data URIs, and still reports no off-device
requests. Stills and clip regenerated.

## Still open

1. **Save progress** — no mid-game save; everything resets on page reload.
2. **Leaderboard** — local only (localStorage); a backend would make it global.
3. **Sound variety** — one set of SFX per weapon; could vary by combo level.
4. **On-screen fire button** — mobile still auto-fires while a finger is down.
   The bottom bar now carries pause, bomb and volume, so a fire button needs a
   layout decision rather than just a hit zone.
5. **No test suite.** What exists is a Playwright harness used to confirm each of
   the fixes above; it was not committed. Ask if you want it in the repo.

---

## How to Run

Open `void_striker.html` directly in any modern browser. No build step, no server required.

```bash
open void_striker.html        # macOS
start void_striker.html       # Windows
xdg-open void_striker.html    # Linux
```

Or serve locally:
```bash
npx serve .
python3 -m http.server 8080
```

---

## Suggested Next Steps

- [ ] On-screen fire button, which needs the bottom bar re-laid out
- [ ] Mid-run save, so a closed tab does not destroy a long run
- [ ] Screen-edge warning indicators for off-screen enemies
- [ ] SFX that vary with combo level
- [ ] A fourth boss hull, once three have been seen in a real run

## After changing the game

The generated copies are never edited. From the repo root:

```
npm run demo                       # self-hosts the fonts into public/demo/
npm run check                      # typecheck + lint
node scripts/render/capture-game.mjs --shots   # only if the visuals changed
node scripts/render/capture-game.mjs           # regenerates the clip + poster
```

and in `mobile/void-striker/`: `npm run sync` then `npm run verify`.

The stills and the clip are committed and the site serves them, so a visual
change that is not re-captured leaves the site showing a build that no longer
exists. `src/content/site.ts` carries their alt text and the game's description;
both are written from the software and have to move with it.
