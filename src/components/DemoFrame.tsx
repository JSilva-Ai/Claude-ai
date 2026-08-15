import { useRef, useState } from 'react';
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
          src={src}
          title={`${demo.headline} — playable demo`}
          allow="fullscreen; gamepad; autoplay"
          sandbox="allow-scripts allow-same-origin allow-pointer-lock allow-fullscreen"
          loading="lazy"
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
