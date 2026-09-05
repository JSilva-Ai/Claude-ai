/**
 * Render individual sound cues, and controlled sequences of them, to WAV.
 *
 *   node scripts/audio-render.mjs --out=dir [--game=path/to/void_striker.html]
 *
 * Why this exists.
 *
 * Two audio passes on this game passed every measurement and failed the human
 * listening test on the actual phone. The reason is structural: the only ear in
 * the loop belonged to someone who saw the work days later, on a device, after
 * it had already been written broadly. Nothing here can hear, so the fix is not
 * a better metric — it is getting rendered audio in front of a person BEFORE
 * the design is applied to twenty more sounds.
 *
 * So this renders named cues, current and new, as files somebody can play.
 *
 * How it works: the game is loaded in a real browser, its destination node is
 * tapped exactly as scripts/audio-probe.mjs does it, and `window.playCue` is
 * called on a schedule. What comes out is the real signal path — the effects
 * bus, the compressor, the high shelf, the master and the limiter — not a
 * reimplementation of it that could drift from the game.
 *
 * The music is silenced through the game's own stored volume before load, so
 * what is compared is the effects' identity and nothing else.
 */
import { chromium } from 'playwright';
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
/* The project's own ffmpeg, the same one scripts/audio-probe.mjs uses. There is
   no ffmpeg on PATH in this environment and there does not need to be. */
import ffmpegStatic from 'ffmpeg-static';

const arg = (n, d) => {
  const hit = process.argv.find((a) => a.startsWith(`--${n}=`));
  return hit ? hit.slice(n.length + 3) : d;
};
const ROOT = resolve(import.meta.dirname, '..');
const GAME = resolve(arg('game', join(ROOT, 'game', 'void_striker.html')));
const OUT = resolve(arg('out', join(ROOT, '.audio-ab')));
const ffmpeg = arg('ffmpeg', ffmpegStatic);
/* The build before this pass fired kill() AND explode() for one destroyed
   enemy. Rendering only kill() from it would flatter the old sound by leaving
   out half of what actually played, so --legacy restores the pair. */
const LEGACY = process.argv.includes('--legacy');
mkdirSync(OUT, { recursive: true });

/** Each entry is a schedule: [delaySeconds, cueName, argument]. */
const TAKES = {
  '01_player_shot':   { secs: 2.0, cues: [[0.3, 'shoot', 'normal']] },
  '02_enemy_shot':    { secs: 2.0, cues: [[0.3, 'enemyShoot']] },
  '03_enemy_destroy': { secs: 2.5,
    cues: LEGACY ? [[0.3, 'kill', 0], [0.3, 'explode']] : [[0.3, 'kill', 0]] },
  '04_bomb':          { secs: 4.0, cues: [[0.3, 'bomb']] },
  // sustained fire: the fatigue test, and the voice-count stress
  '07_sustained_fire': {
    secs: 8.0,
    cues: Array.from({ length: 56 }, (_, i) => [0.3 + i * 0.13, 'shoot', 'normal']),
  },
};

/* A realistic order: the player opens fire, the rank answers, ships break up,
   the bomb lands. No music — this take is about the effects' identity. */
const COMBAT = { secs: 9.0, cues: [] };
for (let i = 0; i < 22; i++) COMBAT.cues.push([0.4 + i * 0.16, 'shoot', 'normal']);
for (let i = 0; i < 6; i++) COMBAT.cues.push([0.9 + i * 0.55, 'enemyShoot']);
[1.6, 2.3, 2.5, 3.4, 4.1].forEach((t, i) => {
  COMBAT.cues.push([t, 'kill', i]);
  if (LEGACY) COMBAT.cues.push([t, 'explode']);
});
COMBAT.cues.push([4.6, 'bomb']);
for (let i = 0; i < 10; i++) COMBAT.cues.push([6.4 + i * 0.16, 'shoot', 'normal']);
[7.0, 7.4].forEach((t, i) => {
  COMBAT.cues.push([t, 'kill', i + 2]);
  if (LEGACY) COMBAT.cues.push([t, 'explode']);
});

