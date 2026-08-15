import { useEffect, useRef, useState } from 'react';
import { home } from '../content/site';
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
    </section>
  );
}
