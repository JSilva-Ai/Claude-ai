/**
 * Measures what the game actually sounds like, so audio work is not guesswork.
 *
 *   node scripts/audio-probe.mjs [--seconds=14] [--play] [--wav=out.wav]
 *   node scripts/audio-probe.mjs --file=some-recording.mov     (measure anything)
 *
 * Prints, for the captured audio:
 *
 *   peak / RMS / crest factor      is it clipping, and does it have dynamics
 *   five band means                where the energy sits
 *   spread of 100 ms RMS blocks    does the level move, or is it a flat wall
 *
 * ---
 *
 * Why this exists.
 *
 * The owner said twice that the sound was annoying. Reasoning about the graph
 * produced two rounds of plausible fixes aimed at the wrong half of the mix.
 * What settled it was measuring: a recording of the real game showed 200-800 Hz
 * sitting 13 dB above everything from 800 Hz to 2.5 kHz, flat, and rendering
 * the engine's *music alone* reproduced that profile band for band — so the
 * wall of sound was the music bed, not the effects.
 *
 * Two things about the method are easy to get wrong:
 *
 *  - The tap must be installed from addInitScript. Patch AudioNode.connect
 *    after page load and the chain is already wired to destination, so the tap
 *    records silence.
 *  - A spectral centroid taken from getByteFrequencyData is level-dependent:
 *    a quieter mix reads as "darker" because more of its high bins fall under
 *    the analyser's absolute floor. Band means at matched level, as here, do
 *    not have that failure mode.
 */
