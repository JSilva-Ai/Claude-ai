import { mount } from './mount';
import { PageHead } from '../components/Shell';
import { AppCard } from '../components/AppCard';
import { apps, appsPage } from '../content/site';

mount(
  <>
    <PageHead label={appsPage.label} title={appsPage.headline} lede={appsPage.lede} />
    <section className="section section--ruled">
      <div className="container">
        <ul className="appgrid">
          {apps.map((app, i) => (
            <AppCard app={app} i={i} headingLevel={2} key={app.slug} />
          ))}
        </ul>
      </div>
    </section>
  </>,
);
