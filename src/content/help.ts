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
  /** [TODO] Only state a response time you will actually meet. */
  responseNote: '[TODO] State your real response time, e.g. "We usually reply within two business days." If you cannot commit to one, delete this line rather than promising something vague.',
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
    'How to request deletion of your data from New AI Vision Labs apps, what gets deleted, and how long it takes.',
  updated: '[TODO — date of publication]',
  headline: 'Deleting your data.',
  lede: 'You can ask us to delete the personal information associated with you at any time, and you do not have to give a reason.',
  intro: [
    '[TODO] Before publishing, check this page against what each app actually stores. If an app keeps everything on the device and sends us nothing, say so here explicitly — "there is nothing on our servers to delete, and removing the app removes the data" is a complete and honest answer, and it is the best one.',
  ] as (string | string[])[],
  steps: {
    heading: 'How to request deletion',
    /** Numbered on the page. */
    items: [
      {
        title: 'Email us',
        body: `Write to ${site.email} with the subject "Data deletion request".`,
      },
      {
        title: 'Tell us which app',
        body: 'Name the app you want your data deleted from, or say "all apps" if you mean all of them.',
      },
      {
        title: 'Tell us how to find you',
        body: '[TODO] State exactly what identifier you need in order to locate an account — the email address the account was created with, a username, or an in-app ID and where to find it. If your apps have no accounts, replace this step with a note saying no identifier is needed.',
      },
    ],
  },
  inApp: {
    heading: 'Deleting from inside the app',
    body: [
      '[TODO] If an app has accounts, Apple requires that account deletion be initiable from within the app itself — a link to this page is not sufficient on its own. Describe the in-app path here (for example: Settings → Account → Delete account), and make sure it exists.',
    ] as (string | string[])[],
  },
  whatHappens: {
    heading: 'What happens next',
    body: [
      '[TODO] State your real timeline for acknowledging and completing a request. Under the GDPR the outside limit is one month from receipt, extendable in limited circumstances.',
      '[TODO] List what is deleted and what is not. Some records are kept because the law requires it — purchase and tax records are the usual example — and a deletion request does not override that. Say which, and for how long.',
      '[TODO] State how long deleted data persists in backups before it is overwritten, if you keep backups.',
    ] as (string | string[])[],
  },
  storeNote: {
    heading: 'Purchases',
    body: [
      'Deleting your data does not cancel a subscription, because subscriptions are held by the App Store or Google Play rather than by us. Cancel those in the store, on the account you bought them with.',
    ] as (string | string[])[],
  },
};
