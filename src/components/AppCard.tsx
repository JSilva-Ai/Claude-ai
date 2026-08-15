import type { App } from '../content/site';
import { asset, url } from '../lib/url';
import { useReveal } from '../lib/hooks';

/**
 * One app, on the grid.
 *
 * The whole card is a link, but only the title carries the anchor — a nested
 * anchor per store badge inside a card-wide anchor is invalid HTML and gives
 * a screen reader two overlapping targets. The card grows the hit area around
 * the title instead, via a stretched pseudo-element in CSS.
 */
export function AppCard({
  app,
  i,
  /**
   * The card's heading level, which depends on what is above it: on the home
   * page these sit under an h2 section head, on /apps they sit directly under
   * the h1. A fixed level would skip one on whichever page it was not chosen
   * for, which is an axe heading-order violation and a real problem for anyone
   * navigating by headings.
   */
  headingLevel = 3,
}: {
  app: App;
  i: number;
  headingLevel?: 2 | 3;
}) {
  const H = `h${headingLevel}` as 'h2' | 'h3';
  const ref = useReveal<HTMLLIElement>();
  const shot = app.screenshots[0];

  return (
    <li
      className="appcard"
      ref={ref}
      data-reveal
      style={{ '--reveal-delay': `${i * 80}ms` } as React.CSSProperties}
    >
      <div className="appcard__art">
        {shot ? (
          <img
            src={asset(shot.src)}
            alt={shot.alt}
            width={shot.width}
            height={shot.height}
            loading={i < 2 ? 'eager' : 'lazy'}
            decoding="async"
          />
        ) : (
          /* No screenshot yet. An empty framed panel is honest; a stock
             device mockup would be decoration standing in for a product. */
          <div className="appcard__empty" aria-hidden="true">
            <span className="appcard__empty-mark" />
          </div>
        )}
        <span className={`pill pill--${app.status === 'In development' ? 'dev' : 'live'}`}>
          {app.status}
        </span>
      </div>

      <div className="appcard__meta">
        <H className="appcard__name">
          <a className="appcard__link" href={url(`apps/${app.slug}`)}>
            {app.name}
          </a>
        </H>
        <p className="appcard__tagline">{app.tagline}</p>
        <p className="mono appcard__platforms">{app.platforms.join(' · ')}</p>
      </div>
    </li>
  );
}
