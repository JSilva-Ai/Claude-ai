import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import type { ReactNode } from 'react';
import { Shell } from '../components/Shell';
import '../index.css';

/**
 * Every page entry ends in a call to this.
 *
 * The site is a multi-page build: each route is its own HTML document with its
 * own <title>, description, and canonical, and its own tiny entry module.
 * There is no router, and no 404-rewrite trick standing in for one.
 *
 * That choice is load-bearing rather than stylistic. On a static host, a
 * single-page app serves every unknown path as the 404 document — GitHub Pages
 * returns it with an actual 404 status. The privacy policy, the terms, and the
 * data-deletion instructions are URLs that Apple and Google reviewers open
 * directly, and a legal page that answers 404 is a rejected listing. Real files
 * answer 200.
 */
export function mount(children: ReactNode) {
  const el = document.getElementById('root');
  if (!el) throw new Error('No #root element on the page');
  createRoot(el).render(
    <StrictMode>
      <Shell>{children}</Shell>
    </StrictMode>,
  );
}
