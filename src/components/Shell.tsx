import type { ReactNode } from 'react';
import { Nav } from './Nav';
import { Footer } from './Footer';

/**
 * Page chrome shared by every route.
 *
 * Each page is its own document (see the entries in vite.config.ts), so this
 * is composition rather than routing — there is no router on the site and no
 * client-side navigation to keep in sync with the URL.
 */
export function Shell({ children }: { children: ReactNode }) {
  return (
    <>
      <Nav />
      <main id="main">{children}</main>
      <Footer />
    </>
  );
}

/** The standard heading block for a section. */
export function SectionHead({
  index,
  label,
  headline,
  lede,
  id,
}: {
  index?: string;
  label?: string;
  headline: ReactNode;
  lede?: string;
  id?: string;
}) {
  return (
    <div className="head">
      {(index || label) && (
        <p className="label head__label">
          {index && <span className="head__index mono">{index}</span>}
          {label}
        </p>
      )}
      <h2 className="head__title" id={id}>
        {headline}
      </h2>
      {lede && <p className="head__lede">{lede}</p>}
    </div>
  );
}

/**
 * The banner at the top of a subpage. Subpages do not run the WebGL field —
 * it belongs to the home page, where it has room to be the subject rather
 * than a texture behind a heading.
 */
export function PageHead({
  label,
  title,
  lede,
  meta,
}: {
  label?: ReactNode;
  title: string;
  lede?: string;
  meta?: ReactNode;
}) {
  return (
    <header className="section pagehead">
      <div className="container">
        {label && <p className="label pagehead__label">{label}</p>}
        <h1 className="pagehead__title">{title}</h1>
        {lede && <p className="pagehead__lede">{lede}</p>}
        {meta && <div className="pagehead__meta">{meta}</div>}
      </div>
    </header>
  );
}
