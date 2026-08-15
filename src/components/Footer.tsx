import { Logo } from './Logo';
import { footer, site } from '../content/site';
import { url } from '../lib/url';

/**
 * Footer.
 *
 * The legal and support links live here and only here. Both stores expect a
 * privacy policy and a support contact to be reachable from any page of the
 * site, and a footer is the one place a reviewer will always look.
 */
export function Footer() {
  return (
    <footer className="footer">
      <div className="container footer__inner">
        <div className="footer__brand">
          <Logo size={30} />
          <p className="footer__blurb">{footer.blurb}</p>
          <a className="footer__email" href={`mailto:${site.email}`}>
            {site.email}
          </a>
        </div>

        <div className="footer__cols">
          {footer.columns.map((col) => (
            <div className="footer__col" key={col.title}>
              <h2 className="label footer__col-title">{col.title}</h2>
              <ul className="footer__list">
                {col.links.map((link) => (
                  <li key={link.route}>
                    <a href={url(link.route)}>{link.label}</a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>

      <div className="container footer__base">
        <p className="mono footer__copy">
          © {new Date().getFullYear()} {footer.copyright}
        </p>
        <p className="mono footer__domain">{site.domain}</p>
      </div>
    </footer>
  );
}