import { chromium } from 'playwright';
import { execFileSync, spawnSync } from 'node:child_process';
import { writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import ffmpeg from 'ffmpeg-static';

const HERE = dirname(fileURLToPath(import.meta.url));
const GAME = join(HERE, '..', 'game', 'void_striker.html');

const arg = (n, d) => {
  const hit = process.argv.find((a) => a.startsWith(`--${n}=`));
  return hit ? hit.split('=').slice(1).join('=') : d;
};
const has = (n) => process.argv.includes(`--${n}`);

const SECONDS = Number(arg('seconds', 14));
const tmp = mkdtempSync(join(tmpdir(), 'vs-audio-'));

/** Capture the game's own output through a tap on its destination node. */
async function captureGame() {
  const browser = await chromium.launch({
    args: ['--autoplay-policy=no-user-gesture-required'],
  });
  const page = await browser.newPage();
  // this environment has no egress to Google Fonts and each attempt stalls load
  await page.route('**://fonts.googleapis.com/**', (r) => r.abort());

  await page.addInitScript(() => {
    window.__chunks = [];
    window.__sr = 48000;
    const orig = AudioNode.prototype.connect;
    AudioNode.prototype.connect = function (dest) {
      const isDest =
        dest && dest.constructor && /AudioDestinationNode/.test(dest.constructor.name);
      if (isDest && !window.__tap) {
        const ctx = dest.context;
        window.__sr = ctx.sampleRate;
        const tap = ctx.createScriptProcessor(4096, 1, 1);
        const sink = ctx.createGain();
        sink.gain.value = 0;
        orig.call(tap, sink);
        orig.call(sink, dest);
        tap.onaudioprocess = (e) =>
          window.__chunks.push(Array.from(e.inputBuffer.getChannelData(0)));
        window.__tap = tap;
      }
      if (isDest && window.__tap) {
        try { orig.call(this, window.__tap); } catch { /* already connected */ }
      }
      return orig.apply(this, arguments);
    };
  });

  await page.goto('file://' + GAME);
  await page.evaluate(() => { try { localStorage.clear(); } catch { /* private mode */ } });
  await page.reload();
  await page.waitForTimeout(800);

  // space opens the pilot hub, which is also what unlocks the audio context
  await page.keyboard.press(' ');
  await page.waitForTimeout(1200);
  if (has('play')) {
    await page.click('#btn-start');
    await page.waitForTimeout(1500);
  }
  await page.evaluate(() => { window.__chunks.length = 0; });  // drop the fade-in
  await page.waitForTimeout(SECONDS * 1000);

  const out = await page.evaluate(() => {
    const flat = [];
    for (const c of window.__chunks) for (const v of c) flat.push(v);
    return { sr: window.__sr, samples: flat, tapped: !!window.__tap };
  });
  await browser.close();
  if (!out.tapped || !out.samples.length) {
    throw new Error('no audio captured — the tap never saw a destination connect');
  }
  const raw = Buffer.alloc(out.samples.length * 2);
  out.samples.forEach((v, i) =>
    raw.writeInt16LE(Math.max(-32768, Math.min(32767, Math.round(v * 32767))), i * 2),
  );
  const rawPath = join(tmp, 'cap.raw');
  const wavPath = arg('wav', join(tmp, 'cap.wav'));
  writeFileSync(rawPath, raw);
  execFileSync(ffmpeg, ['-hide_banner', '-loglevel', 'error', '-f', 's16le',
    '-ar', String(out.sr), '-ac', '1', '-i', rawPath, wavPath, '-y']);
  console.log(`  captured ${(out.samples.length / out.sr).toFixed(1)}s at ${out.sr} Hz`);
  return wavPath;
}

/** Anything ffmpeg can open — a screen recording, say. */
function fromFile(src) {
  const wav = join(tmp, 'in.wav');
  execFileSync(ffmpeg, ['-hide_banner', '-loglevel', 'error', '-i', src,
    '-vn', '-ac', '1', '-ar', '48000', '-c:a', 'pcm_s16le', wav, '-y']);
  return wav;
}

/* ffmpeg writes astats and volumedetect to stderr, and execFileSync hands back
   only stdout on a zero exit — which is how this first reported every figure as
   `undefined`. spawnSync gives both streams whatever the exit code. */
const ff = (args) => {
  const r = spawnSync(ffmpeg, args, { encoding: 'utf8', maxBuffer: 1 << 28 });
  return (r.stdout || '') + (r.stderr || '');
};

const BANDS = [
  ['20-200 Hz   ', 'lowpass=f=200:poles=2'],
  ['200-800 Hz  ', 'highpass=f=200:poles=2,lowpass=f=800:poles=2'],
  ['800-2500 Hz ', 'highpass=f=800:poles=2,lowpass=f=2500:poles=2'],
  ['2.5-6 kHz   ', 'highpass=f=2500:poles=2,lowpass=f=6000:poles=2'],
  ['6 kHz+      ', 'highpass=f=6000:poles=2'],
];

function report(wav) {
  const stats = ff(['-hide_banner', '-i', wav, '-af', 'astats=metadata=1:reset=0', '-f', 'null', '-']);
  const grab = (k) => (stats.match(new RegExp(`${k}: (-?[\\d.]+)`)) || [])[1];
  console.log('');
  console.log(`  peak          ${grab('Peak level dB')} dBFS`);
  console.log(`  rms           ${grab('RMS level dB')} dBFS`);
  console.log(`  crest factor  ${grab('Crest factor')}       (under ~4 is a flat wall)`);
  console.log('');
  let loudest = { db: -999, name: '' };
  for (const [name, filt] of BANDS) {
    const out = ff(['-hide_banner', '-i', wav, '-af', `${filt},volumedetect`, '-f', 'null', '-']);
    const mean = (out.match(/mean_volume: (-?[\d.]+)/) || [])[1];
    const db = Number(mean);
    if (db > loudest.db) loudest = { db, name: name.trim() };
    console.log(`  ${name} ${String(mean).padStart(7)} dB`);
  }
  console.log('');
  console.log(`  loudest band: ${loudest.name}`);
  if (/^200-800/.test(loudest.name)) {
    console.log('  ^ 200-800 Hz on top is the boxy-drone signature. See VOID_STRIKER.md.');
  }

  // movement: the spread of short-term loudness. A slow swell barely shifts the
  // whole-file crest factor, but it shows up clearly here.
  const pcm = execFileSync(ffmpeg, ['-hide_banner', '-loglevel', 'error', '-i', wav,
    '-f', 's16le', '-ac', '1', '-ar', '48000', '-'], { maxBuffer: 1 << 28 });
  const n = pcm.length / 2;
  const block = 4800; // 100 ms
  const env = [];
  for (let i = 0; i + block < n; i += block) {
    let sum = 0;
    for (let j = 0; j < block; j++) {
      const v = pcm.readInt16LE((i + j) * 2) / 32768;
      sum += v * v;
    }
    const r = Math.sqrt(sum / block);
    if (r > 1e-6) env.push(r);
  }
  env.sort((a, b) => a - b);
  const q = (k) => env[Math.min(env.length - 1, Math.floor(env.length * k))] || 1e-9;
  const db = (x) => 20 * Math.log10(x);
  const spread = db(q(0.9)) - db(q(0.1));
  console.log('');
  console.log(`  100ms loudness  p10 ${db(q(0.1)).toFixed(1)}  p50 ${db(q(0.5)).toFixed(1)}  p90 ${db(q(0.9)).toFixed(1)} dB`);
  console.log(`  spread          ${spread.toFixed(1)} dB          (under ~6 dB is a drone)`);
}

const src = arg('file', null);
console.log(src ? `\n── ${src} ──` : `\n── the game${has('play') ? ', in a run' : ', title screen'} ──`);
report(src ? fromFile(src) : await captureGame());
console.log('');
