import { execSync } from 'node:child_process';
import { readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

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
    if (name === 'node_modules' || name === 'dist' || name.startsWith('.')) continue;
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

export default defineConfig({
  /**
   * `base` is configurable because the same build has to serve from a domain
   * root and from a subpath (a GitHub Pages project site lives at /<repo>/).
   * Set BASE_PATH at build time; it must carry a trailing slash.
   */
  base: process.env.BASE_PATH ?? '/',
  plugins: [react(), buildStamp()],
  build: {
    rollupOptions: { input },
    // Small assets inline; anything larger stays a request the browser can
    // cache separately from the JS it would otherwise be parsed with.
    assetsInlineLimit: 2048,
  },
});
