import { useId } from 'react';

/**
 * The NAI monogram, inline.
 *
 * This is the same geometry as src/assets/logo.svg — that file exists so the
 * mark can be handed to anyone as a standalone asset, and this component
 * exists so the mark can inherit `currentColor` and animate with the page. If
 * one changes, change both (and scripts/render/brand.mjs, which rasterises it
 * for the favicon tile and the social card).
 *
 * The gradient and the clip path both need ids, and a page can hold several
 * copies of this component. `useId` keeps them from colliding — two elements
 * sharing an id means the second one silently references the first one's
 * clip, which crops the mark to the wrong box.
 */
export function Logo({ size = 34, className }: { size?: number; className?: string }) {
  const uid = useId().replace(/:/g, '');
  const grad = `nai-sphere-${uid}`;
  const clip = `nai-baseline-${uid}`;

  return (
    <svg
      className={className}
      width={(size * 58) / 48}
      height={size}
      viewBox="0 0 58 48"
      fill="none"
      aria-hidden="true"
      focusable="false"
    >
      <defs>
        <linearGradient id={grad} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0%" stopColor="var(--blue)" />
          <stop offset="100%" stopColor="var(--blue-deep)" />
        </linearGradient>
        {/* A stroked diagonal cannot end in a horizontal edge, so the N's
            diagonal and the A's feet all hang below the baseline. One clip
            cuts every foot flat at once. */}
        <clipPath id={clip}>
          <rect x="0" y="0" width="58" height="38" />
        </clipPath>
      </defs>

      <g
        stroke="currentColor"
        strokeWidth="4.5"
        strokeLinecap="butt"
        strokeLinejoin="miter"
        clipPath={`url(#${clip})`}
      >
        {/* N — the miter limit sits below the join ratio so its reversals get
            cut flat instead of throwing a spike past the baseline. */}
        <path d="M8 38.01V15l13 23V15" strokeMiterlimit="1.4" />
        {/* A — apex carried above the N's cap height; this join stays sharp. */}
        <path d="M21 38.01 31 10l10 28.01" strokeMiterlimit="5" />
        <path d="M23.9 30h14.2" />
        {/* i — stem */}
        <path d="M48 38.01V22" />
      </g>
      {/* i — tittle, as the sphere. The only filled element, and the only one
          carrying the blue. */}
      <circle cx="48" cy="14" r="3.3" fill={`url(#${grad})`} />
    </svg>
  );
}

/** Mark plus wordmark. The nav and the footer both use this. */
export function Lockup({ size = 26 }: { size?: number }) {
  return (
    <span className="lockup">
      <Logo size={size} />
      <span className="lockup__word">New AI Vision Labs</span>
    </span>
  );
}