const TAP = () => {
  window.__chunks = [];
  window.__sr = 48000;
  const orig = AudioNode.prototype.connect;
  AudioNode.prototype.connect = function (dest) {
    const isDest = dest && dest.constructor && /AudioDestinationNode/.test(dest.constructor.name);
    if (isDest && !window.__tap) {
      const ctx = dest.context;
      window.__sr = ctx.sampleRate;
      const tap = ctx.createScriptProcessor(4096, 1, 1);
      const sink = ctx.createGain();
      sink.gain.value = 0;
      orig.call(tap, sink);
      orig.call(sink, dest);
      tap.onaudioprocess = (e) => window.__chunks.push(Array.from(e.inputBuffer.getChannelData(0)));
      window.__tap = tap;
    }
    if (isDest && window.__tap) { try { orig.call(this, window.__tap); } catch { /* already */ } }
    return orig.apply(this, arguments);
  };
};

const write = (name, sr, samples) => {
  const raw = Buffer.alloc(samples.length * 2);
  samples.forEach((v, i) =>
    raw.writeInt16LE(Math.max(-32768, Math.min(32767, Math.round(v * 32767))), i * 2));
  const rawPath = join(OUT, `${name}.raw`);
  const wavPath = join(OUT, `${name}.wav`);
  writeFileSync(rawPath, raw);
  execFileSync(ffmpeg, ['-hide_banner', '-loglevel', 'error', '-f', 's16le',
    '-ar', String(sr), '-ac', '1', '-i', rawPath, wavPath, '-y']);
  return wavPath;
};

const browser = await chromium.launch({ args: ['--autoplay-policy=no-user-gesture-required'] });

async function render(name, take) {
  const page = await browser.newPage();
  await page.route('**://fonts.googleapis.com/**', (r) => r.abort());
  await page.addInitScript(TAP);
  /* Music off at the source. The unlock routine starts the bed on the first
     gesture — correct in the game, wrong here: it put a pad under every take
     and the first render of a cue that does not exist still measured 0.100.
     The game reads this at startup, so setting it before load is enough. */
  await page.addInitScript(() => {
    try { localStorage.setItem('vs_vol_music', '0'); } catch { /* private mode */ }
  });
  await page.goto('file://' + GAME);
  await page.waitForTimeout(700);
  // a gesture unlocks the audio; the music is left alone so it cannot colour
  // the comparison, and the tap is cleared of anything the hub made
  await page.evaluate(() => { if (window.playCue) window.playCue('menuClick'); });
  await page.waitForTimeout(500);
  const ok = await page.evaluate(() => typeof window.playCue === 'function');
  if (!ok) { await page.close(); throw new Error('window.playCue missing — build predates the render hook'); }
  await page.evaluate(() => { window.__chunks.length = 0; window.__peakVoices = 0; });

  await page.evaluate(async (cues) => {
    const t0 = performance.now();
    for (const [at, cue, a] of cues.sort((x, y) => x[0] - y[0])) {
      const wait = t0 + at * 1000 - performance.now();
      if (wait > 0) await new Promise((r) => setTimeout(r, wait));
      window.playCue(cue, a);
    }
  }, take.cues);
  await page.waitForTimeout(take.secs * 1000);

  const out = await page.evaluate(() => {
    const flat = [];
    for (const c of window.__chunks) for (const v of c) flat.push(v);
    return { sr: window.__sr, samples: flat };
  });
  await page.close();
  if (!out.samples.length) throw new Error(`nothing captured for ${name}`);
  const path = write(name, out.sr, out.samples);
  const peak = out.samples.reduce((m, v) => Math.max(m, Math.abs(v)), 0);
  const clipped = out.samples.filter((v) => Math.abs(v) >= 0.999).length;
  console.log(`  ${name.padEnd(22)} ${(out.samples.length / out.sr).toFixed(1)}s  ` +
              `peak ${peak.toFixed(3)}  clipped ${clipped}`);
  return { path, peak, clipped };
}

const results = {};
for (const [name, take] of Object.entries(TAKES)) results[name] = await render(name, take);
results['05_combat'] = await render('05_combat', COMBAT);
await browser.close();
console.log(`\n  wrote ${Object.keys(results).length} takes to ${OUT}`);
