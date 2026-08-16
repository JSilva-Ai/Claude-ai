import { SectionHead } from './Shell';
import { useReveal } from '../lib/hooks';
import { home } from '../content/site';

export function Approach() {
  return (
    <section className="section section--ruled" id="approach" aria-labelledby="approach-title">
      <div className="container">
        <SectionHead
          index={home.approach.index}
          label={home.approach.label}
          headline={home.approach.headline}
          id="approach-title"
        />

        <div className="approach">
          <div className="approach__body">
            {home.approach.body.map((p) => (
              <p key={p.slice(0, 24)}>{p}</p>
            ))}
          </div>

          <ul className="approach__points">
            {home.approach.points.map((point, i) => (
              <Point key={point.title} title={point.title} body={point.body} i={i} />
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}

function Point({ title, body, i }: { title: string; body: string; i: number }) {
  const ref = useReveal<HTMLLIElement>();
  return (
    <li
      className="approach__point"
      ref={ref}
      data-reveal
      style={{ '--reveal-delay': `${i * 70}ms` } as React.CSSProperties}
    >
      <h3 className="approach__point-title">{title}</h3>
      <p className="approach__point-body">{body}</p>
    </li>
  );
}
