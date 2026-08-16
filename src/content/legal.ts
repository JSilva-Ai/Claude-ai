/**
 * The four pages Apple and Google both require before a listing goes live:
 * a privacy policy, terms of use, a support page with a working contact, and
 * data-deletion instructions.
 *
 * These are honest templates, not finished policy. Two rules were followed
 * while writing them and should be followed while editing them:
 *
 *   1. Nothing here asserts what any app collects, stores, or shares. Those
 *      are facts about software I cannot inspect, and a privacy policy that
 *      guesses is worse than no policy — it is a false statement to your users
 *      and to the stores. Every such point is a [TODO] with a note on what
 *      belongs there.
 *   2. Nothing here is legal advice. The structure and the general language
 *      are conventional and will look familiar to a reviewer, but a lawyer in
 *      your jurisdiction should read both documents before you publish them.
 *
 * A [TODO] left in place is visible on the live page. That is deliberate.
 */

/** A paragraph, or a bullet list. */
export type Block = string | string[];

export interface Section {
  heading: string;
  body: Block[];
}

export interface LegalDoc {
  /** <title> and <h1>. */
  title: string;
  /** Meta description. */
  description: string;
  /** [TODO] Set to the date you actually publish, and update it on every edit. */
  updated: string;
  intro: Block[];
  sections: Section[];
}

const UPDATED = '[TODO — date of publication]';

/* ------------------------------------------------------------------ privacy */

