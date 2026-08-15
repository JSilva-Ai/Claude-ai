import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { research } from '../content/site';

function Item({ item }: { item: (typeof research.items)[number] }) {
  const ref = useReveal<HTMLLIElement>();
  return (
    <li className="research__item" ref={ref} data-reveal>
      <div className="research__meta">
        <span className="research__status" data-status={item.status}>
          <span className="dot" aria-hidden="true" />
          {item.status}
        </span>
      </div>
      <h3 className="research__title">{item.title}</h3>
      <div>
        <p className="research__abstract">{item.abstract}</p>
        <ul className="research__tags">
          {item.tags.map((t) => (
            <li key={t}>
              <span className="tag">{t}</span>
            </li>
          ))}
        </ul>
      </div>
    </li>
  );
}

export function Research() {
  return (
    <section className="section section--ruled" id="research" aria-labelledby="research-title">
      <div className="container">
        <SectionHead
          index={research.index}
          label={research.label}
          headline={<span id="research-title">{research.headline}</span>}
          lede={research.lede}
        />
        <ul className="research__list">
          {research.items.map((item) => (
            <Item item={item} key={item.title} />
          ))}
        </ul>
      </div>
    </section>
  );
}
