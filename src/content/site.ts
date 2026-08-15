/**
 * Every visible string on the site, in one file, so a copy pass never has to
 * touch layout.
 *
 * Nothing in here is invented. Where a real fact is needed and does not exist
 * yet — a release date, a store URL, a screenshot — the value is an explicit
 * [TODO] rather than a plausible placeholder, so it fails loudly in review
 * instead of shipping as though it were true. There are no metrics, no team
 * counts, no publication counts, and no testimonials on this site until there
 * is something real to put in them.
 */

export const site = {
  name: 'New AI Vision Labs',
  /** Used where the full name is too long: nav on small screens, manifest. */
  shortName: 'NAI Labs',
  domain: 'newaivisionlabs.com',
  origin: 'https://newaivisionlabs.com',
  email: 'office@newaivisionlabs.com',
  /** The proposition, in one sentence. Read it out loud before changing it. */
  proposition:
    'We are an independent app studio. We design, build, and publish our own apps on the App Store and Google Play.',
  /** Shorter form, for meta descriptions and the footer. */
  blurb: 'An independent app studio building for iOS and Android.',
};

/**
 * Routes, written the way they appear in the sitemap. `url()` in lib/url.ts
 * turns these into hrefs that survive being served from a subpath.
 */
export const routes = {
  home: '',
  apps: 'apps',
  demo: 'demo',
  support: 'support',
  privacy: 'privacy',
  terms: 'terms',
  dataDeletion: 'data-deletion',
} as const;

export const nav = [
  { route: routes.apps, label: 'Apps' },
  { route: routes.demo, label: 'Demo' },
  { route: routes.support, label: 'Support' },
] as const;

export const home = {
  hero: {
    eyebrow: 'Independent app studio',
    /** Set as three lines so the break is authored, not left to the browser. */
    headline: ['We build', 'the apps', 'we want to use.'],
    accentWord: 'use.',
    lede: site.proposition,
    primaryCta: { label: 'See what we are building', route: routes.apps },
    secondaryCta: { label: 'Play the demo', route: routes.demo },
  },
  approach: {
    index: '01',
    label: 'How we work',
    headline: 'Small team. Whole product.',
    body: [
      'We are a small studio, and everything we publish is our own. There is no client work behind the scenes and no white-label version of what you see here.',
      'The same people write the code, draw the interface, and answer the support email. That is a real constraint on how much we can ship at once, and it is also the reason the details hold up.',
    ],
    points: [
      {
        title: 'We ship our own work',
        body: 'Every app under our name is designed and built in-house, start to finish.',
      },
      {
        title: 'We keep data collection minimal',
        body: 'We ask for what an app needs to function and nothing else. What each app collects is written on its own privacy page.',
      },
      {
        title: 'Support is a person',
        body: 'Email reaches us directly. There is no ticket queue and no chatbot in front of it.',
      },
    ],
  },
  demoCallout: {
    index: '02',
    label: 'Playable',
    headline: 'Try something we made.',
    body: 'VOID STRIKER runs right here in the page — the real build, not a trailer. Six weapons, boss waves, and an upgrade shop between them.',
    cta: { label: 'Open the demo', route: routes.demo },
  },
};

/* -------------------------------------------------------------------------
   Apps
   ------------------------------------------------------------------------- */

export interface StoreLink {
  /** 'appStore' | 'googlePlay' — drives which badge is drawn. */
  store: 'appStore' | 'googlePlay';
  /** Empty string means "not published yet"; the badge renders as unavailable. */
  href: string;
}

export interface Screenshot {
  /** Path under public/, e.g. 'media/apps/void-striker/01.png'. */
  src: string;
  alt: string;
  width: number;
  height: number;
}

export interface App {
  slug: string;
  name: string;
  /** One line, shown on the card and under the title. */
  tagline: string;
  /** 'In development' | 'On the stores' — drives the status pill. */
  status: 'In development' | 'On the stores';
  platforms: string[];
  /** Longer description for the app's own page. Paragraphs. */
  description: string[];
  screenshots: Screenshot[];
  stores: StoreLink[];
  /** Set when the app has a playable web build. Route, not a full URL. */
  demoRoute?: string;
}

/**
 * The studio's apps. One entry today.
 *
 * VOID STRIKER's description is written from the game's own source, which is
 * vendored at game/void_striker.html — every feature named below was read out
 * of it rather than assumed. What is still open is the store plan, and that is
 * marked inline.
 *
 * Adding an app also means adding its page: copy apps/void-striker/index.html
 * to apps/<slug>/index.html and change the slug it imports. See README.
 */
