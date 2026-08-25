# Working on this repo

Read this first. It exists so a new session starts with the state of play
instead of rediscovering it, and so the decisions below are not quietly
reversed by someone who was not in the room when they were made.

The site: an independent app studio, **New AI Vision Labs LLC**, publishing to
the App Store and Google Play. One product so far, VOID STRIKER.

## The rules that are not mine to change

These came from the owner and hold until he says otherwise.

- **Nothing invented.** No metrics, no team counts, no testimonials, no
  release dates. Where a real fact is missing the value is a visible `[TODO]`,
  so it fails loudly in review instead of shipping as though it were true.
  The testimonials component exists and is deliberately empty and disabled.
- **English only.** No i18n, no language switcher. Natural American English,
  independent-studio tone, no inflated marketing language.
- **The EIN never enters this repo.** It is required nowhere and is useful to
  anyone attempting fraud in the company's name. Same for formation documents
  and the D-U-N-S number — the latter is not secret, it is simply not needed
  by a website.
- **The privacy policy may not assert what an app collects** without that
  being verified against the software. The current claims were checked: no
  route contacts a third-party host, sets a cookie, or writes to storage.

## Decisions already taken, with the reasoning

Do not "fix" these without asking.

- **The home address is published**, in `site.postalAddress` and in the
  privacy policy. This was decided with the trade-off stated: Google Play
  displays the developer address on the listing and the EU trader rules
  oblige Apple to publish it, so withholding it from the site would not have
  kept it private. A registered agent was offered and declined.
- **`deploy.yml` names `main` literally.** It used to follow
  `repository.default_branch`, the default was moved off main, and every push
  reported "skipped" — a green tick, no deploy — while the live site served a
  branch build four commits behind. Do not make this clever again.
- **Multi-page build, not an SPA.** The legal routes have to be real files
  answering 200 because store reviewers open them directly.
- **The legal pages carry a `<noscript>` block** built from the same content
  module. Google Play's check on the privacy policy URL does not run scripts,
  and those pages served zero characters of body text without JavaScript.
- **The game sits in a phone frame, fitted to width, on `#00020f`** — the
  measured colour of the game frame's own edges, so the letterbox is
  invisible. Filling the screen would crop 56% of the play area.
- **Media is 520x720** everywhere, the game's canvas size, so a clip, a still
  and an empty slot are interchangeable.

## Capacitor

Done, in `mobile/void-striker/` — a separate npm project holding the iOS and
Android projects, so there is now something to submit. Read its README before
touching it; the reasoning is there rather than here. Three things from it
belong in this file:

- **The bundle id is `com.newaivisionlabs.voidstriker`**, derived from the
  domain rather than chosen. It is permanent once a build has been uploaded
  under it, and it is the one value to confirm before that happens.
- **The game's source is never modified to suit the app.** The two things the
  native platforms need — suspending the audio when backgrounded, and a back
  button that closes a modal, pauses a run, or minimises rather than exiting —
  are done from outside by `src/native.js`, so a new build of the game drops in
  with one command. The shim reads `#modal`, `#modal-close`, `window.popModal`
  and `window.pauseGame`; renaming any of those means editing it in the same
  commit.
- **The app icon is drawn by `scripts/render/app-icon.mjs`**, which replaced
  Capacitor's placeholder on his instruction to propose one. It is the ship the
  game itself draws — the same hull and wing paths lifted out of `drawShip` — on
  the game's own violet, so it cannot drift into advertising a different game.
  Re-run that script rather than editing the PNGs; it writes the iOS 1024 (with
  its alpha channel stripped, which iOS requires), both Android legacy sets and
  the adaptive foreground inside its 66-of-108dp safe zone.

Nothing has run on a physical device. What has been checked is that the
packaged build makes no request off the device, throws nothing on load, and
draws a frame — `npm run verify` there, in Chromium.

## State

Everything is committed and pushed to `main`, which is both the default
branch and what deploys. The site is at `https://newaivisionlabs.com/`; the
`github.io` URL now redirects there. Every page carries
`<meta name="build-sha">` — that settles which build a browser is showing,
which is not hypothetical.

Verify with: `npm run check`, `npm run qa`, and `node scripts/a11y.mjs --url=…`
per route. All were passing at the last commit.

## The Apple enrollment, and the domain

Apple rejected the Developer Program enrollment (ID TZRBLU4CMC) because the
website they were given "directs me to a domain placeholder page rather than an
active website". This was not a fault in the site: `newaivisionlabs.com`
resolved to `2.57.91.91`, Hostinger's parking page, while the built site sat at
`https://jsilva-ai.github.io/Claude-ai/` and had never been connected to the
domain. Apple looked at the domain.

