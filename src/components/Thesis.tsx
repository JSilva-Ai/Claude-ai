import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { thesis } from '../content/site';

export function Thesis() {
  const bodyRef = useReveal<HTMLDivElement>();
  const quoteRef = useReveal<HTMLElement>();

  const [before, after] = thesis.headline.split(thesis.accentWord);

  return (
    <section className="section section--ruled" id="thesis" aria-labelledby="thesis-title">
      <div className="container">
        <SectionHead
          index={thesis.index}
          label={thesis.label}
          split={false}
          headline={
            <span id="thesis-title">
              {before}
              <span className="accent">{thesis.accentWord}</span>
              {after}
            </span>
          }
        />

        <div className="thesis__layout">
          <div className="thesis__body" ref={bodyRef} data-reveal>
            {thesis.body.map((p) => (
              <p key={p.slice(0, 24)}>{p}</p>
            ))}
          </div>

          <figure className="thesis__quote" ref={quoteRef} data-reveal>
            <blockquote>{thesis.pullQuote}</blockquote>
            <figcaption className="label thesis__attribution">{thesis.attribution}</figcaption>
          </figure>
        </div>
      </div>
    </section>
  );
}
