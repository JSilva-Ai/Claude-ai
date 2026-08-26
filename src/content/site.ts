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
  email: 'support@newaivisionlabs.com',

  /**
   * Who is behind the studio.
   *
   * The entity is a Georgia limited liability company, registered with the
   * Secretary of State and holding an EIN issued to "NEW AI VISION LABS LLC".
   *
   * `name` above is the trading name and is what the site says everywhere it
   * is speaking to a visitor. `legalName` is the entity, and it belongs in the
   * three places that are speaking to a lawyer or a store reviewer: the
   * privacy policy, the terms, and the copyright line.
   *
   * The EIN itself is never stored in this repo and never goes on the site. It
   * is required nowhere and is useful to anyone attempting fraud in the
   * company's name.
   */
  legalName: 'New AI Vision Labs LLC',
  /** The jurisdiction the entity is formed in — named in the terms. */
  jurisdiction: 'Georgia, United States',
  operator: 'Jorge Silva',

  /**
   * City and state, for the places that only need to say where the studio
   * operates from — the footer, and prose that would read badly with a street
   * address dropped into it.
   *
   * This is enough for the privacy policy's "who we are", which has to say who
   * the controller is and where they operate from. It is *not* a postal
   * address, so it does not cover the two cases that need one: a Google Play
   * listing, where the developer address is displayed and verified, and
   * offering the apps in the EU. Both want a full street address, which is
   * `postalAddress` below.
   */
  location: 'Kennesaw, Georgia, United States',

  /**
   * The operator's home address, published deliberately.
   *
   * This is a decision, not an oversight, and it was taken with the trade-off
   * stated: Google Play displays the developer address on the store listing,
   * and the EU trader rules oblige Apple to show it too, so withholding it
   * from this site would not have kept it private once an app is listed. A
   * registered agent or a commercial mailbox would have avoided that; the
   * owner weighed both and chose to use the home address.
   *
   * Swapping in a business address later is a one-line change here plus the
   * matching sentence in the privacy policy's "Who we are".
   */
  postalAddress: '1926 Barrett Knoll Circle NW, Kennesaw, GA 30152, United States',

  /** Displayed on the site and linked as tel:. */
  phone: '+1 (404) 597-3852',
  /** The same number, dial-safe, for href="tel:". */
  phoneHref: '+14045973852',

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

/** A recorded clip, at the house 520x720. Paths are under public/. */
export interface GameClipSources {
  webm: string;
  mp4: string;
  poster: string;
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
  /** Shown on the card and on the app page in place of a screenshot. */
  clip?: GameClipSources;
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
    platforms: ['Browser'],
    description: [
      'A vertical-scrolling arcade shooter: waves of enemies, six weapons picked up as you go, a boss every fifth wave, and an upgrade shop that opens every third wave so a good run compounds. Enemies arrive in five movement formations and the boss rotates through three hulls. Three difficulty levels change enemy speed, fire rate, and toughness, and the score multiplier along with them.',
      'It is written as a single file with no engine and no libraries — the rendering is Canvas 2D and the music is synthesised in the browser with the Web Audio API rather than streamed. It collects nothing: your scores, achievements and settings are saved on your own device and never sent anywhere, and there is no account to make.',
      'The browser build is finished and you can watch a run of it on the demo page. Which stores it reaches, and in what form, is not decided yet — so there is no release date here, because we would only move it.',
    ],
    screenshots: [
      {
        src: 'media/apps/void-striker/01.jpg',
        alt: 'VOID STRIKER title screen: the game name in glowing blue and violet lockup in front of a large moon, with the player ship rendered large below it, engine lit, above a five-item feature panel reading six weapon types, five enemy formations, three boss types, combo system, twelve achievements, and a tap-to-start button.',
        width: 520,
        height: 720,
      },
      {
        src: 'media/apps/void-striker/02.jpg',
        alt: 'Wave three: a formation of enemies near the top of the screen against a large moon, and the wave transition banner sweeping across the middle, naming sector one, the weave formation, and the 86 credits awarded.',
        width: 520,
        height: 720,
      },
      {
        src: 'media/apps/void-striker/03.jpg',
        alt: 'A kill scoring 500 points inside an expanding ring, the Combo King achievement toast, and a five-times combo running, all against a large moon behind the formation.',
        width: 520,
        height: 720,
      },
      {
        src: 'media/apps/void-striker/04.jpg',
        alt: 'Later in the same wave: a seven-times combo, missile and beam pickups drifting down past the moon, and the pause and bomb controls at either end of the status bar.',
        width: 520,
        height: 720,
      },
    ],
    clip: {
      webm: 'media/games/void-striker/clip.webm',
      mp4: 'media/games/void-striker/clip.mp4',
      poster: 'media/games/void-striker/poster.jpg',
    },
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
  label: 'Gameplay',
  headline: 'VOID STRIKER',
  lede: 'Fourteen seconds of an actual run — recorded from the game itself, not animated for the site.',
  /**
   * The clip. Recorded by `npm run capture` from the real build, frame by
   * frame, at the house 520x720.
   *
   * This page used to embed the game as a playable iframe. It is a video now
   * because a clip is the format that generalises: every future game gets one,
   * at the same size, with no per-game embedding work and no third-party
   * frame to sandbox.
   */
  clip: {
    webm: 'media/games/void-striker/clip.webm',
    mp4: 'media/games/void-striker/clip.mp4',
    poster: 'media/games/void-striker/poster.jpg',
  },
  clipAlt:
    'VOID STRIKER gameplay: the player ship firing upward through waves of enemies, with the score and wave counter across the top.',
  /** Shown if `clip` is ever cleared. */
  unconfigured: {
    title: 'No clip recorded yet',
    body: 'Run `npm run capture` to record one from the game build, or point `demo.clip` at an existing file.',
  },
  /**
   * The playable build is still shipped at public/demo/void-striker/ — the
   * capture script reads from it — so it costs nothing to offer. Delete this
   * and the link that renders it if you would rather the game were not
   * reachable at all.
   */
  playable: { label: 'Play the full game', href: 'demo/void-striker/index.html' },
  facts: [
    { label: 'Recorded at', value: '520 x 720, 60 fps' },
    { label: 'Engine', value: 'None. Canvas 2D' },
    { label: 'Audio', value: 'Synthesised, Web Audio' },
  ],
  note: 'Recorded from the real build. The game runs in the browser with no engine and no libraries.',
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
  gameplayLabel: 'Gameplay',
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
  /**
   * Rendered as "Copyright © <year> New AI Vision Labs LLC. All rights
   * reserved." with the year filled at run time.
   *
   * The entity, not the trading name: a copyright notice identifies who owns
   * the work, and that is the LLC. "All rights reserved." is a formality with
   * no legal effect left in the Berne Convention countries, but it is the
   * convention a reader expects and its absence gets noticed.
   */
  copyright: site.legalName,
  rightsReserved: 'All rights reserved.',
};
