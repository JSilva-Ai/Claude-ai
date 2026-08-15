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
- **Boss battles** — every 5th wave, 3 boss variants, rage mode at 50% HP
- **Currency/upgrade shop** — opens every 3 waves. Player earns credits per wave (`50 + wave×15`). 8 upgrades available, priced at `basePrice × 1.05^(wave-1)`. Prices shown on cards, greyed out if unaffordable. Skip button available.
- **Combo system** — kill streak multiplies score, small combo text in bottom HUD
- **Float texts** — small score popups above kills
- **Particle system** — burst, ring, trail particles
- **Leaderboard** — localStorage, top 10, name entry on game over
- **Achievements** — 8 unlockable, stored in localStorage
- **Space music** — Web Audio API synthesis: Am7 pad (8 detuned triangle oscillators), convolution reverb, bell melody (A-minor pentatonic, 24-note phrase, vibrato), shimmer noise. Fades in/out cleanly.
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
  { name:'EASY',   lives:7, spdM:0.7,  fireM:0.5,  hpM:0.6,  scM:0.7  },
  { name:'NORMAL', lives:5, spdM:1.0,  fireM:1.0,  hpM:1.0,  scM:1.0  },
  { name:'HARD',   lives:3, spdM:1.6,  fireM:1.8,  hpM:1.6,  scM:1.6  },
]
```

- `spdM` — enemy AND player move speed multiplier
- `fireM` — enemy fire rate multiplier (higher = enemies shoot more); player fire CD divided by `fireM`
- `hpM` — enemy HP multiplier
- `scM` — score multiplier

---

## Upgrade Pricing Formula

```js
price = basePrice × 1.05^(wave - 1)
```
No per-repeat penalty. Prices grow 5% each wave.

**Base prices:** Hull Plating 65, Rapid Fire 50, Power Core 40, Magnet 55, Score Surge 40, Chain Shot 70, Overdrive 50, Shield+ 45.

**Credit income per wave:** `50 + wave×15` (×1.2 bonus if no damage taken that wave).

---

## Known Issues / Suggested Improvements for Claude Code

1. **Touch controls** — on mobile, the player follows finger X but fires automatically. Consider adding a dedicated on-screen fire button or tap-to-fire.
2. **Music continuity** — music stops and restarts between waves. Could crossfade or keep it running continuously.
3. **No pause** — no pause button/key implemented yet.
4. **Boss variety** — only 1 boss draw routine (`drawBoss`), `btype` field exists but isn't used for visuals.
5. **Wave transition** — currently just a float text; could add a proper wave-clear animation or countdown.
6. **Mobile layout** — upgrade shop cards can be small on narrow phones; consider stacking vertically on portrait mobile.
7. **Save progress** — no mid-game save; everything resets on page reload.
8. **Sound variety** — only one set of SFX per weapon; could vary by combo level or streak.
9. **Enemy patterns** — regular enemies only bounce horizontally; adding formations or dive patterns would add depth.
10. **Leaderboard** — currently local only (localStorage); could integrate a backend for global scores.

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

## Suggested Next Steps for Claude Code Session

- [ ] Add a pause screen (Escape key)
- [ ] Add on-screen mobile fire button
- [ ] Add a high score display on the title screen
- [ ] Add wave transition animation
- [ ] Add enemy formation patterns (V-shape, spiral, grid march)
- [ ] Add a second boss visual variant
- [ ] Persist upgrade purchases across waves (already done) — consider persisting best run stats
- [ ] Add screen-edge warning indicators for off-screen enemies
