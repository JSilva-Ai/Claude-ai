import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { lab } from '../content/site';

export function Lab() {
  const principlesRef = useReveal<HTMLUListElement>();
  const statsRef = useReveal<HTMLDListElement>();

  return (
    <section className="section section--ruled" id="lab" aria-labelledby="lab-title">
      <div className="container">
        <SectionHead
          index={lab.index}
          label={lab.label}
          headline={<span id="lab-title">{lab.headline}</span>}
          lede={lab.lede}
        />

        <div className="lab__layout">
          <ul className="lab__principles" ref={principlesRef} data-reveal>
            {lab.principles.map((p) => (
              <li className="lab__principle" key={p.title}>
                <h3>{p.title}</h3>
                <p>{p.body}</p>
              </li>
            ))}
          </ul>

          <dl className="lab__stats" ref={statsRef} data-reveal>
            {lab.stats.map((s) => (
              <div className="lab__stat" key={s.label}>
                <dd>{s.value}</dd>
                <dt className="label">{s.label}</dt>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
