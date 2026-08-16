import { mount } from './mount';
import { Hero } from '../components/Hero';
import { Approach } from '../components/Approach';
import { Testimonials } from '../components/Testimonials';
import { SectionHead } from '../components/Shell';
import { AppCard } from '../components/AppCard';
import { apps, appsPage, home } from '../content/site';
import { url } from '../lib/url';

function AppsPreview() {
  return (
    <section className="section section--ruled" aria-labelledby="apps-preview-title">
      <div className="container">
        <SectionHead label={appsPage.label} headline={appsPage.headline} id="apps-preview-title" />
        <ul className="appgrid">
          {apps.map((app, i) => (
            <AppCard app={app} i={i} key={app.slug} />
          ))}
        </ul>
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
          <p className="label">
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
    <AppsPreview />
    <DemoCallout />
    <Testimonials />
  </>,
);
