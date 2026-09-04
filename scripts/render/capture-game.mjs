/**
 * Records a game to a looping clip at the site's standard media size.
 *
 *   node scripts/render/capture-game.mjs [--seconds=14] [--fps=60] [--keep-frames]
 *   node scripts/render/capture-game.mjs --shots
 *
 * Output, into public/media/games/void-striker/:
 *   clip.webm    VP9
 *   clip.mp4     H.264, for Safari
 *   poster.jpg   first drawn frame, for the <video> poster
 *
 * With --shots, into public/media/apps/void-striker/:
 *   01..04.jpg   stills, pulled from the same stepped run
 *
 * The stills are frames of the same take rather than a separate staged
 * session, which is the point: they cannot drift out of sync with the clip or
 * show a version of the game that no longer exists.
 *
 * ---
 *
 * Why frames are pulled one at a time instead of screen-recorded.
 *
 * The game's loop is `update(); draw(); requestAnimationFrame(loop)` and its
 * clock is `gs.t++` — one rAF is one game step, and nothing reads wall-clock
 * time. So rAF is replaced with a queue this script drains by hand: step once,
 * screenshot, step again. The result is exact at any capture speed, and a
 * headless machine that renders at 6 fps still produces a clip that plays at
 * the right speed.
 *
 * A MediaRecorder capture cannot do this. It timestamps by wall clock rather
 * than by the frame it was asked to record, so under software rasterisation it
 * produces clips several times longer than the run, each playing at its own
 * wrong speed, dropping frames whenever the encoder falls behind. That failure
 * is why the previous set of clips in this repo were re-done this way.
 *
 * The clip fades from and to black so the loop point is a clean cut rather than
 * a jump — gameplay state cannot match across a seam, so the seam is hidden
 * instead of pretended away.
 */

import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readdirSync, rmSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import ffmpeg from 'ffmpeg-static';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);

/** The site's standard game-media size. Keep in step with --media-w/h in tokens.css. */
const W = 520;
const H = 720;
const FPS = Number(args.fps ?? 60);
const SECONDS = Number(args.seconds ?? 14);

/**
 * Frames played before recording starts.
 *
 * The take used to begin at wave 1, which is three enemies on an empty
 * starfield — an honest picture of the game's first ten seconds and a poor
 * picture of the game. Playing forward first puts the recording somewhere with
 * formations on screen, upgrades bought and the score in five figures, without
 * faking anything: it is the same seeded run, just not its opening.
 *
 * The warm-up is stepped but not screenshotted, so it costs very little.
 *
 * 600 rather than more because the ship has to survive the warm-up AND the take
 * on NORMAL's five lives, and it is flying a fixed script rather than dodging.
 * At 900 it died partway through the take. The script fails loudly if that
 * happens rather than quietly recording a game-over screen.
 *
 * A caveat worth knowing: the take is seeded but not perfectly reproducible.
 * The game schedules wave spawns and the shop's auto-close with real-time
 * setTimeout, while frames here are pumped by hand — so how much game time
 * passes between two frames depends on how fast this machine takes screenshots.
 * Two runs on the same commit can differ slightly. If a still index ever looks
 * wrong, re-measure rather than assuming it drifted for a deeper reason.
 */
const WARMUP = Number(args.warmup ?? 600);
const FRAMES = Math.round(FPS * SECONDS);

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const GAME = join(ROOT, 'public', 'demo', 'void-striker', 'index.html');
const OUT = join(ROOT, 'public', 'media', 'games', 'void-striker');
const TMP = join(ROOT, '.frames');

rmSync(TMP, { recursive: true, force: true });
mkdirSync(TMP, { recursive: true });
mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

// Capture at 2x and scale down on encode: the game draws hairline strokes and
// small mono type, and downsampling resolves both far better than encoding a
// 1x capture directly.
const page = await browser.newPage({
  viewport: { width: W, height: H },
  deviceScaleFactor: 2,
});

/**
 * Take rAF away from the page before any of its script runs, and hand back a
 * manual pump. Everything the game does — movement, spawning, particles, its
 * own `gs.t` clock — advances only when __step() is called.
 */