**Done.** The site now serves from `newaivisionlabs.com`:

```
@     A       185.199.108.153 .109.153 .110.153 .111.153
www   CNAME   jsilva-ai.github.io.
```

and `public/CNAME` names the domain, which is what makes the deploy build for
the domain root rather than the `/Claude-ai/` subpath. The MX, SPF and DMARC
records came through the change untouched — that was the one thing that could
have broken silently, and it was checked before and after.

Two things about that cutover are worth keeping, because they are not obvious
and the second one cost a confused ten minutes:

- **The order is load-bearing.** With a CNAME in the artifact, Pages redirects
  the `github.io` URL to the custom domain. Merge before the DNS is pointed and
  that redirect lands on the registrar's parking page — the original problem,
  with the working URL gone too. DNS first, then merge, then Enforce HTTPS.
- **The `www` record did not survive.** Removing the apex `A` record at
  Hostinger also took the existing `www` CNAME with it, so `www` had to be
  created rather than edited. Worth checking for by name after any change to
  that zone.

What is left is his: resubmit the enrollment with `https://newaivisionlabs.com`,
replying against ID TZRBLU4CMC so it reaches the same reviewer.

The `[TODO]` markers below are the other half of this. They render as loud
orange boxes on `/privacy` and `/terms`, and `Last updated: [TODO — date of
publication]` sits directly under the `<h1>` on both — the pages a store
reviewer opens first. They are deliberate and they are his; they are also the
first thing anyone assessing whether this is a real company will read.

## Open, and whose they are

His:
- DKIM at Hostinger publishes an **empty key** (`v=DKIM1;p=`), which reads as
  revoked and is worse than absent. MX, SPF and DMARC are fine.
- Age rating, once the store questionnaires are filled — closes the `[TODO]`
  in the policy's "Children" section.
- A lawyer to read the terms; the publication date.
- Resubmitting the Apple enrollment now that the domain serves the site.
- Any future change to the DNS zone: **only the `A` records and the `www`
  CNAME.** Touching nameservers, or any "connect a website" / "reset DNS"
  button the registrar offers, takes the MX with them and support email dies
  silently.
- D-U-N-S is issued. Apple validates against the D&B record, so the address
  and phone there must match what goes into App Store Connect.

Mine, when asked:
- Design changes he still has in mind.
- A mid-run save. Closing the tab still destroys a run, which is the last thing
  the pause screen does not solve.
- The leaderboard is still local-only.

Done, on his instruction to improve the game and then to make it as good as it
can be for the App Store. The detail is in `game/VOID_STRIKER.md`, which lists
each fix and how it was confirmed. The ones that mattered most for a phone:

- **The pause, bomb and volume buttons could not be pressed at all on a touch
  device.** Every handler read `e.touches[0]`, the finger that went down first,
  which during play is always the one steering. Driven with real multi-touch,
  not a mouse — a mouse cannot reproduce it.
- **A cancelled touch left the ship stuck firing.** No `touchcancel` listener,
  so Control Centre or an incoming call jammed the controls on.
- **The wave transition fired every frame** for the 1.5s between the last kill
  and the next spawn. Clearing wave 1 landed you on wave 4 with 310 credits;
  it is wave 2 and 89 credits now. This was the largest single distortion of
  the game's pacing and economy.
- **Touch targets were 27pt** against Apple's 44pt minimum. They measure 45pt
  now, which cost 16 units of play area.
- **Backgrounding the app pauses the run** rather than leaving the player to
  come back into an ambush.

The earlier pass:
- The game has a pause screen (`ESC` / `P` / a button), so Android's back button
  now pauses mid-run instead of minimising. `src/native.js` moved with it.
- The music no longer restarts on every new run; it runs continuously and
  changes intensity instead. It also has a low end now, which it never had.
- The modal close button's duplicate listener is gone.
- Three bugs found while confirming those: enemy bullets moved twice per frame
  (double speed on every difficulty), `Q` was a free unlimited screen-clear, and
  the clean-wave credit bonus always paid out because it compared a value
  against itself.

## Egress

The proxy allows GitHub and package registries. It does not allow the live
site or arbitrary domains, so the rendered page cannot be fetched from here —
build locally and drive Chromium instead of trying to load production. DNS
resolution works; there is no `dig`, so query it from Python if needed.
