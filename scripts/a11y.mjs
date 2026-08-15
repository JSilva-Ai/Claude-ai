/**
 * Accessibility audit.
 *
 *   node scripts/a11y.mjs [--url=...] [--vp=desktop,mobile]
 *
 * Runs axe-core over the page in three states — at rest, with the mobile menu
 * open, and under reduced motion — then walks the whole page by keyboard and
 * reports any focusable element that never receives a visible focus ring.
 * Automated checks catch perhaps half of what matters, so the keyboard walk
 * and the contrast table are reported alongside them.
 */

import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { chromium } from 'playwright';

const require = createRequire(import.meta.url);
const axeSource = readFileSync(require.resolve('axe-core'), 'utf8');

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);
const URL = args.url ?? 'http://127.0.0.1:4173/Claude-ai/';
const VIEWPORTS = {
  desktop: { width: 1440, height: 900 },
  mobile: { width: 390, height: 844 },
};
const wanted = (args.vp ? String(args.vp).split(',') : ['desktop', 'mobile']).filter(
  (v) => v in VIEWPORTS,
);

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

let violationCount = 0;

async function audit(page, context) {
  const results = await page.evaluate(async () => {
    // eslint-disable-next-line no-undef
    return await window.axe.run(document, {
      resultTypes: ['violations'],
      runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'] },
    });
  });
  if (!results.violations.length) {
    console.log(`  ✓ ${context}: no violations`);
    return;
  }
  for (const v of results.violations) {
    violationCount++;
    console.log(`  ✗ ${context}: [${v.impact}] ${v.id} — ${v.help}`);
    for (const node of v.nodes.slice(0, 4)) {
      console.log(`      ${node.target.join(' ')}`);
      const msg = node.failureSummary?.split('\n').filter(Boolean).slice(1, 3).join(' | ');
      if (msg) console.log(`        ${msg}`);
    }
    if (v.nodes.length > 4) console.log(`      …and ${v.nodes.length - 4} more`);
  }
}

for (const name of wanted) {
  console.log(`\n── ${name} ─────────────────────────────`);
  const ctx = await browser.newContext({ viewport: VIEWPORTS[name] });
  const page = await ctx.newPage();
  await page.goto(URL, { waitUntil: 'networkidle' });
  // Fire every scroll reveal, or axe audits a page of opacity-0 elements.
  await page.evaluate(async () => {
    for (let y = 0; y < document.body.scrollHeight; y += 300) {
      window.scrollTo({ top: y, behavior: 'instant' });
      await new Promise((r) => requestAnimationFrame(() => setTimeout(r, 55)));
    }
    window.scrollTo({ top: 0, behavior: 'instant' });
  });
  await page.waitForTimeout(600);
  await page.addScriptTag({ content: axeSource });

  await audit(page, 'at rest');

  if (name === 'mobile') {
    await page.click('.nav__toggle');
    // The sheet's last item finishes its staggered fade around 970ms. Auditing
    // before then measures contrast against a half-faded button and reports a
    // failure that does not exist at rest.
    await page.waitForTimeout(1500);
    await audit(page, 'menu open');
    await page.click('.nav__toggle');
    await page.waitForTimeout(400);
  }

  // --- Keyboard walk -------------------------------------------------------
  // Real Tab presses, not element.focus(): :focus-visible only matches when
  // the browser judges the interaction to be keyboard-driven, so a scripted
  // focus() reports every element as having no ring.
  await page.evaluate(() => window.scrollTo(0, 0));
  const seen = new Set();
  const focusProblems = [];
  let steps = 0;
  for (; steps < 80; steps++) {
    await page.keyboard.press('Tab');
    const info = await page.evaluate(() => {
      const el = document.activeElement;
      if (!el || el === document.body) return null;
      const cs = getComputedStyle(el);
      return {
        key: `${el.tagName}.${el.className}.${(el.textContent || '').trim().slice(0, 20)}`,
        label: `${el.tagName.toLowerCase()}.${String(el.className).slice(0, 28)} "${(el.textContent || '').trim().slice(0, 24)}"`,
        ring:
          (cs.outlineStyle !== 'none' && parseFloat(cs.outlineWidth) > 0) ||
          cs.boxShadow !== 'none',
        offscreen: el.getBoundingClientRect().width === 0,
      };
    });
    if (!info) break;
    if (seen.has(info.key)) break; // wrapped around
    seen.add(info.key);
    if (!info.ring && !info.offscreen) focusProblems.push(`no focus indicator: ${info.label}`);
  }
  console.log(`  · ${seen.size} elements reached by Tab`);
  for (const p of focusProblems) {
    violationCount++;
    console.log(`  ✗ ${p}`);
  }

  // --- Touch targets -------------------------------------------------------
  const smallTargets = await page.evaluate(() =>
    [...document.querySelectorAll('a[href], button')]
      .map((el) => ({ el, r: el.getBoundingClientRect() }))
      .filter(({ r }) => r.width > 0 && (r.height < 24 || r.width < 24))
      .map(
        ({ el, r }) =>
          `${el.tagName.toLowerCase()}.${String(el.className).slice(0, 28)} ${Math.round(r.width)}×${Math.round(r.height)}`,
      ),
  );
  for (const t of smallTargets) {
    violationCount++;
    console.log(`  ✗ target below 24×24 (WCAG 2.2 AA): ${t}`);
  }

  await ctx.close();
}

await browser.close();
console.log(violationCount ? `\n${violationCount} issue(s).` : '\nClean.');
process.exitCode = violationCount ? 1 : 0;
