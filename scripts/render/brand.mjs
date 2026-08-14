/**
 * Renders the brand assets from the one canonical description of the mark.
 *
 *   node scripts/render/brand.mjs            # write all assets
 *   node scripts/render/brand.mjs --review   # + contact sheets for art direction
 *   node scripts/render/brand.mjs --og-variants   # alternates, for comparison
 *
 * Art-direction switches, kept because they were the real alternatives:
 *   --og=mark         the accent is the mark's centre dot        (shipping)
 *   --og=accent-word  the accent is the word "perception" instead
 *   --og=flush        each headline line solved to the same right edge
 *
 * Output:
 *   public/favicon.svg          hand-written, chrome-aware
 *   public/og.jpg               1200×630 social card
 *   public/brand/mark-512.png   PWA / apple-touch tile
 *
 * The geometry below is the same geometry as src/components/Logo.tsx. If one
 * moves, the other moves with it.
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

/* -------------------------------------------------------------------------
   Palette — mirrors src/styles/tokens.css. Assets are rasterised outside the
   page's cascade, so the tokens have to be restated here as literals.
   ------------------------------------------------------------------------- */
const INK = '#08090b';
const INK_100 = '#0c0e12';
const PORCELAIN = '#edeef0';
const GREY_200 = '#9aa0aa';
const GREY_300 = '#6f757f';
const PHOSPHOR = '#d4f85c';

/* -------------------------------------------------------------------------
   The mark. 32-unit box, every edge on an integer so 16px and 32px rasters
   are exact rather than grey. See Logo.tsx for the reasoning behind each
   number.
   ------------------------------------------------------------------------- */
const BOX = 32;
const SW = 2;
const A = 3;
const B = BOX - A;
const TICK = 8;
const DOT = 3.75;

const TICK_PATH = [
  `M${A} ${A + TICK}V${A}H${A + TICK}`,
  `M${B - TICK} ${A}H${B}V${A + TICK}`,
  `M${B} ${B - TICK}V${B}H${B - TICK}`,
  `M${A + TICK} ${B}H${A}V${B - TICK}`,
].join('');

/** Inline SVG for the mark at a given rendered size. */
function markSvg({ size = 32, stroke = PORCELAIN, dot = stroke, extra = '' } = {}) {
  return (
    `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}" ` +
    `viewBox="0 0 ${BOX} ${BOX}" fill="none" ${extra}>` +
    `<path d="${TICK_PATH}" stroke="${stroke}" stroke-width="${SW}"/>` +
    `<circle cx="16" cy="16" r="${DOT}" fill="${dot}"/>` +
    `</svg>`
  );
}

/* -------------------------------------------------------------------------
   favicon.svg
   Transparent and full-bleed rather than a tile: at 16px the mark needs every
   pixel it can get, and an inset mark inside a tile leaves the corner ticks at
   one pixel each.
   Colour follows the browser chrome. Phosphor is the default rather than the
   dark-mode override so that a browser which ignores prefers-color-scheme in
   favicons still renders something visible on a light tab strip.
   ------------------------------------------------------------------------- */
const FAVICON =
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${BOX} ${BOX}">` +
  `<style>` +
  `path,circle{fill:none;stroke:${PHOSPHOR}}` +
  `circle{fill:${PHOSPHOR};stroke:none}` +
  `@media(prefers-color-scheme:light){path{stroke:${INK}}circle{fill:${INK}}}` +
  `</style>` +
  `<path d="${TICK_PATH}" stroke-width="${SW}"/>` +
  `<circle cx="16" cy="16" r="${DOT}"/>` +
  `</svg>\n`;

/* -------------------------------------------------------------------------
   Shared page chrome for the rasterised assets.
   ------------------------------------------------------------------------- */
