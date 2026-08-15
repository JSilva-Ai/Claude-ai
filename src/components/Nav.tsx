import { useEffect, useMemo, useState } from 'react';
import { Logo } from './Logo';
import { useActiveSection, useMediaQuery, useScrollY } from '../lib/hooks';
import { nav, ui } from '../content/site';
import './nav.css';

export function Nav() {
  const scrollY = useScrollY();
  const [open, setOpen] = useState(false);
  const ids = useMemo(() => nav.map((n) => n.id), []);
  const active = useActiveSection(ids);
  // The lockup is proportional to its mark, so one number sets the whole thing.
  const compact = useMediaQuery('(max-width: 30rem)');
  const condensed = scrollY > 24;

  // Lock the page behind the mobile sheet, and let Escape close it.
  useEffect(() => {
    document.body.dataset.scrollLocked = String(open);
    if (!open) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setOpen(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open]);

  // Close the sheet if the viewport grows past the breakpoint while it is open.
  useEffect(() => {
    const mq = window.matchMedia('(min-width: 64rem)');
    const on = () => mq.matches && setOpen(false);
    mq.addEventListener('change', on);
    return () => mq.removeEventListener('change', on);
  }, []);

  return (
    <>
      <a className="skip-link" href="#main">
        {ui.skipToContent}
      </a>

      <nav className="nav" data-condensed={condensed} aria-label="Primary">
        <div className="container nav__inner">
          <a className="nav__logo" href="#top" aria-label="New AI Vision Labs — home">
            <Logo size={compact ? 21 : 26} live />
          </a>

          <ul className="nav__links">
            {nav.map((item) => (
              <li key={item.id}>
                <a
                  className="nav__link"
                  href={`#${item.id}`}
                  data-active={active === item.id}
                  aria-current={active === item.id ? 'true' : undefined}
                >
                  <span className="nav__link-text">{item.label}</span>
                </a>
              </li>
            ))}
          </ul>

          <div className="nav__actions">
            <a className="btn btn--ghost btn--sm nav__cta" href="#contact">
              <span className="btn__label">{ui.navContact}</span>
            </a>
            <button
              className="nav__toggle"
              type="button"
              onClick={() => setOpen((v) => !v)}
              aria-expanded={open}
              aria-controls="nav-sheet"
            >
              <span className="visually-hidden">{open ? 'Close menu' : 'Open menu'}</span>
              <span className="nav__toggle-bars" data-open={open} aria-hidden="true">
                <span />
                <span />
              </span>
            </button>
          </div>
        </div>
        <div className="nav__rule" aria-hidden="true" />
      </nav>

      {/* Mobile sheet. Rendered always so it can transition, hidden from AT
          and from tab order when closed. */}
      <div className="sheet" id="nav-sheet" data-open={open} inert={!open || undefined}>
        <ul className="sheet__links">
          {nav.map((item, i) => (
            <li key={item.id} style={{ '--i': i } as React.CSSProperties}>
              <a className="sheet__link" href={`#${item.id}`} onClick={() => setOpen(false)}>
                <span className="mono sheet__index">
                  {String(i + 1).padStart(2, '0')}
                </span>
                {item.label}
              </a>
            </li>
          ))}
        </ul>
        <div className="sheet__foot" style={{ '--i': nav.length } as React.CSSProperties}>
          <a className="btn btn--primary" href="#contact" onClick={() => setOpen(false)}>
            <span className="btn__label">{ui.sheetCta}</span>
          </a>
        </div>
      </div>
    </>
  );
}
