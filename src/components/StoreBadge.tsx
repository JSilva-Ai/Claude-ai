import type { StoreLink } from '../content/en/site';
import { appsPage } from '../content/en/site';

const LABEL: Record<StoreLink['store'], string> = {
  appStore: 'App Store',
  googlePlay: 'Google Play',
};

/**
 * A store link.
 *
 * These are deliberately *not* imitations of Apple's "Download on the App
 * Store" or Google's "Get it on Google Play" badges. Both are trademarked
 * artwork with published rules about size, clear space, and alteration, and a
 * hand-drawn lookalike breaks those rules while also looking slightly wrong
 * next to the real thing.
 *
 * [TODO] When an app is published, download the official badge for each store
 * from Apple's Marketing Resources and Google Play's Brand Guidelines, drop
 * the SVGs into public/brand/, and swap the markup below for an <img>. The
 * slot is already the right shape and the layout will not move.
 *
 * Until a store href exists, the badge renders as a disabled, non-focusable
 * marker rather than a dead link.
 */
export function StoreBadge({ link }: { link: StoreLink }) {
  const label = LABEL[link.store];

  if (!link.href) {
    return (
      <span className="badge badge--pending" aria-disabled="true">
        <span className="badge__store">{label}</span>
        <span className="badge__note">{appsPage.notYetOnStores}</span>
      </span>
    );
  }

  return (
    <a className="badge" href={link.href} rel="noopener">
      <span className="badge__store">{label}</span>
      <span className="badge__note">Download</span>
    </a>
  );
}
