/**
 * Renders the raster brand assets from one description of the mark.
 *
 *   node scripts/render/brand.mjs
 *
 * Output:
 *   public/og.jpg               1200×630 social card
 *   public/brand/mark-512.png   PWA / apple-touch tile
 *
 * The geometry below is the same geometry as src/assets/logo.svg and
 * src/components/Logo.tsx. These assets are rasterised outside the page's
 * cascade, so the tokens have to be restated here as literals — if the mark
 * moves, it moves in all three places.
 *
 * favicon.svg is written by hand rather than generated: it is a reduction of
 * the mark (peak and sphere only) rather than the mark at a small size, and
 * that reduction is a design decision, not something to derive.
 */

import { createServer } from 'node:http';
import { createReadStream, existsSync, mkdirSync, statSync, writeFileSync } from 'node:fs';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const PUBLIC = join(ROOT, 'public');
const BRAND = join(PUBLIC, 'brand');
const PORT = 8932;

/* --- Palette, mirroring src/styles/tokens.css ---------------------------- */
const BLACK = '#050507';
const BLACK_100 = '#0c0d11';
const WHITE = '#ffffff';
const CHROME = '#c8cdd4';
const CHROME_DIM = '#8a9099';
const BLUE = '#0A84FF';
const BLUE_DEEP = '#1E6FFF';

/* --- The mark ------------------------------------------------------------ */
function markSvg({ size = 58, stroke = WHITE, id = 'm' } = {}) {
  const h = (size * 48) / 58;
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${h}" ` +
    `viewBox="0 0 58 48" fill="none">` +
    `<defs>` +
    `<linearGradient id="s${id}" x1="0" y1="0" x2="1" y2="1">` +
    `<stop offset="0%" stop-color="${BLUE}"/><stop offset="100%" stop-color="${BLUE_DEEP}"/>` +
    `</linearGradient>` +
    `<clipPath id="c${id}"><rect x="0" y="0" width="58" height="38"/></clipPath>` +
    `</defs>` +
    `<g stroke="${stroke}" stroke-width="4.5" stroke-linecap="butt" ` +
    `stroke-linejoin="miter" clip-path="url(#c${id})">` +
    `<path d="M8 38.01V15l13 23V15" stroke-miterlimit="1.4"/>` +
    `<path d="M21 38.01 31 10l10 28.01" stroke-miterlimit="5"/>` +
    `<path d="M23.9 30h14.2"/>` +
    `<path d="M48 38.01V22"/>` +
    `</g>` +
    `<circle cx="48" cy="14" r="3.3" fill="url(#s${id})"/>` +
    `</svg>`
  );
}

const FONTS = `
@font-face{font-family:'Archivo Variable';font-style:normal;font-weight:100 900;
font-stretch:62% 125%;font-display:block;
src:url('/fonts/archivo-latin-wdth-normal.woff2') format('woff2-variations')}
@font-face{font-family:'JetBrains Mono Variable';font-style:normal;font-weight:100 800;
font-display:block;
src:url('/fonts/jetbrains-mono-latin-wght-normal.woff2') format('woff2-variations')}
*{margin:0;padding:0;box-sizing:border-box}
body{background:${BLACK};-webkit-font-smoothing:antialiased}
.mono{font-family:'JetBrains Mono Variable',ui-monospace,monospace;text-transform:uppercase}
.sans{font-family:'Archivo Variable',system-ui,sans-serif}
`;

/* --- The social card -----------------------------------------------------
   Flush-left, nothing centred. The mark sits at the top with the wordmark,
   the proposition is the subject, and the blue appears exactly twice: the
   sphere in the mark, and the glow behind the lower right.
   ------------------------------------------------------------------------- */
const OG_W = 1200;
const OG_H = 630;
const G = 88;

