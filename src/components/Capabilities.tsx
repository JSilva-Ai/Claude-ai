import { SectionHead } from './SectionHead';
import { useReveal } from '../lib/hooks';
import { capabilities, capabilityLoop } from '../content/site';

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

/**
 * The section headline claims one loop; without this it is only a claim. Runs
 * full-bleed, which is the one place on the page the container is broken — the
 * loop is the thing the four columns above are part of, so it is drawn wider
 * than they are.
 */
function CapabilityLoop() {
  const ref = useReveal<HTMLDivElement>();
  return (
    <div className="loop" ref={ref} data-reveal>
      <p className="label loop__label">{capabilityLoop.label}</p>
      <ol className="loop__rail">
        {capabilityLoop.stations.map((s) => (
          <li className="loop__station" key={s.code}>
            <span className="loop__tick" aria-hidden="true" />
            <span className="loop__code mono">{s.code}</span>
            <span className="loop__hands">{s.hands}</span>
          </li>
        ))}
      </ol>
      <p className="loop__return">
        <span className="loop__return-arrow" aria-hidden="true" />
        {capabilityLoop.returnLabel}
      </p>
    </div>
  );
}

export function Capabilities() {
  return (
    <section className="section section--ruled" id="capabilities" aria-labelledby="cap-title">
      <div className="container">
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

        <CapabilityLoop />
      </div>
    </section>
  );
}
