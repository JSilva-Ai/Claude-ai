/**
 * Support and data deletion.
 *
 * Both are store requirements with a functional test behind them: a reviewer
 * will look for a contact that works and for instructions a user could
 * actually follow. Google Play in particular expects the deletion route to be
 * reachable without installing anything, which is why it is a page on this
 * site and not only a screen inside an app.
 */

import type { Section } from './legal';
import { site } from './site';

export const support = {
  title: 'Support',
  description: `How to reach New AI Vision Labs about any of our apps. Email ${site.email}.`,
  /** The page's whole reason for existing — kept as its own field so no edit can bury it. */
  email: site.email,
  headline: 'Talk to us.',
  lede: 'Email reaches the people who build the apps. There is no ticket system and no chatbot in front of it.',
  emailLabel: 'Support email',
  phoneLabel: 'Phone',
  /**
   * Deliberately absent. No response-time commitment is made, because none can
   * currently be met — and a promise on a support page is the kind a user holds
   * you to. Add one here only when it is real, and it will render automatically.
   */
  responseNote: '',
  helpful: {
    heading: 'What to include',
    body: [
      'You do not need any of this to write to us, but it usually saves a round trip:',
      [
        'Which app, and the version number if you can find it',
        'Your device and OS version',
        'What you expected to happen, and what happened instead',
        'A screenshot or screen recording, if the problem is visible',
      ],
    ] as (string | string[])[],
  },
  sections: [
    {
      heading: 'Bugs and crashes',
      body: [
        'Send whatever you have. A vague report of something going wrong is still worth sending — we would rather hear about it and ask questions than not hear about it.',
      ],
    },
    {
      heading: 'Refunds',
      body: [
        'Purchases go through the App Store or Google Play, not through us, so refunds are handled by them. Apple: reportaproblem.apple.com. Google Play: through your order history in the Play Store.',
        'If a refund is refused and you think it should not have been, write to us anyway — we can sometimes help.',
      ],
    },
    {
      heading: 'Privacy and your data',
      body: [
        'Requests for access to, correction of, or deletion of your personal information go to the same address. Deletion has its own page with the details of what to send.',
      ],
    },
    {
      heading: 'Feature requests',
      body: [
        'Welcome, and genuinely read. We will not promise a timeline, and most requests take a long time or never happen — but they do shape what gets built.',
      ],
    },
  ] as Section[],
};

export const dataDeletion = {
  title: 'Data Deletion',
  description:
    'How to delete data from New AI Vision Labs apps. Nothing is stored on our servers, so deletion happens on your device.',
  updated: '[TODO — set on the day this is published]',
  headline: 'Deleting your data.',
  lede: 'There is nothing on our servers to delete, because nothing is ever sent there. Everything our apps save stays on your own device, and you control it.',
  intro: [
    'Both app stores require a page explaining how to request deletion of your data. In our case the honest answer is short: we do not have any. We run no accounts, no servers our apps talk to, and no analytics, so there is no record of you anywhere for us to erase.',
  ] as (string | string[])[],
  steps: {
    heading: 'Deleting what is on your device',
    items: [
      {
        title: 'In the browser',
        body: 'VOID STRIKER keeps your high scores, achievements and volume setting in your browser\'s local storage. Clearing site data for newaivisionlabs.com in your browser settings removes all of it immediately.',
      },
      {
        title: 'On a phone',
        body: 'Deleting an app removes its stored data along with it. On iOS you can also use Settings → General → iPhone Storage; on Android, Settings → Apps → Storage → Clear data.',
      },
      {
        title: 'If you have emailed us',
        body: `The one thing we do hold is any support correspondence you have sent us. Write to ${'office@newaivisionlabs.com'} and ask us to delete it, and we will.`,
      },
    ],
  },
  inApp: {
    heading: 'Account deletion',
    body: [
      'None of our apps have accounts, so there is no account to delete. If that changes, Apple requires account deletion to be available from inside the app itself, and this page will describe where to find it.',
    ] as (string | string[])[],
  },
  whatHappens: {
    heading: 'What we would do with a request',
    body: [
      'If you write to us asking for your data, we will tell you plainly that we hold none, and delete the email exchange itself if you want that too. We will reply within the period the applicable law requires.',
      /*
       * MAINTENANCE NOTE — not rendered, and not a blocker for launch.
       * If any future app gains a server, accounts, or analytics, this page is
       * rewritten before that app ships: a real timeline, a list of what is and
       * is not deleted, and how long deleted data survives in backups.
       */
    ] as (string | string[])[],
  },
  storeNote: {
    heading: 'Purchases',
    body: [
      'If you ever buy something from us, that purchase is held by the App Store or Google Play rather than by us, and deleting data on your device does not cancel it. Cancel subscriptions in the store, on the account you bought them with.',
    ] as (string | string[])[],
  },
};
