import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { lab } from '../content/site';

export function Lab() {
  const principlesRef = useReveal<HTMLUListElement>();
  const statsRef = useReveal<HTMLDListElement>();
  const rolesRef = useReveal<HTMLDivElement>();

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

        {/* The one place on the page that addresses a person rather than
            describing a system. The brief asks the Lab section for a human
            element; a roster of invented faces would be the corporate answer
            and a dishonest one, so the human element is the address itself —
            what the lab is looking for, and what to send. */}
        <div className="lab__roles" ref={rolesRef} data-reveal>
          <div className="lab__roles-head">
            <p className="label">{lab.rolesLabel}</p>
            <p className="lab__roles-note">{lab.rolesNote}</p>
          </div>
          <ul>
            {lab.roles.map((r) => (
              <li className="lab__role" key={r.code}>
                <span className="lab__role-code mono">{r.code}</span>
                <h3 className="lab__role-title">{r.title}</h3>
                <p className="lab__role-note">{r.note}</p>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
