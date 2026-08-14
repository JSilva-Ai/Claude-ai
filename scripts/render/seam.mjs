/**
 * Loop-seam check: renders each scene at t and t+LOOP and diffs the interior
 * (the HUD's REC counter is a function of raw t and is excluded). A captured
 * clip only loops invisibly if these frames are identical.
 */
import { createServer } from 'node:http';
import { createReadStream, existsSync, statSync } from 'node:fs';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const MIME = { '.html': 'text/html', '.js': 'text/javascript', '.woff2': 'font/woff2' };
const server = createServer((req, res) => {
  const path = join(ROOT, normalize(decodeURIComponent(req.url.split('?')[0])));
  if (!path.startsWith(ROOT) || !existsSync(path) || statSync(path).isDirectory())
    return res.writeHead(404).end();
  res.writeHead(200, { 'content-type': MIME[extname(path)] ?? 'application/octet-stream' });
  createReadStream(path).pipe(res);
});
await new Promise((r) => server.listen(8932, r));

const browser = await chromium.launch({
  args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
const page = await browser.newPage({ viewport: { width: 1000, height: 640 } });
await page.goto('http://127.0.0.1:8932/scripts/render/stage.html');
await page.waitForFunction(() => window.__ready === true);

const scenes = await page.evaluate(() => window.__scenes.map((s) => s.id));
let bad = 0;
for (const id of scenes) {
  const diff = await page.evaluate(
    ([sceneId, loop]) => {
      const c = document.getElementById('stage');
      const ctx = c.getContext('2d');
      // Crop the HUD entirely: its blink and REC counter are functions of raw t.
      const X = 90, Y = 90, W = c.width - 180, H = c.height - 180;
      window.__drawAt(sceneId, 0);
      const a = ctx.getImageData(X, Y, W, H).data;
      window.__drawAt(sceneId, loop);
      const b = ctx.getImageData(X, Y, W, H).data;
      let n = 0;
      for (let i = 0; i < a.length; i += 4) {
        if (Math.abs(a[i] - b[i]) > 6 || Math.abs(a[i + 1] - b[i + 1]) > 6) n++;
      }
      return +((n / (a.length / 4)) * 100).toFixed(2);
    },
    [id, 12],
  );
  if (diff > 0.1) bad++;
  console.log(`  ${diff > 0.1 ? '✗' : '✓'} ${id.padEnd(9)} ${diff}% of interior pixels differ`);
}
console.log(bad ? `\n${bad} scene(s) do not loop cleanly.` : '\nAll scenes loop seamlessly.');
await browser.close();
server.close();
process.exitCode = bad ? 1 : 0;
