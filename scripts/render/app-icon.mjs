/**
 * Draws the app icon, and writes every size the two stores need.
 *
 *   node scripts/render/app-icon.mjs
 *
 * Output:
 *   mobile/void-striker/ios/App/App/Assets.xcassets/AppIcon.appiconset/
 *     AppIcon-512@2x.png                 1024x1024, no alpha channel
 *   mobile/void-striker/android/app/src/main/res/mipmap-<density>/
 *     ic_launcher.png                    legacy square, 48..192
 *     ic_launcher_round.png              legacy round, 48..192
 *     ic_launcher_foreground.png         adaptive foreground, 108dp, art inside
 *                                        the 66dp safe zone
 *   mobile/void-striker/android/app/src/main/res/values/ic_launcher_background.xml
 *
 * ---
 *
 * Why a script rather than a drawn file.
 *
 * The icon is the ship the game actually draws — the same hull and wing paths
 * copied out of drawShip — so it cannot drift into representing a different
 * game, and a change to the ship can be answered by re-running this. It also
 * means the icon arrives in the repo with its provenance attached instead of as
 * a binary nobody can edit.
 *
 * Both stores reject a placeholder icon, and Capacitor's is what was here
 * before. This replaces it.
 *
 * iOS rejects an icon that carries an alpha channel, and a canvas screenshot
 * always has one, so the 1024 is re-encoded through ffmpeg to rgb24. Android
 * needs the alpha, on the adaptive foreground especially, so those are left
 * alone.
 */

import { chromium } from 'playwright';
import { execFileSync } from 'node:child_process';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import ffmpeg from 'ffmpeg-static';

const REPO = fileURLToPath(new URL('../../', import.meta.url));
const IOS = join(REPO, 'mobile/void-striker/ios/App/App/Assets.xcassets/AppIcon.appiconset');
const RES = join(REPO, 'mobile/void-striker/android/app/src/main/res');

/* Densities, and the pixel size of a legacy 48dp launcher icon at each. */
const DENSITY = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };

/** The deep violet the adaptive icon sits on; also the icon's own ground. */
const GROUND = '#120632';

/**
 * The page that does the drawing.
 *
 * `mode` picks what fills the frame:
 *   'full'  — ground, glow and ship: the iOS icon and the legacy Android ones
 *   'fg'    — ship and glow only, transparent, sized for the adaptive safe zone
 * `round` clips to a circle, for ic_launcher_round.
 */