const FONTS = `
@font-face{font-family:'Archivo Variable';font-style:normal;font-weight:100 900;
font-stretch:62% 125%;font-display:block;
src:url('/fonts/archivo-latin-wdth-normal.woff2') format('woff2-variations')}
@font-face{font-family:'JetBrains Mono Variable';font-style:normal;font-weight:100 800;
font-display:block;
src:url('/fonts/jetbrains-mono-latin-wght-normal.woff2') format('woff2-variations')}
*{margin:0;padding:0;box-sizing:border-box}
body{background:${INK};-webkit-font-smoothing:antialiased;text-rendering:geometricPrecision}
.mono{font-family:'JetBrains Mono Variable',ui-monospace,monospace;text-transform:uppercase}
.sans{font-family:'Archivo Variable',system-ui,sans-serif}
`;

/** The lockup as static markup — the same proportions Logo.tsx derives. */
function lockup({ size = 30, color = PORCELAIN, dot = color } = {}) {
  return (
    `<span style="display:inline-flex;align-items:center;gap:${size * 0.52}px;color:${color}">` +
    markSvg({ size, stroke: color, dot }) +
    `<span class="sans" style="font-size:${size * 0.5}px;font-weight:500;` +
    `font-variation-settings:'wdth' 118,'wght' 500;letter-spacing:.185em;` +
    `margin-right:-.185em;line-height:1;text-transform:uppercase;white-space:nowrap">` +
    `New AI Vision Labs</span></span>`
  );
}

/* -------------------------------------------------------------------------
   The social card.
   Art direction: the card is itself a detected object — the same corner ticks
   the mark is made of, drawn at the margin, holding the whole composition.
   Structure is editorial: masthead rule, a monumental flush-left statement
   anchored to the lower-left, a telemetry footer. Nothing is centred.
   ------------------------------------------------------------------------- */
const OG_W = 1200;
const OG_H = 630;

function ogHtml(variant = 'mark') {
  const M = 44; // where the card's own detection bracket sits
  const G = 92; // content margin
  const colW = OG_W - G * 2;
  const arm = 38;
  const MARK = 152; // the mark, at the size that makes it the card's subject

  // "perception" is the load-bearing word, so it is the one that may glow —
  // but only in the variant where the mark's dot gives the accent up.
  const accentWord = variant === 'accent-word';
  const line1 = accentWord
    ? `Machine <em style="font-style:normal;color:${PHOSPHOR}">perception</em>,`
    : 'Machine perception,';
  const line2 = 'trained in synthetic worlds.';

  return `<!doctype html><meta charset="utf-8"><style>${FONTS}
  body{width:${OG_W}px;height:${OG_H}px;position:relative;overflow:hidden;background:${INK}}

  /* Instrument ground: a measured grid, not a texture. */
  .grid{position:absolute;inset:0;
    background-image:linear-gradient(to right,rgba(237,238,240,.035) 1px,transparent 1px),
      linear-gradient(to bottom,rgba(237,238,240,.035) 1px,transparent 1px);
    background-size:48px 48px}

  /* The card, bracketed: the mark's own language holding the composition. */
  .frame{position:absolute;inset:${M}px}
  .frame i{position:absolute;width:${arm}px;height:${arm}px;
    border:0 solid rgba(237,238,240,.2)}
  .frame i:nth-child(1){top:0;left:0;border-top-width:1.5px;border-left-width:1.5px}
  .frame i:nth-child(2){top:0;right:0;border-top-width:1.5px;border-right-width:1.5px}
  .frame i:nth-child(3){bottom:0;right:0;border-bottom-width:1.5px;border-right-width:1.5px}
  .frame i:nth-child(4){bottom:0;left:0;border-bottom-width:1.5px;border-left-width:1.5px}

  /* Masthead: name block left, mark large right. The mark is the subject of
     the card, not a credit in the corner. */
  .masthead{position:absolute;left:${G}px;right:${G}px;top:${G}px;height:${MARK}px;
    display:flex;align-items:center;justify-content:space-between}
  .name{color:${PORCELAIN};font-size:26px;font-weight:500;
    font-variation-settings:'wdth' 118,'wght' 500;letter-spacing:.185em;
    margin-right:-.185em;line-height:1;text-transform:uppercase;white-space:nowrap}
  .sub{margin-top:15px}

  .rule{position:absolute;left:${G}px;right:${G}px;height:1px;
    background:rgba(237,238,240,.14)}


  .tag{font-size:12px;font-weight:500;letter-spacing:.22em;color:${GREY_300};
    white-space:nowrap}

  .head{position:absolute;left:${G}px;width:${colW}px;top:${G + MARK + 96}px;
    color:${PORCELAIN};font-weight:600;line-height:.95;
    letter-spacing:-.022em;white-space:nowrap}
  /* max-content so the line reports its true set width, not the column's */
  .head span{display:block;width:max-content;font-variation-settings:'wdth' 116,'wght' 600}

  .foot{position:absolute;left:${G}px;right:${G}px;bottom:${G - 28}px;
    display:flex;align-items:baseline;justify-content:space-between}
  </style>

  <div class="grid"></div>
  <div class="frame"><i></i><i></i><i></i><i></i></div>

  <div class="masthead">
    <span>
      <span class="sans name">New AI Vision Labs</span>
      <span class="mono tag sub" style="display:block">Machine perception research</span>
    </span>
    ${markSvg({ size: MARK, stroke: PORCELAIN, dot: accentWord ? PORCELAIN : PHOSPHOR })}
  </div>

  <div class="rule" style="top:${G + MARK + 46}px"></div>

  <div class="head sans">
    <span id="l1">${line1}</span>
    <span id="l2">${line2}</span>
  </div>

  <div class="rule" style="bottom:${G + 8}px"></div>
  <div class="foot">
    <span class="mono tag">newaivisionlabs.com</span>
    <span class="mono tag">Ten synthetic worlds · running</span>
  </div>`;
}

