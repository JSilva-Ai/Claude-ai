# New AI Vision Labs

The website for New AI Vision Labs — an independent app studio publishing to
the App Store and Google Play.

---

## Running it

```bash
npm install
npm run dev            # http://localhost:5173
npm run build          # tsc -b && vite build
npm run preview        # serve dist/ on :4173
```

React, Vite, and hand-written CSS. No CSS framework, no animation library, no
router, no 3D library.

## Structure

This is a **multi-page build**, not a single-page app. Every route is its own
HTML document with its own `<title>`, description, canonical, and entry module.

That is a deployment decision rather than a stylistic one. On a static host an
SPA serves unknown paths from the 404 document, and GitHub Pages returns it
with a real 404 status. `/privacy`, `/terms`, `/support` and `/data-deletion`
are URLs Apple and Google reviewers open directly, and a legal page that
answers 404 is a rejected listing. Real files answer 200.

```
index.html                 → src/pages/home.tsx
apps/index.html            → src/pages/apps.tsx
apps/void-striker/         → src/pages/app-void-striker.tsx
demo/                      → src/pages/demo.tsx
support/  privacy/  terms/  data-deletion/
```

`vite.config.ts` discovers every `index.html` in the project, so adding a route
means adding a directory — there is no list to keep in sync. `public/sitemap.xml`
*is* a list, and does need updating.

```
src/
  content/
    site.ts        studio, nav, home, apps, demo, testimonials, footer
    legal.ts       privacy policy and terms
    help.ts        support and data deletion
  components/      one component per unit; nav.css and hero.css sit beside theirs
  lib/
    perceptionField.ts   the home hero's WebGL2 point cloud
    url.ts               internal links and public assets, resolved against BASE_URL
    hooks.ts             reveal, media query, pointer, scroll
  pages/           one entry per route
  styles/          tokens, base, ui, sections
scripts/
  shoot.mjs        screenshots every route across six viewports
  a11y.mjs         axe-core + keyboard walk + touch-target audit
  perf.mjs         Core Web Vitals, transfer weight, measured frame rate
  render/brand.mjs regenerates og.jpg and the app tile from the mark
```

## Adding an app

1. Add an entry to `apps` in `src/content/site.ts`.
2. Copy `apps/void-striker/index.html` to `apps/<slug>/index.html` and update
   its title, description, and canonical.
3. Copy `src/pages/app-void-striker.tsx` to `src/pages/app-<slug>.tsx`, change
   the slug, and point the new HTML at it.
4. Add the route to `public/sitemap.xml` and to `ROUTES` in `scripts/shoot.mjs`.

Screenshots go in `public/media/apps/<slug>/` and are listed on the app entry.

## The identity

The mark is an **NAI monogram**: the N drawn whole, the A set so its left arm
crosses the N's right stem with its apex carried above the N's cap height. That
overhang is the peak — the letters interlock rather than standing side by side.
The i's tittle is the sphere, and it is the only filled element and the only
one carrying the blue.

Three files hold the same geometry and must move together:

| | |
|---|---|
| `src/assets/logo.svg` | standalone asset, explicit colours |
| `src/components/Logo.tsx` | inline, inherits `currentColor` |
| `scripts/render/brand.mjs` | rasterised for `og.jpg` and the app tile |

`public/favicon.svg` is deliberately *not* the same drawing. It is a reduction
— the peak and the sphere only — because at 16px each of three letters gets
about four pixels and the result is a grey smudge.

Palette and type live in `src/styles/tokens.css`: `#050507` ground, `#0A84FF →
#1E6FFF` primary, `#C8CDD4` chrome for the second voice, pure white body copy.
Headings are heavy and condensed on Archivo's width axis (`wdth` 76, `wght`
800) rather than by transform — scaling a letterform horizontally thins its
horizontals unevenly.

## The hero

`src/lib/perceptionField.ts` renders a WebGL2 point cloud. Points at rest are
achromatic; points that have returned run the mark's blue, and the deeper blue
appears in the mid band as a depth cue — the same gradient as the sphere.

It is ornament, it is confined to the home page, and it makes no claim. If the
GPU cannot run it or the visitor prefers reduced motion, the page loses a
texture and nothing else.

## Checks

```bash
npm run check      # types + lint
npm run qa         # eight routes × six viewports
npm run qa:a11y    # axe-core, keyboard walk, touch targets
npm run qa:perf    # Core Web Vitals and measured frame rate
npm run brand      # regenerate og.jpg and brand/mark-512.png
```

Everything except `check` and `brand` needs the built site being served:
`npm run build` then `npm run preview`. Point them elsewhere with `--url=…`.
`qa:a11y` audits one route at a time; pass `--url` per route.

Current numbers on the home page, at 4× CPU throttle with software WebGL:

| | |
|---|---|
| LCP | 0.58 s |
| CLS | 0.0000 |
| Total transfer | ~364 KB |
| axe-core | no violations on any route, at rest and with the menu open |

## Deploying

`.github/workflows/deploy.yml` publishes to GitHub Pages from whichever branch
is the repository default. `base` is configurable because the same build serves
from a domain root and from a subpath:

```bash
npm run build                        # domain root
BASE_PATH=/Claude-ai/ npm run build  # GitHub Pages project site
```

The workflow resolves this itself: a `public/CNAME` means a custom domain and
the site builds for the root, otherwise it builds for `/<repo>/`. Internal
links and runtime-built asset URLs go through `src/lib/url.ts`, which resolves
them against `BASE_URL` — Vite cannot rewrite those for you.

## Before this goes public

- **`demo.src` in `src/content/site.ts` is empty.** The demo page renders a
  placeholder until it points at a playable build. See the note there for the
  two ways to wire it up.
- **Every `[TODO]` marker is visible on the live page.** That is deliberate.
  `src/content/legal.ts` and `src/content/help.ts` are honest templates, not
  finished policy — nothing in them asserts what any app collects, because that
  is a fact about software that has to be checked rather than guessed. Have a
  lawyer read the privacy policy and terms before publishing.
- **VOID STRIKER's description, platforms, and screenshots are placeholders.**
- The canonical URLs and the sitemap point at `newaivisionlabs.com` while the
  build is served from GitHub Pages. That is intended — the domain is owned and
  not yet pointed at the site.

## Conventions worth knowing

- **Text stops at `--chrome-dim`.** `--chrome-faint` and below are under 4.5:1
  on the ground and are reserved for rules, dots, and disabled marks.
- **The blue is a signal.** It marks the one thing on a screen being offered.
  If two things glow, neither reads as important.
- **Reviews are built, switched off, and empty.** `Testimonials.tsx` renders
  nothing until there are real store reviews to put in it. Do not write filler
  there to see how it looks.
- **Reduced motion is a layout, not a fallback.** Every page is designed to be
  complete with all animation disabled.