const PAGE = (size, mode, round) => `<!doctype html><meta charset="utf-8">
<style>html,body{margin:0;background:transparent}canvas{display:block}</style>
<canvas id="c" width="${size}" height="${size}"></canvas>
<script>
(function(){
  var S=${size}, mode=${JSON.stringify(mode)}, round=${round};
  var x=document.getElementById('c').getContext('2d');

  if(round){ x.beginPath(); x.arc(S/2,S/2,S/2,0,Math.PI*2); x.clip(); }

  if(mode!=='fg'){
    // Ground. A radial rather than a flat fill so the icon has a centre of
    // gravity at 40px, where the ship itself is barely more than a wedge.
    var g=x.createRadialGradient(S*.5,S*.40,0,S*.5,S*.40,S*.80);
    g.addColorStop(0,'#3a1590'); g.addColorStop(.5,'#160a3e'); g.addColorStop(1,'#04010c');
    x.fillStyle=g; x.fillRect(0,0,S,S);
  }

  /*
    The ship is 76 units across the wingtips. The scale is derived from the
    fraction of the frame it should occupy rather than picked: at 0.0135 the
    wings measured 102% of the width and ran off both edges, which iOS then
    clips again when it masks the corners.

    'full' gives it 64% and leaves the violet ground visible around it.
    'fg' gives it 55%, inside the 66-of-108dp safe zone an adaptive icon must
    respect — a launcher may mask that foreground to a circle, a squircle or a
    teardrop, and anything outside the zone is not guaranteed to survive.
  */
  var art = S * (mode==='fg' ? 0.55 : 0.64) / 76;
  x.save();
  x.translate(S/2, S*0.5 - 8*art);   // the hull's own centre, not the path origin
  x.scale(art,art);

  /*
    Glow, kept deliberately tight. The first version used a 52-unit engine wash
    and a 62-unit halo, which at 40px — the size an icon is actually judged at
    on a home screen — stopped reading as light and started reading as the whole
    icon being out of focus. A hard silhouette survives downscaling; a soft one
    does not.
  */
  var fg=x.createRadialGradient(0,22,0,0,22,26);
  fg.addColorStop(0,'rgba(170,225,255,.8)');
  fg.addColorStop(.4,'rgba(70,150,255,.34)');
  fg.addColorStop(1,'rgba(20,40,180,0)');
  x.fillStyle=fg; x.beginPath(); x.arc(0,22,26,0,Math.PI*2); x.fill();

  // A close halo, only enough to lift the hull off the ground
  var hg=x.createRadialGradient(0,-4,0,0,-4,42);
  hg.addColorStop(0,'rgba(110,180,255,.26)');
  hg.addColorStop(1,'rgba(80,120,255,0)');
  x.fillStyle=hg; x.beginPath(); x.arc(0,-4,42,0,Math.PI*2); x.fill();

  // Thruster — short, so it reads as a flame rather than a smear
  var tf=x.createLinearGradient(0,12,0,34);
  tf.addColorStop(0,'rgba(255,255,255,.95)');
  tf.addColorStop(.35,'rgba(130,205,255,.8)');
  tf.addColorStop(1,'rgba(40,80,255,0)');
  x.fillStyle=tf;
  x.beginPath(); x.moveTo(-4.5,12); x.quadraticCurveTo(-6,24,0,34); x.quadraticCurveTo(6,24,4.5,12); x.fill();

  // Wings — the game's own paths
  var wg=x.createLinearGradient(-38,-5,0,20);
  wg.addColorStop(0,'#3f7fff'); wg.addColorStop(1,'#0d2a7a');
  x.fillStyle=wg;
  x.beginPath(); x.moveTo(10,-5); x.lineTo(22,6); x.lineTo(38,16); x.lineTo(30,20); x.lineTo(18,18); x.closePath(); x.fill();
  x.beginPath(); x.moveTo(-10,-5); x.lineTo(-22,6); x.lineTo(-38,16); x.lineTo(-30,20); x.lineTo(-18,18); x.closePath(); x.fill();

  // Wingtip lights — the same running lights the live ship gained when its
  // hull picked up detail. Small enough that they read as a bright pixel at
  // the 48px legacy size and a proper lit point at 1024.
  x.save(); x.globalCompositeOperation='lighter';
  [[-30,17],[30,17]].forEach(function(wt){
    var wtg=x.createRadialGradient(wt[0],wt[1],0,wt[0],wt[1],5);
    wtg.addColorStop(0,'rgba(255,255,255,.95)'); wtg.addColorStop(.4,'rgba(120,200,255,.6)'); wtg.addColorStop(1,'rgba(0,0,0,0)');
    x.fillStyle=wtg; x.beginPath(); x.arc(wt[0],wt[1],5,0,Math.PI*2); x.fill();
  });
  x.restore();

  // Hull
  var hl=x.createLinearGradient(-14,-28,14,20);
  hl.addColorStop(0,'#bfe4ff'); hl.addColorStop(.42,'#4aa0ff'); hl.addColorStop(1,'#12307f');
  x.fillStyle=hl;
  x.beginPath();
  x.moveTo(0,-28);
  x.bezierCurveTo(4,-22,10,-12,14,-4); x.lineTo(20,6);
  x.bezierCurveTo(22,10,20,14,18,16); x.lineTo(12,20);
  x.bezierCurveTo(8,22,4,22,4,18); x.lineTo(-4,18);
  x.bezierCurveTo(-4,22,-8,22,-12,20); x.lineTo(-18,16);
  x.bezierCurveTo(-20,14,-22,10,-20,6); x.lineTo(-14,-4);
  x.bezierCurveTo(-10,-12,-4,-22,0,-28);
  x.fill();

  // Canopy
  var cp=x.createRadialGradient(-1,-16,0,-1,-16,10);
  cp.addColorStop(0,'rgba(235,250,255,.98)');
  cp.addColorStop(.5,'rgba(90,190,255,.85)');
  cp.addColorStop(1,'rgba(10,40,120,.5)');
  x.fillStyle=cp;
  x.beginPath();
  x.moveTo(0,-24); x.bezierCurveTo(5,-20,7,-10,6,-2);
  x.bezierCurveTo(3,0,0,0,0,0); x.bezierCurveTo(0,0,-3,0,-6,-2);
  x.bezierCurveTo(-7,-10,-5,-20,0,-24);
  x.fill();
  x.restore();
})();
</script>`;

const browser = await chromium.launch();

async function render(size, mode, round) {
  const page = await browser.newPage({ viewport: { width: size, height: size } });
  await page.setContent(PAGE(size, mode, round));
  await page.waitForTimeout(60);
  const buf = await page.locator('#c').screenshot({ omitBackground: true });
  await page.close();
  return buf;
}

/* ── iOS ─────────────────────────────────────────────────────────────────── */
mkdirSync(IOS, { recursive: true });
const iosTmp = join(IOS, '.icon-with-alpha.png');
writeFileSync(iosTmp, await render(1024, 'full', false));
execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-i', iosTmp, '-pix_fmt', 'rgb24', join(IOS, 'AppIcon-512@2x.png')]);
execFileSync('rm', ['-f', iosTmp]);
console.log('  ios      AppIcon-512@2x.png  1024x1024, alpha stripped');

/* ── Android ─────────────────────────────────────────────────────────────── */
for (const [name, mult] of Object.entries(DENSITY)) {
  const dir = join(RES, `mipmap-${name}`);
  mkdirSync(dir, { recursive: true });

  const legacy = Math.round(48 * mult);
  writeFileSync(join(dir, 'ic_launcher.png'), await render(legacy, 'full', false));
  writeFileSync(join(dir, 'ic_launcher_round.png'), await render(legacy, 'full', true));

  const adaptive = Math.round(108 * mult);
  writeFileSync(join(dir, 'ic_launcher_foreground.png'), await render(adaptive, 'fg', false));

  console.log(`  android  mipmap-${name.padEnd(8)} ${legacy}px legacy, ${adaptive}px foreground`);
}

writeFileSync(
  join(RES, 'values/ic_launcher_background.xml'),
  `<?xml version="1.0" encoding="utf-8"?>\n` +
    `<!--\n` +
    `  The ground behind the adaptive icon's foreground. It matches the darkest\n` +
    `  part of the icon art so the two read as one shape whatever mask the\n` +
    `  launcher applies. Generated by scripts/render/app-icon.mjs.\n` +
    `-->\n` +
    `<resources>\n    <color name="ic_launcher_background">${GROUND}</color>\n</resources>\n`,
);
console.log(`  android  ic_launcher_background.xml  ${GROUND}`);

await browser.close();
