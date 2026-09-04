/**
 * Visual QA harness.
 *
 *   node scripts/shoot.mjs [--url=http://127.0.0.1:4173/Claude-ai/]
 *                          [--vp=desktop,mobile] [--routes=,apps/] [--full]
 *
 * Walks every route, writes PNGs to .qa/, and fails on console errors, failed
 * requests, broken images, or horizontal overflow.
 *
 * The site is multi-page, so this navigates between real documents rather than
 * scrolling one. That also means each route gets its own console-error budget:
 * an error on /privacy is not masked by a clean home page.
 */

import { mkdirSync, rmSync } from 'node:fs';
import { chromium } from 'playwright';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);

const URL = args.url ?? 'http://127.0.0.1:4173/Claude-ai/';
const OUT = '.qa';

const VIEWPORTS = {
  xl: { width: 1920, height: 1080, dsf: 1 },
  desktop: { width: 1440, height: 900, dsf: 1 },
  laptop: { width: 1280, height: 800, dsf: 1 },
  tablet: { width: 834, height: 1112, dsf: 2 },
  mobile: { width: 390, height: 844, dsf: 3 },
  small: { width: 320, height: 640, dsf: 2 },
};

/** Route → filename stem. Keep in step with public/sitemap.xml. */
const ROUTES = [
  ['', 'home'],
  ['apps/', 'apps'],
  ['apps/loop/', 'app-loop'],
  ['apps/shield/', 'app-shield'],
  ['apps/guard/', 'app-guard'],
  ['apps/biblelink/', 'app-biblelink'],
  ['apps/void-striker/', 'app-void-striker'],
  ['apps/galaxy-forge/', 'app-galaxy-forge'],
  ['demo/', 'demo'],
  ['support/', 'support'],
  ['privacy/', 'privacy'],
  ['terms/', 'terms'],
  ['data-deletion/', 'data-deletion'],
];

const wanted = (args.vp ? String(args.vp).split(',') : ['desktop', 'mobile']).filter(
  (v) => v in VIEWPORTS,
);
const routes = args.routes
  ? ROUTES.filter(([r]) => String(args.routes).split(',').includes(r))
  : ROUTES;

rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

const problems = [];

for (const name of wanted) {
  const vp = VIEWPORTS[name];

  for (const [route, stem] of routes) {
    const context = await browser.newContext({
      viewport: { width: vp.width, height: vp.height },
      deviceScaleFactor: vp.dsf,
      isMobile: name === 'mobile' || name === 'small',
      hasTouch: name === 'mobile' || name === 'small' || name === 'tablet',
      reducedMotion: args.motion === 'reduce' ? 'reduce' : 'no-preference',
    });
    const page = await context.newPage();
    const tag = `${stem}/${name}`;

    page.on('console', (m) => {
      if (m.type() === 'error') problems.push(`[${tag}] console: ${m.text()}`);
    });
    page.on('pageerror', (e) => problems.push(`[${tag}] pageerror: ${e.message}`));
    page.on('requestfailed', (r) => {
      // A cancelled fetch during teardown is not a broken asset. Closing the
      // context aborts whatever is still in flight, and the narrow viewports,
      // shot last, race it most often. A genuinely missing file still surfaces
      // as a broken image below or as a non-200 in the route check.
      if (r.failure()?.errorText === 'net::ERR_ABORTED') return;
      problems.push(`[${tag}] request failed: ${r.url()} — ${r.failure()?.errorText}`);
    });

    const res = await page.goto(URL + route, { waitUntil: 'networkidle' });
    if (!res || res.status() !== 200) {
      problems.push(`[${tag}] HTTP ${res ? res.status() : 'no response'} for /${route}`);
    }
    await page.waitForTimeout(route === '' ? 1800 : 700);

    if (args.full) {
      // Scroll through so every reveal has fired. Small steps on purpose:
      // IntersectionObserver samples at frame boundaries and coalesces, so a
      // viewport-sized jump can carry an element past the root between two
      // samples and its reveal never fires.
      await page.evaluate(async () => {
        for (let y = 0; y < document.body.scrollHeight; y += 300) {
          window.scrollTo({ top: y, behavior: 'instant' });
          await new Promise((r) => requestAnimationFrame(() => setTimeout(r, 45)));
        }
        window.scrollTo({ top: 0, behavior: 'instant' });
        await new Promise((r) => setTimeout(r, 300));
      });
      await page.waitForTimeout(500);
    }

    await page.screenshot({ path: `${OUT}/${stem}-${name}.png` });

    // Broken images do not 404 behind a static host's directory handling —
    // decode state is the only honest signal.
    const broken = await page.evaluate(() =>
      [...document.querySelectorAll('img')]
        .filter((img) => img.complete && img.naturalWidth === 0)
        .map((img) => img.getAttribute('src')),
    );
    for (const src of broken) problems.push(`[${tag}] broken image: ${src}`);

    const overflow = await page.evaluate(() => {
      const docWidth = document.documentElement.clientWidth;
      if (document.documentElement.scrollWidth <= docWidth + 1) return null;
      const offenders = [];
      for (const el of document.querySelectorAll('*')) {
        const r = el.getBoundingClientRect();
        if (r.right > docWidth + 1 || r.left < -1) {
          offenders.push(
            `${el.tagName.toLowerCase()}.${String(el.className).slice(0, 40)} → ${Math.round(r.left)}..${Math.round(r.right)}`,
          );
        }
        if (offenders.length > 6) break;
      }
      return { scrollWidth: document.documentElement.scrollWidth, docWidth, offenders };
    });
    if (overflow) {
      problems.push(
        `[${tag}] HORIZONTAL OVERFLOW ${overflow.scrollWidth} > ${overflow.docWidth}\n    ` +
          overflow.offenders.join('\n    '),
      );
    }

    await context.close();
  }
  console.log(`  shot ${name} — ${routes.length} routes`);
}

await browser.close();

if (problems.length) {
  console.log('\n─── PROBLEMS ───');
  for (const p of problems) console.log('  ' + p);
  process.exitCode = 1;
} else {
  console.log('\nNo console errors, failed requests, broken images, or horizontal overflow.');
}