/**
 * Sets the statement to the column measure. `flush` solves a size per line so
 * both lines end on the same right edge — a type block, not a paragraph.
 * `even` keeps one size for both and lets the rag fall where it falls.
 */
function fitHeadline(mode, colW) {
  const lines = [document.getElementById('l1'), document.getElementById('l2')];
  const widthAt = (el, px) => {
    el.style.fontSize = px + 'px';
    return el.getBoundingClientRect().width;
  };
  const solve = (el) => {
    let lo = 20;
    let hi = 200;
    for (let i = 0; i < 40; i++) {
      const mid = (lo + hi) / 2;
      if (widthAt(el, mid) > colW) hi = mid;
      else lo = mid;
    }
    return lo;
  };
  const sizes = lines.map(solve);
  const applied = mode === 'flush' ? sizes : [Math.min(...sizes), Math.min(...sizes)];
  lines.forEach((el, i) => {
    el.style.fontSize = applied[i] + 'px';
  });
  return applied.map((s) => Math.round(s * 10) / 10);
}

/* -------------------------------------------------------------------------
   Static server — the assets need the self-hosted fonts from /public/fonts.
   ------------------------------------------------------------------------- */
const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.woff2': 'font/woff2',
  '.svg': 'image/svg+xml',
};

function serve() {
  return new Promise((resolve) => {
    const server = createServer((req, res) => {
      const url = decodeURIComponent((req.url ?? '/').split('?')[0]);
      // A real document to anchor setContent against, so the relative /fonts
      // URLs in the injected markup resolve to this server.
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

/* -------------------------------------------------------------------------
   Run
   ------------------------------------------------------------------------- */
const args = process.argv.slice(2);
const review = args.includes('--review');
const ogVariants = args.includes('--og-variants');
const variantArg = (args.find((a) => a.startsWith('--og=')) ?? '--og=mark').slice(5);

mkdirSync(BRAND, { recursive: true });
writeFileSync(join(PUBLIC, 'favicon.svg'), FAVICON);
console.log(`  favicon.svg      ${FAVICON.length} B`);

const server = await serve();
const browser = await chromium.launch({
  args: ['--force-color-profile=srgb', '--disable-lcd-text', '--disable-dev-shm-usage'],
});

/** A page anchored to the asset server, so /fonts resolves. */
async function stage(width, height, html) {
  const page = await browser.newPage({ viewport: { width, height }, deviceScaleFactor: 2 });
  await page.addInitScript(`window.__fit = ${fitHeadline.toString()};`);
  await page.goto(`http://127.0.0.1:${PORT}/__blank`);
  await page.setContent(html);
  await page.evaluate(async () => {
    await document.fonts.ready;
  });
  return page;
}

async function writeOg(variant, out) {
  const page = await stage(OG_W, OG_H, ogHtml(variant));
  const sizes = await page.evaluate(
    ([mode, colW]) => window.__fit(mode, colW),
    [variant === 'flush' ? 'flush' : 'even', OG_W - 92 * 2],
  );
  writeFileSync(out, await page.screenshot({ type: 'jpeg', quality: 92 }));
  await page.close();
  return sizes;
}

if (ogVariants) {
  for (const v of ['mark', 'accent-word', 'flush']) {
    const sizes = await writeOg(v, join(BRAND, `_og-${v}.jpg`));
    console.log(`  _og-${v}.jpg   headline ${sizes.join(' / ')}px`);
  }
} else {
  const sizes = await writeOg(variantArg, join(PUBLIC, 'og.jpg'));
  console.log(`  og.jpg           1200×630, headline ${sizes.join(' / ')}px`);
}

/* --- mark-512.png -------------------------------------------------------
   The app tile. Ink ground so it never lands on an unknown background, and the
   one phosphor dot — at 40px on a home screen the accent is the whole recall.
   The mark is held at 64% of the tile: inside a maskable circle, clear of the
   iOS corner radius, and large enough that the ticks still read once the OS
   has scaled it down. No grid here — it is invisible at icon sizes and only
   costs bytes and edge noise beside the ticks.
   ----------------------------------------------------------------------- */
{
  const S = 512;
  const inner = Math.round(S * 0.64);
  const page = await stage(
    S,
    S,
    `<!doctype html><meta charset="utf-8"><style>${FONTS}
    body{width:${S}px;height:${S}px;background:${INK_100};display:grid;place-items:center}
    </style>` + markSvg({ size: inner, stroke: PORCELAIN, dot: PHOSPHOR }),
  );
  writeFileSync(
    join(BRAND, 'mark-512.png'),
    await page.screenshot({ type: 'png', scale: 'css' }),
  );
  await page.close();
  console.log(`  brand/mark-512.png  ${S}×${S}`);
}

/* --- review sheets ------------------------------------------------------ */
if (review) {
  const sizes = [16, 20, 24, 32, 48, 64];
  const page = await stage(
    1240,
    400,
    `<!doctype html><meta charset="utf-8"><style>${FONTS}
    body{padding:44px;color:${PORCELAIN};font-family:'JetBrains Mono Variable',monospace}
    h4{font-size:10px;letter-spacing:.2em;color:${GREY_300};font-weight:500;
      text-transform:uppercase;margin:34px 0 14px}
    .strip{display:flex;align-items:center;gap:30px;flex-wrap:wrap}
    .chip{display:inline-grid;place-items:center;padding:14px;background:${INK_100}}
    .lite .chip{background:${PORCELAIN}}
    .stack{display:flex;flex-direction:column;gap:26px;align-items:flex-start}
    </style>
    <h4>Lockup · 22 / 30 / 44 / 64</h4>
    <div class="stack">${[22, 30, 44, 64].map((s) => lockup({ size: s, dot: PHOSPHOR })).join('')}</div>
    <h4>Mark on ink</h4>
    <div class="strip">${sizes.map((s) => `<span class="chip">${markSvg({ size: s })}</span>`).join('')}</div>
    <h4>Mark on porcelain</h4>
    <div class="strip lite">${sizes.map((s) => `<span class="chip">${markSvg({ size: s, stroke: INK })}</span>`).join('')}</div>
    <h4>Mark 400 · plain / accent</h4>
    <div class="strip">${markSvg({ size: 300 })}${markSvg({ size: 300, dot: PHOSPHOR })}</div>`,
  );
  writeFileSync(
    join(BRAND, '_review.png'),
    await page.screenshot({ fullPage: true, type: 'png', scale: 'css' }),
  );
  await page.close();
  console.log('  brand/_review.png');
}

await browser.close();
server.close();
console.log('\nBrand assets written.');
