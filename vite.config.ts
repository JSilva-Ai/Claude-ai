import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

/**
 * `base` is configurable because the same build has to serve from a domain
 * root (a custom domain, Netlify, Vercel) and from a subpath (a GitHub Pages
 * project site is served at /<repo>/). Set BASE_PATH at build time; it must
 * carry a trailing slash.
 */
export default defineConfig({
  base: process.env.BASE_PATH ?? '/',
  plugins: [react()],
  build: {
    // The clips are already compressed; inlining anything at this size would
    // only bloat the JS the browser has to parse before first paint.
    assetsInlineLimit: 2048,
  },
});