export const apps: App[] = [
  {
    slug: 'void-striker',
    name: 'VOID STRIKER',
    tagline: 'An arcade space shooter, playable in the browser right now.',
    status: 'In development',
    platforms: ['Browser', 'iOS [TODO]', 'Android [TODO]'],
    description: [
      'A vertical-scrolling arcade shooter: waves of enemies, six weapons picked up as you go, a boss every fifth wave, and an upgrade shop that opens every third wave so a good run compounds. Three difficulty levels change enemy speed, fire rate, and toughness, and the score multiplier along with them.',
      'It is written as a single file with no engine and no libraries — the rendering is Canvas 2D and the music is synthesised in the browser with the Web Audio API rather than streamed. Scores, achievements, and settings are kept on your own device.',
      'The browser build is finished and playable on the demo page. [TODO] Say what the iOS and Android plan actually is — a wrapper around this build, a native rewrite, or undecided — and whether there is a release window you are willing to commit to. "In development" with no date is more honest than a date you will move.',
    ],
    screenshots: [],
    stores: [
      { store: 'appStore', href: '' },
      { store: 'googlePlay', href: '' },
    ],
    demoRoute: routes.demo,
  },
];

export const appsPage = {
  index: '',
  label: 'Apps',
  headline: 'What we are building.',
  lede: 'Everything here is our own work. This page will grow as things ship; right now there is one.',
  /** Shown when an app has no store links yet. */
  notYetOnStores: 'Not on the stores yet',
  inDevelopmentNote:
    'This app is still in development. There is no download link because there is nothing to download yet.',
};

/* -------------------------------------------------------------------------
   Demo
   ------------------------------------------------------------------------- */

export const demo = {
  label: 'Playable demo',
  headline: 'VOID STRIKER',
  lede: 'The real game, running in this page. Not a trailer and not a recording — it is the same build, and your score goes on the leaderboard.',
  /**
   * The playable build, self-hosted.
   *
   * `game/void_striker.html` is the canonical source; `npm run demo` copies it
   * to public/ and self-hosts its two Google Fonts faces on the way. Re-run
   * that after any change to the game — do not edit the copy in public/.
   *
   * Self-hosting also keeps the embed same-origin, which the game needs: its
   * leaderboard, achievements, and volume setting are all localStorage.
   */
  src: 'demo/void-striker/index.html',
  unconfigured: {
    title: 'Demo not connected yet',
    body: 'The playable build has not been pointed at from the site. Set `demo.src` in src/content/site.ts to the URL of the web build.',
  },
  /** Read out of the game's own key handling, not guessed. */
  controls: [
    { keys: '\u2190 \u2192 \u2191 \u2193  /  WASD', action: 'Move' },
    { keys: 'Space  /  Z', action: 'Fire' },
    { keys: 'Q', action: 'Bomb' },
    { keys: '1 2 3  /  4', action: 'Pick upgrade / skip' },
    { keys: 'Drag', action: 'Move and fire, on touch' },
  ],
  fullscreenLabel: 'Fullscreen',
  note: 'Runs entirely in your browser. Scores and achievements are saved on this device only — nothing is sent anywhere.',
};

/* -------------------------------------------------------------------------
   Testimonials — built, switched off, and empty.

   This component exists so that turning it on later is a one-line change, and
   it renders nothing at all while `enabled` is false. Do not put anything in
   `items` that is not a real review a real person wrote. Store reviews are the
   intended source.
   ------------------------------------------------------------------------- */

export interface Testimonial {
  quote: string;
  author: string;
  /** Where the review was left, e.g. 'App Store'. */
  source: string;
}

export const testimonials: {
  enabled: boolean;
  label: string;
  headline: string;
  items: Testimonial[];
} = {
  enabled: false,
  label: 'Reviews',
  headline: 'What people say.',
  items: [],
};

/* -------------------------------------------------------------------------
   Interface strings
   ------------------------------------------------------------------------- */

export const ui = {
  skipToContent: 'Skip to content',
  menu: 'Menu',
  close: 'Close',
  backToApps: 'All apps',
  screenshotsLabel: 'Screenshots',
  noScreenshots: '[TODO] Screenshots go in public/media/apps/<slug>/ and are listed in src/content/site.ts.',
  supportShort: 'Support',
  emailUs: 'Email us',
  onThisPage: 'On this page',
  lastUpdated: 'Last updated',
};

export const footer = {
  blurb: site.blurb,
  columns: [
    {
      title: 'Studio',
      links: [
        { label: 'Apps', route: routes.apps },
        { label: 'Demo', route: routes.demo },
      ],
    },
    {
      title: 'Help',
      links: [
        { label: 'Support', route: routes.support },
        { label: 'Data deletion', route: routes.dataDeletion },
      ],
    },
    {
      title: 'Legal',
      links: [
        { label: 'Privacy Policy', route: routes.privacy },
        { label: 'Terms of Use', route: routes.terms },
      ],
    },
  ],
  /** Rendered as "© <year> New AI Vision Labs" with the year filled at build. */
  copyright: site.name,
};
