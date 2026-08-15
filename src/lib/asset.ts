/**
 * Resolve a public-directory path against the deployed base.
 *
 * Vite rewrites asset URLs it can see — those in `index.html` and in `url()`
 * inside CSS — but URLs built at runtime in JS are invisible to it. Those are
 * the environment posters and clips, and hardcoding them to `/media/...`
 * breaks the moment the site is served from a subpath, which is exactly what
 * GitHub Pages does for a project site.
 */
export function asset(path: string): string {
  // BASE_URL always carries a trailing slash; the argument never leads with one.
  return import.meta.env.BASE_URL + path.replace(/^\/+/, '');
}
