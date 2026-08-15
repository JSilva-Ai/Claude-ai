/**
 * Renders the ten Proving Grounds environments to looping WebM clips plus
 * poster frames, using headless Chromium's MediaRecorder.
 *
 *   node scripts/render/capture.mjs [sceneId ...]
 *
 * Output: public/media/env/<id>.webm, <id>.mp4, and <id>.jpg
 *
 * Frames are pulled from the page one at a time and encoded with ffmpeg,
 * rather than recorded with MediaRecorder. MediaRecorder timestamps by wall
 * clock and drops frames when the encoder falls behind — under software
 * rasterisation that produced clips 1.5x to 6x longer than LOOP, each playing
 * at its own wrong speed, and missing about a third of their frames, so the
 * loops never closed. Pulling frame by frame is slower and exact.
 *
 * Each clip is encoded twice: VP9 for browsers that take it, and H.264
 * because Safari's WebM support is both recent and patchy.
 */

import { execFileSync } from 'node:child_process';
import { createServer } from 'node:http';
import {
  createReadStream,
  existsSync,
  mkdirSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import ffmpegPath from 'ffmpeg-static';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const OUT = join(ROOT, 'public/media/env');
const PORT = 8931;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.woff2': 'font/woff2',
};

function serve() {
  return new Promise((resolve) => {
    const server = createServer((req, res) => {
      const url = decodeURIComponent((req.url ?? '/').split('?')[0]);
      const path = join(ROOT, normalize(url).replace(/^(\.\.[/\\])+/, ''));
      if (!path.startsWith(ROOT) || !existsSync(path) || statSync(path).isDirectory()) {
        res.writeHead(404).end('not found');
        return;
      }
      res.writeHead(200, {
        'content-type': MIME[extname(path)] ?? 'application/octet-stream',
        'cache-control': 'no-store',
      });
      createReadStream(path).pipe(res);
    });
    server.listen(PORT, () => resolve(server));
  });
}

// Poster timestamps hand-picked per scene so every still is a composed frame,
// not an arbitrary sample.
const POSTER_T = {
  drift: 3.1,
  canopy: 5.4,
  hallway: 8.2,
  swarm: 4.6,
  lattice: 2.3,
  tide: 6.0,
  relay: 7.4,
  quarry: 9.1,
  orbit: 5.8,
  parse: 6.6,
};

/** Frames per second the clips are authored and encoded at. */
const FPS = 30;
/** Loop length in seconds — must match LOOP in scenes.js. */
const LOOP = 12;
const FRAMES = LOOP * FPS;

/**
 * Encode a directory of numbered frames into the delivery pair.
 *
 * A bare CRF is not enough for H.264 here: these panels carry a lot of
 * high-frequency line detail on flat black and x264 spends freely on it, so
 * the rate cap is what keeps the two formats comparable in weight.
 * yuv420p and the constrained level are what make the MP4 play on older iOS;
 * faststart moves the index ahead of the data so playback can begin before
 * the file has finished downloading.
 */
function encode(id, dir) {
  const input = ['-framerate', String(FPS), '-i', join(dir, 'f%05d.png')];
  execFileSync(
    ffmpegPath,
    ['-y', '-loglevel', 'error', ...input, '-an',
     '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '34',
     '-row-mt', '1', '-deadline', 'good', '-cpu-used', '2',
     '-pix_fmt', 'yuv420p',
     join(OUT, `${id}.webm`)],
    { stdio: 'inherit' },
  );
  execFileSync(
    ffmpegPath,
    ['-y', '-loglevel', 'error', ...input, '-an',
     '-c:v', 'libx264', '-profile:v', 'high', '-level:v', '4.0',
     '-pix_fmt', 'yuv420p', '-preset', 'slower', '-tune', 'animation',
     '-crf', '30', '-maxrate', '1100k', '-bufsize', '2200k', '-g', '48',
     '-movflags', '+faststart',
     join(OUT, `${id}.mp4`)],
    { stdio: 'inherit' },
  );
  return {
    webm: statSync(join(OUT, `${id}.webm`)).size,
    mp4: statSync(join(OUT, `${id}.mp4`)).size,
  };
}

