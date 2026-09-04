/**
 * The checks, exactly as CI runs them.
 *
 *   npm run ci
 *
 * One command, one definition. This script *is* what .github/workflows/checks.yml
 * runs, rather than a local approximation of it — which is the only arrangement
 * where "it passed locally" and "it passed CI" mean the same thing.
 *
 * That is not a hypothetical tidiness. The head refactor shipped a 404 on every
 * page under a subpath and CI caught it on the merge, because CI builds at
 * BASE_PATH=/Claude-ai/ and every local run had been at "/". The workflow even
 * said why in a comment. Reading a comment is not a mechanism; running the same
 * script is.
 *
 * A second trap is closed here too. Reproducing that failure by hand the first
 * time, BASE_PATH was set on the build but not on `vite preview` — so the server
 * came up at "/", every subpath request fell through to the SPA fallback, and
 * the home page's chunks 404'd. It looks exactly like the real bug and is not
 * it. Here the base is computed once and passed to both.
 *
 * Flags:
 *   --base=/          build and serve at a different base (default /Claude-ai/,
 *                     which is what a GitHub Pages project site deploys to)
 *   --skip-build      reuse the dist already on disk
 *   --only=a11y|qa    run one suite
 *   --port=4173
 */

import { spawn, spawnSync } from 'node:child_process';
import { readdirSync, readFileSync, statSync, existsSync } from 'node:fs';
import { join, relative } from 'node:path';

const args = Object.fromEntries(
  process.argv.slice(2).map((a) => {
    const [k, v] = a.replace(/^--/, '').split('=');
    return [k, v ?? true];
  }),
);

/**
 * The base CI deploys and tests at.
 *
 * `/Claude-ai/` rather than `/` on purpose: the production deploy builds at the
 * domain root because public/CNAME is present, so testing at "/" would leave
 * every base-relative URL — which is all of them, since links go through
 * lib/url.ts — untested in the harder of the two configurations.
 */
const BASE = String(args.base ?? '/Claude-ai/');
const PORT = Number(args.port ?? 4173);
const ORIGIN = `http://127.0.0.1:${PORT}`;
const URL = ORIGIN + BASE;

const only = args.only ? String(args.only) : null;
const run = (name) => !only || only === name;

/**
 * Every site page, read from the build that is about to be served.
 *
 * Derived rather than listed, and derived from `dist` rather than from the
 * route table, because what shipped is the only thing worth testing. The list
 * written out by hand in the workflow silently stopped covering five product
 * pages the day they were added — the accessibility step went on checking the
 * eight routes that existed when someone typed them. A list read off the build
 * cannot fall behind it.
 *
 * `dist` holds one document that is not a site page: the playable game, copied
 * verbatim out of public/ and mounting nothing. A page is a document this app
 * mounts into, so that is the test — it has `id="root"`. Running the site's
 * accessibility checks against the game would fail on a missing nav and tell
 * nobody anything, and hardcoding an exclusion would go stale the next time
 * something is copied into public/.
 */
function pagesIn(dir, found = []) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) pagesIn(path, found);
    else if (name === 'index.html' && readFileSync(path, 'utf8').includes('id="root"')) {
      found.push(relative('dist', path).replace(/\/?index\.html$/, ''));
    }
  }
  return found;
}

function step(label) {
  console.log(`\n\x1b[1m── ${label}\x1b[0m`);
}

function sh(cmd, cmdArgs, env = {}) {
  const r = spawnSync(cmd, cmdArgs, {
    stdio: 'inherit',
    env: { ...process.env, ...env },
    shell: process.platform === 'win32',
  });
  return r.status ?? 1;
}

let failed = [];

if (!args['skip-build']) {
  step(`Types and lint`);
  if (sh('npm', ['run', 'check'])) failed.push('check');

  step(`Build at ${BASE}`);
  if (sh('npm', ['run', 'build'], { BASE_PATH: BASE })) {
    console.error('\nBuild failed — nothing to serve.');
    process.exit(1);
  }
}

step(`Serve ${URL}`);
/*
 * BASE_PATH reaches preview as well as build. Without it the server comes up at
 * "/" and every subpath request falls through to the SPA fallback, which serves
 * the home page — a failure that looks like the one it hides.
 */
const server = spawn('npx', ['vite', 'preview', '--port', String(PORT), '--host', '127.0.0.1'], {
  env: { ...process.env, BASE_PATH: BASE },
  stdio: ['ignore', 'pipe', 'pipe'],
});
let serverLog = '';
server.stdout.on('data', (d) => (serverLog += d));
server.stderr.on('data', (d) => (serverLog += d));

const stop = () => {
  if (!server.killed) server.kill('SIGTERM');
};
process.on('exit', stop);
process.on('SIGINT', () => {
  stop();
  process.exit(130);
});

let up = false;
for (let i = 0; i < 40; i++) {
  try {
    const res = await fetch(URL);
    if (res.ok) {
      up = true;
      break;
    }
  } catch {
    /* not listening yet */
  }
  await new Promise((r) => setTimeout(r, 500));
}
if (!up) {
  console.error(`\nPreview did not come up at ${URL}\n${serverLog}`);
  process.exit(1);
}
/*
 * Vite prints the base it is actually serving. If that disagrees with what we
 * asked for, every check below would pass against the SPA fallback instead of
 * the real documents, which is worse than failing.
 */
const served = serverLog.match(/Local:\s+(\S+)/)?.[1] ?? '';
if (served && !served.endsWith(BASE)) {
  console.error(`\nPreview is serving ${served}, not ${URL}. Refusing to test the wrong site.`);
  process.exit(1);
}
console.log(`  serving ${served || URL}`);

if (!existsSync('dist')) {
  console.error('\nNo dist/ to test. Drop --skip-build.');
  process.exit(1);
}
const ROUTES = pagesIn('dist').sort();

if (run('a11y')) {
  step(`Accessibility — ${ROUTES.length} routes`);
  let bad = 0;
  for (const route of ROUTES) {
    const path = route === '' ? '' : `${route}/`;
    console.log(`\n  ── /${path}`);
    if (sh('node', ['scripts/a11y.mjs', `--url=${URL}${path}`])) bad++;
  }
  if (bad) failed.push(`a11y (${bad} route${bad === 1 ? '' : 's'})`);
}

if (run('qa')) {
  step('Visual QA across six viewports');
  if (sh('node', ['scripts/shoot.mjs', `--url=${URL}`, '--vp=xl,desktop,laptop,tablet,mobile,small', '--full']))
    failed.push('visual QA');
}

stop();

console.log('');
if (failed.length) {
  console.error(`\x1b[31m✗ ${failed.join(', ')}\x1b[0m`);
  process.exit(1);
}
console.log('\x1b[32m✓ everything CI runs, green\x1b[0m');
