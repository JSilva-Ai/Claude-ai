import { useEffect, useRef, useState } from 'react';
import { createPerceptionField } from '../lib/perceptionField';
import { usePointer, useReducedMotion } from '../lib/hooks';
import { hero, ui } from '../content/site';
import './hero.css';

/**
 * The perception field, mounted behind the hero copy.
 * Falls back to a composed static field if WebGL2 is unavailable — the
 * fallback is designed, not an empty box.
 */
function Field({ animate }: { animate: boolean }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const readoutRef = useRef<HTMLDListElement>(null);
  const pointer = usePointer();
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    // The readout is written straight into the DOM rather than held in state:
    // it updates several times a second and React has no reason to re-render
    // the hero for it.
    const cells = readoutRef.current?.querySelectorAll<HTMLElement>('[data-cell]');
    const handle = createPerceptionField(canvas, {
      pointer: pointer.current,
      animate,
      onStats: cells
        ? (s) => {
            const values = [
              s.samples.toLocaleString('en-US'),
              s.radius.toFixed(2) + ' m',
              `${s.originX >= 0 ? '+' : ''}${s.originX.toFixed(2)}, ${s.originY >= 0 ? '+' : ''}${s.originY.toFixed(2)}`,
            ];
            cells.forEach((cell, i) => {
              cell.textContent = values[i];
            });
          }
        : undefined,
    });
    if (!handle) {
      setFailed(true);
      return;
    }
    return () => handle.destroy();
  }, [animate, pointer]);

  return (
    <div className="hero__field" aria-hidden="true">
      {!failed && <canvas ref={canvasRef} className="hero__canvas" />}
      <div className="hero__scrim" />
      <div className="grain" />
      <div className="hero__horizon" />

      {/* Annotation, the way an instrument annotates its own display. These
          are the field's real values, read out of the running renderer. */}
      {!failed && (
        <dl className="hero__readout" ref={readoutRef}>
          {hero.readout.map((r) => (
            <div key={r}>
              <dt>{r}</dt>
              <dd className="mono" data-cell>
                —
              </dd>
            </div>
          ))}
        </dl>
      )}
    </div>
  );
}

export function Hero() {
  const reduced = useReducedMotion();
  const [lit, setLit] = useState(false);

  // Load choreography starts after first paint so the sequence is seen, not
  // missed. Reduced motion skips straight to the resolved state.
  useEffect(() => {
    if (reduced) {
      setLit(true);
      return;
    }
    const id = requestAnimationFrame(() => setLit(true));
    return () => cancelAnimationFrame(id);
  }, [reduced]);

  return (
    <header className="hero" id="top" data-lit={lit}>
      <Field animate={!reduced} />

      <div className="container hero__inner">
        <div className="hero__eyebrow" style={{ '--i': 0 } as React.CSSProperties}>
          <span className="dot" />
          <span className="label">{hero.status}</span>
          <span className="hero__eyebrow-sep" aria-hidden="true" />
          <span className="label">{hero.mode}</span>
        </div>

        <h1 className="hero__headline display display-1">
          {hero.headline.map((line, i) => (
            <span className="hero__line" key={line}>
              <span className="hero__line-inner" style={{ '--i': i + 1 } as React.CSSProperties}>
                {line === hero.headline[hero.headline.length - 1] ? (
                  <>
                    {line.replace(hero.accentWord + '.', '')}
                    <em className="accent">{hero.accentWord}.</em>
                  </>
                ) : (
                  line
                )}
              </span>
            </span>
          ))}
        </h1>

        <p className="hero__lede lede" style={{ '--i': 4 } as React.CSSProperties}>
          {hero.lede}
        </p>

        <div className="hero__actions" style={{ '--i': 5 } as React.CSSProperties}>
          <a className="btn btn--primary" href={hero.primaryCta.href}>
            <span className="btn__label">{hero.primaryCta.label}</span>
            <span className="btn__arrow" aria-hidden="true">
              <svg width="12" height="12" viewBox="0 0 14 14" fill="none">
                <path
                  d="M3 11L11 3M11 3H5M11 3V9"
                  stroke="currentColor"
                  strokeWidth="1.6"
                  strokeLinecap="square"
                />
              </svg>
            </span>
          </a>
          <a className="btn btn--ghost" href={hero.secondaryCta.href}>
            <span className="btn__label">{hero.secondaryCta.label}</span>
          </a>
        </div>
      </div>

      <div className="hero__telemetry" style={{ '--i': 6 } as React.CSSProperties}>
        <div className="container hero__telemetry-inner">
          <dl className="hero__stats">
            {hero.telemetry.map((t) => (
              <div className="hero__stat" key={t.label}>
                <dt className="label">{t.label}</dt>
                <dd className="hero__stat-value">
                  <span className="mono">{t.value}</span>
                  <span className="hero__stat-unit">{t.unit}</span>
                </dd>
              </div>
            ))}
          </dl>
          <a className="hero__scroll" href="#thesis" aria-label={ui.scrollLabel}>
            <span className="label">{ui.scroll}</span>
            <span className="hero__scroll-rail" aria-hidden="true">
              <span className="hero__scroll-dot" />
            </span>
          </a>
        </div>
      </div>
    </header>
  );
}
