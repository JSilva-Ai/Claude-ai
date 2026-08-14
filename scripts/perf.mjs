/**
 * Performance audit.
 *
 *   node scripts/perf.mjs [--url=...] [--cpu=4] [--net=slow]
 *
 * Reports Core Web Vitals, transfer weight by type, long tasks, and the frame
 * rate the hero field actually sustains under CPU throttling. Numbers, not
 * opinions — the point is to catch a regression, not to feel fast.
 */

import { chromium } from 'playwright';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);
const URL = args.url ?? 'http://127.0.0.1:4173';
const cpuThrottle = Number(args.cpu ?? 4);

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
const page = await context.newPage();

const bytes = { total: 0 };
page.on('response', async (res) => {
  try {
    const type = (res.request().resourceType() || 'other').padEnd(0);
    const len = Number(res.headers()['content-length'] ?? 0);
    const size = len || (await res.body().catch(() => Buffer.alloc(0))).length;
    bytes[type] = (bytes[type] ?? 0) + size;
    bytes.total += size;
  } catch {
    /* response body may be unavailable for redirects */
  }
});

const cdp = await context.newCDPSession(page);
await cdp.send('Emulation.setCPUThrottlingRate', { rate: cpuThrottle });

await page.addInitScript(() => {
  window.__vitals = { lcp: 0, cls: 0, longTasks: [], shifts: [] };
  new PerformanceObserver((l) => {
    for (const e of l.getEntries()) {
      window.__vitals.lcp = e.startTime;
      window.__vitals.lcpEl = e.element
        ? `${e.element.tagName}.${String(e.element.className).slice(0, 32)}`
        : e.url || 'unknown';
    }
  }).observe({ type: 'largest-contentful-paint', buffered: true });
  new PerformanceObserver((l) => {
    for (const e of l.getEntries()) {
      if (!e.hadRecentInput) {
        window.__vitals.cls += e.value;
        if (e.value > 0.001) {
          window.__vitals.shifts.push({
            value: +e.value.toFixed(4),
            nodes: e.sources
              ?.map((s) => s.node?.tagName + '.' + (s.node?.className || '').slice(0, 24))
              .slice(0, 2),
          });
        }
      }
    }
  }).observe({ type: 'layout-shift', buffered: true });
  new PerformanceObserver((l) => {
    for (const e of l.getEntries()) window.__vitals.longTasks.push(Math.round(e.duration));
  }).observe({ type: 'longtask', buffered: true });
});

const t0 = Date.now();
await page.goto(URL, { waitUntil: 'load' });
const loadMs = Date.now() - t0;
await page.waitForTimeout(3500);

const v = await page.evaluate(() => window.__vitals);
const paint = await page.evaluate(() =>
  Object.fromEntries(
    performance.getEntriesByType('paint').map((e) => [e.name, Math.round(e.startTime)]),
  ),
);

// Measured frame rate of the hero field, under the same throttling.
const fps = await page.evaluate(
  () =>
    new Promise((resolve) => {
      let frames = 0;
      const start = performance.now();
      const tick = () => {
        frames++;
        if (performance.now() - start < 2000) requestAnimationFrame(tick);
        else resolve(Math.round((frames / (performance.now() - start)) * 1000));
      };
      requestAnimationFrame(tick);
    }),
);

// Scroll the page and watch for dropped frames — the grain overlay and the
// reveal transitions are the usual suspects.
const scrollFps = await page.evaluate(
  () =>
    new Promise((resolve) => {
      let frames = 0;
      const start = performance.now();
      let y = 0;
      const tick = () => {
        frames++;
        y += 26;
        window.scrollTo(0, y);
        if (performance.now() - start < 2500) requestAnimationFrame(tick);
        else {
          window.scrollTo(0, 0);
          resolve(Math.round((frames / (performance.now() - start)) * 1000));
        }
      };
      requestAnimationFrame(tick);
    }),
);

const kb = (n) => (n / 1024).toFixed(1).padStart(7) + ' KB';

console.log(`\n  CPU throttle       ${cpuThrottle}x`);
console.log(`  load event         ${loadMs} ms`);
console.log(`  first paint        ${paint['first-paint'] ?? '—'} ms`);
console.log(`  first contentful   ${paint['first-contentful-paint'] ?? '—'} ms`);
console.log(`  LCP                ${Math.round(v.lcp)} ms  (${v.lcpEl ?? '—'})`);
console.log(`  CLS                ${v.cls.toFixed(4)}`);
for (const s of v.shifts.slice(0, 5)) {
  console.log(`      shift ${s.value} ${(s.nodes ?? []).join(', ')}`);
}
console.log(`  long tasks         ${v.longTasks.length} (${v.longTasks.join(', ') || 'none'})`);
console.log(`  hero fps           ${fps}`);
console.log(`  scroll fps         ${scrollFps}`);
console.log('\n  transfer by type');
for (const [k, val] of Object.entries(bytes).sort((a, b) => b[1] - a[1])) {
  console.log(`    ${k.padEnd(12)} ${kb(val)}`);
}

await browser.close();
