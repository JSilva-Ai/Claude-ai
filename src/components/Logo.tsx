import type { CSSProperties, HTMLAttributes, SVGProps } from 'react';

/**
 * The detection bracket.
 *
 * Four corner ticks around a solid centre dot — the same shape the perception
 * layer draws around every object it recognises inside the Proving Grounds.
 * The identity and the product are one drawing.
 *
 * Geometry is fixed on a 32-unit box and every edge lands on an integer, so a
 * 16px or 32px raster (favicon, tab strip, PWA tile) is pixel-crisp rather than
 * a grey smear:
 *
 *   BOX   32      the drawing square
 *   SW     2      stroke — 7.7% of the bracket side, the site's hairline scaled
 *                 up for logo use; 1px at 16px, 2px at 32px, both exact
 *   A/B    3/29   stroke centreline, so the ink stops 2 units from the edge
 *   TICK   8      corner arm; leaves a 10-unit gap mid-edge (38% of the side
 *                 open) — enough that it never collapses into a rectangle
 *   DOT    3.75   centre radius; d7.5 is 29% of the side, sized by eye rather
 *                 than by ratio because a lone circle in a large void always
 *                 reads smaller than it measures
 */
const BOX = 32;
const SW = 2;
const A = 3;
const B = BOX - A;
const TICK = 8;
const DOT = 3.75;

const TICKS = [
  `M${A} ${A + TICK}V${A}H${A + TICK}`,
  `M${B - TICK} ${A}H${B}V${A + TICK}`,
  `M${B} ${B - TICK}V${B}H${B - TICK}`,
  `M${A + TICK} ${B}H${A}V${B - TICK}`,
].join('');

/**
 * Lock-on. The ticks settle inward once on mount and tighten a hair on hover —
 * a system acquiring a target, not a logo asking for attention. Everything
 * lives behind `prefers-reduced-motion: no-preference`, so the still mark is
 * the real mark and the movement is the addition.
 */
const CSS = `
.nvl-logo__ticks,.nvl-logo__dot{transform-box:fill-box;transform-origin:center}
@media (prefers-reduced-motion:no-preference){
.nvl-logo--live .nvl-logo__ticks{
animation:nvl-lock var(--dur-slow,620ms) var(--ease-out,cubic-bezier(.16,1,.3,1)) backwards;
transition:transform var(--dur-slow,620ms) var(--ease-out,cubic-bezier(.16,1,.3,1))}
.nvl-logo--live .nvl-logo__dot{
animation:nvl-acquire var(--dur-base,320ms) var(--ease-out,cubic-bezier(.16,1,.3,1)) 160ms backwards}
.nvl-logo--live:hover .nvl-logo__ticks{transform:scale(.955)}
@keyframes nvl-lock{from{transform:scale(1.09);opacity:0}to{transform:none;opacity:1}}
@keyframes nvl-acquire{from{transform:scale(.6);opacity:0}to{transform:none;opacity:1}}
}`;

function join(...parts: (string | false | undefined)[]) {
  return parts.filter(Boolean).join(' ');
}

export interface LogoMarkProps extends Omit<SVGProps<SVGSVGElement>, 'width' | 'height'> {
  /** Rendered edge length in px. The mark is square by construction. */
  size?: number;
  /**
   * Accessible name. Defaults to the lab's name because a bare mark is almost
   * always standing in for it; pass `null` when adjacent text already names it
   * and the mark is decoration.
   */
  label?: string | null;
  /** Centre dot in phosphor — the one place a hardcoded accent is intended. */
  accent?: boolean;
  /** Opt in to the lock-on. Off by default: restraint is the house position. */
  live?: boolean;
}

export function LogoMark({
  size = 32,
  label = 'New AI Vision Labs',
  accent = false,
  live = false,
  className,
  ...rest
}: LogoMarkProps) {
  const decorative = label === null;
  return (
    <>
      {live && (
        <style href="nvl-logo" precedence="medium">
          {CSS}
        </style>
      )}
      <svg
        className={join('nvl-logo', live && 'nvl-logo--live', className)}
        width={size}
        height={size}
        viewBox={`0 0 ${BOX} ${BOX}`}
        fill="none"
        role={decorative ? undefined : 'img'}
        aria-hidden={decorative || undefined}
        focusable="false"
        {...rest}
      >
        {!decorative && <title>{label}</title>}
        <path
          className="nvl-logo__ticks"
          d={TICKS}
          stroke="currentColor"
          strokeWidth={SW}
          strokeLinecap="butt"
          strokeLinejoin="miter"
        />
        <circle
          className="nvl-logo__dot"
          cx={BOX / 2}
          cy={BOX / 2}
          r={DOT}
          fill={accent ? 'var(--phosphor, #d4f85c)' : 'currentColor'}
        />
      </svg>
    </>
  );
}

export interface LogoProps extends HTMLAttributes<HTMLSpanElement> {
  /** Edge length of the mark in px. Everything else is derived from it. */
  size?: number;
  /** Centre dot in phosphor. */
  accent?: boolean;
  /** Opt in to the lock-on. */
  live?: boolean;
  /** Drop the wordmark and render the mark alone, keeping the same name. */
  markOnly?: boolean;
}

/**
 * Horizontal lockup. The wordmark stays live text — selectable, searchable,
 * and it restyles with the rest of the page — rather than outlines.
 *
 * Proportions are multiples of the mark, so the lockup holds at any size.
 * Both were solved by eye against the alternatives rather than derived:
 *
 *   wordmark  0.58 × mark   — cap height lands at ~0.42 of the mark, which is
 *                             where the word and the drawing carry equal
 *                             weight. Smaller and the word becomes a caption;
 *                             larger and the mark demotes itself to an icon.
 *   gap       0.44 × mark   — the mark is mostly negative space, so it needs
 *                             less air beside it than its bounding box
 *                             suggests. Past ~0.5 the two halves stop reading
 *                             as one object.
 */
export function Logo({
  size = 26,
  accent = false,
  live = false,
  markOnly = false,
  className,
  style,
  ...rest
}: LogoProps) {
  const wordStyle: CSSProperties = {
    fontFamily: 'var(--font-sans, ui-sans-serif, system-ui, sans-serif)',
    fontSize: `${size * 0.58}px`,
    fontWeight: 500,
    fontVariationSettings: "'wdth' 118, 'wght' 500",
    letterSpacing: '0.185em',
    // Tracking adds a trailing sidebearing after the final S; pull it back so
    // the lockup's optical right edge is the letter, not the space.
    marginInlineEnd: '-0.185em',
    lineHeight: 1,
    whiteSpace: 'nowrap',
    textTransform: 'uppercase',
  };

  return (
    <span
      className={join('nvl-logo', live && 'nvl-logo--live', className)}
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: `${size * 0.44}px`,
        color: 'inherit',
        ...style,
      }}
      {...rest}
    >
      <LogoMark size={size} label={null} accent={accent} live={live} />
      {markOnly ? (
        <span
          style={{
            position: 'absolute',
            width: 1,
            height: 1,
            overflow: 'hidden',
            clip: 'rect(0 0 0 0)',
            clipPath: 'inset(50%)',
            whiteSpace: 'nowrap',
          }}
        >
          New AI Vision Labs
        </span>
      ) : (
        <span style={wordStyle}>New AI Vision Labs</span>
      )}
    </span>
  );
}

export default Logo;
