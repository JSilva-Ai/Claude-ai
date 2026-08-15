import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { thesis } from '../content/site';

export function Thesis() {
  const bodyRef = useReveal<HTMLDivElement>();
  const quoteRef = useReveal<HTMLDivElement>();

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

          <div className="thesis__aside" ref={quoteRef} data-reveal>
            <figure className="thesis__quote">
              <blockquote>{thesis.pullQuote}</blockquote>
              <figcaption className="label thesis__attribution">{thesis.attribution}</figcaption>
            </figure>

            <div className="thesis__cases">
              <p className="label thesis__cases-label">{thesis.casesLabel}</p>
              <ul>
                {thesis.cases.map((c) => (
                  <li key={c.code}>
                    <span className="thesis__case">{c.case}</span>
                    <a className="thesis__case-env mono" href="#proving-grounds">
                      <span className="thesis__case-code">{c.code}</span>
                      {c.env}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
