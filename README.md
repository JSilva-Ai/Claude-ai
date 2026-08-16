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

## Game media

**Every piece of game media on this site is 520×720.** That is the size VOID
STRIKER's canvas is authored at, adopted as the house format: a clip, a
screenshot and an empty slot are then interchangeable, and a grid never reflows
when one replaces another. The size lives in `--media-w` / `--media-h` /
`--media-ratio` in `tokens.css`, and `capture-game.mjs` writes at exactly it.
The width is a cap rather than a fixed size — it has to shrink on a 320px
phone — but the ratio always holds.

`GameClip.tsx` is the one component that fills the slot. Under reduced motion
it renders the poster and nothing else: no decoder, no source elements, no play
control to argue with.

### Recording a clip

```bash
npm run demo       # build the game into public/ (needed by the capture)
npm run capture    # record public/media/games/void-striker/{clip.webm,clip.mp4,poster.jpg}
```

Frames are pulled one at a time rather than screen-recorded. The game's loop is
`update(); draw(); requestAnimationFrame(loop)` with `gs.t++` as its only clock,
so one rAF is one game step and nothing reads wall-clock time — the capture
replaces rAF with a queue it drains by hand. The result is exact at any capture
speed, and a headless machine rendering at 6 fps still produces a clip that
plays at the right speed. A MediaRecorder capture cannot: it timestamps by wall
clock, which is what produced several-times-too-long clips the last time this
repo tried it.

The clip fades from and to black, because gameplay state cannot match across a
loop seam — the seam is hidden rather than pretended away. The upgrade shop is
dismissed by pressing `1` on a timer: it is drawn on the canvas and the game
state is inside an IIFE, so there is nothing to detect from outside, and the
key is inert except during the upgrade phase.

### The game itself

`game/void_striker.html` is the game, exactly as authored, and
`game/VOID_STRIKER.md` is its handoff notes. `npm run demo` builds the
deployable copy into `public/demo/void-striker/`.

The script exists because the game has one external dependency — an `@import`
of two faces from Google Fonts — and it downloads them, writes them alongside,
and rewrites the import. A third-party font request would hand every visitor's
IP to Google on a site whose privacy policy says collection is minimal, and it
would make the studio's one piece of proof depend on a CDN being up.

**Edit `game/void_striker.html` and re-run `npm run demo`. Never edit the copy
under `public/`** — it is generated and will be overwritten.

The playable build is still shipped, because the capture reads from it, and
`/demo` offers it as a secondary link. `/demo` itself shows the clip — delete
`demo.playable` in `src/content/site.ts` if you would rather the game were not
reachable at all.

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
npm run demo       # rebuild the game into public/ from game/void_striker.html
npm run capture    # re-record the 520x720 gameplay clip
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

## The business address question

The site does **not** publish a home address, and does not need to. But it is
worth knowing exactly when that stops being a choice, because at that point an
address gets published whether or not this repo contains one:

- **Google Play.** The developer address is shown on the store listing, is
  verified by Google, and cannot be suppressed. A USPS PO box is refused. A
  street address from a mailbox service or a registered agent is accepted.
- **Offering the apps in the EU.** Apple publishes trader details — name,
  address, phone, email — under the Digital Services Act, and the GDPR expects
  the controller's address in the privacy notice itself.

So the problem to solve is not "how do I hide an address", it is "how do I have
one that is not my house". In Georgia, the usual routes, cheapest first:

1. **A commercial mailbox with a street address** (a CMRA — the UPS Store and
   similar). Roughly $10–30/month, accepted by Google Play because it is a
   street address rather than a PO box.
2. **A registered agent's address**, if the studio is or becomes an LLC.
   Agents run $50–150/year.

### The entity

**New AI Vision Labs LLC** — a Georgia limited liability company, registered
with the Secretary of State, holding an EIN issued in that name.

That matters in three places in this repo:

- `site.legalName` is the entity and appears in the privacy policy, the terms,
  and the copyright line. `site.name` is the trading name and is what the site
  says everywhere it is talking to a visitor rather than to a lawyer.
- The terms name Georgia as the governing law, which is where the entity is
  formed. Those now agree, which they must.
- The liability cap in the terms is still `[TODO]` and is now worth setting
  properly, because there is an entity for it to protect.

**The EIN is not in this repo and must never be.** It is required nowhere on a
website and is useful to anyone attempting fraud in the company's name. The
same is true of the formation documents.

One thing worth checking outside this repo: a Georgia LLC's registered agent
and registered office address are public record on the Secretary of State's
searchable database. If the home address was used there, it is already public
independently of this website, and switching to a commercial registered agent
(around $50–150/year) is what takes it off that record.

## Before this goes public

- **Every `[TODO]` marker is visible on the live page.** That is deliberate.
  `src/content/legal.ts` and `src/content/help.ts` are honest templates, not
  finished policy — nothing in them asserts what any app collects, because that
  is a fact about software that has to be checked rather than guessed. Have a
  lawyer read the privacy policy and terms before publishing.
- **VOID STRIKER's store plan is undecided, and the site says so.** Platforms
  read `Browser` only, and the copy states no release date rather than one that
  would move. Screenshots are still to come.
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