await page.addInitScript(() => {
  /*
   * Seed the game's randomness.
   *
   * The game calls Math.random() for spawn positions, enemy types and particle
   * jitter, so two captures of "the same" run are different runs: the first
   * pass at picking still frames by index chose a dense wave, and the identical
   * command a minute later put the upgrade shop at both of those indices.
   *
   * mulberry32 with a fixed seed makes the whole take reproducible — same
   * clip, same frames, same stills, every time and on every machine. It also
   * means the frame numbers chosen for the stills below stay meaningful
   * instead of silently pointing at whatever happens to be there next time.
   *
   * One caveat, because it looks like a bug the first time you meet it: the
   * audio engine draws from this same stream. Every noise burst fills a buffer
   * with thousands of Math.random() calls, and the melody and the per-voice
   * detune take a few more. So a take is reproducible for a given build, but
   * changing anything about the audio shifts the gameplay RNG and the run
   * comes out differently — same seed, different score. If the clip and stills
   * churn after an audio-only commit, that is why, and nothing is wrong.
   */
  let seed = 0x9e3779b9;
  Math.random = () => {
    seed |= 0;
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };

  const queue = [];
  let now = 0;
  // @ts-expect-error - replacing a host API on purpose
  window.requestAnimationFrame = (cb) => queue.push(cb) && queue.length;
  // @ts-expect-error - the game never cancels, but keep the API shape honest
  window.cancelAnimationFrame = () => {};
  Object.defineProperty(window, '__step', {
    value: (n = 1) => {
      for (let i = 0; i < n; i++) {
        const due = queue.splice(0, queue.length);
        // 16.667ms per step, so anything reading the rAF timestamp still sees a
        // steady 60fps rather than a clock that never moves.
        now += 1000 / 60;
        for (const cb of due) cb(now);
      }
    },
  });
});

await page.goto(`file://${GAME}`);
await page.waitForTimeout(400);
await page.evaluate(() => document.fonts.ready);

// Draw the home screen, then start a NORMAL run.
//
// There used to be a `page.click('canvas')` here, because the game opened on a
// title card you tapped through to reach the menu. That card is gone and the
// hub opens on load, so the modal now covers the canvas and clicking it timed
// out — this script failed loudly rather than silently, which is the good
// version of this failure.
await page.evaluate(() => window.__step(30));
await page.screenshot({ path: join(TMP, 'home.png') });
// #btn-start rather than matching the button's own label text — the pilot
// hub renamed START GAME to START MISSION and this broke silently until the
// next capture ran; an id survives a copy change the way text can't.
await page.click('#btn-start');
await page.waitForTimeout(250);
await page.evaluate(() => window.__step(20));

const phase = await page.evaluate(() => document.getElementById('modal').classList.contains('open'));
if (phase) throw new Error('the menu is still open — the game did not start');

// Hold fire for the whole take.
await page.keyboard.down(' ');

/**
 * A movement pattern, in frames. Hand-scripted rather than random so the clip
 * is reproducible and so the ship is somewhere interesting rather than parked
 * in a corner — this is a shot, not a playthrough.
 */
const moves = [
  [0, 'ArrowLeft'],
  [70, null],
  [110, 'ArrowRight'],
  [200, null],
  [250, 'ArrowLeft'],
  [300, null],
  [360, 'ArrowRight'],
  [470, null],
  [520, 'ArrowLeft'],
  [600, null],
  [660, 'ArrowRight'],
  [760, null],
];
let held = null;

/**
 * Apply the movement script at frame `f`, looping it so it covers a take of any
 * length as well as the warm-up before it.
 */
async function drive(f) {
  const span = moves[moves.length - 1][0] + 40;
  for (const [at, key] of moves) {
    if (at !== f % span) continue;
    if (held) await page.keyboard.up(held);
    held = key;
    if (key) await page.keyboard.down(key);
  }
}

/**
 * The upgrade shop opens every third wave and waits for input. Left alone it
 * parks the clip on a static menu — the first take spent ten of fourteen
 * seconds there.
 *
 * It is drawn on the canvas rather than in the DOM, and the game's state lives
 * inside an IIFE, so there is nothing to read from out here to detect it. Keys
 * are the way through: the game's handler ignores 1-4 unless `gs.upgradePhase`
 * is set, so these presses are inert during play.
 *
 * Pressing only "1" is not enough, and quietly stopped working when repeat
 * purchases started escalating in price. If card 1 costs more than the player
 * holds, the buy is refused, the shop does not close — it only auto-closes when
 * NOTHING is affordable — and the take parks on the shop for the rest of its
 * length. That is exactly what happened: 300 of 840 frames were one static
 * screen. Rotating through 1, 2, 3, 4 buys what is affordable and then presses
 * skip, which always closes it.
 */
