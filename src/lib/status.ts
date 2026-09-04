import type { Status } from '../content/en/site';

/**
 * The status pill's modifier class.
 *
 * Here rather than beside the card because two components need it — the card
 * and the product page — and because a module that exports both a component
 * and a helper defeats fast refresh.
 *
 * Which of four treatments a stage gets is a presentation decision, so the
 * content module does not carry it: `site.ts` should not have to know that
 * pills have colours at all.
 */
export function statusModifier(status: Status): string {
  switch (status) {
    case 'Product discovery':
      return 'research';
    case 'In development':
      return 'dev';
    case 'Final testing':
      return 'testing';
    case 'On the stores':
      return 'live';
  }
}
