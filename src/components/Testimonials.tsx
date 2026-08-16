import { testimonials } from '../content/site';

/**
 * Reviews.
 *
 * Built, switched off, and empty — by instruction and by principle. It returns
 * null while `testimonials.enabled` is false, so nothing renders, nothing is
 * announced to a screen reader, and no empty heading is left behind in the
 * document outline.
 *
 * Turning it on is a one-line change in src/content/site.ts. The only thing
 * that belongs in `items` is a review a real person actually wrote — the App
 * Store and Google Play listings are the intended source. Do not write filler
 * here to see how it looks; a fabricated review is a false statement about a
 * customer, and it survives far longer than the afternoon it was convenient.
 *
 * The guard is deliberately belt-and-braces: even if `enabled` were flipped by
 * accident, an empty `items` array still renders nothing.
 */
export function Testimonials() {
  if (!testimonials.enabled || testimonials.items.length === 0) return null;

  return (
    <section className="section section--ruled" aria-labelledby="reviews-title">
      <div className="container">
        <p className="label">{testimonials.label}</p>
        <h2 className="head__title" id="reviews-title">
          {testimonials.headline}
        </h2>
        <ul className="reviews">
          {testimonials.items.map((t) => (
            <li className="review" key={t.quote.slice(0, 32)}>
              <blockquote className="review__quote">{t.quote}</blockquote>
              <p className="review__by">
                <span className="review__author">{t.author}</span>
                <span className="mono review__source">{t.source}</span>
              </p>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
