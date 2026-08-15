import type { ReactNode } from 'react';
import { useReveal } from '../lib/hooks';

interface Props {
  index: string;
  label: string;
  headline: ReactNode;
  lede?: ReactNode;
  /** Places the lede in a second column on wide viewports. */
  split?: boolean;
}

/**
 * Every section opens the same way: index, mono label, rule, headline.
 * The repetition is the point — it is what makes the page read as one
 * instrument rather than eight landing-page blocks.
 */
export function SectionHead({ index, label, headline, lede, split = true }: Props) {
  const ref = useReveal<HTMLDivElement>();

  return (
    <div
      className={`section-head${split && lede ? ' section-head--split' : ''}`}
      ref={ref}
      data-reveal
    >
      <div>
        <p className="section-head__index label">
          <span className="section-head__no">{index}</span>
          <span>{label}</span>
        </p>
        <h2 className="display display-3 section-head__title">{headline}</h2>
      </div>
      {lede && <p className="body section-head__lede">{lede}</p>}
    </div>
  );
}
