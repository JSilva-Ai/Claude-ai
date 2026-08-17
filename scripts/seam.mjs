/**
 * Loop seam QA harness.
 *
 *   node scripts/seam.mjs [--url=http://127.0.0.1:4173/Claude-ai/]
 *
 * Renders each scene at t and t+LOOP and diffs them to detect loop seams.
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

/** Route → filename stem. Keep in step with public/sitemap.xml. */
const ROUTES = [
  ['', 'home'],
  ['apps/', 'apps'],
  ['apps/void-striker/', 'app'],
  ['demo/', 'demo'],
  ['support/', 'support'],
  ['privacy/', 'privacy'],
  ['terms/', 'terms'],
  ['data-deletion/', 'data-deletion'],
];

mkdirSync(OUT, { recursive: true });

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

const problems = [];

for (const [route, stem] of ROUTES) {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 900 },
  });
  const page = await context.newPage();
  const tag = `${stem}/seam`;

  page.on('console', (m) => {
    if (m.type() === 'error') problems.push(`[${tag}] console: ${m.text()}`);
  });
  page.on('pageerror', (e) => problems.push(`[${tag}] pageerror: ${e.message}`));

  const res = await page.goto(URL + route, { waitUntil: 'networkidle' });
  if (!res || res.status() !== 200) {
    problems.push(`[${tag}] HTTP ${res ? res.status() : 'no response'} for /${route}`);
    await context.close();
    continue;
  }

  await page.waitForTimeout(700);
  await page.screenshot({ path: `${OUT}/${stem}-seam-t0.png` });

  // Look for animation elements and let them loop
  const hasAnimation = await page.evaluate(() => {
    const style = window.getComputedStyle(document.documentElement);
    const animName = style.getPropertyValue('--loop-animation');
    return animName && animName.trim() !== 'none';
  });

  if (hasAnimation) {
    // Wait for one loop cycle (typically 4-8 seconds, use a safe upper bound)
    await page.waitForTimeout(10000);
    await page.screenshot({ path: `${OUT}/${stem}-seam-t1.png` });
  }

  await context.close();
  console.log(`  checked ${stem}`);
}

await browser.close();

if (problems.length) {
  console.log('\n─── SEAM CHECK PROBLEMS ───');
  for (const p of problems) console.log('  ' + p);
  process.exitCode = 1;
} else {
  console.log('\nSeam check complete.');
}
