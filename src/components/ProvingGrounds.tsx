import { useCallback, useEffect, useRef, useState } from 'react';
import { SectionHead } from './SectionHead';
import { useMediaQuery, useReducedMotion, useReveal } from '../lib/hooks';
import { environments, provingGrounds } from '../content/site';
import './provingGrounds.css';

type Env = (typeof environments)[number];

interface CardProps {
  env: Env;
  i: number;
  /** Motion is allowed at all (section toggle + reduced-motion). */
  enabled: boolean;
  /** On touch, only one card plays at a time; the parent elects it. */
  elected: boolean;
  onVisible(id: string, ratio: number): void;
  hoverToPlay: boolean;
}

function EnvironmentCard({ env, i, enabled, elected, onVisible, hoverToPlay }: CardProps) {
  const revealRef = useReveal<HTMLLIElement>();
  const videoRef = useRef<HTMLVideoElement>(null);
  const wrapRef = useRef<HTMLDivElement>(null);
  // The <video> is not mounted until the card is genuinely wanted. Ten videos
  // mounted at once is ten decoders, even when paused.
  const [mounted, setMounted] = useState(false);
  const [playing, setPlaying] = useState(false);
  const [hovered, setHovered] = useState(false);

  // Report visibility upward so the parent can elect one card on touch.
  useEffect(() => {
    const el = wrapRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      (entries) => onVisible(env.id, entries[0].intersectionRatio),
      { threshold: [0, 0.25, 0.5, 0.75, 1] },
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [env.id, onVisible]);

  const wanted = enabled && (hoverToPlay ? hovered : elected);

  useEffect(() => {
    if (wanted) setMounted(true);
  }, [wanted]);

  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;
    if (wanted) {
      // play() rejects if the element is removed mid-flight or autoplay is
      // blocked; neither is an error worth surfacing.
      v.play()
        .then(() => setPlaying(true))
        .catch(() => setPlaying(false));
    } else {
      v.pause();
      setPlaying(false);
    }
  }, [wanted, mounted]);

  return (
    <li
      className="env"
      data-span={env.code === '01' || env.code === '04' ? 'wide' : 'narrow'}
      ref={revealRef}
      data-reveal
      style={{ '--reveal-delay': `${(i % 3) * 80}ms` } as React.CSSProperties}
    >
      <div
        className="env__frame ticks"
        ref={wrapRef}
        onPointerEnter={() => setHovered(true)}
        onPointerLeave={() => setHovered(false)}
        onFocus={() => setHovered(true)}
        onBlur={() => setHovered(false)}
        tabIndex={-1}
      >
        <div className="env__media">
          <img
            className="env__poster"
            src={`/media/env/${env.id}.jpg`}
            alt={`${env.name} environment: ${env.discipline}. ${env.blurb}`}
            width={960}
            height={600}
            loading={i < 2 ? 'eager' : 'lazy'}
            decoding="async"
            data-hidden={playing}
          />
          {mounted && (
            <video
              className="env__video"
              ref={videoRef}
              src={`/media/env/${env.id}.webm`}
              poster={`/media/env/${env.id}.jpg`}
              muted
              loop
              playsInline
              preload="none"
              aria-hidden="true"
              tabIndex={-1}
              data-visible={playing}
            />
          )}
          <span className="env__scanline" aria-hidden="true" />
        </div>

        <div className="env__chrome" aria-hidden="true">
          <span className="env__code mono">{env.code}</span>
          <span className="env__state">
            <span className={playing ? 'dot' : 'env__state-dot'} />
            <span className="label">{playing ? 'Running' : 'Standby'}</span>
          </span>
        </div>
      </div>

      <div className="env__meta">
        <div className="env__title-row">
          <h3 className="env__name">{env.name}</h3>
          <p className="label env__discipline">{env.discipline}</p>
        </div>
        <p className="env__blurb">{env.blurb}</p>
        <p className="env__metric">
          <span className="label">{env.metric.label}</span>
          <span className="env__metric-value mono">{env.metric.value}</span>
        </p>
      </div>
    </li>
  );
}

export function ProvingGrounds() {
  const reduced = useReducedMotion();
  const hoverCapable = useMediaQuery('(hover: hover) and (pointer: fine)');
  const [motionOn, setMotionOn] = useState(true);
  const ratios = useRef(new Map<string, number>());
  const [elected, setElected] = useState<string | null>(null);

  const enabled = motionOn && !reduced;

  // On touch, elect the single most-visible card. Ten simultaneous video
  // decodes is the fastest way to make a phone feel broken.
  const onVisible = useCallback(
    (id: string, ratio: number) => {
      ratios.current.set(id, ratio);
      if (hoverCapable) return;
      let best: string | null = null;
      let bestRatio = 0.45;
      for (const [key, value] of ratios.current) {
        if (value > bestRatio) {
          bestRatio = value;
          best = key;
        }
      }
      setElected((prev) => (prev === best ? prev : best));
    },
    [hoverCapable],
  );

  return (
    <section
      className="section section--ruled grounds"
      id="proving-grounds"
      aria-labelledby="grounds-title"
    >
      <div className="container container--wide">
        <SectionHead
          index={provingGrounds.index}
          label={provingGrounds.label}
          headline={<span id="grounds-title">{provingGrounds.headline}</span>}
          lede={provingGrounds.lede}
        />

        <div className="grounds__bar">
          <p className="grounds__note label">{provingGrounds.note}</p>
          {!reduced && (
            <button
              type="button"
              className="grounds__toggle"
              onClick={() => setMotionOn((v) => !v)}
              aria-pressed={motionOn}
            >
              <span className="grounds__toggle-track" aria-hidden="true">
                <span className="grounds__toggle-thumb" />
              </span>
              <span className="label">Motion {motionOn ? 'on' : 'off'}</span>
            </button>
          )}
        </div>

        <ul className="grounds__grid">
          {environments.map((env, i) => (
            <EnvironmentCard
              key={env.id}
              env={env}
              i={i}
              enabled={enabled}
              elected={elected === env.id}
              onVisible={onVisible}
              hoverToPlay={hoverCapable}
            />
          ))}
        </ul>
      </div>
    </section>
  );
}
