import { SectionHead } from './SectionHead';
import { ResolvedField } from './ResolvedField';
import { useReveal } from '../lib/hooks';
import { contact, ui } from '../content/site';

export function Contact() {
  const ref = useReveal<HTMLUListElement>();
  const closeRef = useReveal<HTMLDivElement>();
  const [before, after] = contact.headline.split(contact.accentWord);

  return (
    <section
      className="section section--ruled contact"
      id="contact"
      aria-labelledby="contact-title"
    >
      <ResolvedField />
      <div className="container">
        <SectionHead
          index={contact.index}
          label={contact.label}
          split={false}
          headline={
            <span id="contact-title" className="contact__headline">
              {before}
              <span className="accent">{contact.accentWord}</span>
              {after}
            </span>
          }
          lede={contact.lede}
        />

        <ul className="contact__channels" ref={ref} data-reveal>
          {contact.channels.map((c) => (
            <li className="channel" key={c.kind}>
              <h3 className="channel__kind">{c.kind}</h3>
              <p className="channel__detail">{c.detail}</p>
              <a className="link channel__action" href={`mailto:${c.action}`}>
                {c.action}
                <svg width="12" height="12" viewBox="0 0 14 14" fill="none" aria-hidden="true">
                  <path
                    d="M3 11L11 3M11 3H5M11 3V9"
                    stroke="currentColor"
                    strokeWidth="1.6"
                    strokeLinecap="square"
                  />
                </svg>
              </a>
            </li>
          ))}
        </ul>

        <div className="contact__close" ref={closeRef} data-reveal>
          <p className="contact__close-line">{ui.closingLine}</p>
          <a className="btn btn--primary" href={`mailto:${contact.channels[0].action}`}>
            <span className="btn__label">{ui.closingCta}</span>
            <span className="btn__arrow" aria-hidden="true">
              <svg width="12" height="12" viewBox="0 0 14 14" fill="none">
                <path
                  d="M3 11L11 3M11 3H5M11 3V9"
                  stroke="currentColor"
                  strokeWidth="1.6"
                  strokeLinecap="square"
                />
              </svg>
            </span>
          </a>
        </div>
      </div>
    </section>
  );
}
