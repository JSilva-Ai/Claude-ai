# New AI Vision Labs — Creative Direction

**Status:** locked. All specialist passes work against this document. Deviations require Creative Director sign-off.

---

## 1. Positioning

New AI Vision Labs is a **machine perception research lab**. It builds systems that see — that
convert raw light, depth, and motion into a usable model of the world, and then act inside it.

The lab's distinguishing method: **perception is trained in simulation before it is trusted in
reality.** The lab runs a suite of synthetic worlds — the *Proving Grounds* — where perception
models are grown, stressed, and broken on purpose, millions of times faster than reality allows.

This is the one-sentence difference: **most companies wrap a model. This lab builds the world the
model learns in.**

## 2. What it is not

Not an AI startup with an API key. Not a chatbot. Not a "solutions provider." The tone is a
research institution that happens to have exceptional design taste — closer to a particle physics
lab or a flight test center than to SaaS.

## 3. Audience

In priority order:

1. **Research engineers** who will judge the site in 4 seconds on whether it is technically real.
2. **Prospective partners** in robotics, medical imaging, industrial inspection, earth observation.
3. **Candidates** — the people the lab wants to hire read this page top to bottom.

Everything must survive a skeptical reader. No claim without a mechanism behind it.

## 4. The 5 / 15 / after test

- **5 seconds:** "This is a serious instrument, not a landing page." Signal: the live perception
  field in the hero — a real-time system, not a decorative loop — plus monumental typography and
  an interface that behaves like calibrated equipment.
- **15 seconds:** "They build machine perception, and they train it inside simulated worlds."
- **After leaving:** the *Proving Grounds* — ten worlds, running. That is the memory hook.

## 5. Personality

Precise · Unhurried · Physical · Instrumented · Understated confidence.

The site should feel *measured*. Nothing bounces. Nothing pulses for attention. Movement happens
because a system is running, not because a designer wanted movement.

## 6. Visual language

**Phosphor on ink.** The reference is scientific instrumentation — oscilloscopes, telemetry
overlays, wind-tunnel schlieren imaging, LIDAR returns — rendered with the restraint of a
type-driven editorial layout.

- **Ink** `#08090B` — near-black ground, everything sits on it.
- **Phosphor** `#D4F85C` — the single signal color. Acid lime-yellow. Used *sparingly*: live
  indicators, one word per headline, the key line of a chart. Deliberately not AI-blue.
- **Plasma** `#7B5CFF` — violet, secondary depth only. Never competes with phosphor.
- **Ember** `#FF5A3D` — reserved exclusively for live/critical telemetry states.
- **Porcelain** `#EDEEF0` — primary type.
- Greys are cool-neutral, never blue-tinted.

Rule: **one accent per viewport.** If two things glow, neither reads as important.

### Banned
Glowing blue brains. Circuit boards. Robot stock photography. Purple-to-blue SaaS gradients.
Floating 3D glass spheres. "The future of X." Generic isometric illustration. Bento grids used
as decoration rather than structure.

### Typography
- **Archivo Variable** — one family, exploiting the `wdth` (62–125) and `wght` (100–900) axes.
  Display is set *expanded* and tight-tracked for monumentality; UI text sits at normal width.
  Using the width axis rather than a second family is what makes the type feel authored.
- **JetBrains Mono Variable** — labels, telemetry, section indices, data. Uppercase, tracked out.
  Mono carries the "instrument" half of the identity and must appear on every section.

### Motion
Cinematic and mechanical. Long eases (`cubic-bezier(0.16, 1, 0.3, 1)`), 400–900ms, no bounce, no
spring overshoot. Reveals are *translations of a few pixels with opacity*, never scale-ups from
0.8. The hero field runs continuously; everything else is still until scrolled to.

`prefers-reduced-motion` is a first-class layout, not a fallback: the site must look complete and
intentional with every animation disabled.

## 7. Narrative spine

1. **Hero** — a perception field, live. The thesis in one sentence.
2. **Thesis / Vision** — why perception is the bottleneck, stated as an argument.
3. **Capabilities** — four research lines, with mechanism, not adjectives.
4. **Proving Grounds** — the ten synthetic worlds. The centerpiece. Video.
5. **Research** — depth: open problems the lab is actually working on.
6. **Applications** — where perception becomes consequence.
7. **Lab / People** — human, without corporate headshot energy.
8. **Contact** — the close of an argument, not a form dump.

## 8. Quality bar

Every section must answer: *would a research engineer screenshot this and send it to a
colleague?* If not, it is not finished.