const PICK_EVERY = 10;
const PICK_KEYS = ['1', '2', '3', '4'];
let pickN = 0;

const pad = (n) => String(n).padStart(5, '0');

/*
  Warm up. Same inputs as the take, no screenshots. The run is seeded, so if the
  ship survives this once it survives it every time — and if it does not, that
  is a deterministic fact worth failing on rather than silently recording a
  title screen.
*/
if (WARMUP > 0) {
  process.stdout.write(`  warming up ${WARMUP} frames`);
  for (let f = 0; f < WARMUP; f++) {
    await drive(f);
    if (f > 0 && f % PICK_EVERY === 0) await page.keyboard.press(PICK_KEYS[pickN++ % PICK_KEYS.length]);
    await page.evaluate(() => window.__step(1));
    if (f % 300 === 0) process.stdout.write('.');
  }
  console.log(' done');

  /* A modal can only be open here if the run ended: the upgrade shop is drawn
     on the canvas, not in the DOM. */
  const died = await page.evaluate(() => document.getElementById('modal').classList.contains('open'));
  if (died) {
    throw new Error(
      `the ship did not survive the ${WARMUP}-frame warm-up, so the take would ` +
        'record a game-over screen. Lower --warmup, or adjust the movement script.',
    );
  }
}

process.stdout.write(`  capturing ${FRAMES} frames`);

for (let f = 0; f < FRAMES; f++) {
  await drive(WARMUP + f);
  if (f > 0 && f % PICK_EVERY === 0) await page.keyboard.press(PICK_KEYS[pickN++ % PICK_KEYS.length]);
  await page.evaluate(() => window.__step(1));
  await page.screenshot({ path: join(TMP, `f${pad(f)}.png`) });
  if (f % 120 === 0) process.stdout.write('.');
}
if (held) await page.keyboard.up(held);
await page.keyboard.up(' ');
console.log(` done (${readdirSync(TMP).length} frames)`);

/* The run has to still be running at the end, or the tail of the clip is a
   game-over modal and the stills may be picked from it. */
if (await page.evaluate(() => document.getElementById('modal').classList.contains('open'))) {
  throw new Error('the run ended during the take — lower --warmup or --seconds');
}

/**
 * One more frame, of the upgrade shop.
 *
 * The shop is a real feature and it earns one of the four store stills, but it
 * can no longer be picked out of the take by frame index: rotating the shop
 * keys closes it within about ten frames, so whether one lands inside the
 * recorded window is luck, and in the take this was written against, none did.
 *
 * So it is found rather than assumed. Play on with no shop keys pressed, and
 * sample the canvas's own brightness after each step until it jumps — the shop
 * is a full-screen lit UI over a game that is almost entirely black, so the
 * signal is unambiguous and needs no screenshot to read.
 */
const groundLuma = await page.evaluate(() => {
  const c = document.getElementById('c');
  const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data;
  let t = 0;
  for (let i = 0; i < d.length; i += 4000) t += d[i] + d[i + 1] + d[i + 2];
  return t;
});

process.stdout.write('  looking for the upgrade shop');
let shopFound = false;
for (let f = 0; f < 1200 && !shopFound; f++) {
  await drive(f);
  await page.evaluate(() => window.__step(1));
  if (f % 10) continue;
  if (f % 200 === 0) process.stdout.write('.');
  if (await page.evaluate(() => document.getElementById('modal').classList.contains('open'))) break;
  const lit = await page.evaluate(() => {
    const c = document.getElementById('c');
    const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data;
    let t = 0;
    for (let i = 0; i < d.length; i += 4000) t += d[i] + d[i + 1] + d[i + 2];
    return t;
  });
  if (lit > groundLuma * 2.5) {
    await page.evaluate(() => window.__step(6));   // let the cards settle
    await page.screenshot({ path: join(TMP, 'shop.png') });
    shopFound = true;
  }
}
console.log(shopFound ? ' found' : ' not found (the shop still falls back to a gameplay frame)');
if (held) await page.keyboard.up(held);
await page.keyboard.up(' ');

