import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { Blocks, Sections } from '../components/Prose';
import { support } from '../content/help';
import { site } from '../content/site';

mount(
  <>
    <PageHead label={support.title} title={support.headline} lede={support.lede} />

    {/* The email is the reason this page exists and is required to be
        obvious — it gets its own panel above everything else, not a line
        inside a paragraph. */}
    <section className="section section--tight">
      <div className="container">
        <div className="mailcard">
          <p className="label mailcard__label">{support.emailLabel}</p>
          <a className="mailcard__address" href={`mailto:${support.email}`}>
            {support.email}
          </a>
          <p className="label mailcard__label mailcard__label--2">{support.phoneLabel}</p>
          <a className="mailcard__phone" href={`tel:${site.phoneHref}`}>
            {site.phone}
          </a>
          <p className="mailcard__place">{site.location}</p>
          <p className="todo mailcard__note">{support.responseNote}</p>
        </div>
      </div>
    </section>

    <section className="section">
      <div className="container prose">
        <section className="prose__section">
          <h2 className="prose__h2">{support.helpful.heading}</h2>
          <Blocks blocks={support.helpful.body} />
        </section>
        <Sections sections={support.sections} />
      </div>
    </section>
  </>,
);
