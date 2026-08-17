import { useEffect, useRef, useState } from 'react';
import type { GameClipSources } from '../content/site';
import { asset } from '../lib/url';
import { useReducedMotion } from '../lib/hooks';

/**
 * A game clip, at the site's standard media size.
 *
 * Every piece of game media on this site is 520×720 — the size VOID STRIKER's
 * canvas is authored at, adopted as the house format so a clip, a screenshot
 * and an empty slot are interchangeable and the grid never reflows when one
 * replaces another. `scripts/render/capture-game.mjs` writes at exactly this
 * size; the ratio is a token so nothing has to remember the numbers.
 *
 * WebM is offered first because it is the smaller of the two and every browser
 * that can decode it should. Safari falls through to H.264.
 *
 * Playback rules, in order of who they are for:
 *   - Reduced motion: the poster, and only the poster. No decoder is created,
 *     no source element is mounted, and the play control is not offered — a
 *     paused video that a visitor has to keep paused is not respect.
 *   - Otherwise the clip is muted, inline, and loops, and starts only when it
 *     is actually on screen. A decoder running for a picture nobody is looking
 *     at costs the same as one somebody is.
 */
export function GameClip({
  clip,
  alt,
  eager = false,
}: {
  clip: GameClipSources;
  alt: string;
  /** Set on the one clip above the fold, so it is not deferred behind the observer. */
  eager?: boolean;
}) {
  const reduced = useReducedMotion();
  const wrapRef = useRef<HTMLDivElement>(null);
  const videoRef = useRef<HTMLVideoElement>(null);
  const [visible, setVisible] = useState(eager);
  const [playing, setPlaying] = useState(false);
  /**
   * Autoplay was refused.
   *
   * A muted inline video is allowed to start on its own almost everywhere, but
   * "almost" is doing real work: iOS Low Power Mode blocks it outright, Safari
   * blocks it when the tab is in the background at load, and any browser with
   * autoplay disabled by the visitor blocks it too. Left alone, the failure is
   * silent and indistinguishable from a still image — the page just shows a
   * frozen frame of a game that is supposed to be running, with nothing to
   * click. This is the one state a headless check cannot reproduce, so it is
   * handled rather than assumed away.
   */
  const [blocked, setBlocked] = useState(false);

  useEffect(() => {
    const el = wrapRef.current;
    if (!el || reduced) return;
    const obs = new IntersectionObserver(
      (entries) => setVisible(entries[0].isIntersecting),
      { threshold: 0.2 },
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [reduced]);

  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;
    if (visible) {
      v.play()
        .then(() => {
          setPlaying(true);
          setBlocked(false);
        })
        .catch(() => {
          setPlaying(false);
          // Only offer the control while the clip is actually on screen. A
          // rejection during teardown, when the element is being removed, is
          // not a blocked autoplay and must not leave a button behind.
          setBlocked(true);
        });
    } else {
      v.pause();
      setPlaying(false);
      setBlocked(false);
    }
  }, [visible]);

  /** Started from a real click, which is the gesture the policy was waiting for. */
  const start = () => {
    const v = videoRef.current;
    if (!v) return;
    v.play()
      .then(() => {
        setPlaying(true);
        setBlocked(false);
      })
      .catch(() => setBlocked(true));
  };

  return (
    <div className="clip" ref={wrapRef}>
      <img
        className="clip__poster"
        src={asset(clip.poster)}
        alt={alt}
        width={520}
        height={720}
        loading={eager ? 'eager' : 'lazy'}
        decoding="async"
        data-hidden={playing}
      />
      {!reduced && visible && (
        <video
          className="clip__video"
          ref={videoRef}
          poster={asset(clip.poster)}
          muted
          loop
          playsInline
          preload="none"
          aria-hidden="true"
          tabIndex={-1}
          data-visible={playing}
        >
          <source src={asset(clip.webm)} type="video/webm" />
          <source src={asset(clip.mp4)} type="video/mp4" />
        </video>
      )}

      {blocked && (
        <button type="button" className="clip__play" onClick={start}>
          <span className="clip__play-icon" aria-hidden="true" />
          <span className="clip__play-label">Play {alt.split(':')[0]}</span>
        </button>
      )}
    </div>
  );
}
