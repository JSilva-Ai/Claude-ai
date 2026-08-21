/**
 * Checks the packaged game the way a device would run it.
 *
 *   node scripts/verify-www.mjs [--shot=path.png]
 *
 * Three things are worth catching before a build reaches a phone, and all
 * three are silent on a developer's desk:
 *
 *   1. A request that leaves the device. The app has no server, no account and
 *      no analytics, and the privacy policy says so. One live font import is
 *      enough to make that untrue, and it renders perfectly on wifi.
 *   2. A script error on load. The game is one file with no build step, so
 *      nothing type-checks it; a typo shows up as a black screen.
 *   3. The shim failing to load. It is injected by build-www.mjs, and a
 *      missing file would only be noticed by the back button doing the wrong
 *      thing on someone's phone.
 *
 * Chromium stands in for the two web views. It is not iOS's WKWebView and it
 * cannot tell you how the game feels in the hand, but it answers all three of
 * the questions above, which are the ones that have a right answer.
 */

import { createServer } from 'node:http';
import { existsSync, readFileSync } from 'node:fs';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const HERE = fileURLToPath(new URL('..', import.meta.url));
const WWW = join(HERE, 'www');
const shot = process.argv.find((a) => a.startsWith('--shot='))?.slice(7);

if (!existsSync(join(WWW, 'index.html'))) {
  console.error('No www/ — run `npm run build` first.');
  process.exit(1);
}

const TYPES = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.woff2': 'font/woff2',
  '.png': 'image/png',
};

/**
 * Served over http rather than opened as a file:// URL, because file:// gives
 * the page a null origin and localStorage throws — which is exactly what the
 * game's saved scores, settings and achievements use. The native web views
 * both serve the app over a real origin, so this matches them.
 */
const server = createServer((req, res) => {
  const rel = normalize(decodeURIComponent(req.url.split('?')[0])).replace(/^(\.\.[/\\])+/, '');
  const path = join(WWW, rel === '/' ? 'index.html' : rel);
  if (!path.startsWith(WWW) || !existsSync(path)) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'content-type': TYPES[extname(path)] ?? 'application/octet-stream' });
  res.end(readFileSync(path));
});

await new Promise((r) => server.listen(0, '127.0.0.1', r));
const origin = `http://127.0.0.1:${server.address().port}`;

const browser = await chromium.launch();
/** A phone-shaped viewport, so the canvas scales the way it will on a device. */
const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 3 });

const offDevice = [];
const errors = [];
page.on('request', (r) => {
  if (!r.url().startsWith(origin) && !r.url().startsWith('data:')) offDevice.push(r.url());
});
page.on('pageerror', (e) => errors.push(String(e)));
page.on('console', (m) => {
  if (m.type() === 'error') errors.push(m.text());
});

await page.goto(origin, { waitUntil: 'networkidle' });
/** Long enough for the title screen's animation to have run a few frames. */
await page.waitForTimeout(1500);

const state = await page.evaluate(() => {
  const c = document.getElementById('c');
  return {
    canvas: c ? { w: c.width, h: c.height, css: c.style.width } : null,
    shim: typeof window.popModal,
    /** The game only paints if its loop is running; a blank canvas is a fail. */
    painted: (() => {
      if (!c) return false;
      const d = c.getContext('2d').getImageData(0, 0, c.width, c.height).data;
      for (let i = 0; i < d.length; i += 4000) if (d[i] || d[i + 1] || d[i + 2]) return true;
      return false;
    })(),
  };
});

if (shot) await page.screenshot({ path: shot });
await browser.close();
server.close();

const fail = [];
if (offDevice.length) fail.push(`requests left the device:\n  ${offDevice.join('\n  ')}`);
if (errors.length) fail.push(`errors on load:\n  ${errors.join('\n  ')}`);
if (!state.canvas) fail.push('no canvas — the game did not start');
else if (!state.painted) fail.push('the canvas is blank — the game did not draw a frame');
if (state.shim !== 'function') fail.push('the game did not expose popModal — the back button shim has nothing to call');

if (fail.length) {
  console.error(`\n  ${fail.join('\n\n  ')}\n`);
  process.exit(1);
}

console.log(
  `  ok — no off-device requests, no errors, canvas ${state.canvas.w}x${state.canvas.h} ` +
    `drawn at ${state.canvas.css}`,
);
