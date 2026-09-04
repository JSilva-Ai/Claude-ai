/**
 * Internal links and public-directory assets, resolved against the deployed
 * base path.
 *
 * Vite rewrites the URLs it can see — those written literally in `index.html`
 * and in `url()` inside CSS — but anything built at runtime in JS is invisible
 * to it. That covers every internal `<a href>` and every image the app builds
 * from content, and hardcoding those to `/apps/` breaks the moment the site is
 * served from a subpath, which is exactly what a GitHub Pages project site
 * does.
 */

import { DEFAULT_LOCALE, locales, localeFromRoute, routeIn } from '../content/locales';
import type { Locale } from '../content/locales';

/** `BASE_URL` always carries a trailing slash; the argument never leads with one. */
function join(path: string): string {
  return import.meta.env.BASE_URL + path.replace(/^\/+/, '');
}

/**
 * The locale of the document this script is running in.
 *
 * Read from `<html lang>`, which the build writes from the route the document
 * was generated at. That is deliberately the same fact the browser, a screen
 * reader and a search engine all use — rather than a second copy of it baked
 * into the bundle, which could disagree with the attribute and would be much
 * harder to notice than a wrong `lang`.
 *
 * Falls back to the default locale outside a browser, and for any value that
 * is not a locale this site builds.
 */
export function currentLocale(): Locale {
  const tag = typeof document === 'undefined' ? '' : document.documentElement.lang;
  const found = Object.values(locales).find((l) => l.lang === tag);
  return found ?? locales[DEFAULT_LOCALE];
}

/**
 * An internal page URL. Pass the route as it appears in the sitemap — `''` for
 * home, `'apps'`, `'apps/void-striker'` — and get back a path with the
 * trailing slash the static host needs to resolve `index.html`.
 */
export function url(route: string, locale: Locale = currentLocale()): string {
  const clean = routeIn(locale, route);
  return clean === '' ? import.meta.env.BASE_URL : join(clean + '/');
}

/** A file in `public/`, e.g. `asset('media/shots/hero.png')`. */
export function asset(path: string): string {
  return join(path);
}

/**
 * True when `route` is the page currently being viewed. Used for the nav's
 * `aria-current`. Compares full path segments so `/apps` does not report
 * itself active while `/apps/void-striker` is open — that page marks itself.
 */
export function isCurrent(route: string, pathname: string = location.pathname): boolean {
  const norm = (s: string) => s.replace(/^\/+|\/+$/g, '');
  const base = norm(import.meta.env.BASE_URL);
  const here = norm(pathname);
  const stripped = base && here.startsWith(base) ? norm(here.slice(base.length)) : here;
  // The locale prefix is not part of the route a nav item names: /pt/apps and
  // /apps are both the products page, each in its own language.
  return localeFromRoute(stripped).rest === norm(route);
}
