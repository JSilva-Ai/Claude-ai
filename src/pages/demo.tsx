import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { GameClip } from '../components/GameClip';
import { demo } from '../content/en/site';
import { asset, url } from '../lib/url';

mount(
  <>
    <PageHead label={demo.label} title={demo.headline} lede={demo.lede} />
    <section className="section section--tight">
      <div className="container demo">
        {demo.clip ? (
          <GameClip clip={demo.clip} alt={demo.clipAlt} eager />
        ) : (
          <div className="demo__placeholder">
            <p className="demo__placeholder-title">{demo.unconfigured.title}</p>
            <p className="demo__placeholder-body">{demo.unconfigured.body}</p>
          </div>
        )}

        <div className="demo__side">
          <p className="demo__note">{demo.note}</p>

          <dl className="facts">
            {demo.facts.map((f) => (
              <div className="facts__row" key={f.label}>
                <dt className="label">{f.label}</dt>
                <dd className="mono facts__value">{f.value}</dd>
              </div>
            ))}
          </dl>

          <div className="demo__actions">
            {demo.playable && (
              <a className="btn" href={asset(demo.playable.href)} target="_blank" rel="noopener">
                {demo.playable.label}
                <span className="btn__arrow" aria-hidden="true">↗</span>
              </a>
            )}
            <a className="btn btn--primary" href={url(`apps/void-striker`)}>
              About the game
              <span className="btn__arrow" aria-hidden="true">↗</span>
            </a>
          </div>
        </div>
      </div>
    </section>
  </>,
);
