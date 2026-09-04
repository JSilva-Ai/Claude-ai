/**
 * RTL regression coverage.
 *
 *   node scripts/rtl.mjs [--url=http://127.0.0.1:4173/Claude-ai/]
 *                        [--vp=desktop,mobile] [--routes=,apps/]
 *
 * Runs before Arabic exists, and that is the point: the layout has to be
 * direction-agnostic *before* there is content depending on it, or the first
 * Arabic page becomes a bug hunt through a design system nobody has ever seen
 * mirrored.
 *
 * It forces `dir="rtl"` on a site whose only published locale is English, so
 * the text stays Latin and reads oddly. That is fine — none of the four checks
 * below are about language. They are about whether the box model was written in
 * physical or logical terms, which is a property of the CSS alone.
 *
 * Why this exists as a permanent suite rather than a one-off: converting the
 * prose list's `padding-left` to `padding-inline-start` while leaving its
 * bullet at `left: calc(...)` pushed /support/ 3px wide in RTL. Nothing was out
 * of bounds, nothing looked wrong in LTR, and the entire existing suite stayed
 * green — because every check in it runs left to right. A one-off sweep found
 * that once. A suite finds the next one.
 *
 * The four checks:
 *
 *   1. Horizontal overflow      the document must not be wider than the viewport
 *   2. Out-of-bounds elements   nothing may hang past either edge
 *   3. Mirror symmetry          an element's distance from the start edge should
 *                               be the same in both directions — this is what
 *                               catches a physical property that did not flip
 *   4. Directional icons        the "opens elsewhere" arrow must point the other
 *                               way, since it is a glyph and glyphs do not mirror
 *                               themselves
 */

import { chromium } from 'playwright';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);

const URL = args.url ?? 'http://127.0.0.1:4173/Claude-ai/';

const VIEWPORTS = {
  desktop: { width: 1440, height: 900 },
  tablet: { width: 834, height: 1112 },
  mobile: { width: 390, height: 844 },
  small: { width: 320, height: 640 },
};

/**
 * A sample, not every route.
 *
 * Direction bugs live in components, and every component on the site appears on
 * one of these five: the home page carries the hero, the approach grid and the
 * product cards; /apps/ the grouped grid; a product page the detail layout and
 * the side rail; /support/ the prose and its lists; /privacy/ the long-form
 * document with its on-this-page rail. Sweeping all thirteen would take four
 * times as long to re-check the same CSS, and a suite that is slow enough to
 * skip is a suite that gets skipped.
 */
const ROUTES = args.routes
  ? String(args.routes).split(',')
  : ['', 'apps/', 'apps/void-striker/', 'support/', 'privacy/'];

const wanted = (args.vp ? String(args.vp).split(',') : Object.keys(VIEWPORTS)).filter(
  (v) => v in VIEWPORTS,
);

/**
 * Deliberately not mirrored, with the reason.
 *
 * The phone mockup on the home page is a picture of an object, not a layout: a
 * phone's side button is on the right of the device whichever way the language
 * on its screen reads, and its island is centred. Mirroring either would draw a
 * phone that does not exist.
 */
const EXEMPT = ['hero__phone-button', 'hero__phone-island'];

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});

let problems = 0;
const note = (route, vp, msg) => {
  problems++;
  console.log(`  ✗ [${route || '/'} · ${vp}] ${msg}`);
};

/**
 * Geometry of every classed element, keyed by a stable path through the DOM.
 *
 * `start` is the distance from the edge the text begins at — the left in LTR,
 * the right in RTL — which is the whole point: in a correctly mirrored layout
 * that number is the same in both directions, and a physical property that did
 * not flip is exactly what makes it differ.
 */
function geometry() {
  const out = {};
  const w = window.innerWidth;
  [...document.querySelectorAll('[class]')].forEach((el, i) => {
    const r = el.getBoundingClientRect();
    if (r.width < 1 || r.height < 1) return;
    const cls = String(el.className);
    out[`${i}:${el.tagName}:${cls.slice(0, 40)}`] = {
      cls,
      start: Math.round(getComputedStyle(el).direction === 'rtl' ? w - r.right : r.left),
      width: Math.round(r.width),
      top: Math.round(r.top),
    };
  });
  return out;
}

for (const name of wanted) {
  const vp = VIEWPORTS[name];

  for (const route of ROUTES) {
    const url = URL + route;

    // Left to right first, as the reference the mirror is measured against.
    const ltr = await browser.newPage({ viewport: vp });
    await ltr.goto(url, { waitUntil: 'networkidle' });
    await ltr.waitForTimeout(250);
    const before = await ltr.evaluate(geometry);
    await ltr.close();

    const page = await browser.newPage({ viewport: vp });
    // Before any script runs, so the first paint is already right-to-left —
    // flipping it afterwards would measure a relayout rather than a render.
    await page.addInitScript(() => document.documentElement.setAttribute('dir', 'rtl'));
    await page.goto(url, { waitUntil: 'networkidle' });
    await page.evaluate(() => document.documentElement.setAttribute('dir', 'rtl'));
    await page.waitForTimeout(250);

    // 1 + 2: overflow, and anything hanging past an edge.
    const bounds = await page.evaluate(() => {
      const w = window.innerWidth;
      const out = [];
      document.querySelectorAll('[class]').forEach((el) => {
        const r = el.getBoundingClientRect();
        if (r.width < 1) return;
        if (r.left < -1 || r.right > w + 1) {
          out.push(`${el.tagName.toLowerCase()}.${String(el.className).slice(0, 34)} [${Math.round(r.left)}…${Math.round(r.right)}]`);
        }
      });
      return { over: document.documentElement.scrollWidth - w, out: out.slice(0, 4) };
    });
    if (bounds.over > 1) note(route, name, `document ${bounds.over}px wider than the viewport`);
    for (const el of bounds.out) note(route, name, `outside the viewport: ${el}`);

    // 3: mirror symmetry. Only elements the direction change did not reflow —
    // a different width means the text wrapped differently, and comparing
    // positions then measures the wrap rather than the box model.
    const after = await page.evaluate(geometry);
    let checked = 0;
    for (const [key, a] of Object.entries(before)) {
      const b = after[key];
      if (!b || a.width !== b.width || a.top !== b.top) continue;
      if (EXEMPT.some((c) => a.cls.includes(c))) continue;
      checked++;
      if (Math.abs(a.start - b.start) > 2) {
        note(
          route,
          name,
          `not mirrored: .${a.cls.slice(0, 34)} sits ${a.start}px from the start in LTR, ${b.start}px in RTL`,
        );
      }
    }

    // 4: the one directional glyph on the site.
    const arrows = await page.evaluate(() =>
      [...document.querySelectorAll('.btn__arrow')].map(
        (el) => getComputedStyle(el).transform,
      ),
    );
    for (const t of arrows) {
      // Any matrix with a negative horizontal scale mirrors the glyph.
      const m = t.match(/matrix\(([-\d.]+)/);
      if (!m || Number(m[1]) >= 0) {
        note(route, name, `the ↗ arrow is not mirrored in RTL (transform: ${t})`);
        break;
      }
    }

    await page.close();
    console.log(`  · ${name} ${(route || '/').padEnd(20)} ${checked} elements compared`);
  }
}

await browser.close();
console.log(
  problems ? `\n${problems} RTL problem(s).` : '\nRTL clean: no overflow, nothing out of bounds, layout mirrors.',
);
process.exitCode = problems ? 1 : 0;
