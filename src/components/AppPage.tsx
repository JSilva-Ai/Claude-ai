import { PageHead } from './Shell';
import { StoreBadge } from './StoreBadge';
import { apps, appsPage, routes, site, ui } from '../content/site';
import { asset, url } from '../lib/url';
import { GameClip } from './GameClip';
import { statusModifier } from '../lib/status';

/**
 * The per-app page template.
 *
 * Every app gets the same page: what it is, what it looks like, where to get
 * it, and — required by both stores — a route to its privacy terms and to
 * support. Those two links are not optional furniture; a listing is rejected
 * without them, and a reviewer follows them.
 */
export function AppPage({ slug }: { slug: string }) {
  const app = apps.find((a) => a.slug === slug);

  if (!app) {
    return (
      <PageHead
        title="App not found"
        lede="This page is generated from src/content/site.ts and no app matches this slug."
      />
    );
  }

  return (
    <>
      <PageHead
        label={<a href={url(routes.apps)}>{ui.backToApps}</a>}
        title={app.name}
        /* The product's own line where it has one — that sentence is the whole
           idea in eight words, and it earns the lede slot over a description of
           what stage the thing is at. */
        lede={app.positioning ?? app.tagline}
      />

      <section className="section section--ruled">
        <div className="container app">
          <div className="app__body">
            <p className={`pill pill--${statusModifier(app.status)}`}>{app.status}</p>
            {app.positioning && <p className="app__tagline">{app.tagline}</p>}
            {app.description.map((p) => (
              <p className={p.includes('[TODO') ? 'todo' : 'app__para'} key={p.slice(0, 24)}>
                {p}
              </p>
            ))}

            {app.demoRoute && (
              <p className="app__para">
                <a className="btn btn--primary" href={url(app.demoRoute)}>
                  Play the demo
                  <span className="btn__arrow" aria-hidden="true">↗</span>
                </a>
              </p>
            )}
          </div>

          <aside className="app__side">
            {/* The "Get it" block appears only once a store is the actual plan.
                A research-stage concept has no stores array, and printing two
                greyed-out badges under it would suggest a submission that is
                years away from being made. */}
            {app.stores.length > 0 && (
              <>
                <h2 className="label">Get it</h2>
                {app.status !== 'On the stores' && (
                  <p className="app__note">{appsPage.inDevelopmentNote}</p>
                )}
                <div className="app__badges">
                  {app.stores.map((s) => (
                    <StoreBadge key={s.store} link={s} />
                  ))}
                </div>
              </>
            )}

            <h2 className={`label${app.stores.length > 0 ? ' app__side-h' : ''}`}>
              {ui.kindLabel}
            </h2>
            <p className="mono app__platforms">{app.kind}</p>

            {app.platforms && (
              <>
                <h2 className="label app__side-h">Platforms</h2>
                <p className="mono app__platforms">{app.platforms.join(' · ')}</p>
              </>
            )}

            {/* Required by both stores, per app. */}
            <h2 className="label app__side-h">Legal &amp; support</h2>
            <ul className="app__links">
              <li>
                <a href={url(routes.privacy)}>Privacy Policy</a>
              </li>
              <li>
                <a href={url(routes.terms)}>Terms of Use</a>
              </li>
              <li>
                <a href={url(routes.support)}>Support</a>
              </li>
              <li>
                <a href={url(routes.dataDeletion)}>Data deletion</a>
              </li>
              <li>
                <a href={`mailto:${site.email}`}>{site.email}</a>
              </li>
            </ul>
          </aside>
        </div>
      </section>

      <section className="section" aria-labelledby="shots-title">
        <div className="container">
          <h2 className="head__title head__title--sm" id="shots-title">
            {app.clip ? ui.gameplayLabel : ui.screenshotsLabel}
          </h2>

          <div className="gameplay">
            {app.clip && <GameClip clip={app.clip} alt={`${app.name} gameplay`} />}
          </div>

          {app.screenshots.length === 0 ? (
            !app.clip && <p className="app__empty">{ui.noScreenshots}</p>
          ) : (
            <ul className="shots">
              {app.screenshots.map((s) => (
                <li className="shots__item" key={s.src}>
                  <img
                    src={asset(s.src)}
                    alt={s.alt}
                    width={s.width}
                    height={s.height}
                    loading="lazy"
                    decoding="async"
                  />
                </li>
              ))}
            </ul>
          )}
        </div>
      </section>
    </>
  );
}
