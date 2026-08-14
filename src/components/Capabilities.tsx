import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { capabilities } from '../content/site';

function Capability({ item, i }: { item: (typeof capabilities.items)[number]; i: number }) {
  const ref = useReveal<HTMLLIElement>();
  return (
    <li
      className="cap ticks"
      ref={ref}
      data-reveal
      style={{ '--reveal-delay': `${i * 70}ms` } as React.CSSProperties}
    >
      <span className="cap__code" aria-hidden="true">
        {item.code}
      </span>
      <h3 className="cap__title">{item.title}</h3>
      <p className="cap__summary">{item.summary}</p>
      <ul className="cap__points">
        {item.points.map((p) => (
          <li key={p}>{p}</li>
        ))}
      </ul>
    </li>
  );
}

export function Capabilities() {
  return (
    <section className="section section--ruled" id="capabilities" aria-labelledby="cap-title">
      <div className="container container--wide">
        <SectionHead
          index={capabilities.index}
          label={capabilities.label}
          headline={<span id="cap-title">{capabilities.headline}</span>}
          lede={capabilities.lede}
        />
        <ul className="caps">
          {capabilities.items.map((item, i) => (
            <Capability item={item} i={i} key={item.code} />
          ))}
        </ul>
      </div>
    </section>
  );
}
