/**
 * Visual QA harness.
 *
 *   node scripts/shoot.mjs [--url=http://127.0.0.1:4173] [--vp=desktop,mobile]
 *                          [--full] [--sections] [--motion]
 *
 * Writes PNGs to .qa/ and reports any console errors, which is the cheapest
 * way to catch a broken render before looking at a single pixel.
 */

import { mkdirSync, rmSync } from 'node:fs';
import { chromium } from 'playwright';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);

const URL = args.url ?? 'http://127.0.0.1:4173';
const OUT = '.qa';

const VIEWPORTS = {
  xl: { width: 1920, height: 1080, dsf: 1 },
  desktop: { width: 1440, height: 900, dsf: 1 },
  laptop: { width: 1280, height: 800, dsf: 1 },
  tablet: { width: 834, height: 1112, dsf: 2 },
  mobile: { width: 390, height: 844, dsf: 3 },
  small: { width: 320, height: 640, dsf: 2 },
};

const wanted = (args.vp ? String(args.vp).split(',') : ['desktop', 'mobile']).filter(
  (v) => v in VIEWPORTS,
);

rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

const problems = [];

for (const name of wanted) {
  const vp = VIEWPORTS[name];
  const context = await browser.newContext({
    viewport: { width: vp.width, height: vp.height },
    deviceScaleFactor: vp.dsf,
    isMobile: name === 'mobile' || name === 'small',
    hasTouch: name === 'mobile' || name === 'small' || name === 'tablet',
    reducedMotion: args.motion === 'reduce' ? 'reduce' : 'no-preference',
  });
  const page = await context.newPage();
  page.on('console', (m) => {
    if (m.type() === 'error') problems.push(`[${name}] console: ${m.text()}`);
  });
  page.on('pageerror', (e) => problems.push(`[${name}] pageerror: ${e.message}`));
  page.on('requestfailed', (r) =>
    problems.push(`[${name}] request failed: ${r.url()} — ${r.failure()?.errorText}`),
  );

  await page.goto(URL, { waitUntil: 'networkidle' });
  await page.waitForTimeout(2200); // let the hero choreography resolve

  await page.screenshot({ path: `${OUT}/${name}-hero.png` });

  if (args.full) {
    // Scroll through so every reveal has fired before the full-page shot.
    await page.evaluate(async () => {
      const step = window.innerHeight * 0.7;
      for (let y = 0; y < document.body.scrollHeight; y += step) {
        window.scrollTo(0, y);
        await new Promise((r) => setTimeout(r, 190));
      }
      window.scrollTo(0, 0);
      await new Promise((r) => setTimeout(r, 400));
    });
    await page.waitForTimeout(700);
    // Chromium stitches full-page shots by scrolling, which smears any
    // position:fixed layer down the capture. Pin them for the shot only.
    await page.addStyleTag({
      content: '.grain{display:none!important}.nav{position:absolute!important}',
    });
    await page.screenshot({ path: `${OUT}/${name}-full.png`, fullPage: true });
  }

  if (args.sections) {
    // Reveals are scroll-triggered; without a pass down the page the lower
    // items in a section are still at opacity 0 when it is captured.
    await page.evaluate(async () => {
      const step = window.innerHeight * 0.7;
      for (let y = 0; y < document.body.scrollHeight; y += step) {
        window.scrollTo(0, y);
        await new Promise((r) => setTimeout(r, 150));
      }
    });
    const ids = ['thesis', 'capabilities', 'proving-grounds', 'research', 'applications', 'lab', 'contact'];
    for (const id of ids) {
      const el = await page.$(`#${id}`);
      if (!el) {
        problems.push(`[${name}] missing section #${id}`);
        continue;
      }
      await el.scrollIntoViewIfNeeded();
      await page.waitForTimeout(900);
      await el.screenshot({ path: `${OUT}/${name}-${id}.png` });
    }
  }

  // Broken images do not 404 behind an SPA fallback — the server happily
  // returns index.html with a 200. Decode state is the only honest signal.
  const brokenImages = await page.evaluate(() =>
    [...document.querySelectorAll('img')]
      .filter((img) => img.complete && img.naturalWidth === 0)
      .map((img) => img.getAttribute('src')),
  );
  for (const src of brokenImages) problems.push(`[${name}] broken image: ${src}`);

  // Horizontal overflow is the single most common responsive defect.
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
      `[${name}] HORIZONTAL OVERFLOW ${overflow.scrollWidth} > ${overflow.docWidth}\n    ` +
        overflow.offenders.join('\n    '),
    );
  }

  await context.close();
  console.log(`  shot ${name}`);
}

await browser.close();

if (problems.length) {
  console.log('\n─── PROBLEMS ───');
  for (const p of problems) console.log('  ' + p);
  process.exitCode = 1;
} else {
  console.log('\nNo console errors, failed requests, or horizontal overflow.');
}
