import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { DemoFrame } from '../components/DemoFrame';
import { demo } from '../content/site';

mount(
  <>
    <PageHead label={demo.label} title={demo.headline} lede={demo.lede} />
    <section className="section section--tight">
      <div className="container demo">
        <DemoFrame />
        <div className="demo__controls">
          <h2 className="label">Controls</h2>
          <dl className="controls">
            {demo.controls.map((c) => (
              <div className="controls__row" key={c.action}>
                <dt className="mono controls__keys">{c.keys}</dt>
                <dd className="controls__action">{c.action}</dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  </>,
);