const ogHtml = `<!doctype html><meta charset="utf-8"><style>${FONTS}
body{width:${OG_W}px;height:${OG_H}px;position:relative;overflow:hidden}
.glow{position:absolute;right:-140px;bottom:-220px;width:760px;height:640px;
  background:radial-gradient(closest-side, rgba(10,132,255,.30), transparent 72%)}
.grid{position:absolute;inset:0;
  background-image:linear-gradient(to right,rgba(200,205,212,.035) 1px,transparent 1px),
    linear-gradient(to bottom,rgba(200,205,212,.035) 1px,transparent 1px);
  background-size:60px 60px}
.wrap{position:absolute;inset:${G}px;display:flex;flex-direction:column;justify-content:space-between}
.top{display:flex;align-items:center;gap:18px}
.word{color:${WHITE};font-size:26px;font-variation-settings:'wdth' 108,'wght' 600;
  letter-spacing:.185em;margin-right:-.185em;line-height:1;text-transform:uppercase}
.head{color:${WHITE};font-size:76px;line-height:1.02;letter-spacing:-.02em;
  font-variation-settings:'wdth' 76,'wght' 800;max-width:15ch}
.head em{font-style:normal;background:linear-gradient(135deg,${BLUE},${BLUE_DEEP});
  -webkit-background-clip:text;background-clip:text;color:transparent}
.sub{margin-top:22px;color:${CHROME};font-size:23px;line-height:1.5;max-width:52ch;
  font-variation-settings:'wdth' 100,'wght' 400}
.foot{display:flex;justify-content:space-between;align-items:baseline;
  border-top:1px solid rgba(200,205,212,.14);padding-top:20px}
.tag{font-size:14px;letter-spacing:.2em;color:${CHROME_DIM}}
</style>
<div class="grid"></div><div class="glow"></div>
<div class="wrap">
  <div class="top">${markSvg({ size: 52, id: 'a' })}<span class="sans word">New AI Vision Labs</span></div>
  <div>
    <div class="sans head">We build the apps we want to <em>use.</em></div>
    <div class="sans sub">An independent app studio. We design, build, and publish our own apps on the App Store and Google Play.</div>
  </div>
  <div class="foot">
    <span class="mono tag">newaivisionlabs.com</span>
    <span class="mono tag">iOS · Android</span>
  </div>
</div>`;

/* --- Static server, so the self-hosted fonts resolve --------------------- */
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.woff2': 'font/woff2',
  '.svg': 'image/svg+xml',
};

function serve() {
  return new Promise((resolve) => {
    const server = createServer((req, res) => {
      const url = decodeURIComponent((req.url ?? '/').split('?')[0]);
      if (url === '/__blank') {
        res.writeHead(200, { 'content-type': MIME['.html'] }).end('<!doctype html><title>b</title>');
        return;
      }
      const path = join(PUBLIC, normalize(url).replace(/^(\.\.[/\\])+/, ''));
      if (!path.startsWith(PUBLIC) || !existsSync(path) || statSync(path).isDirectory()) {
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

mkdirSync(BRAND, { recursive: true });
const server = await serve();
const browser = await chromium.launch({ args: ['--force-color-profile=srgb', '--disable-lcd-text'] });

async function stage(width, height, html, scale = 2) {
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: scale });
  await page.goto(`http://127.0.0.1:${PORT}/__blank`);
  await page.setContent(html);
  await page.evaluate(async () => {
    await document.fonts.ready;
  });
  return page;
}

{
  const page = await stage(OG_W, OG_H, ogHtml);
  writeFileSync(join(PUBLIC, 'og.jpg'), await page.screenshot({ type: 'jpeg', quality: 92 }));
  await page.close();
  console.log(`  og.jpg              ${OG_W}×${OG_H}`);
}

/* The app tile. A ground so it never lands on an unknown background, and the
   mark held at 62% — inside a maskable circle and clear of the iOS corner
   radius. */
{
  const S = 512;
  const page = await stage(
    S,
    S,
    `<!doctype html><meta charset="utf-8"><style>${FONTS}
    body{width:${S}px;height:${S}px;background:${BLACK_100};display:grid;place-items:center}
    </style>${markSvg({ size: Math.round(S * 0.62), id: 'b' })}`,
    1,
  );
  writeFileSync(join(BRAND, 'mark-512.png'), await page.screenshot({ type: 'png', scale: 'css' }));
  await page.close();
  console.log(`  brand/mark-512.png  ${S}×${S}`);
}

await browser.close();
server.close();
console.log('\nBrand assets written.');
