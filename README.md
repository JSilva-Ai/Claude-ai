# New AI Vision Labs

The website for a machine perception research lab — a lab whose distinguishing
method is that it authors the synthetic worlds its vision systems are trained
and broken in.

Creative direction is locked in [`BRAND.md`](./BRAND.md). Every decision in
this repo works against that document; read it before changing anything
visual.

---

## Running it

```bash
npm install
npm run dev            # http://localhost:5173
npm run build          # tsc -b && vite build
npm run preview        # serve dist/ on :4173
```

No CSS framework, no animation library, no 3D library. React, Vite, and
about 30 KB of hand-written CSS.

## What is where

```
src/
  content/site.ts        every visible string on the page, including UI labels
  lib/
    perceptionField.ts   the hero's WebGL2 point cloud
    mat4.ts              the four matrix operations that renderer needs
    hooks.ts             reveal, media query, pointer, active-section
  components/            one component + one stylesheet per section
  styles/
    tokens.css           colour, type scale, spacing, motion, z-index
    base.css             reset, display type, layout primitives
    ui.css               buttons, tags, cards, reveals
    sections.css         section-level patterns
scripts/
  render/                the ten environments, and their capture pipeline
  shoot.mjs              visual QA screenshots across six viewports
  a11y.mjs               axe-core + keyboard walk + touch-target audit
  perf.mjs               Core Web Vitals, transfer weight, measured frame rate
```

## The hero

`src/lib/perceptionField.ts` renders a depth sensor sweeping an unknown
surface. Wavefronts propagate from a drifting origin; points return a value as
a front crosses them and decay behind it, so the geometry is *inferred over
time* rather than displayed. That is the lab's thesis, drawn.

One buffer, one draw call, no per-frame allocation, no dependencies. It
measures the frame time it is actually getting and spends down to fit —
shedding samples in steps, and settling on a single resolved frame if the
device cannot sustain the animation. Points are shuffled at init so any prefix
of the buffer is a spatially uniform subset rather than the top of the field.

Under `prefers-reduced-motion` it draws one fully resolved frame, composed as
a still. The same renderer runs beneath the contact section in `resolved`
mode: the hero opens on a surface being inferred, and the page closes on the
same surface, returned.

## The ten environments

`scripts/render/scenes.js` holds ten canvas simulations, captured to looping
WebM and MP4 plus poster frames. They share one art-directed rule, which is
what makes ten different simulations read as one instrument suite:

> the **world** is drawn in cool grey — the **perception layer** is drawn in
> phosphor, with plasma for uncertain or predicted state and ember reserved
> for threat.

```bash
node scripts/render/capture.mjs               # all ten: webm, mp4, poster
node scripts/render/capture.mjs --sheet       # contact sheet for art direction
node scripts/render/capture.mjs --posters     # posters only, fast iteration
node scripts/render/capture.mjs --keep-frames # leave the PNG frames on disk
node scripts/render/seam.mjs                  # verify every clip loops cleanly
```

Frames are pulled from the page one at a time and encoded with ffmpeg rather
than recorded with MediaRecorder. That is not a stylistic choice:
MediaRecorder timestamps by wall clock rather than by the frame index it was
asked to record, and under software rasterisation that produced clips 1.5× to
6× longer than the loop — each playing at its own wrong speed — while
silently dropping frames when the encoder fell behind, so the loops never
actually closed. Pulling frame by frame is slower to run and exact: every
clip is 12.00 s and 360 frames.

Each clip ships as VP9 WebM and H.264 MP4, and the page offers both sources.
Safari's WebM support is recent and patchy, and Chromium's recorder can only
produce VP8/VP9 in the first place.

All motion is a periodic function of `t` over `LOOP` seconds and deterministic
(seeded, never `Math.random()` at draw time), so the clips loop invisibly.
`seam.mjs` enforces this by rendering each scene at `t` and `t + LOOP` and
diffing the interior — a non-integer cycle count or an unwrapped negative
phase shows up immediately as a torn seam.

On the page, a monitor's `<video>` is not mounted until the card is genuinely
wanted, playback is gated on visibility, and only the two lead monitors start
on their own. Ten mounted decoders is ten decoders, even when paused.

## Checks

```bash
npm run lint
npx tsc --noEmit -p tsconfig.app.json
node scripts/shoot.mjs --vp=xl,desktop,laptop,tablet,mobile,small --full --sections
node scripts/a11y.mjs
node scripts/perf.mjs --cpu=4
node scripts/render/seam.mjs
```

`shoot.mjs` also fails on console errors, failed requests, broken images
(which a dev server's SPA fallback happily serves as 200s), and horizontal
overflow.

Current numbers, at 4× CPU throttle with software WebGL:

| | |
|---|---|
| LCP | 1.8 s (0.35 s FCP) |
| CLS | 0.0000 |
| Hero / scroll frame rate | 41 / 44 fps |
| Total transfer | 622 KB (initial view) |
| axe-core | no violations, at rest and with the menu open |

## Conventions worth knowing

- **Text stops at `--grey-300`.** Everything below it falls under 4.5:1 on ink
  and is reserved for rules, dots and disabled marks.
- **One accent per viewport.** If two things glow, neither reads as important.
- **Ruled grids, not cards.** Rounded surfaces are reserved for the
  environment monitors, which need a frame because they hold video.
- **Reduced motion is a layout, not a fallback.** The site is designed to be
  complete and intentional with every animation disabled.
- Display type is set on Archivo's `wdth` axis. Using the width axis instead
  of a second family is what makes the type feel authored.