export const privacy: LegalDoc = {
  title: 'Privacy Policy',
  description:
    'How New AI Vision Labs handles personal information across its apps and this website.',
  updated: UPDATED,
  intro: [
    'This policy explains how New AI Vision Labs ("we", "us") handles personal information in the apps we publish and on this website.',
    'Our apps differ from one another in what they need to function, so what is collected differs too. Where that is the case, this policy says so and the specifics are listed per app rather than generalized here.',
  ],
  sections: [
    {
      heading: 'Who we are',
      body: [
        'New AI Vision Labs is an independent app studio. The legal entity behind it is New AI Vision Labs LLC, a limited liability company registered in Georgia, United States, based in Kennesaw and operated by Jorge Silva. New AI Vision Labs LLC is the data controller for the personal information described in this policy.',
        'You can reach us by email at office@newaivisionlabs.com or by phone at +1 (404) 597-3852. A full postal address is available on request.',
        '[TODO] Replace "available on request" with the address once there is a business one — see `postalAddress` in src/content/site.ts. City and state are enough for this page today; a full street address is required before a Google Play listing or before offering the apps in the EU.',
      ],
    },
    {
      heading: 'What we collect',
      body: [
        '[TODO] This is the section that has to be filled in per app, and it is the one that cannot be guessed. For each app you publish, list exactly what it collects. Work from what the code actually does, not from what you intend it to do.',
        'For each item, state the data, why it is needed, and how long it is kept. Categories to check before you write this section:',
        [
          'Account information, if the app has accounts at all — email address, display name, password hashes',
          'Content the user creates in the app, and whether it stays on the device or reaches a server',
          'Purchase and subscription records, including what the store shares back with us',
          'Diagnostics and crash reports, and whether they are tied to a device or user identifier',
          'Usage analytics, if any — which events, and whether they are linked to an identifier',
          'Advertising identifiers, if the app shows ads or measures installs',
          'Device information: model, OS version, locale, and anything else read at runtime',
          'Permissions the app requests — camera, photos, microphone, location, contacts, notifications — and what each is used for',
        ],
        'If an app collects nothing at all, say that plainly. It is a strong statement and it is worth making explicitly rather than by omission.',
        'This website itself is a static site. [TODO] Confirm and then state whether it uses any analytics, and name the provider if it does.',
      ],
    },
    {
      heading: 'How we use information',
      body: [
        'We use personal information only to provide and support the app you are using: to make its features work, to process purchases, to fix crashes and defects, and to answer you when you contact support.',
        '[TODO] If you use information for anything beyond that — marketing email, advertising personalization, product analytics that inform a roadmap — it has to be listed here and, in several jurisdictions, consented to separately. Do not leave it implied.',
        'We do not sell personal information.',
      ],
    },
    {
      heading: 'Legal bases for processing',
      body: [
        'Where the GDPR applies, we rely on the following legal bases:',
        [
          'Performance of a contract — processing needed to deliver the app and its features to you',
          'Legitimate interests — keeping our apps working, secure, and free of defects',
          'Consent — where the law requires it, such as optional analytics or marketing, and which you can withdraw at any time',
          'Legal obligation — where we must retain records, for example for tax purposes',
        ],
        '[TODO] Remove any basis you do not actually rely on. An unused basis listed here is a claim you cannot support.',
      ],
    },
    {
      heading: 'Third parties',
      body: [
        '[TODO] List every third party that receives data, and why. This is the section reviewers check most closely, and it is easy to under-report because SDKs collect data whether or not you call them directly. Check the app\'s actual dependency list.',
        'Common categories to account for:',
        [
          'Apple App Store and Google Play, for distribution, purchases, and subscription status',
          'Crash and diagnostics reporting, if you have integrated any',
          'Analytics, if you have integrated any',
          'Backend hosting, if the app talks to a server you run or rent',
          'Advertising or attribution networks, if you use them',
        ],
        'If no third party receives any data from an app, say that.',
      ],
    },
    {
      heading: 'Data retention',
      body: [
        '[TODO] State how long each category of data is kept, and what triggers deletion. "As long as necessary" is not specific enough for a reviewer or for a data subject request — give periods, even if they are approximate.',
      ],
    },
    {
      heading: 'Your rights',
      body: [
        'Depending on where you live, you may have the right to request access to the personal information we hold about you, to have it corrected or deleted, to object to or restrict how we use it, to receive a copy in a portable format, and to withdraw consent where our use is based on consent.',
        'To exercise any of these, email office@newaivisionlabs.com. We will respond within the period the applicable law requires. For deletion specifically, see the data deletion page, which sets out exactly what to send.',
        'If you are in the EU or UK and you believe we have handled your information improperly, you may complain to your local supervisory authority.',
      ],
    },
    {
      heading: 'Children',
      body: [
        '[TODO] State the intended audience of each app and the age rating you have declared to the stores. If an app is directed to children, Apple\'s Kids Category rules, Google Play\'s Families policy, and COPPA all impose requirements well beyond this document — get those reviewed specifically.',
        'We do not knowingly collect personal information from children where doing so would require verifiable parental consent we have not obtained. If you believe a child has provided us with personal information, email us and we will delete it.',
      ],
    },
    {
      heading: 'International transfers',
      body: [
        '[TODO] If any data leaves the region it was collected in — which it does as soon as you use a hosting provider or an SDK operated abroad — name the destination and the safeguard you rely on, such as Standard Contractual Clauses.',
      ],
    },
    {
      heading: 'Security',
      body: [
        'We take reasonable technical and organizational measures to protect personal information. No system is perfectly secure, and we do not claim otherwise.',
        '[TODO] If you hold user data on a server, describe the concrete measures in one or two sentences — encryption in transit and at rest, access control, backups. Keep it truthful and specific.',
      ],
    },
    {
      heading: 'Changes to this policy',
      body: [
        'We may update this policy as our apps change. The date at the top reflects the most recent revision. If a change materially affects how we handle your information, we will make that clear rather than relying on the updated date alone.',
      ],
    },
    {
      heading: 'Contact',
      body: [
        'Questions about this policy or about your information: office@newaivisionlabs.com.',
      ],
    },
  ],
};

/* -------------------------------------------------------------------------- */

