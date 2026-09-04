import { mount } from './mount';
import { PageHead, SectionHead } from '../components/Shell';
import { AppCard } from '../components/AppCard';
import { appsPage, portfolio } from '../content/en/site';

/**
 * The portfolio, in two groups.
 *
 * Applications and games are read differently — one is judged on what it does
 * for you, the other on whether it looks worth an evening — so they are shown
 * apart rather than mixed into one grid the visitor has to sort mentally.
 */
mount(
  <>
    <PageHead label={appsPage.label} title={appsPage.headline} lede={appsPage.lede} />
    <section className="section section--ruled">
      <div className="container">
        {portfolio.map((group) => (
          <div className="portfolio-group" key={group.id}>
            <SectionHead
              label={group.label}
              headline={group.headline}
              id={`group-${group.id}`}
            />
            <ul className="appgrid" aria-labelledby={`group-${group.id}`}>
              {group.items.map((app, i) => (
                <AppCard app={app} i={i} headingLevel={3} key={app.slug} />
              ))}
            </ul>
          </div>
        ))}
      </div>
    </section>
  </>,
);
