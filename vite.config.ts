import { execSync } from 'node:child_process';
import { readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { privacy, terms } from './src/content/legal';
import { support, dataDeletion } from './src/content/help';

const root = fileURLToPath(new URL('.', import.meta.url));

/**
 * Every index.html in the project is a page.
 *
 * This is a multi-page build rather than a single-page app, which is a
 * deployment decision more than an architectural one: on a static host an SPA
 * serves unknown paths from the 404 document, and GitHub Pages returns it with
 * a real 404 status. /privacy, /terms, /support and /data-deletion are URLs
 * that Apple and Google reviewers open directly, so they have to be real files
 * answering 200.
 *
 * Discovered rather than listed so that adding a route is adding a directory,
 * and nobody has to remember to register it here as well.
 */
function findPages(dir: string, found: string[] = []): string[] {
  for (const name of readdirSync(dir)) {
    /*
     * Two directories hold index.html files that are not routes.
     *
     * `public/` is copied to the site root verbatim by Vite, so the game at
     * public/demo/void-striker/ already ships as /demo/void-striker/. Treating
     * it as a page as well built a second copy at /public/demo/void-striker/ —
     * a real, reachable URL serving a duplicate of the game, which nothing
     * links to and no one should find.
     *
     * `mobile/` is the native app: a separate npm project that packages the
     * game with Capacitor, holding the built web payload and the copy synced
     * into each native project. Three more index.html files, no routes.
     *
     * `loop/` is the LOOP app: a Flutter project, not part of this site at
     * all. Its `web/index.html` is Flutter's own host page, and left
     * discoverable here it would be built and published as the route /loop/ —
     * a page that cannot work, since Vite would not produce the Dart bundle
     * it loads.
     */
    if (
      name === 'node_modules' ||
      name === 'dist' ||
      name === 'public' ||
      name === 'mobile' ||
      name === 'loop' ||
      name.startsWith('.')
    )
      continue;
    const path = join(dir, name);
    if (statSync(path).isDirectory()) findPages(path, found);
    else if (name === 'index.html') found.push(path);
  }
  return found;
}

const input = Object.fromEntries(
  findPages(root).map((path) => {
    const key = relative(root, path).replace(/\/?index\.html$/, '') || 'index';
    return [key, path];
  }),
);

/**
 * Stamp the build into every page.
 *
 * Without this there is no way to tell which build a browser is actually
 * showing, which is not hypothetical: a cached copy of an older build was
 * mistaken for a broken deploy, and the only thing that settled it was
 * spotting a fixed typo still present in a screen recording.
 *
 * `View source` on any page now answers it in one line. GITHUB_SHA is set by
 * Actions; locally it falls back to the checked-out commit.
 */
function buildStamp() {
  let sha = process.env.GITHUB_SHA ?? '';
  if (!sha) {
    try {
      sha = execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim();
    } catch {
      sha = 'unknown';
    }
  }
  const built = new Date().toISOString();
  return {
    name: 'build-stamp',
    transformIndexHtml() {
      return [
        { tag: 'meta', attrs: { name: 'build-sha', content: sha.slice(0, 12) }, injectTo: 'head' as const },
        { tag: 'meta', attrs: { name: 'build-time', content: built }, injectTo: 'head' as const },
      ];
    },
  };
}

/**
 * Put the legal text in the HTML, for readers that do not run JavaScript.
 *
 * /privacy, /terms, /support and /data-deletion are real files answering 200 —
 * that was the reason for a multi-page build. But the *text* was rendered by
 * React on the client, so `curl` on any of the four returned a document with
 * exactly zero characters of body text. A reviewer opening it in Safari sees
 * the policy; Google Play's automated check on the privacy policy URL does not
 * run scripts, and an empty policy page is a documented rejection.
 *
 * <noscript> is the right tool: a browser with JavaScript never renders it, so
 * real visitors are unaffected and there is nothing to keep in sync visually,
 * while anything fetching the URL without a script engine gets the full text.
 *
 * Pre-rendering the React tree would be better still — one source of truth
 * rather than two renderings of it — but it needs the components to survive
 * SSR, and this closes the compliance hole today.
 */
function legalNoscript() {
  const docs: Record<string, unknown> = {
    privacy,
    terms,
    support,
    'data-deletion': dataDeletion,
  };

  const esc = (s: string) =>
    s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  /** Walk the content object in key order, which is document order. */
  const render = (node: unknown, depth = 0): string => {
    if (typeof node === 'string') return node.trim() ? `<p>${esc(node)}</p>` : '';
    if (Array.isArray(node)) {
      // A nested array of strings is a list in the page; a list of blocks is not.
      if (node.every((n) => typeof n === 'string')) {
        return `<ul>${node.map((n) => `<li>${esc(n as string)}</li>`).join('')}</ul>`;
      }
      return node.map((n) => render(n, depth)).join('');
    }
    if (node && typeof node === 'object') {
      return Object.entries(node as Record<string, unknown>)
        .map(([key, value]) => {
          if (key === 'title' && typeof value === 'string') return `<h1>${esc(value)}</h1>`;
          if (key === 'heading' && typeof value === 'string') return `<h2>${esc(value)}</h2>`;
          return render(value, depth + 1);
        })
        .join('');
    }
    return '';
  };

  return {
    name: 'legal-noscript',
    transformIndexHtml(_html: string, ctx: { filename: string }) {
      const key = Object.keys(docs).find((k) =>
        ctx.filename.replace(/\\/g, '/').includes(`/${k}/index.html`),
      );
      if (!key) return;
      return [
        {
          tag: 'noscript',
          children: render(docs[key]),
          injectTo: 'body' as const,
        },
      ];
    },
  };
}

export default defineConfig({
  /**
   * `base` is configurable because the same build has to serve from a domain
   * root and from a subpath (a GitHub Pages project site lives at /<repo>/).
   * Set BASE_PATH at build time; it must carry a trailing slash.
   */
  base: process.env.BASE_PATH ?? '/',
  plugins: [react(), buildStamp(), legalNoscript()],
  build: {
    rollupOptions: { input },
    // Small assets inline; anything larger stays a request the browser can
    // cache separately from the JS it would otherwise be parsed with.
    assetsInlineLimit: 2048,
  },
});
