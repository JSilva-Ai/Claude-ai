import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { Blocks } from '../components/Prose';
import { dataDeletion as dd } from '../content/help';
import { site, ui } from '../content/site';

mount(
  <>
    <PageHead
      label={dd.title}
      title={dd.headline}
      lede={dd.lede}
      meta={<p className="mono pagehead__updated">{ui.lastUpdated}: {dd.updated}</p>}
    />
    <section className="section">
      <div className="container prose">
        <Blocks blocks={dd.intro} />

        <section className="prose__section">
          <h2 className="prose__h2">{dd.steps.heading}</h2>
          <ol className="steps">
            {dd.steps.items.map((s, i) => (
              <li className="steps__item" key={s.title}>
                <span className="mono steps__n">{String(i + 1).padStart(2, '0')}</span>
                <div>
                  <h3 className="steps__title">{s.title}</h3>
                  <p className={s.body.includes('[TODO') ? 'todo' : undefined}>{s.body}</p>
                </div>
              </li>
            ))}
          </ol>
          <p>
            <a className="btn btn--primary" href={`mailto:${site.email}?subject=Data%20deletion%20request`}>
              Email a deletion request
            </a>
          </p>
        </section>

        <section className="prose__section">
          <h2 className="prose__h2">{dd.inApp.heading}</h2>
          <Blocks blocks={dd.inApp.body} />
        </section>
        <section className="prose__section">
          <h2 className="prose__h2">{dd.whatHappens.heading}</h2>
          <Blocks blocks={dd.whatHappens.body} />
        </section>
        <section className="prose__section">
          <h2 className="prose__h2">{dd.storeNote.heading}</h2>
          <Blocks blocks={dd.storeNote.body} />
        </section>
      </div>
    </section>
  </>,
);