await browser.close();

const run = (a) => execFileSync(ffmpeg, a, { stdio: ['ignore', 'ignore', 'pipe'] });

/* --- Stills --------------------------------------------------------------
   Frame numbers chosen by looking at the take, not by dividing the runtime:
   an evenly spaced sample of a shooter gives four near-identical pictures of
   an empty starfield. These are the title, a dense wave, the upgrade shop —
   a real feature, worth one of the four slots — and a late-game moment.

   These indices only mean anything because the run is seeded. Before that they
   pointed at whatever happened to be there, and two identical commands a
   minute apart produced different pictures.

   They were found by measuring rather than by scrubbing a contact sheet, and
   re-measured after the warm-up was added because every old index then pointed
   somewhere else. The measure is a 24x24 reduction of each frame: the upgrade
   shop is the one frame with a high mean (a flat, full-screen lit UI), and a
   good gameplay frame is the one with the most CELLS LIT rather than the
   highest mean — a shooter on black has a mean near zero however much is
   happening in it, which is why an earlier mean-only pass ranked empty frames
   alongside full ones. Re-run that measurement if the take ever changes. */
if (args.shots) {
  const SHOTS = join(ROOT, 'public', 'media', 'apps', 'void-striker');
  mkdirSync(SHOTS, { recursive: true });
  const picks = [
    ['home.png', '01'],          // the hub, which is now the game's first screen
    [`f${pad(242)}.png`, '02'],   // busiest gameplay frame of the take
    [existsSync(join(TMP, 'shop.png')) ? 'shop.png' : `f${pad(359)}.png`, '03'],
    [`f${pad(475)}.png`, '04'],   // a later moment, well clear of the other two
  ];
  for (const [src, n] of picks) {
    run(['-y', '-i', join(TMP, src), '-vf', `scale=${W}:${H}:flags=lanczos`,
         '-q:v', '4', join(SHOTS, `${n}.jpg`)]);
    console.log(`  media/apps/void-striker/${n}.jpg`);
  }
  if (!args['keep-frames']) rmSync(TMP, { recursive: true, force: true });
  process.exit(0);
}

/* --- Encode ------------------------------------------------------------- */
const fade = `fade=t=in:st=0:d=0.5,fade=t=out:st=${SECONDS - 0.6}:d=0.6`;
const scale = `scale=${W}:${H}:flags=lanczos`;
const input = ['-framerate', String(FPS), '-i', join(TMP, 'f%05d.png')];

run([
  '-y',
  ...input,
  '-vf', `${scale},${fade}`,
  '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '32', '-row-mt', '1',
  '-deadline', 'good', '-cpu-used', '2', '-pix_fmt', 'yuv420p',
  '-an', join(OUT, 'clip.webm'),
]);

run([
  '-y',
  ...input,
  '-vf', `${scale},${fade}`,
  '-c:v', 'libx264', '-profile:v', 'high', '-level:v', '4.0', '-pix_fmt', 'yuv420p',
  '-preset', 'slower', '-tune', 'animation', '-crf', '28',
  // A bare CRF lets x264 spend freely on this much line detail; the cap is what
  // keeps the file from ballooning past the WebM it is meant to back up.
  '-maxrate', '1400k', '-bufsize', '2800k', '-g', String(FPS * 2),
  '-movflags', '+faststart', '-an', join(OUT, 'clip.mp4'),
]);

// Poster: a frame from a little way in, so it shows play rather than a fade-up.
run([
  '-y', '-i', join(TMP, `f${pad(Math.round(FPS * 2))}.png`),
  '-vf', scale, '-q:v', '4', join(OUT, 'poster.jpg'),
]);

if (!args['keep-frames']) rmSync(TMP, { recursive: true, force: true });

for (const f of readdirSync(OUT)) {
  const { size } = await import('node:fs').then((m) => m.statSync(join(OUT, f)));
  console.log(`  ${f.padEnd(12)} ${(size / 1024).toFixed(0)} KB`);
}
