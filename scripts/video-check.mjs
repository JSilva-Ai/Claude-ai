/**
 * End-to-end check on the Proving Grounds monitors.
 *
 *   node scripts/video-check.mjs [--url=http://127.0.0.1:4173]
 *
 * Confirms the things that unit-level checks cannot: that a monitor actually
 * mounts and plays on hover, that it reports the duration the clips were
 * authored for, that it pauses when it leaves the viewport, and that no more
 * decoders are running than intended.
 */

import { chromium } from 'playwright';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);
const URL = args.url ?? 'http://127.0.0.1:4173';
const EXPECTED_DURATION = 12;

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
const problems = [];
page.on('pageerror', (e) => problems.push(`pageerror: ${e.message}`));

await page.goto(URL, { waitUntil: 'networkidle' });
await page.evaluate(async () => {
  for (let y = 0; y < document.body.scrollHeight; y += 300) {
    window.scrollTo({ top: y, behavior: 'instant' });
    await new Promise((r) => requestAnimationFrame(() => setTimeout(r, 40)));
  }
});
await page.locator('#proving-grounds').scrollIntoViewIfNeeded();
await page.waitForTimeout(2500);

// --- Lead monitors should be running without any interaction ---------------
const auto = await page.evaluate(() =>
  [...document.querySelectorAll('.env__video')].map((v) => ({
    src: v.currentSrc.split('/').pop(),
    paused: v.paused,
    duration: Math.round(v.duration * 100) / 100,
  })),
);
console.log(`  auto-started monitors: ${auto.length}`);
for (const v of auto) {
  console.log(`    ${v.src} — ${v.paused ? 'paused' : 'playing'}, ${v.duration}s`);
  if (v.paused) problems.push(`lead monitor ${v.src} did not start`);
  if (Math.abs(v.duration - EXPECTED_DURATION) > 0.05) {
    problems.push(`${v.src} is ${v.duration}s, expected ${EXPECTED_DURATION}s`);
  }
}
if (auto.length > 2) problems.push(`${auto.length} monitors mounted before hover; expected 2`);
if (auto.length === 0) problems.push('no monitors auto-started');

// --- Hover should mount and play a monitor that was not running -------------
const cards = page.locator('.env__frame');
await cards.nth(5).hover();
await page.waitForTimeout(2500);
const hovered = await page.evaluate(() => {
  const v = document.querySelectorAll('.env')[5].querySelector('video');
  return v
    ? {
        src: v.currentSrc.split('/').pop(),
        paused: v.paused,
        duration: Math.round(v.duration * 100) / 100,
        time: v.currentTime,
      }
    : null;
});
if (!hovered) {
  problems.push('hovering a monitor did not mount its video');
} else {
  console.log(
    `  on hover: ${hovered.src} — ${hovered.paused ? 'paused' : 'playing'}, ` +
      `${hovered.duration}s, t=${hovered.time.toFixed(2)}`,
  );
  if (hovered.paused) problems.push(`hovered monitor ${hovered.src} did not play`);
  if (hovered.time === 0) problems.push(`hovered monitor ${hovered.src} is not advancing`);
}

// --- Scrolling away should stop every decoder ------------------------------
await page.evaluate(() => window.scrollTo({ top: 0, behavior: 'instant' }));
await page.waitForTimeout(1600);
const afterScroll = await page.evaluate(
  () => [...document.querySelectorAll('.env__video')].filter((v) => !v.paused).length,
);
console.log(`  playing after scrolling away: ${afterScroll}`);
if (afterScroll > 0) problems.push(`${afterScroll} monitor(s) still decoding off-screen`);

// --- The motion toggle must actually stop playback -------------------------
await page.locator('#proving-grounds').scrollIntoViewIfNeeded();
await page.waitForTimeout(2000);
await page.locator('.grounds__toggle').click();
await page.waitForTimeout(1200);
const afterToggle = await page.evaluate(
  () => [...document.querySelectorAll('.env__video')].filter((v) => !v.paused).length,
);
console.log(`  playing after motion toggled off: ${afterToggle}`);
if (afterToggle > 0) problems.push(`${afterToggle} monitor(s) ignored the motion toggle`);

await browser.close();

if (problems.length) {
  console.log('\n─── PROBLEMS ───');
  for (const p of problems) console.log('  ' + p);
  process.exitCode = 1;
} else {
  console.log('\nMonitors behave correctly.');
}
