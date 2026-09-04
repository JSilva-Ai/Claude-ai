import { useEffect, useRef, useState } from 'react';
import { apps, home, routes } from '../content/en/site';
import { GameClip } from './GameClip';
import { url } from '../lib/url';
import { usePointer, useReducedMotion } from '../lib/hooks';
import { createPerceptionField, type FieldHandle } from '../lib/perceptionField';
import './hero.css';

/**
 * Home hero.
 *
 * The field behind the headline is the same WebGL renderer the site has always
 * used, recoloured to the identity: points at rest are achromatic, points that
 * have returned run the mark's blue. It is the studio's one piece of ornament
 * and it is confined to this page.
 *
 * It is decoration here, so it carries no readout and makes no claim. If the
 * GPU cannot run it, or the visitor prefers reduced motion, the page loses a
 * texture and nothing else — the headline, the lede, and both calls to action
 * are ordinary DOM and never depend on it.
 */
export function Hero() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const pointer = usePointer();
  const reduced = useReducedMotion();
  const [live, setLive] = useState(false);
  /* The one app carrying media. Absent until something ships: the hero drops
     back to a single column rather than framing a placeholder. */
  const featured = apps.find((a) => a.clip);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    let handle: FieldHandle | null = null;
    handle = createPerceptionField(canvas, {
      pointer: pointer.current,
      animate: !reduced,
      mode: 'scan',
      onReady: () => setLive(true),
    });
    return () => handle?.destroy();
  }, [pointer, reduced]);

  return (
    <section className="hero" aria-labelledby="hero-title">
      <canvas className="hero__canvas" ref={canvasRef} aria-hidden="true" data-live={live} />
      <div className="hero__grain" aria-hidden="true" />

      <div className="container hero__inner">
        <div className="hero__copy">
          <p className="label hero__eyebrow">
            <span className="hero__dot" aria-hidden="true" />
            {home.hero.eyebrow}
          </p>

          <h1 className="hero__title" id="hero-title">
            {home.hero.headline.map((line) => {
              const accent = line.includes(home.hero.accentWord);
              if (!accent) return <span className="hero__line" key={line}>{line}</span>;
              const [before] = line.split(home.hero.accentWord);
              return (
                <span className="hero__line" key={line}>
                  {before}
                  <em className="hero__accent">{home.hero.accentWord}</em>
                </span>
              );
            })}
          </h1>

          <p className="hero__lede">{home.hero.lede}</p>

          <div className="hero__actions">
            <a className="btn btn--primary" href={url(home.hero.primaryCta.route)}>
              {home.hero.primaryCta.label}
              <span className="btn__arrow" aria-hidden="true">↗</span>
            </a>
            <a className="btn" href={url(home.hero.secondaryCta.route)}>
              {home.hero.secondaryCta.label}
            </a>
          </div>
        </div>

        {/*
          The product, at full size, above the fold.

          This site was three screens of prose before a visitor saw a single
          thing the studio had made — which is a strange way to sell craft. The
          field behind it is masked to fade out on the left, so it was already
          composed to leave the right side to something; until now that side
          held nothing.

          The frame is a plain bezel at the house 520x720, not a phone
          silhouette. A phone outline would be a lie about the aspect — the
          game's canvas is 13:18, nothing like a handset — and cropping the
          product to fit a decorative shell is the wrong way round.
        */}
        {featured?.clip && (
          <div className="hero__stage">
            <div className="hero__phone">
              <span className="hero__phone-island" aria-hidden="true" />
              <span className="hero__phone-button" aria-hidden="true" />
              <div className="hero__screen">
                <GameClip clip={featured.clip} alt={`${featured.name} gameplay`} eager />
              </div>
            </div>
            <p className="hero__caption">
              <a className="hero__caption-link" href={url(`${routes.apps}${featured.slug}/`)}>
                {featured.name}
              </a>
              <span className="hero__caption-sep" aria-hidden="true">·</span>
              <span className="hero__caption-status">{featured.status}</span>
            </p>
          </div>
        )}
      </div>
    </section>
  );
}
