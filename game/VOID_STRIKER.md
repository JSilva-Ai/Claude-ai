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
- **Modal menu system** — START GAME, RANKINGS (leaderboard), ACHIEVEMENTS, volume slider + mute
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
  three drawn hulls (DREADNOUGHT / MANTA / HIVE CORE) in `_drawBossBody`, and
  `BOSS_HW` gives each its own travel clamp.
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
- **Space music** — Web Audio API synthesis: Am7 pad (8 detuned triangle
  oscillators), convolution reverb, bell melody (A-minor pentatonic, 24-note
  phrase, vibrato), shimmer noise, a sub-bass layer (55 Hz sine + 110 Hz
  triangle, low-passed at 190 Hz) and a kick on the beat. The bed is continuous
  — it does not restart between the title screen and a run. `musicIntensity(0|1)`
  gates the kick and is what makes the same track read as menu music in one
  place and combat music in the other.
- **SFX** — shoot (per weapon type), hit, kill, explode, combo, wave start, boss, upgrade, game over, shield, bomb
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
  ├── AUDIO ENGINE          — initAC(), _master(), playTone(), noise()
  ├── SPACE MUSIC           — musicStart(), musicStop() — pad + melody + shimmer
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
