/**
 * The locales the site is built to carry, and the one it publishes.
 *
 * Two lists on purpose. `locales` is what the architecture supports; `PUBLISHED`
 * is what actually exists as pages. They are separate because the directive is
 * explicit that no locale goes live until its copy has been reviewed and
 * approved, and the gap between "the code can do this" and "this is public" is
 * exactly where a half-translated site ships by accident.
 *
 * Pages are discovered by walking directories, so a locale becomes public the
 * moment its directory lands on `main`. There is no switch to forget to flip —
 * and none to protect you either. `PUBLISHED` is therefore a statement about
 * what has been approved, checked against the filesystem by the build.
 */
export type LocaleCode = 'en' | 'pt' | 'es' | 'ar';

export interface Locale {
  code: LocaleCode;
  /** Goes in <html lang>. */
  lang: string;
  /** Goes in <html dir>. Arabic is a true RTL locale, not translated text. */
  dir: 'ltr' | 'rtl';
  /** The URL prefix. English is unprefixed, so every existing URL is unmoved. */
  prefix: string;
  /** The language's own name, for a switcher — never the English name for it. */
  endonym: string;
  /** og:locale. */
  ogLocale: string;
}

export const locales: Record<LocaleCode, Locale> = {
  en: { code: 'en', lang: 'en', dir: 'ltr', prefix: '', endonym: 'English', ogLocale: 'en_US' },
  /*
   * Brazil, on the owner's decision. The URL stays `/pt/` — short, and it is
   * the language that is being offered rather than a country — while `lang`
   * and `hreflang` say `pt-BR`, which is what actually reaches a search engine
   * and a screen reader. A reader in Portugal is served this and understands
   * it; the tag says which variant was written, not who may read it.
   */
  pt: { code: 'pt', lang: 'pt-BR', dir: 'ltr', prefix: 'pt', endonym: 'Português', ogLocale: 'pt_BR' },
  es: { code: 'es', lang: 'es', dir: 'ltr', prefix: 'es', endonym: 'Español', ogLocale: 'es_ES' },
  /*
   * Plain `ar`, not a country. Modern Standard Arabic reads across the region,
   * and regionalising the tag without regionalising the copy claims a
   * distinction that would not exist in the text. Revisit only if there is a
   * country-specific strategy to go with it.
   */
  ar: { code: 'ar', lang: 'ar', dir: 'rtl', prefix: 'ar', endonym: 'العربية', ogLocale: 'ar_AR' },
};

/**
 * The source language, and the canonical one. Every other locale is a
 * translation of this and `hreflang="x-default"` points at it.
 */
export const DEFAULT_LOCALE: LocaleCode = 'en';

/**
 * What is actually published.
 *
 * English only, and it stays that way until PT, ES or AR copy has been reviewed
 * and approved. Adding a code here without the pages behind it, or pages without
 * the code, fails the build — see `localeFromRoute` and the check in
 * vite.config.ts.
 *
 * The language switcher, when it exists, lists exactly this array. It is not
 * shown at all while the array has one entry: a control offering one choice is
 * furniture, and a control offering four when three are unwritten is a lie.
 */
export const PUBLISHED: readonly LocaleCode[] = ['en'];

/** Every locale code, in display order, whether published or not. */
export const ALL: readonly LocaleCode[] = ['en', 'pt', 'es', 'ar'];

/**
 * Split a route into its locale and the route within that locale.
 *
 * `'apps/loop'` → `en` + `'apps/loop'`; `'pt/apps/loop'` → `pt` + `'apps/loop'`.
 * A first segment that is not a locale prefix belongs to the route, so a future
 * `/press/` is never mistaken for a language.
 */
export function localeFromRoute(route: string): { locale: Locale; rest: string } {
  const clean = route.replace(/^\/+|\/+$/g, '');
  const [head, ...tail] = clean.split('/');
  const match = ALL.map((c) => locales[c]).find((l) => l.prefix !== '' && l.prefix === head);
  if (match) return { locale: match, rest: tail.join('/') };
  return { locale: locales[DEFAULT_LOCALE], rest: clean };
}

/** The route a locale's copy of a page lives at. Inverse of `localeFromRoute`. */
export function routeIn(locale: Locale, rest: string): string {
  const clean = rest.replace(/^\/+|\/+$/g, '');
  if (locale.prefix === '') return clean;
  return clean === '' ? locale.prefix : `${locale.prefix}/${clean}`;
}