export const terms: LegalDoc = {
  title: 'Terms of Use',
  description: 'The terms that apply to New AI Vision Labs apps and this website.',
  updated: UPDATED,
  intro: [
    'These terms apply to the apps published by New AI Vision Labs LLC, a Georgia limited liability company ("New AI Vision Labs", "we", "us"), and to this website. By installing an app or using the site, you agree to them.',
    '[TODO] Have a lawyer in your jurisdiction review this document before you publish it. The structure below is conventional, but the enforceability of several clauses — the liability cap in particular — depends entirely on local law.',
  ],
  sections: [
    {
      heading: 'The apps',
      body: [
        'We grant you a personal, non-exclusive, non-transferable, revocable license to use our apps on devices you own or control, for your own non-commercial use.',
        'You may not copy, modify, reverse-engineer, decompile, resell, or redistribute our apps, except to the extent that applicable law expressly permits it regardless of this restriction.',
        'Apps downloaded from the App Store or Google Play are also subject to that store\'s own terms. Where a store\'s terms conflict with these, the store\'s terms govern the distribution of the app.',
      ],
    },
    {
      heading: 'Acceptable use',
      body: [
        'Do not use our apps to break the law, to interfere with the app\'s operation or security, to gain unauthorized access to any system, or to harass, abuse, or harm anyone.',
      ],
    },
    {
      heading: 'Purchases and subscriptions',
      body: [
        '[TODO] Fill this in only if an app charges money. State what is sold, whether it is a one-time purchase or a subscription, the billing period, how renewal works, and how to cancel.',
        'Purchases made through the App Store or Google Play are processed by Apple or Google, not by us. Refunds are handled under that store\'s policy, and requests should go to the store rather than to us.',
      ],
    },
    {
      heading: 'User content',
      body: [
        '[TODO] Fill this in only if an app lets users create, upload, or share content. State who owns it (the user should), what license you need to operate the service, and what happens to it when an account is deleted. Delete this whole section if no app has user content.',
      ],
    },
    {
      heading: 'Availability',
      body: [
        'We may change, suspend, or discontinue an app or any of its features at any time. We will try to give reasonable notice of a discontinuation where we can, but we do not guarantee that any app will remain available.',
      ],
    },
    {
      heading: 'Disclaimers',
      body: [
        'Our apps are provided "as is" and "as available", without warranties of any kind, whether express or implied, including implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
        'Some jurisdictions do not allow the exclusion of certain warranties. Where that is the case, the exclusions above apply only to the extent permitted, and nothing in these terms limits your statutory consumer rights.',
      ],
    },
    {
      heading: 'Limitation of liability',
      body: [
        'To the fullest extent permitted by law, New AI Vision Labs LLC is not liable for indirect, incidental, special, consequential, or punitive damages, or for loss of profits, revenue, or data, arising from your use of our apps.',
        '[TODO] State the liability cap. It is commonly the greater of the amount you paid in the preceding twelve months or a small fixed sum — confirm what is enforceable where you are established.',
        'Nothing in these terms excludes liability for death or personal injury caused by negligence, for fraud, or for anything else that cannot lawfully be excluded.',
      ],
    },
    {
      heading: 'Termination',
      body: [
        'You may stop using our apps at any time by deleting them. We may suspend or end your access if you materially breach these terms.',
      ],
    },
    {
      heading: 'Changes to these terms',
      body: [
        'We may update these terms. The date at the top reflects the most recent revision, and continuing to use an app after a change means you accept the revised terms.',
      ],
    },
    {
      heading: 'Governing law',
      body: [
        'These terms are governed by the laws of the State of Georgia, United States, without regard to its conflict-of-laws rules. The state and federal courts located in Georgia have jurisdiction over any dispute arising from them.',
        'This does not take away rights you have under the consumer-protection law of the country you live in. Those generally apply regardless of what this clause says.',
      ],
    },
    {
      heading: 'Contact',
      body: ['Questions about these terms: office@newaivisionlabs.com.'],
    },
  ],
};
