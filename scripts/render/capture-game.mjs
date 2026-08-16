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
import { mkdirSync, readdirSync, rmSync } from 'node:fs';
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

// Draw the title screen, then open the menu and start a NORMAL run.
await page.evaluate(() => window.__step(30));
await page.screenshot({ path: join(TMP, 'title.png') });
await page.click('canvas', { position: { x: W / 2, y: H / 2 } });
await page.waitForTimeout(250);
for (const b of await page.$$('#modal button')) {
  if ((await b.textContent()).trim().includes('START GAME')) {
    await b.click();
    break;
  }
}
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
 * The upgrade shop opens every third wave and waits for input. Left alone it
 * parks the clip on a static menu — the first take spent ten of fourteen
 * seconds there.
 *
 * It is drawn on the canvas rather than in the DOM, and the game's state lives
 * inside an IIFE, so there is nothing to read from out here to detect it.
 * Pressing "1" on a timer is the way through: the game's key handler ignores
 * 1-4 unless `gs.upgradePhase` is set, so the press is inert during play and
 * takes the first upgrade the moment the shop appears.
 */
const PICK_EVERY = 20;

const pad = (n) => String(n).padStart(5, '0');
process.stdout.write(`  capturing ${FRAMES} frames`);

for (let f = 0; f < FRAMES; f++) {
  for (const [at, key] of moves) {
    if (at !== f) continue;
    if (held) await page.keyboard.up(held);
    held = key;
    if (key) await page.keyboard.down(key);
  }
  if (f > 0 && f % PICK_EVERY === 0) await page.keyboard.press('1');
  await page.evaluate(() => window.__step(1));
  await page.screenshot({ path: join(TMP, `f${pad(f)}.png`) });
  if (f % 120 === 0) process.stdout.write('.');
}
if (held) await page.keyboard.up(held);
await page.keyboard.up(' ');
console.log(` done (${readdirSync(TMP).length} frames)`);

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

   They were found by measuring rather than by scrubbing a contact sheet: mean
   luma per frame over the whole take, then the brightest frames (the upgrade
   shop, which is a full-screen lit UI) and the busiest gameplay frames after
   the third wave. Re-run that measurement if the take ever changes. */
if (args.shots) {
  const SHOTS = join(ROOT, 'public', 'media', 'apps', 'void-striker');
  mkdirSync(SHOTS, { recursive: true });
  const picks = [
    ['title.png', '01'],
    [`f${pad(618)}.png`, '02'],
    [`f${pad(322)}.png`, '03'],
    [`f${pad(663)}.png`, '04'],
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
