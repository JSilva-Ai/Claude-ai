import { useEffect, useRef, useState } from 'react';
import { demo } from '../content/site';
import { asset } from '../lib/url';

/**
 * The playable demo, embedded.
 *
 * `demo.src` is a single configuration point in src/content/site.ts. A value
 * beginning with `http` is used as given; anything else is treated as a path
 * inside public/ and resolved against the site's base, so a self-hosted build
 * keeps working when the site moves to a subpath.
 *
 * While it is empty the page renders an honest placeholder rather than an
 * empty frame. A blank iframe looks like a bug; a panel that says the demo is
 * not connected yet says what is actually true.
 *
 * The sandbox is the smallest set that still lets a WebGL game run: its own
 * scripts, its own origin (canvas games need storage for saves), pointer lock
 * and fullscreen for input, and nothing else. It cannot navigate the parent
 * page or open popups. Widen this only if the build genuinely fails without it.
 */
export function DemoFrame() {
  const wrapRef = useRef<HTMLDivElement>(null);
  const [failed, setFailed] = useState(false);
  /**
   * Whether the game holds keyboard focus.
   *
   * Focus crossing into an iframe is close to invisible from the parent
   * document, and each of the obvious approaches was tried and measured:
   *
   *   - `:focus` / `:focus-visible` on the iframe never match. With the game
   *     focused, `iframe.matches(':focus')` is false while
   *     `document.activeElement` *is* the iframe.
   *   - `:focus-within` on the wrapper fails for the same reason.
   *   - `focus` / `focusin` handlers on the iframe element never fire — the
   *     event targets the inner document and does not cross the boundary.
   *
   * What does happen is that the parent window blurs. So the signal is a window
   * blur while the iframe is the active element, and a window focus to clear
   * it. Switching browser tabs also blurs the window, which leaves the ring on
   * — correct, as it happens: the game still holds focus and will still receive
   * the arrow keys when you come back.
   *
   * The game is played with the arrow keys, so this is not a nicety: it is the
   * only thing telling a keyboard player whether their input is going to the
   * game or to the page.
   */
  const [focused, setFocused] = useState(false);
  const iframeRef = useRef<HTMLIFrameElement>(null);

  useEffect(() => {
    const onBlur = () => setFocused(document.activeElement === iframeRef.current);
    const onFocus = () => setFocused(false);
    window.addEventListener('blur', onBlur);
    window.addEventListener('focus', onFocus);
    return () => {
      window.removeEventListener('blur', onBlur);
      window.removeEventListener('focus', onFocus);
    };
  }, []);

  if (!demo.src) {
    return (
      <div className="demo__placeholder">
        <p className="demo__placeholder-title">{demo.unconfigured.title}</p>
        <p className="demo__placeholder-body">{demo.unconfigured.body}</p>
      </div>
    );
  }

  const src = demo.src.startsWith('http') ? demo.src : asset(demo.src);

  const goFullscreen = () => {
    const el = wrapRef.current;
    if (!el) return;
    // Safari on iPhone has no Element.requestFullscreen at all, so this is a
    // progressive enhancement rather than a control we can rely on.
    el.requestFullscreen?.().catch(() => {});
  };

  return (
    <>
      <div className="demo__frame" ref={wrapRef}>
        <iframe
          className="demo__iframe"
          ref={iframeRef}
          src={src}
          title={`${demo.headline} — playable demo`}
          allow="fullscreen; gamepad; autoplay"
          /* Fullscreen is granted through `allow` above — it is a Permissions
             Policy feature, not a sandbox flag, and naming it here is a parse
             error the browser reports on every load. */
          sandbox="allow-scripts allow-same-origin allow-pointer-lock"
          loading="lazy"
          data-focused={focused}
          onError={() => setFailed(true)}
        />
      </div>

      {failed && (
        <p className="demo__error" role="status">
          The demo could not be loaded. If it is hosted elsewhere, that host may
          not allow embedding.
        </p>
      )}

      <div className="demo__bar">
        <button type="button" className="btn btn--sm" onClick={goFullscreen}>
          {demo.fullscreenLabel}
        </button>
        <p className="demo__note">{demo.note}</p>
      </div>
    </>
  );
}
