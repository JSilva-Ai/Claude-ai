/**
 * Every page on the site, and the metadata that goes in its head.
 *
 * This is the route table. It exists because the head of a page is not
 * content a person should be maintaining by hand thirteen times: a title, a
 * description, a canonical, five Open Graph tags and three Twitter tags,
 * repeated per document, is a copy-paste surface where a wrong canonical hides
 * for months. `pageMeta()` in vite.config.ts renders all of it from here at
 * build time, so each index.html carries only the two things Vite has to read
 * literally — the charset, and the module script that is the page's entry.
 *
 * It also exists for what comes next. A four-locale site is fifty-two
 * documents; the same head rendered from one table is the difference between
 * that being routine and being unmaintainable.
 *
 * Adding a page: add a row here, create <route>/index.html with the two
 * literal lines, and add the route to public/sitemap.xml and to ROUTES in
 * scripts/shoot.mjs. `findPages` in vite.config.ts discovers the document
 * itself — a row without a document is inert, and a document without a row
 * fails the build rather than shipping with no title.
 */
export interface PageMeta {
  /** The route as it appears in the sitemap: '' for home, 'apps', 'apps/loop'. */
  route: string;
  /** <title>, og:title and twitter:title — one string, three tags. */
  title: string;
  /** The meta description, og:description and twitter:description. */
  description: string;
}

export const pages: PageMeta[] = [
  {
    route: '',
    title: 'New AI Vision Labs — independent technology studio',
    description:
      'New AI Vision Labs is an independent technology studio. We design and build our own products — intelligent applications and original games — and publish them under our own name.',
  },
  {
    route: 'apps',
    title: 'Products — New AI Vision Labs',
    description:
      'The six products New AI Vision Labs is building — four intelligent applications and two games — each marked with the stage it is at.',
  },
  {
    route: 'apps/biblelink',
    title: 'BIBLELINK — New AI Vision Labs',
    description:
      'BIBLELINK is an application by New AI Vision Labs, built and going through final testing before release.',
  },
  {
    route: 'apps/galaxy-forge',
    title: 'GALAXY FORGE — New AI Vision Labs',
    description:
      'GALAXY FORGE is the second game from New AI Vision Labs, currently in development.',
  },
  {
    route: 'apps/guard',
    title: 'GUARD — New AI Vision Labs',
    description:
      'GUARD is a product concept in research at New AI Vision Labs, exploring the money people lose to renewals, trials and deadlines nobody was watching.',
  },
  {
    route: 'apps/loop',
    title: 'LOOP — New AI Vision Labs',
    description:
      'LOOP is a consumer application in development at New AI Vision Labs, engineered around proactive intelligence and built in English, Portuguese and Spanish.',
  },
  {
    route: 'apps/shield',
    title: 'SHIELD — New AI Vision Labs',
    description:
      'SHIELD is a product concept in research at New AI Vision Labs, exploring personal trust intelligence: weighing a digital interaction before you act on it.',
  },
  {
    route: 'apps/void-striker',
    title: 'VOID STRIKER — New AI Vision Labs',
    description:
      'VOID STRIKER is an arcade space shooter by New AI Vision Labs, playable in the browser and in final testing for iOS and Android.',
  },
  {
    route: 'demo',
    title: 'Playable demo — New AI Vision Labs',
    description:
      'Play a browser build of VOID STRIKER, running in the page.',
  },
  {
    route: 'support',
    title: 'Support — New AI Vision Labs',
    description:
      'Support for New AI Vision Labs apps. Email support@newaivisionlabs.com.',
  },
  {
    route: 'privacy',
    title: 'Privacy Policy — New AI Vision Labs',
    description:
      'How New AI Vision Labs handles personal information across its apps and this website.',
  },
  {
    route: 'terms',
    title: 'Terms of Use — New AI Vision Labs',
    description:
      'The terms that apply to New AI Vision Labs apps and this website.',
  },
  {
    route: 'data-deletion',
    title: 'Data Deletion — New AI Vision Labs',
    description:
      'How to request deletion of your data from New AI Vision Labs apps.',
  },
];

/** Looked up by `pageMeta()` per document, and by the sitemap check. */
export function pageFor(route: string): PageMeta | undefined {
  return pages.find((p) => p.route === route);
}
