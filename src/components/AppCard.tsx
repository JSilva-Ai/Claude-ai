import type { App } from '../content/site';
import { asset, url } from '../lib/url';
import { GameClip } from './GameClip';
import { useReveal } from '../lib/hooks';
import { statusModifier } from '../lib/status';

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
   * The card's heading level, which depends on what is above it. On /apps the
   * group headings sit under the page h1, so they are h2 and the cards are h3.
   * On the home page the portfolio section adds its own h2 above the groups,
   * so everything moves down one and the cards are h4. A fixed level would
   * skip one on whichever page it was not chosen for, which is an axe
   * heading-order violation and a real problem for anyone navigating by
   * headings.
   */
  headingLevel = 4,
}: {
  app: App;
  i: number;
  headingLevel?: 2 | 3 | 4;
}) {
  const H = `h${headingLevel}` as 'h2' | 'h3' | 'h4';
  const stage = statusModifier(app.status);
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
        {app.clip ? (
          <GameClip clip={app.clip} alt={`${app.name} gameplay`} eager={i < 2} />
        ) : shot ? (
          <img
            src={asset(shot.src)}
            alt={shot.alt}
            width={shot.width}
            height={shot.height}
            loading={i < 2 ? 'eager' : 'lazy'}
            decoding="async"
          />
        ) : (
          /* No artwork yet.
             A stock device mockup would be decoration standing in for a product
             that does not exist, so the slot carries a plain cover instead: the
             mark, the name, and the product's own line. That fills a panel this
             tall with something true, where an empty frame at the same size
             reads as an image that failed to load. */
          <div className="appcard__cover" aria-hidden="true">
            <span className="appcard__cover-mark" />
            <span className="appcard__cover-name">{app.name}</span>
            {app.positioning && (
              <span className="appcard__cover-line">{app.positioning}</span>
            )}
          </div>
        )}
      </div>

      <div className="appcard__meta">
        {/* The status sits here rather than over the art: a clip fills the slot
            edge to edge and every corner of it is game HUD, so an overlay pill
            covers the score or the credits whichever corner it takes. */}
        <span className={`pill pill--${stage}`}>{app.status}</span>
        <H className="appcard__name">
          <a className="appcard__link" href={url(`apps/${app.slug}`)}>
            {app.name}
          </a>
        </H>
        <p className="appcard__tagline">{app.tagline}</p>
        {/* The kind is always known; the platforms often are not this early, and
            a card that guessed at them would be the only untrue line on it. */}
        <p className="mono appcard__platforms">
          {app.platforms ? `${app.kind} · ${app.platforms.join(' · ')}` : app.kind}
        </p>
      </div>
    </li>
  );
}