const args = process.argv.slice(2);
const postersOnly = args.includes('--posters');
/** --sheet renders every scene into one contact sheet for art direction review. */
const sheet = args.includes('--sheet');
/** --keep-frames leaves the extracted PNG frames on disk for inspection. */
const keepFrames = args.includes('--keep-frames');
const only = args.filter((a) => !a.startsWith('--'));

mkdirSync(OUT, { recursive: true });

const server = await serve();

const browser = await chromium.launch({
  args: [
    '--use-gl=angle',
    '--use-angle=swiftshader',
    '--enable-unsafe-swiftshader',
    '--autoplay-policy=no-user-gesture-required',
    '--disable-dev-shm-usage',
  ],
});

const page = await browser.newPage({ viewport: { width: 1000, height: 640 } });
page.on('console', (m) => m.type() === 'error' && console.error('  page error:', m.text()));
page.on('pageerror', (e) => console.error('  page exception:', e.message));

await page.goto(`http://127.0.0.1:${PORT}/scripts/render/stage.html`);
await page.waitForFunction(() => window.__ready === true, null, { timeout: 30_000 });

const scenes = await page.evaluate(() => window.__scenes);
const targets = only.length ? scenes.filter((s) => only.includes(s.id)) : scenes;

console.log(`Rendering ${targets.length} environment(s) → public/media/env\n`);

if (sheet) {
  const b64 = await page.evaluate(
    ([ids, times]) => {
      const cols = 2;
      const cw = 480;
      const ch = 300;
      const out = document.createElement('canvas');
      out.width = cols * cw;
      out.height = Math.ceil(ids.length / cols) * ch;
      const octx = out.getContext('2d');
      octx.fillStyle = '#000';
      octx.fillRect(0, 0, out.width, out.height);
      const stage = document.getElementById('stage');
      ids.forEach((id, i) => {
        window.__drawAt(id, times[i]);
        octx.drawImage(stage, (i % cols) * cw, Math.floor(i / cols) * ch, cw, ch);
      });
      return out.toDataURL('image/jpeg', 0.9).split(',')[1];
    },
    [targets.map((s) => s.id), targets.map((s) => POSTER_T[s.id] ?? 4)],
  );
  writeFileSync(join(OUT, '_sheet.jpg'), Buffer.from(b64, 'base64'));
  console.log('  contact sheet → public/media/env/_sheet.jpg');
} else {
  const manifest = [];
  for (const s of targets) {
    const t0 = Date.now();
    process.stdout.write(`  ${s.code} ${s.title.padEnd(9)} `);

    let webmLen = 0;
    let mp4Len = 0;
    if (!postersOnly) {
      const dir = join(OUT, `.frames-${s.id}`);
      mkdirSync(dir, { recursive: true });
      for (let f = 0; f < FRAMES; f++) {
        const png = await page.evaluate(
          ([id, index]) => window.__frame(id, index),
          [s.id, f],
        );
        writeFileSync(join(dir, `f${String(f).padStart(5, '0')}.png`), Buffer.from(png, 'base64'));
      }
      const sizes = encode(s.id, dir);
      if (!keepFrames) rmSync(dir, { recursive: true, force: true });
      webmLen = sizes.webm;
      mp4Len = sizes.mp4;
    }

    const posterB64 = await page.evaluate(
      ([id, t]) => window.__poster(id, t),
      [s.id, POSTER_T[s.id] ?? 4],
    );
    const jpg = Buffer.from(posterB64, 'base64');
    writeFileSync(join(OUT, `${s.id}.jpg`), jpg);

    manifest.push({ id: s.id, webm: webmLen, mp4: mp4Len, jpg: jpg.length });
    console.log(
      `webm ${(webmLen / 1024).toFixed(0).padStart(4)} KB   ` +
        `mp4 ${(mp4Len / 1024).toFixed(0).padStart(4)} KB   ` +
        `jpg ${(jpg.length / 1024).toFixed(0).padStart(3)} KB   ` +
        `${((Date.now() - t0) / 1000).toFixed(1)}s`,
    );
  }

  const total = manifest.reduce((a, m) => a + m.webm + m.mp4 + m.jpg, 0);
  console.log(`\nTotal media: ${(total / 1024 / 1024).toFixed(2)} MB`);
}

await browser.close();
server.close();
