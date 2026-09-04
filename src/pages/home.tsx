import { mount } from './mount';
import { Hero } from '../components/Hero';
import { Approach } from '../components/Approach';
import { Testimonials } from '../components/Testimonials';
import { SectionHead } from '../components/Shell';
import { AppCard } from '../components/AppCard';
import { home, portfolio } from '../content/site';
import { url } from '../lib/url';

/**
 * The portfolio, on the home page.
 *
 * The whole point of this section is that a visitor who never clicks anything
 * still leaves knowing this is a studio with several products at several
 * stages. So it shows all of them, in the same two groups as /apps, rather
 * than a teaser of two with a link to the rest.
 *
 * The group headings are h3 under this section's h2, which puts the cards at
 * h4 — one level deeper than on /apps, where the groups sit directly under the
 * page h1. AppCard takes the level rather than fixing it, because a skipped
 * heading level is an axe violation and a real problem for anyone navigating
 * by headings.
 */
function Portfolio() {
  const p = home.portfolio;
  return (
    <section className="section section--ruled" aria-labelledby="portfolio-title">
      <div className="container">
        <SectionHead
          index={p.index}
          label={p.label}
          headline={p.headline}
          lede={p.body}
          id="portfolio-title"
        />
        {portfolio.map((group) => (
          <div className="portfolio-group" key={group.id}>
            <h3 className="head__title head__title--sm" id={`home-group-${group.id}`}>
              {group.label}
            </h3>
            <ul className="appgrid" aria-labelledby={`home-group-${group.id}`}>
              {group.items.map((app, i) => (
                <AppCard app={app} i={i} key={app.slug} />
              ))}
            </ul>
          </div>
        ))}
        <p className="portfolio__more">
          <a className="btn btn--sm" href={url(p.cta.route)}>
            {p.cta.label}
            <span className="btn__arrow" aria-hidden="true">↗</span>
          </a>
        </p>
      </div>
    </section>
  );
}

function DemoCallout() {
  const c = home.demoCallout;
  return (
    <section className="section demo-callout" aria-labelledby="demo-callout-title">
      <div className="container demo-callout__inner">
        <div>
          {/* head__label, not label: the index and the word are a flex row with
              a gap. A bare .label renders them touching — "02PLAYABLE". */}
          <p className="label head__label">
            <span className="head__index mono">{c.index}</span>
            {c.label}
          </p>
          <h2 className="head__title" id="demo-callout-title">{c.headline}</h2>
          <p className="head__lede">{c.body}</p>
        </div>
        <a className="btn btn--primary" href={url(c.cta.route)}>
          {c.cta.label}
          <span className="btn__arrow" aria-hidden="true">↗</span>
        </a>
      </div>
    </section>
  );
}

mount(
  <>
    <Hero />
    <Approach />
    <Portfolio />
    <DemoCallout />
    <Testimonials />
  </>,
);
