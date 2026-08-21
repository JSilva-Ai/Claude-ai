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

## State

Everything is committed and pushed to `main`, which is both the default
branch and what deploys. `https://jsilva-ai.github.io/Claude-ai/`. Every page
carries `<meta name="build-sha">` — that settles which build a browser is
showing, which is not hypothetical.

Verify with: `npm run check`, `npm run qa`, and `node scripts/a11y.mjs --url=…`
per route. All were passing at the last commit.

## Open, and whose they are

His:
- DKIM at Hostinger publishes an **empty key** (`v=DKIM1;p=`), which reads as
  revoked and is worse than absent. MX, SPF and DMARC are fine.
- Age rating, once the store questionnaires are filled — closes the `[TODO]`
  in the policy's "Children" section.
- A lawyer to read the terms; the publication date.
- Pointing `newaivisionlabs.com`. **Change only the `A` records and the `www`
  CNAME.** Touching nameservers or clearing records takes the MX with them and
  support email dies silently.
- D-U-N-S is issued. Apple validates against the D&B record, so the address
  and phone there must match what goes into App Store Connect.

Mine, when asked:
- **Wrap VOID STRIKER with Capacitor.** This is the critical path: the game is
  a single HTML file, there is no iOS or Android project, so there is nothing
  to submit yet. Everything else is preparation for a submission that cannot
  happen.
- Design changes he still has in mind.
- The game has no pause key and its music restarts between waves. Raised,
  never authorised.

## Egress

The proxy allows GitHub and package registries. It does not allow the live
site or arbitrary domains, so the rendered page cannot be fetched from here —
build locally and drive Chromium instead of trying to load production. DNS
resolution works; there is no `dig`, so query it from Python if needed.
