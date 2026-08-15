import { Logo } from './Logo';
import { footer } from '../content/site';

export function Footer() {
  return (
    <footer className="footer">
      <div className="container">
        <div className="footer__top">
          <div className="footer__brand">
            <Logo />
            <p className="footer__blurb">{footer.blurb}</p>
          </div>

          <div className="footer__cols">
            {footer.columns.map((col) => (
              <nav className="footer__col" key={col.title} aria-label={col.title}>
                <h3 className="label">{col.title}</h3>
                <ul>
                  {col.links.map((l) => (
                    <li key={l.label}>
                      <a href={l.href}>{l.label}</a>
                    </li>
                  ))}
                </ul>
              </nav>
            ))}
          </div>
        </div>

        <div className="footer__bottom">
          <p className="label">
            © {new Date().getFullYear()} New AI Vision Labs
          </p>
          <p className="label">{footer.location}</p>
        </div>
      </div>
    </footer>
  );
}
