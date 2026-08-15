import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { applications } from '../content/site';

function App({ item, i }: { item: (typeof applications.items)[number]; i: number }) {
  const ref = useReveal<HTMLLIElement>();
  return (
    <li
      className="app ticks"
      ref={ref}
      data-reveal
      style={{ '--reveal-delay': `${(i % 2) * 80}ms` } as React.CSSProperties}
    >
      <p className="app__sector">
        <span className="label app__no">{String(i + 1).padStart(2, '0')}</span>
        <span className="label">{item.sector}</span>
      </p>
      <h3 className="app__claim">{item.claim}</h3>
      <p className="app__detail">{item.detail}</p>
    </li>
  );
}

export function Applications() {
  return (
    <section className="section section--ruled" id="applications" aria-labelledby="apps-title">
      <div className="container">
        <SectionHead
          index={applications.index}
          label={applications.label}
          headline={<span id="apps-title">{applications.headline}</span>}
          lede={applications.lede}
        />
        <ul className="apps">
          {applications.items.map((item, i) => (
            <App item={item} i={i} key={item.sector} />
          ))}
        </ul>
      </div>
    </section>
  );
}
