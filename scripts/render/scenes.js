/**
 * Proving Grounds — ten synthetic environments.
 *
 * Each scene is a small real-time simulation rendered to a 2D canvas. They
 * share one art-directed rule that carries the lab's thesis:
 *
 *   the WORLD is drawn in cool grey — the PERCEPTION LAYER is drawn in phosphor.
 *
 * Everything is a periodic function of `t` over LOOP seconds so the captured
 * videos loop seamlessly. No randomness at draw time: all noise comes from a
 * seeded generator sampled once at build.
 */

export const LOOP = 12; // seconds
export const W = 960;
export const H = 600;

// --- Palette (mirrors src/styles/tokens.css) -------------------------------
export const C = {
  ink: '#08090b',
  ink2: '#0c0e12',
  grid: 'rgba(237,238,240,0.045)',
  gridStrong: 'rgba(237,238,240,0.09)',
  world: '#3a4048',
  worldLit: '#5b626c',
  worldFaint: '#22262d',
  porcelain: '#edeef0',
  grey: '#8d939d',
  greyDim: '#5c626b',
  phosphor: '#d4f85c',
  phosphorDim: 'rgba(212,248,92,0.45)',
  phosphorFaint: 'rgba(212,248,92,0.14)',
  plasma: '#7b5cff',
  plasmaFaint: 'rgba(123,92,255,0.3)',
  ember: '#ff5a3d',
};

export function mulberry32(a) {
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const TAU = Math.PI * 2;
/**
 * Phase in [0,1) over the loop.
 *
 * The double modulo is load-bearing: JavaScript's % keeps the sign of the
 * dividend, and several scenes sample backwards past t=0 to build motion
 * trails. A bare % returns a negative phase there, which lands a full cycle
 * away from the equivalent phase at the end of the loop and tears the seam.
 */
const ph = (t, mult = 1, offset = 0) => ((((t / LOOP) * mult + offset) % 1) + 1) % 1;
const wave = (t, mult = 1, offset = 0) => Math.sin(ph(t, mult, offset) * TAU);

// ---------------------------------------------------------------------------
// Shared chrome
// ---------------------------------------------------------------------------

function ground(ctx) {
  ctx.fillStyle = C.ink;
  ctx.fillRect(0, 0, W, H);
}

function vignette(ctx) {
  const g = ctx.createRadialGradient(W / 2, H / 2, H * 0.25, W / 2, H / 2, H * 0.92);
  g.addColorStop(0, 'rgba(0,0,0,0)');
  g.addColorStop(1, 'rgba(0,0,0,0.55)');
  ctx.fillStyle = g;
  ctx.fillRect(0, 0, W, H);
}

function grid(ctx, step = 40, color = C.grid) {
  ctx.strokeStyle = color;
  ctx.lineWidth = 1;
  ctx.beginPath();
  for (let x = 0; x <= W; x += step) {
    ctx.moveTo(x + 0.5, 0);
    ctx.lineTo(x + 0.5, H);
  }
  for (let y = 0; y <= H; y += step) {
    ctx.moveTo(0, y + 0.5);
    ctx.lineTo(W, y + 0.5);
  }
  ctx.stroke();
}

function mono(ctx, size = 12, weight = 500) {
  ctx.font = `${weight} ${size}px "JetBrains Mono", ui-monospace, monospace`;
}

/** Detection bracket — corner ticks, never a full rectangle. */
function bracket(ctx, x, y, w, h, color, opts = {}) {
  const c = opts.corner ?? Math.min(12, w * 0.3, h * 0.3);
  ctx.strokeStyle = color;
  ctx.lineWidth = opts.lw ?? 1.5;
  if (opts.dash) ctx.setLineDash(opts.dash);
  ctx.beginPath();
  ctx.moveTo(x, y + c);
  ctx.lineTo(x, y);
  ctx.lineTo(x + c, y);
  ctx.moveTo(x + w - c, y);
  ctx.lineTo(x + w, y);
  ctx.lineTo(x + w, y + c);
  ctx.moveTo(x + w, y + h - c);
  ctx.lineTo(x + w, y + h);
  ctx.lineTo(x + w - c, y + h);
  ctx.moveTo(x + c, y + h);
  ctx.lineTo(x, y + h);
  ctx.lineTo(x, y + h - c);
  ctx.stroke();
  ctx.setLineDash([]);
  if (opts.label) {
    mono(ctx, 9, 600);
    const tw = ctx.measureText(opts.label).width;
    ctx.fillStyle = color;
    ctx.globalAlpha = 0.16;
    ctx.fillRect(x, y - 13, tw + 8, 12);
    ctx.globalAlpha = 1;
    ctx.fillText(opts.label, x + 4, y - 4);
  }
}

/** Small horizontal confidence meter. */
function meter(ctx, x, y, w, v, color) {
  ctx.fillStyle = 'rgba(237,238,240,0.12)';
  ctx.fillRect(x, y, w, 3);
  ctx.fillStyle = color;
  ctx.fillRect(x, y, w * v, 3);
}

/**
 * HUD frame shared by every environment. This is what makes ten different
 * simulations read as one instrument suite.
 */
function hud(ctx, scene, t) {
  const pad = 22;
  ctx.strokeStyle = 'rgba(237,238,240,0.14)';
  ctx.lineWidth = 1;
  const c = 14;
  ctx.beginPath();
  ctx.moveTo(pad, pad + c);
  ctx.lineTo(pad, pad);
  ctx.lineTo(pad + c, pad);
  ctx.moveTo(W - pad - c, pad);
  ctx.lineTo(W - pad, pad);
  ctx.lineTo(W - pad, pad + c);
  ctx.moveTo(W - pad, H - pad - c);
  ctx.lineTo(W - pad, H - pad);
  ctx.lineTo(W - pad - c, H - pad);
  ctx.moveTo(pad + c, H - pad);
  ctx.lineTo(pad, H - pad);
  ctx.lineTo(pad, H - pad - c);
  ctx.stroke();

  // Top-left: environment identity
  mono(ctx, 11, 700);
  ctx.fillStyle = C.phosphor;
  ctx.fillText(scene.code, pad + 14, pad + 20);
  mono(ctx, 11, 500);
  ctx.fillStyle = C.grey;
  ctx.fillText(scene.title.toUpperCase(), pad + 14 + ctx.measureText(scene.code).width + 14, pad + 20);

  // Top-right: running indicator
  const blink = 0.55 + 0.45 * Math.sin(t * 3.2);
  ctx.fillStyle = C.phosphor;
  ctx.globalAlpha = blink;
  ctx.beginPath();
  ctx.arc(W - pad - 14, pad + 16, 3, 0, TAU);
  ctx.fill();
  ctx.globalAlpha = 1;
  mono(ctx, 10, 500);
  ctx.fillStyle = C.greyDim;
  const label = 'REC ' + String(Math.floor(t * 30)).padStart(5, '0');
  ctx.fillText(label, W - pad - 24 - ctx.measureText(label).width, pad + 20);

  // Bottom-left: the task being learned
  mono(ctx, 10, 500);
  ctx.fillStyle = C.greyDim;
  ctx.fillText(scene.task.toUpperCase(), pad + 14, H - pad - 12);

  // Bottom-right: live metric
  const v = scene.metric(t);
  mono(ctx, 10, 500);
  const mt = `${scene.metricLabel} ${v}`;
  ctx.fillStyle = C.grey;
  ctx.fillText(mt, W - pad - 14 - ctx.measureText(mt).width, H - pad - 12);
}

// ---------------------------------------------------------------------------
// 01 — DRIFT · multi-object tracking
// ---------------------------------------------------------------------------
const drift = (() => {
  const r = mulberry32(11);
  // A real street grid: avenues at fixed pitch, blocks filling the gaps.
  const AV_X = [150, 330, 510, 690, 850];
  const AV_Y = [130, 300, 470];
  const ROAD = 30;

  const buildings = [];
  const edgesX = [-40, ...AV_X, W + 40];
  const edgesY = [-40, ...AV_Y, H + 40];
  for (let i = 0; i < edgesX.length - 1; i++) {
    for (let j = 0; j < edgesY.length - 1; j++) {
      const x0 = edgesX[i] + ROAD / 2 + 6;
      const y0 = edgesY[j] + ROAD / 2 + 6;
      const x1 = edgesX[i + 1] - ROAD / 2 - 6;
      const y1 = edgesY[j + 1] - ROAD / 2 - 6;
      if (x1 - x0 < 30 || y1 - y0 < 30) continue;
      // One to three footprints per block.
      const n = 1 + Math.floor(r() * 3);
      for (let k = 0; k < n; k++) {
        const bw = (x1 - x0) * (0.32 + r() * 0.55);
        const bh = (y1 - y0) * (0.3 + r() * 0.55);
        buildings.push({
          x: x0 + r() * (x1 - x0 - bw),
          y: y0 + r() * (y1 - y0 - bh),
          w: bw,
          h: bh,
          tone: 0.35 + r() * 0.65,
        });
      }
    }
  }

  const lanes = [];
  for (let i = 0; i < 15; i++) {
    const horiz = i % 2 === 0;
    const track = horiz ? AV_Y[i % AV_Y.length] : AV_X[i % AV_X.length];
    const dir = r() > 0.5 ? 1 : -1;
    lanes.push({
      horiz,
      pos: track + (dir > 0 ? 4 : -12),
      // Whole cycles per loop: a fractional speed leaves the vehicle
      // mid-street at the seam and the video visibly jumps.
      speed: 1 + Math.floor(r() * 3),
      dir,
      offset: r(),
      len: 30 + r() * 16,
      wide: 9,
      id: 'T' + String(100 + Math.floor(r() * 800)),
    });
  }
  return {
    id: 'drift',
    code: '01',
    title: 'Drift',
    task: 'multi-object tracking · occlusion recovery',
    metricLabel: 'ID SWITCHES',
    metric: (t) => (t > LOOP * 0.6 ? '0' : '0'),
    draw(ctx, t) {
      ground(ctx);

      // Roadway surface, laid before the buildings.
      ctx.fillStyle = '#101318';
      for (const x of AV_X) ctx.fillRect(x - ROAD / 2, 0, ROAD, H);
      for (const y of AV_Y) ctx.fillRect(0, y - ROAD / 2, W, ROAD);
      // Lane markings
      ctx.strokeStyle = 'rgba(237,238,240,0.13)';
      ctx.lineWidth = 1;
      ctx.setLineDash([9, 12]);
      ctx.beginPath();
      for (const x of AV_X) {
        ctx.moveTo(x + 0.5, 0);
        ctx.lineTo(x + 0.5, H);
      }
      for (const y of AV_Y) {
        ctx.moveTo(0, y + 0.5);
        ctx.lineTo(W, y + 0.5);
      }
      ctx.stroke();
      ctx.setLineDash([]);

      // Building footprints — hairline architecture, not grey blobs.
      for (const b of buildings) {
        const v = Math.round(16 + b.tone * 14);
        ctx.fillStyle = `rgb(${v},${v + 2},${v + 6})`;
        ctx.fillRect(b.x, b.y, b.w, b.h);
        ctx.strokeStyle = `rgba(237,238,240,${(0.05 + b.tone * 0.07).toFixed(3)})`;
        ctx.lineWidth = 1;
        ctx.strokeRect(b.x + 0.5, b.y + 0.5, b.w - 1, b.h - 1);
      }

      // Occlusion band — a bridge the tracker must see through
      const bandY = H * 0.62;
      ctx.fillStyle = 'rgba(8,9,11,0.92)';
      ctx.fillRect(0, bandY, W, 54);
      ctx.strokeStyle = 'rgba(237,238,240,0.1)';
      ctx.lineWidth = 1;
      ctx.strokeRect(0.5, bandY + 0.5, W - 1, 53);
      mono(ctx, 9, 500);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('OCCLUDER', 12, bandY + 32);

      for (const l of lanes) {
        const axis = l.horiz ? W : H;
        const raw = ph(t, l.speed, l.offset) * (axis + 160) - 80;
        const base = l.dir > 0 ? raw : axis - raw;
        const x = l.horiz ? base : l.pos;
        const y = l.horiz ? l.pos : base;
        const w = l.horiz ? l.len : l.wide;
        const h = l.horiz ? l.wide : l.len;
        if (x < -70 || x > W + 70 || y < -70 || y > H + 70) continue;
        const occluded = y + h > bandY && y < bandY + 54;

        // World layer
        ctx.fillStyle = occluded ? '#20242b' : C.worldLit;
        ctx.fillRect(x, y, w, h);
        ctx.fillStyle = occluded ? '#20242b' : '#7d858f';
        // Windshield — enough to read direction of travel at this scale.
        if (l.horiz) ctx.fillRect(l.dir > 0 ? x + w - 7 : x, y, 7, h);
        else ctx.fillRect(x, l.dir > 0 ? y + h - 7 : y, w, 7);

        // Perception layer
        const pad = 6;
        bracket(ctx, x - pad, y - pad, w + pad * 2, h + pad * 2, occluded ? C.plasma : C.phosphor, {
          dash: occluded ? [3, 3] : null,
          label: occluded ? l.id + '·PRED' : l.id,
          lw: 1.3,
          corner: 7,
        });
        // Velocity vector
        ctx.strokeStyle = occluded ? C.plasmaFaint : C.phosphorDim;
        ctx.lineWidth = 1.2;
        ctx.beginPath();
        const cx = x + w / 2;
        const cy = y + h / 2;
        const vl = 24 + 26 * l.speed;
        ctx.moveTo(cx, cy);
        ctx.lineTo(
          cx + (l.horiz ? (vl + w / 2) * l.dir : 0),
          cy + (l.horiz ? 0 : (vl + h / 2) * l.dir),
        );
        ctx.stroke();
      }
      vignette(ctx);
      hud(ctx, drift, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 02 — CANOPY · monocular depth
// ---------------------------------------------------------------------------
const canopy = (() => {
  const r = mulberry32(23);
  const LAYERS = 5;
  const layers = [];
  for (let d = 0; d < LAYERS; d++) {
    const near = 1 - d / (LAYERS - 1); // 1 = nearest plate, 0 = deepest
    const n = 4 + d * 3;
    const trees = [];
    for (let i = 0; i < n; i++) {
      // Crown is a cluster of overlapping blobs riding the top of the trunk —
      // organic mass, never a box.
      const blobs = [];
      const nb = 14 - d * 2 + Math.floor(r() * 6); // deep plates need fewer
      for (let k = 0; k < nb; k++) {
        const rx = 0.2 + r() * 0.4;
        blobs.push({
          dx: (r() - 0.5) * 3.2,
          dy: 0.5 + r() * 0.34,
          rx,
          ry: rx * (0.62 + r() * 0.34),
        });
      }
      const branches = [];
      for (let k = 0; k < 3; k++) {
        branches.push({ at: 0.5 + r() * 0.34, dir: r() > 0.5 ? 1 : -1, len: 0.9 + r() * 1.3 });
      }
      trees.push({
        u: (i + r() * 0.8) / n,
        w: 0.006 + r() * 0.028,
        h: 0.9 + r() * 0.5,
        lean: (r() - 0.5) * 0.2,
        blobs,
        branches,
      });
    }
    layers.push({
      trees,
      near,
      // Integer phase multiplier, so the parallax wraps exactly on the loop.
      // Apparent speed comes from the wrap span, which differs per plate.
      speed: [3, 2, 2, 1, 1][d],
      span: W + 300 + d * 40,
      baseY: H * (0.58 + near * 0.3),
      // Aerial perspective: the near plate is the lightest thing in the world
      // layer and still sits well under the perception layer.
      shade: Math.round(8 + near * 30),
    });
  }
  const COLS = 152; // depth-profile resolution, buffer reused every frame
  const prof = new Float32Array(COLS);
  return {
    id: 'canopy',
    code: '02',
    title: 'Canopy',
    task: 'monocular depth · scale recovery under occlusion',
    metricLabel: 'δ<1.25',
    metric: (t) => (0.962 + wave(t, 2) * 0.004).toFixed(3),
    draw(ctx, t) {
      ground(ctx);
      // Sky seen through the canopy — never brighter than the near foliage.
      const g = ctx.createLinearGradient(0, 0, 0, H);
      g.addColorStop(0, '#0d1015');
      g.addColorStop(0.6, '#0a0c10');
      g.addColorStop(1, '#08090b');
      ctx.fillStyle = g;
      ctx.fillRect(0, 0, W, H);

      prof.fill(0);
      const panX = 54;
      const panW = W - 108;
      const panY = H - 132;
      const panH = 70;
      let leadX = 0;
      let leadW = 0;
      let leadTop = 0;
      let leadD = 1e9;

      for (let li = LAYERS - 1; li >= 0; li--) {
        const L = layers[li];
        const sh = L.shade;
        const fill = `rgb(${sh},${sh + 5},${sh + 12})`;
        // Forest floor for this plate — a receding ground line, not a horizon.
        ctx.fillStyle = fill;
        ctx.fillRect(0, L.baseY, W, 3);
        for (const tr of L.trees) {
          const x = ((tr.u + ph(t, L.speed)) % 1) * L.span - (L.span - W) / 2;
          const tw = 4 + tr.w * W * Math.pow(L.near, 1.6) * 2;
          const th = tr.h * H * (0.45 + L.near * 0.7);
          const topY = L.baseY - th;
          const fr = tw * 1.55;
          const skew = tr.lean * th * 0.28;

          // Litter round the base — one step down, so it sits in shadow
          ctx.fillStyle = `rgb(${sh - 4},${sh + 1},${sh + 8})`;
          ctx.beginPath();
          ctx.ellipse(x + tw / 2, L.baseY + 1, tw * 0.8, tw * 0.22, 0, 0, TAU);
          ctx.fill();

          ctx.fillStyle = fill;
          ctx.beginPath();
          ctx.moveTo(x, L.baseY);
          ctx.lineTo(x + tw, L.baseY);
          ctx.lineTo(x + tw * 0.66 + skew, topY);
          ctx.lineTo(x + tw * 0.26 + skew, topY);
          ctx.closePath();
          // Branches — what stops a trunk reading as a pillar
          for (const br of tr.branches) {
            const by0 = L.baseY - th * br.at;
            const bx0 = x + tw / 2 + skew * br.at;
            const bl = tw * br.len * 2.4;
            ctx.moveTo(bx0, by0 + tw * 0.3);
            ctx.lineTo(bx0 + br.dir * bl, by0 - bl * 0.55);
            ctx.lineTo(bx0 + br.dir * bl, by0 - bl * 0.55 - tw * 0.28);
            ctx.lineTo(bx0, by0 - tw * 0.3);
            ctx.closePath();
          }
          ctx.fill();

          // Crown — a ragged cluster in its own darker value, so it reads as
          // foliage held against the sky rather than a cap on a pole.
          ctx.fillStyle = `rgb(${sh - 7},${sh - 2},${sh + 5})`;
          ctx.beginPath();
          for (const b of tr.blobs) {
            const cx = x + tw / 2 + b.dx * fr + skew * b.dy;
            const cy = L.baseY - th * b.dy;
            ctx.moveTo(cx + fr * b.rx, cy);
            ctx.ellipse(cx, cy, fr * b.rx, fr * b.ry, 0, 0, TAU);
          }
          ctx.fill();

          // Contribute this trunk to the per-column depth estimate.
          const s0 = Math.max(0, Math.floor(((x - tw * 1.3) / W) * COLS));
          const s1 = Math.min(COLS - 1, Math.ceil(((x + tw * 2.3) / W) * COLS));
          for (let s = s0; s <= s1; s++) if (prof[s] < L.near) prof[s] = L.near;

          // Depth samples ride the trunk edges of the nearest plates. Phosphor
          // carries the estimate; plasma marks the samples it does not trust.
          if (L.near > 0.6 && tw > 11) {
            for (let i = 0; i < 7; i++) {
              const f = (i + 0.5) / 7;
              const py = L.baseY - th * f * 0.75;
              if (py < 40 || py > panY - 14) continue;
              const lx = x + (tw * 0.26 + skew) * f;
              const conf = 0.55 + 0.45 * Math.sin(ph(t, 2) * TAU + i * 1.1 + tr.u * 9);
              const weak = L.near < 0.85 && i % 3 === 2;
              ctx.fillStyle = weak ? C.plasma : C.phosphor;
              ctx.globalAlpha = (weak ? 0.5 : 0.35 + L.near * 0.35) + conf * 0.4;
              ctx.fillRect(lx - 2.5, py - 2.5, 5, 5);
              ctx.fillRect(lx + tw * (1 - 0.32 * f) - 2.5, py - 2.5, 5, 5);
              ctx.globalAlpha = 1;
            }
          }
          if (li === 0) {
            const dc = Math.abs(x + tw / 2 - W / 2);
            if (dc < leadD) {
              leadD = dc;
              leadX = x;
              leadW = tw;
              leadTop = Math.max(46, topY);
            }
          }
        }
      }

      // Range lock on the nearest trunk — the one metric claim in the frame.
      if (leadW) {
        const bh = Math.min(panY - 26, layers[0].baseY) - leadTop;
        bracket(ctx, leadX - 13, leadTop, leadW + 26, bh, C.phosphor, { lw: 1.4, corner: 12 });
        mono(ctx, 11, 700);
        ctx.fillStyle = C.phosphor;
        ctx.fillText((2.4 + (leadD / W) * 11).toFixed(1) + ' m', leadX + leadW + 18, leadTop + 12);
      }

      // Sample column tying the panel readout back to the image.
      const rIdx = Math.floor(ph(t, 1) * (COLS - 1));
      const rx = panX + 1 + (rIdx / (COLS - 1)) * (panW - 2);
      ctx.strokeStyle = 'rgba(212,248,92,0.2)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(rx, 46);
      ctx.lineTo(rx, panY);
      ctx.stroke();

      // --- Depth profile panel: the estimate, stated as a scanline ---------
      ctx.fillStyle = 'rgba(8,9,11,0.86)';
      ctx.fillRect(panX, panY, panW, panH);
      ctx.strokeStyle = 'rgba(237,238,240,0.13)';
      ctx.lineWidth = 1;
      ctx.strokeRect(panX + 0.5, panY + 0.5, panW - 1, panH - 1);

      const pTop = panY + 22;
      const pBot = panY + panH - 8;
      const fg = ctx.createLinearGradient(0, pBot, 0, pTop);
      fg.addColorStop(0, 'rgba(26,30,38,0)');
      fg.addColorStop(0.5, 'rgba(123,92,255,0.32)');
      fg.addColorStop(1, 'rgba(212,248,92,0.4)');
      ctx.beginPath();
      ctx.moveTo(panX + 1, pBot);
      for (let s = 0; s < COLS; s++) {
        ctx.lineTo(panX + 1 + (s / (COLS - 1)) * (panW - 2), pBot - prof[s] * (pBot - pTop));
      }
      ctx.lineTo(panX + panW - 1, pBot);
      ctx.closePath();
      ctx.fillStyle = fg;
      ctx.fill();
      ctx.beginPath();
      for (let s = 0; s < COLS; s++) {
        const sx = panX + 1 + (s / (COLS - 1)) * (panW - 2);
        const sy = pBot - prof[s] * (pBot - pTop);
        if (s === 0) ctx.moveTo(sx, sy);
        else ctx.lineTo(sx, sy);
      }
      ctx.strokeStyle = C.phosphor;
      ctx.lineWidth = 1.8;
      ctx.stroke();

      // Reticle on the sampled column
      const ry = pBot - prof[rIdx] * (pBot - pTop);
      ctx.strokeStyle = 'rgba(237,238,240,0.4)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(rx, pTop - 6);
      ctx.lineTo(rx, pBot);
      ctx.stroke();
      ctx.fillStyle = C.porcelain;
      ctx.fillRect(rx - 2.5, ry - 2.5, 5, 5);

      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('DEPTH PROFILE', panX + 9, panY + 15);
      const rd = (0.4 + (1 - prof[rIdx]) * 42).toFixed(1) + ' m';
      ctx.fillStyle = C.porcelain;
      ctx.fillText(rd, panX + 116, panY + 15);
      // Ramp key
      const kw = 84;
      const kx = panX + panW - kw - 52;
      const rg = ctx.createLinearGradient(kx, 0, kx + kw, 0);
      rg.addColorStop(0, '#d4f85c');
      rg.addColorStop(0.5, '#7b5cff');
      rg.addColorStop(1, '#1a1e26');
      ctx.fillStyle = rg;
      ctx.fillRect(kx, panY + 7, kw, 7);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('0.4', kx - 24, panY + 15);
      ctx.fillText('64 m', kx + kw + 6, panY + 15);

      vignette(ctx);
      hud(ctx, canopy, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 03 — HALLWAY · visual SLAM
// ---------------------------------------------------------------------------
const hallway = (() => {
  const r = mulberry32(77);
  const RIBS = 14;
  // Every feature is pinned to a real surface — nothing floats in the void.
  const feats = [];
  for (let i = 0; i < 132; i++) {
    feats.push({ s: Math.floor(r() * 4), u: 0.04 + r() * 0.92, z: r(), weak: r() > 0.82 });
  }
  // The map being built: a closed circuit in map space, plus its wall returns.
  const route = [];
  const marks = [];
  for (let i = 0; i < 160; i++) {
    const a = (i / 160) * TAU;
    const ca = Math.cos(a);
    const sa = Math.sin(a);
    const rx = Math.sign(ca) * Math.pow(Math.abs(ca), 0.42);
    const ry = Math.sign(sa) * Math.pow(Math.abs(sa), 0.42);
    route.push({ x: rx, y: ry });
    if (i % 2 === 0) {
      for (let k = 0; k < 2; k++) {
        const g = k ? 1.16 + r() * 0.1 : 0.82 - r() * 0.1;
        marks.push({ i, x: rx * g, y: ry * g });
      }
    }
  }
  const P = [0, 0];
  return {
    id: 'hallway',
    code: '03',
    title: 'Hallway',
    task: 'visual SLAM · loop closure in repeating geometry',
    metricLabel: 'DRIFT',
    metric: (t) => (0.31 + wave(t, 1) * 0.06).toFixed(2) + ' %',
    draw(ctx, t) {
      ground(ctx);
      const vx = W / 2 + wave(t, 1) * 46;
      const vy = H * 0.5 + wave(t, 1, 0.25) * 22;
      const travel = ph(t, 2);
      // Cross-section half-extents at nearness k (0 = vanishing point, 1 = camera).
      const hwOf = (k) => 30 + Math.pow(k, 2.1) * W * 0.98;
      const hhOf = (k) => 20 + Math.pow(k, 2.1) * H * 0.84;

      // Far end of the run — a door, so the corridor terminates instead of
      // opening onto a black hole.
      const ew = hwOf(travel / RIBS);
      const eh = hhOf(travel / RIBS);
      ctx.fillStyle = '#101318';
      ctx.fillRect(vx - ew, vy - eh, ew * 2, eh * 2);
      ctx.fillStyle = '#191d24';
      ctx.fillRect(vx - ew * 0.42, vy - eh * 0.62, ew * 0.84, eh * 1.62);

      const quad = (ax, ay, bx, by, cx, cy, dx, dy, v) => {
        ctx.beginPath();
        ctx.moveTo(ax, ay);
        ctx.lineTo(bx, by);
        ctx.lineTo(cx, cy);
        ctx.lineTo(dx, dy);
        ctx.closePath();
        ctx.fillStyle = `rgb(${v},${v + 4},${v + 10})`;
        ctx.fill();
      };

      // --- Corridor as four real surfaces, drawn far to near ---------------
      for (let i = 0; i < RIBS; i++) {
        const k0 = (i + travel) / RIBS;
        const k1 = (i + 1 + travel) / RIBS;
        const w0 = hwOf(k0);
        const h0 = hhOf(k0);
        const w1 = hwOf(k1);
        const h1 = hhOf(k1);
        const alt = i % 2 ? 0 : 5;
        // floor / ceiling / left wall / right wall — each its own value step
        quad(
          vx - w0, vy + h0, vx + w0, vy + h0, vx + w1, vy + h1, vx - w1, vy + h1,
          Math.round(20 + k0 * 40 + alt),
        );
        quad(
          vx - w0, vy - h0, vx + w0, vy - h0, vx + w1, vy - h1, vx - w1, vy - h1,
          Math.round(10 + k0 * 17),
        );
        quad(
          vx - w0, vy - h0, vx - w0, vy + h0, vx - w1, vy + h1, vx - w1, vy - h1,
          Math.round(15 + k0 * 25 + alt),
        );
        quad(
          vx + w0, vy - h0, vx + w0, vy + h0, vx + w1, vy + h1, vx + w1, vy - h1,
          Math.round(18 + k0 * 33 + alt),
        );
        // Ceiling light panel — the depth cue that makes the tube read as a
        // tube. Kept only two steps above the ceiling it sits in.
        if (i % 2 === 0) {
          const lit = Math.round(30 + k0 * 28);
          ctx.beginPath();
          ctx.moveTo(vx - w0 * 0.13, vy - h0);
          ctx.lineTo(vx + w0 * 0.13, vy - h0);
          ctx.lineTo(vx + w1 * 0.13, vy - h1);
          ctx.lineTo(vx - w1 * 0.13, vy - h1);
          ctx.closePath();
          ctx.fillStyle = `rgb(${lit},${lit + 4},${lit + 11})`;
          ctx.fill();
        }
        // Rib seam
        ctx.strokeStyle = `rgba(237,238,240,${(0.05 + k0 * 0.16).toFixed(3)})`;
        ctx.lineWidth = 1;
        ctx.strokeRect(vx - w0, vy - h0, w0 * 2, h0 * 2);
      }
      // Handrail lines running to the vanishing point
      ctx.strokeStyle = 'rgba(237,238,240,0.13)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      for (const sgn of [-1, 1]) {
        ctx.moveTo(vx + sgn * hwOf(1), vy + hhOf(1) * 0.16);
        ctx.lineTo(vx + sgn * hwOf(0), vy + hhOf(0) * 0.16);
      }
      ctx.stroke();

      // --- Tracked features, pinned to the surfaces ------------------------
      const put = (f, k) => {
        const w = hwOf(k);
        const h = hhOf(k);
        const d = f.u * 2 - 1;
        if (f.s === 0) {
          P[0] = vx + d * w;
          P[1] = vy + h;
        } else if (f.s === 1) {
          P[0] = vx + d * w;
          P[1] = vy - h;
        } else if (f.s === 2) {
          P[0] = vx - w;
          P[1] = vy + d * h;
        } else {
          P[0] = vx + w;
          P[1] = vy + d * h;
        }
      };
      for (const f of feats) {
        const k = (f.z + travel) % 1;
        put(f, k);
        const px = P[0];
        const py = P[1];
        if (px < -30 || px > W + 30 || py < -30 || py > H + 30) continue;
        put(f, Math.max(k - 0.07, 0.001));
        const a = Math.min(1, k * 3);
        const col = f.weak ? C.plasma : C.phosphor;
        ctx.strokeStyle = col;
        ctx.globalAlpha = a * 0.55;
        ctx.lineWidth = 1.6;
        ctx.beginPath();
        ctx.moveTo(P[0], P[1]);
        ctx.lineTo(px, py);
        ctx.stroke();
        ctx.globalAlpha = a;
        ctx.fillStyle = col;
        ctx.fillRect(px - 1.8, py - 1.8, 3.6, 3.6);
        ctx.globalAlpha = 1;
      }

      // --- Minimap: the map being built ------------------------------------
      const mw = 238;
      const mh = 152;
      const mx = W - mw - 34;
      const my = H - mh - 52;
      const cx = mx + mw / 2;
      const cy = my + mh / 2;
      const sx = mw * 0.33;
      const sy = mh * 0.3;
      ctx.fillStyle = 'rgba(8,9,11,0.88)';
      ctx.fillRect(mx, my, mw, mh);
      ctx.strokeStyle = 'rgba(237,238,240,0.14)';
      ctx.lineWidth = 1;
      ctx.strokeRect(mx + 0.5, my + 0.5, mw - 1, mh - 1);
      const prog = ph(t, 1);
      const done = Math.floor(prog * (route.length - 1));

      // Unmapped remainder — prior, not evidence
      ctx.strokeStyle = 'rgba(123,92,255,0.4)';
      ctx.setLineDash([3, 4]);
      ctx.lineWidth = 1;
      ctx.beginPath();
      for (let i = done; i < route.length; i++) {
        const p = route[i];
        if (i === done) ctx.moveTo(cx + p.x * sx, cy + p.y * sy);
        else ctx.lineTo(cx + p.x * sx, cy + p.y * sy);
      }
      ctx.lineTo(cx + route[0].x * sx, cy + route[0].y * sy);
      ctx.stroke();
      ctx.setLineDash([]);
      // Wall returns accumulated so far
      ctx.fillStyle = C.phosphor;
      ctx.globalAlpha = 0.5;
      for (const m of marks) {
        if (m.i > done) continue;
        ctx.fillRect(cx + m.x * sx - 1, cy + m.y * sy - 1, 2, 2);
      }
      ctx.globalAlpha = 1;
      // Mapped trajectory
      ctx.strokeStyle = C.phosphor;
      ctx.lineWidth = 1.6;
      ctx.beginPath();
      for (let i = 0; i <= done; i++) {
        const p = route[i];
        if (i === 0) ctx.moveTo(cx + p.x * sx, cy + p.y * sy);
        else ctx.lineTo(cx + p.x * sx, cy + p.y * sy);
      }
      ctx.stroke();
      // Keyframes
      ctx.strokeStyle = 'rgba(212,248,92,0.55)';
      ctx.lineWidth = 1;
      for (let i = 0; i <= done; i += 16) {
        const p = route[i];
        ctx.strokeRect(cx + p.x * sx - 2.5, cy + p.y * sy - 2.5, 5, 5);
      }
      // Current pose
      const pp = route[done];
      ctx.fillStyle = C.porcelain;
      ctx.beginPath();
      ctx.arc(cx + pp.x * sx, cy + pp.y * sy, 3.5, 0, TAU);
      ctx.fill();
      // Loop closure — the constraint that snaps the map shut
      if (prog > 0.9) {
        const a = (prog - 0.9) / 0.1;
        ctx.strokeStyle = C.phosphor;
        ctx.globalAlpha = a;
        ctx.lineWidth = 1.4;
        ctx.setLineDash([4, 3]);
        ctx.beginPath();
        ctx.moveTo(cx + pp.x * sx, cy + pp.y * sy);
        ctx.lineTo(cx + route[0].x * sx, cy + route[0].y * sy);
        ctx.stroke();
        ctx.setLineDash([]);
        mono(ctx, 11, 700);
        ctx.fillStyle = C.phosphor;
        ctx.fillText('LOOP CLOSED', mx + 10, my + mh - 10);
        ctx.globalAlpha = 1;
      }
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('MAP', mx + 10, my + 16);
      const kf = 'KEYFRAMES ' + String(Math.floor(done / 16) + 1).padStart(2, '0');
      ctx.fillText(kf, mx + mw - 10 - ctx.measureText(kf).width, my + 16);

      vignette(ctx);
      hud(ctx, hallway, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 04 — SWARM · trajectory forecasting
// ---------------------------------------------------------------------------
const swarm = (() => {
  const N = 46;
  const r = mulberry32(131);
  const agents = [];
  for (let i = 0; i < N; i++) {
    agents.push({
      rx: 120 + r() * 200,
      ry: 90 + r() * 150,
      // Integer cycle counts — sx*3 and sy*2 below must stay whole too.
      sx: 1 + Math.floor(r() * 3),
      sy: 1 + Math.floor(r() * 3),
      p: r(),
      q: r(),
      lead: r() > 0.86,
    });
  }
  const at = (a, t) => [
    W / 2 + Math.cos(ph(t, a.sx, a.p) * TAU) * a.rx + Math.sin(ph(t, a.sy * 2, a.q) * TAU) * 34,
    H / 2 + Math.sin(ph(t, a.sy, a.q) * TAU) * a.ry + Math.cos(ph(t, a.sx * 3, a.p) * TAU) * 22,
  ];
  return {
    id: 'swarm',
    code: '04',
    title: 'Swarm',
    task: 'trajectory forecasting · 3 s horizon, 46 agents',
    metricLabel: 'ADE',
    metric: (t) => (0.14 + wave(t, 3) * 0.02).toFixed(3) + ' m',
    draw(ctx, t) {
      ground(ctx);
      grid(ctx, 48);

      // Forecast cones first, so agents sit above them. Only the leads and a
      // sampled third of the rest are drawn: every agent's line at once is
      // scribble, and the claim being illustrated is that the forecast is
      // legible.
      agents.forEach((a, ai) => {
        if (!a.lead && ai % 3 !== 0) return;
        ctx.beginPath();
        for (let i = 0; i <= 10; i++) {
          const [x, y] = at(a, t + (i / 10) * 0.85);
          if (i === 0) ctx.moveTo(x, y);
          else ctx.lineTo(x, y);
        }
        ctx.strokeStyle = a.lead ? C.phosphorDim : 'rgba(212,248,92,0.16)';
        ctx.lineWidth = a.lead ? 1.4 : 1;
        ctx.stroke();
        // Uncertainty at the horizon
        const [hx, hy] = at(a, t + 0.85);
        ctx.strokeStyle = a.lead ? C.phosphorFaint : 'rgba(212,248,92,0.08)';
        ctx.beginPath();
        ctx.ellipse(hx, hy, 13, 8, 0, 0, TAU);
        ctx.stroke();
      });

      // Agents
      for (const a of agents) {
        const [x, y] = at(a, t);
        const [px, py] = at(a, t - 0.08);
        const ang = Math.atan2(y - py, x - px);
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(ang);
        ctx.fillStyle = a.lead ? C.porcelain : C.world;
        ctx.beginPath();
        ctx.moveTo(7, 0);
        ctx.lineTo(-5, 4);
        ctx.lineTo(-5, -4);
        ctx.closePath();
        ctx.fill();
        ctx.restore();
        if (a.lead) bracket(ctx, x - 14, y - 14, 28, 28, C.phosphor, { lw: 1.2, corner: 6 });
      }

      // Swarm centroid + spread
      let cx = 0;
      let cy = 0;
      for (const a of agents) {
        const [x, y] = at(a, t);
        cx += x;
        cy += y;
      }
      cx /= N;
      cy /= N;
      ctx.strokeStyle = C.plasmaFaint;
      ctx.setLineDash([4, 5]);
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.arc(cx, cy, 165, 0, TAU);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.strokeStyle = C.plasma;
      ctx.beginPath();
      ctx.moveTo(cx - 8, cy);
      ctx.lineTo(cx + 8, cy);
      ctx.moveTo(cx, cy - 8);
      ctx.lineTo(cx, cy + 8);
      ctx.stroke();

      vignette(ctx);
      hud(ctx, swarm, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 05 — LATTICE · instance segmentation
// ---------------------------------------------------------------------------
const lattice = (() => {
  const r = mulberry32(313);
  const FLOOR = H - 66;
  const X0 = 58;
  const X1 = W - 96;
  // A masonry wall: every block rests on the row below it, seams staggered.
  // Nothing floats — the whole point of the task is contact.
  const blocks = [];
  let base = FLOOR;
  let lo = X0;
  let hi = X1;
  for (let row = 0; row < 10 && hi - lo > 190; row++) {
    // Row pitch is uniform inside a row so every block above lands in contact;
    // the pile gets its irregular silhouette by narrowing as it rises.
    const rh = 26 + r() * 30;
    let x = lo;
    let col = 0;
    while (x < hi - 34) {
      const bw = Math.min(48 + r() * 86, hi - x);
      if (bw < 34) break;
      blocks.push({
        x,
        y: base - rh,
        w: bw,
        h: rh,
        row,
        col,
        tone: Math.round(54 + r() * 16),
        id: 'M' + String(10 + blocks.length),
      });
      x += bw + 2;
      col++;
    }
    base -= rh + 2;
    // Step in on one side or the other, rarely both — a tipped pile, not a
    // pyramid.
    const s = r();
    if (s < 0.45) lo += 22 + r() * 74;
    else if (s < 0.9) hi -= 22 + r() * 74;
    else {
      lo += 16 + r() * 34;
      hi -= 16 + r() * 34;
    }
  }
  for (let i = 0; i < blocks.length; i++) blocks[i].o = i / (blocks.length - 1);
  // Four mask treatments so any two touching instances always differ, while
  // phosphor stays the dominant accent and plasma marks only a minority.
  const MASK = [C.phosphor, C.phosphor, C.plasma, C.phosphor];
  const FILL = [
    'rgba(212,248,92,0.05)',
    'rgba(212,248,92,0.03)',
    'rgba(123,92,255,0.08)',
    'rgba(212,248,92,0.03)',
  ];
  const DASH = [null, [5, 4], null, [2, 4]];
  return {
    id: 'lattice',
    code: '05',
    title: 'Lattice',
    task: 'instance segmentation · dense contact, self-similar parts',
    metricLabel: 'mAP',
    metric: (t) => (0.891 + wave(t, 2, 0.3) * 0.006).toFixed(3),
    draw(ctx, t) {
      ground(ctx);
      grid(ctx, 40);
      // Floor plane the stack actually rests on
      ctx.fillStyle = '#14171c';
      ctx.fillRect(0, FLOOR, W, H - FLOOR);
      ctx.fillStyle = '#2a2f36';
      ctx.fillRect(0, FLOOR, W, 2);
      ctx.fillStyle = 'rgba(0,0,0,0.5)';
      ctx.fillRect(X0 - 26, FLOOR + 2, X1 - X0 + 52, 7);

      // Bottom rows land first, top rows lift first — a build, not a shower.
      const p = ph(t, 1);
      for (const b of blocks) {
        const above = -(b.y + b.h + 40);
        const d0 = b.o * 0.08;
        const l0 = 0.74 + (1 - b.o) * 0.15;
        let dy;
        if (p < d0) dy = above;
        else if (p < d0 + 0.07) {
          const k = (p - d0) / 0.07;
          dy = above * Math.pow(1 - k, 3);
        } else if (p < l0) dy = 0;
        else if (p < l0 + 0.09) {
          const k = (p - l0) / 0.09;
          dy = above * k * k;
        } else dy = above;
        const y = b.y + dy;
        if (y > H) continue;
        const settled = dy === 0;

        // World layer — self-similar parts, deliberately hard to tell apart
        const v = b.tone;
        ctx.fillStyle = `rgb(${v},${v + 5},${v + 12})`;
        ctx.fillRect(b.x, y, b.w, b.h);
        ctx.fillStyle = `rgb(${v + 14},${v + 19},${v + 26})`;
        ctx.fillRect(b.x, y, b.w, 3);
        ctx.fillStyle = `rgb(${v - 16},${v - 11},${v - 4})`;
        ctx.fillRect(b.x, y + b.h - 3, b.w, 3);
        ctx.strokeStyle = 'rgba(8,9,11,0.9)';
        ctx.lineWidth = 1;
        ctx.strokeRect(b.x + 0.5, y + 0.5, b.w - 1, b.h - 1);

        // Perception layer — masks inset so touching instances stay separable
        const vi = (b.row * 3 + b.col) % 4;
        const col = MASK[vi];
        const i = 4;
        ctx.fillStyle = FILL[vi];
        ctx.fillRect(b.x + i, y + i, b.w - i * 2, b.h - i * 2);
        ctx.strokeStyle = col;
        ctx.globalAlpha = settled ? 0.8 : 0.42;
        ctx.lineWidth = 1.4;
        if (DASH[vi]) ctx.setLineDash(DASH[vi]);
        ctx.strokeRect(b.x + i + 0.5, y + i + 0.5, b.w - i * 2 - 1, b.h - i * 2 - 1);
        ctx.setLineDash([]);
        ctx.globalAlpha = 1;

        if (b.w > 92 && b.h > 36) {
          mono(ctx, 10, 700);
          ctx.fillStyle = col;
          ctx.globalAlpha = 0.85;
          ctx.fillText(b.id, b.x + i + 6, y + i + 14);
          meter(ctx, b.x + i + 6, y + i + 19, 30, settled ? 0.94 : 0.55, col);
          ctx.globalAlpha = 1;
        }
      }
      vignette(ctx);
      hud(ctx, lattice, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 06 — TIDE · optical flow
// ---------------------------------------------------------------------------
const tide = (() => {
  const r = mulberry32(517);
  // Two bodies in the stream. The flow has to visibly part around them —
  // without an obstacle a flow field is just noise.
  const OBS = [
    { x: W * 0.33, y: H * 0.42, rad: 64 },
    { x: W * 0.68, y: H * 0.66, rad: 44 },
  ];
  const inside = (x, y, pad) => {
    for (const o of OBS) {
      const dx = x - o.x;
      const dy = y - o.y;
      if (dx * dx + dy * dy < (o.rad + pad) * (o.rad + pad)) return true;
    }
    return false;
  };
  const parts = [];
  while (parts.length < 320) {
    const x = r();
    const y = r();
    if (!inside(x * W, y * H, 4)) parts.push({ x, y, p: r() });
  }
  // Shed vortices trailing each body — periodic, so the wake loops cleanly.
  const VORT = [];
  for (const o of OBS) for (let i = 0; i < 2; i++) VORT.push({ o, off: i / 2, sgn: i % 2 ? 1 : -1 });
  const F = [0, 0];
  const flow = (x, y, t) => {
    let u = 1;
    let v = 0.42 * Math.sin(x * 0.009 + y * 0.013 + wave(t, 1) * 1.9);
    for (const o of OBS) {
      const dx = x - o.x;
      const dy = y - o.y;
      const r2 = dx * dx + dy * dy;
      if (r2 < o.rad * o.rad) {
        F[0] = 0;
        F[1] = 0;
        return F;
      }
      // Potential flow past a cylinder — the classic doublet.
      const k = (o.rad * o.rad) / (r2 * r2);
      u -= k * (dx * dx - dy * dy);
      v -= k * 2 * dx * dy;
    }
    for (const V of VORT) {
      const travel = (V.off + ph(t, 2)) % 1;
      const vx = V.o.x + V.o.rad * 1.7 + travel * 420;
      const vy = V.o.y + V.sgn * V.o.rad * 0.62;
      const dx = x - vx;
      const dy = y - vy;
      const g = (V.sgn * 120 * (1 - travel)) / (dx * dx + dy * dy + 1400);
      u -= dy * g;
      v += dx * g;
    }
    F[0] = u;
    F[1] = v;
    return F;
  };
  return {
    id: 'tide',
    code: '06',
    title: 'Tide',
    task: 'dense optical flow · non-rigid motion, low texture',
    metricLabel: 'EPE',
    metric: (t) => (0.62 + wave(t, 2, 0.6) * 0.05).toFixed(2) + ' px',
    draw(ctx, t) {
      ground(ctx);

      // World layer — advected material, deliberately held down in value so
      // the estimate reads as the brighter thing on top of it.
      ctx.strokeStyle = '#767c86';
      ctx.lineWidth = 1;
      for (const p of parts) {
        const life = (p.p + ph(t, 2)) % 1;
        let x = p.x * W;
        let y = p.y * H;
        ctx.globalAlpha = Math.sin(life * Math.PI) * 0.42;
        ctx.beginPath();
        ctx.moveTo(x, y);
        for (let s = 0; s < 9; s++) {
          const f = flow(x, y, t - s * 0.02);
          x += f[0] * 5;
          y += f[1] * 5;
          ctx.lineTo(x, y);
        }
        ctx.stroke();
      }
      ctx.globalAlpha = 1;

      // The bodies themselves — opaque, so the wake reads as a wake.
      for (const o of OBS) {
        ctx.fillStyle = '#2b3038';
        ctx.beginPath();
        ctx.arc(o.x, o.y, o.rad, 0, TAU);
        ctx.fill();
        ctx.strokeStyle = '#4a5058';
        ctx.lineWidth = 1.5;
        ctx.stroke();
      }

      // Perception layer — the estimated field, the loudest thing in frame.
      const step = 46;
      for (let gx = step * 0.6; gx < W; gx += step) {
        for (let gy = step * 0.6; gy < H; gy += step) {
          if (inside(gx, gy, 2)) continue;
          const f = flow(gx, gy, t);
          const m = Math.hypot(f[0], f[1]);
          if (m < 0.02) continue;
          const norm = Math.min(1, m / 1.9);
          const ux = f[0] / m;
          const uy = f[1] / m;
          const len = 10 + norm * 18;
          // Plasma is reserved for the slack water behind the bodies — the
          // region where the estimate is least certain.
          ctx.strokeStyle = m > 0.82 ? C.phosphor : C.plasma;
          ctx.globalAlpha = 0.3 + norm * 0.45;
          ctx.lineWidth = 1.3;
          ctx.beginPath();
          ctx.moveTo(gx - ux * len * 0.4, gy - uy * len * 0.4);
          const ex = gx + ux * len * 0.6;
          const ey = gy + uy * len * 0.6;
          ctx.lineTo(ex, ey);
          ctx.lineTo(ex - ux * 5 + uy * 3.2, ey - uy * 5 - ux * 3.2);
          ctx.moveTo(ex, ey);
          ctx.lineTo(ex - ux * 5 - uy * 3.2, ey - uy * 5 + ux * 3.2);
          ctx.stroke();
          ctx.globalAlpha = 1;
        }
      }

      // Bodies are holes in the estimate — say so.
      ctx.setLineDash([4, 4]);
      ctx.strokeStyle = C.plasma;
      ctx.lineWidth = 1.3;
      for (const o of OBS) {
        ctx.beginPath();
        ctx.arc(o.x, o.y, o.rad + 7, 0, TAU);
        ctx.stroke();
      }
      ctx.setLineDash([]);
      mono(ctx, 10, 700);
      ctx.fillStyle = C.plasma;
      ctx.fillText('NO-FLOW', OBS[0].x - 26, OBS[0].y + 4);

      // Magnitude key
      const kw = 150;
      const kx = W - kw - 40;
      const ky = H - 74;
      const kg = ctx.createLinearGradient(kx, 0, kx + kw, 0);
      kg.addColorStop(0, '#7b5cff');
      kg.addColorStop(1, '#d4f85c');
      ctx.fillStyle = kg;
      ctx.fillRect(kx, ky, kw, 7);
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('FLOW MAG', kx, ky - 8);
      ctx.fillText('0', kx, ky + 20);
      ctx.fillText('9 px/f', kx + kw - ctx.measureText('9 px/f').width, ky + 20);

      vignette(ctx);
      hud(ctx, tide, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 07 — RELAY · predictive control
// ---------------------------------------------------------------------------
const relay = (() => {
  const AX0 = 62;
  const AX1 = W - 62;
  const AY0 = 62;
  const AY1 = H - 136;
  const PX0 = AX0 + 36;
  const PX1 = AX1 - 36;
  const PY0 = AY0 + 16;
  const PY1 = AY1 - 16;
  const Q = [0, 0];
  const pos = (v) => ((v % 1) + 1) % 1; // ph() keeps the sign of t
  // Reflected linear motion — piecewise straight, periodic over the loop.
  // 12 end-wall returns and 14 side-wall bounces per loop: a rally, so a short
  // forecast still contains visible reflections.
  const puck = (t) => {
    const rx = pos(ph(t, 6)) * 2;
    Q[0] = PX0 + (rx < 1 ? rx : 2 - rx) * (PX1 - PX0);
    const ry = pos(ph(t, 7, 0.17)) * 2;
    Q[1] = PY0 + (ry < 1 ? ry : 2 - ry) * (PY1 - PY0);
    return Q;
  };
  /** Next time the puck reaches the paddle plane on `side` (0 = left). */
  const nextHit = (t, side) => {
    let k = Math.floor((t * 12) / LOOP) + 1;
    if (k % 2 !== side) k++;
    return (LOOP * k) / 12;
  };
  const clampY = (y) => Math.max(AY0 + 34, Math.min(AY1 - 34, y));
  const cmdY = (t, side) => clampY(puck(nextHit(t, side))[1]);
  /** Actuator: chases the live puck but is anchored on the forecast. */
  const padY = (t, side) => 0.45 * clampY(puck(t - 0.09)[1]) + 0.55 * cmdY(t, side);
  return {
    id: 'relay',
    code: '07',
    title: 'Relay',
    task: 'predictive control · intercept under 90 ms latency',
    metricLabel: 'RETURN RATE',
    metric: (t) => (99.1 + wave(t, 2) * 0.4).toFixed(1) + ' %',
    draw(ctx, t) {
      ground(ctx);
      grid(ctx, 30, 'rgba(237,238,240,0.03)');

      // --- Arena furniture --------------------------------------------------
      ctx.fillStyle = '#0b0d11';
      ctx.fillRect(AX0, AY0, AX1 - AX0, AY1 - AY0);
      // Side walls are the reflecting surfaces — draw them as mass.
      ctx.fillStyle = '#2b3038';
      ctx.fillRect(AX0, AY0, AX1 - AX0, 5);
      ctx.fillRect(AX0, AY1 - 5, AX1 - AX0, 5);
      // Paddle planes
      ctx.strokeStyle = 'rgba(237,238,240,0.16)';
      ctx.lineWidth = 1;
      ctx.setLineDash([4, 5]);
      ctx.beginPath();
      for (const px of [PX0, PX1]) {
        ctx.moveTo(px + 0.5, AY0);
        ctx.lineTo(px + 0.5, AY1);
      }
      ctx.moveTo(W / 2, AY0);
      ctx.lineTo(W / 2, AY1);
      ctx.stroke();
      ctx.setLineDash([]);
      // End zones, hatched
      ctx.strokeStyle = 'rgba(237,238,240,0.06)';
      ctx.beginPath();
      for (let d = -60; d < AY1 - AY0 + 60; d += 11) {
        ctx.moveTo(AX0, AY0 + d);
        ctx.lineTo(PX0, AY0 + d + 20);
        ctx.moveTo(PX1, AY0 + d);
        ctx.lineTo(AX1, AY0 + d + 20);
      }
      ctx.stroke();
      // Calibration ticks along both walls
      ctx.strokeStyle = 'rgba(237,238,240,0.2)';
      ctx.beginPath();
      for (let gx = PX0; gx <= PX1 + 1; gx += 36) {
        const big = Math.round((gx - PX0) / 36) % 5 === 0;
        ctx.moveTo(gx + 0.5, AY0 + 5);
        ctx.lineTo(gx + 0.5, AY0 + 5 + (big ? 11 : 5));
        ctx.moveTo(gx + 0.5, AY1 - 5);
        ctx.lineTo(gx + 0.5, AY1 - 5 - (big ? 11 : 5));
      }
      ctx.stroke();
      ctx.strokeStyle = 'rgba(237,238,240,0.12)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.arc(W / 2, (AY0 + AY1) / 2, 46, 0, TAU);
      ctx.moveTo(W / 2 - 10, (AY0 + AY1) / 2);
      ctx.lineTo(W / 2 + 10, (AY0 + AY1) / 2);
      ctx.stroke();
      bracket(ctx, AX0, AY0, AX1 - AX0, AY1 - AY0, 'rgba(237,238,240,0.24)', { lw: 1, corner: 18 });


      const pk = puck(t);
      const x = pk[0];
      const y = pk[1];

      // Recent wall impacts — evidence the model is being scored against
      ctx.lineWidth = 1.4;
      for (let k = -2; k <= 26; k++) {
        for (const fam of [0, 1]) {
          const tk = fam ? (LOOP * k) / 12 : (LOOP * (k * 0.5 - 0.17)) / 7;
          const age = (((t - tk) % LOOP) + LOOP) % LOOP;
          if (age > 2.4) continue;
          const p = puck(tk);
          const hx = p[0];
          const hy = p[1];
          ctx.strokeStyle = C.phosphor;
          ctx.globalAlpha = (1 - age / 2.4) * 0.7;
          ctx.beginPath();
          if (fam) {
            ctx.moveTo(hx, hy - 8);
            ctx.lineTo(hx, hy + 8);
          } else {
            ctx.moveTo(hx - 8, hy);
            ctx.lineTo(hx + 8, hy);
          }
          ctx.stroke();
          ctx.globalAlpha = 1;
        }
      }

      // Trail — a motion streak, not a path history. The puck crosses the
      // arena in about a second, so a longer tail draws most of a circuit and
      // the panel reads as a closed diagonal shape rather than a rally.
      const TR = 10;
      ctx.lineWidth = 2.4;
      ctx.strokeStyle = C.porcelain;
      for (let i = 0; i < TR; i++) {
        const a = puck(t - i * 0.022);
        const ax = a[0];
        const ay = a[1];
        const b = puck(t - (i + 1) * 0.022);
        ctx.globalAlpha = 0.5 * (1 - i / TR);
        ctx.beginPath();
        ctx.moveTo(ax, ay);
        ctx.lineTo(b[0], b[1]);
        ctx.stroke();
      }
      ctx.globalAlpha = 1;

      // --- Forecast: a bouncing puck. Confidence decays along the horizon,
      // so the polyline reads forward in time instead of closing into a shape.
      const NF = 16;
      let lx = x;
      let ly = y;
      let vsx = 0;
      let vsy = 0;
      const bounces = [];
      ctx.lineWidth = 2;
      ctx.strokeStyle = C.phosphor;
      for (let i = 1; i <= NF; i++) {
        const f = puck(t + i * 0.02);
        const fx = f[0];
        const fy = f[1];
        const sx = Math.sign(fx - lx);
        const sy = Math.sign(fy - ly);
        if (i > 1 && sx !== 0 && vsx !== 0 && sx !== vsx) bounces.push(lx, ly, 1);
        if (i > 1 && sy !== 0 && vsy !== 0 && sy !== vsy) bounces.push(lx, ly, 0);
        if (sx !== 0) vsx = sx;
        if (sy !== 0) vsy = sy;
        ctx.globalAlpha = 0.9 * (1 - i / NF) + 0.08;
        ctx.beginPath();
        ctx.moveTo(lx, ly);
        ctx.lineTo(fx, fy);
        ctx.stroke();
        // Chevrons carry the direction of travel
        if (i % 9 === 0) {
          const d = Math.hypot(fx - lx, fy - ly) || 1;
          const ux = (fx - lx) / d;
          const uy = (fy - ly) / d;
          ctx.beginPath();
          ctx.moveTo(fx - ux * 8 + uy * 5, fy - uy * 8 - ux * 5);
          ctx.lineTo(fx, fy);
          ctx.lineTo(fx - ux * 8 - uy * 5, fy - uy * 8 + ux * 5);
          ctx.stroke();
        }
        lx = fx;
        ly = fy;
      }
      ctx.globalAlpha = 1;
      // Predicted reflection points, on the wall they bounce off
      for (let i = 0; i < bounces.length; i += 3) {
        const bx = bounces[i];
        const by = bounces[i + 1];
        ctx.strokeStyle = C.phosphor;
        ctx.lineWidth = 1.4;
        ctx.strokeRect(bx - 5.5, by - 5.5, 11, 11);
        ctx.beginPath();
        if (bounces[i + 2]) {
          ctx.moveTo(bx, by - 15);
          ctx.lineTo(bx, by + 15);
        } else {
          ctx.moveTo(bx - 15, by);
          ctx.lineTo(bx + 15, by);
        }
        ctx.stroke();
      }
      // Uncertainty growing with the horizon
      ctx.strokeStyle = C.plasma;
      ctx.lineWidth = 1.2;
      for (const q of [0.45, 0.75, 1]) {
        const f = puck(t + NF * 0.02 * q);
        ctx.globalAlpha = 0.75 - q * 0.3;
        ctx.beginPath();
        ctx.ellipse(f[0], f[1], 7 + q * 16, 5 + q * 11, 0, 0, TAU);
        ctx.stroke();
      }
      ctx.globalAlpha = 1;

      // Intercept — the one critical state in the frame
      const th = nextHit(t, 0) - t < nextHit(t, 1) - t ? nextHit(t, 0) : nextHit(t, 1);
      const ip = puck(th);
      const ix = ip[0];
      const iy = ip[1];
      ctx.strokeStyle = C.ember;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.arc(ix, iy, 12, 0, TAU);
      ctx.moveTo(ix - 19, iy);
      ctx.lineTo(ix - 7, iy);
      ctx.moveTo(ix + 7, iy);
      ctx.lineTo(ix + 19, iy);
      ctx.stroke();
      mono(ctx, 11, 700);
      ctx.fillStyle = C.ember;
      const il = 'T+' + (th - t).toFixed(2);
      ctx.fillText(il, ix + (ix > W / 2 ? -22 - ctx.measureText(il).width : 22), iy + 4);

      // Paddles — grey actuator, phosphor commanded position
      for (const side of [0, 1]) {
        const px = side ? PX1 + 4 : PX0 - 12;
        const ay = padY(t, side);
        const cy = cmdY(t, side);
        ctx.fillStyle = '#4a5058';
        ctx.fillRect(px, ay - 30, 8, 60);
        ctx.fillStyle = '#5b626c';
        ctx.fillRect(px, ay - 30, 8, 3);
        ctx.strokeStyle = C.phosphor;
        ctx.lineWidth = 1.4;
        ctx.beginPath();
        ctx.moveTo(px - 6, cy - 30);
        ctx.lineTo(px + 14, cy - 30);
        ctx.moveTo(px - 6, cy + 30);
        ctx.lineTo(px + 14, cy + 30);
        ctx.stroke();
      }

      // Puck
      ctx.fillStyle = C.porcelain;
      ctx.beginPath();
      ctx.arc(x, y, 6.5, 0, TAU);
      ctx.fill();
      bracket(ctx, x - 19, y - 19, 38, 38, C.phosphor, { lw: 1.4, corner: 8, label: 'PUCK' });

      // Live state vector — what the controller is actually consuming
      const stx = AX0 + 16;
      const sty = AY0 + 16;
      const pv = puck(t - 0.02);
      const vx2 = (x - pv[0]) / 0.02;
      const vy2 = (y - pv[1]) / 0.02;
      ctx.fillStyle = 'rgba(8,9,11,0.82)';
      ctx.fillRect(stx, sty, 190, 64);
      ctx.strokeStyle = 'rgba(237,238,240,0.12)';
      ctx.lineWidth = 1;
      ctx.strokeRect(stx + 0.5, sty + 0.5, 189, 63);
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('STATE', stx + 10, sty + 16);
      mono(ctx, 11, 500);
      ctx.fillStyle = C.porcelain;
      ctx.fillText(
        `P  ${(x - PX0).toFixed(0).padStart(3)} , ${(y - PY0).toFixed(0).padStart(3)} mm`,
        stx + 10,
        sty + 36,
      );
      ctx.fillText(
        `V  ${(Math.hypot(vx2, vy2) * 0.004).toFixed(2)} m/s  ` +
          `${((Math.atan2(vy2, vx2) * 180) / Math.PI).toFixed(0)}°`,
        stx + 10,
        sty + 54,
      );

      // --- Telemetry strip --------------------------------------------------
      const ty = AY1 + 16;
      const cw = (AX1 - AX0) / 3;
      ctx.strokeStyle = 'rgba(237,238,240,0.1)';
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(AX0, ty + 0.5);
      ctx.lineTo(AX1, ty + 0.5);
      for (let i = 1; i < 3; i++) {
        ctx.moveTo(AX0 + cw * i, ty);
        ctx.lineTo(AX0 + cw * i, ty + 56);
      }
      ctx.stroke();
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('RALLY', AX0 + 12, ty + 18);
      ctx.fillText('CONTROL LATENCY', AX0 + cw + 12, ty + 18);
      ctx.fillText('TRACKING ERROR · PADDLE A', AX0 + cw * 2 + 12, ty + 18);

      const rally = 1 + Math.floor(ph(t, 1) * 12);
      mono(ctx, 20, 700);
      ctx.fillStyle = C.porcelain;
      ctx.fillText(String(rally).padStart(2, '0'), AX0 + 12, ty + 44);
      for (let i = 0; i < 12; i++) {
        ctx.fillStyle = i < rally ? C.phosphor : 'rgba(237,238,240,0.14)';
        ctx.fillRect(AX0 + 52 + i * 10, ty + 34, 6, 10);
      }

      const lat = 90 + wave(t, 3) * 4;
      mono(ctx, 20, 700);
      ctx.fillStyle = C.porcelain;
      ctx.fillText(lat.toFixed(0), AX0 + cw + 12, ty + 44);
      mono(ctx, 10, 500);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('ms / 120 BUDGET', AX0 + cw + 44, ty + 44);
      meter(ctx, AX0 + cw + 12, ty + 50, cw - 30, lat / 120, C.phosphor);

      // Live residual between commanded and achieved paddle position
      const sw = cw - 30;
      const sx0 = AX0 + cw * 2 + 12;
      let emax = 0.001;
      ctx.beginPath();
      for (let i = 0; i <= 40; i++) {
        const tt = t - (40 - i) * 0.03;
        const e = Math.abs(padY(tt, 0) - cmdY(tt, 0));
        emax = Math.max(emax, e);
      }
      for (let i = 0; i <= 40; i++) {
        const tt = t - (40 - i) * 0.03;
        const e = Math.abs(padY(tt, 0) - cmdY(tt, 0));
        const sxx = sx0 + 84 + (i / 40) * (sw - 84);
        const syy = ty + 50 - (e / emax) * 22;
        if (i === 0) ctx.moveTo(sxx, syy);
        else ctx.lineTo(sxx, syy);
      }
      ctx.strokeStyle = C.phosphor;
      ctx.lineWidth = 1.4;
      ctx.stroke();
      mono(ctx, 20, 700);
      ctx.fillStyle = C.porcelain;
      ctx.fillText((emax * 0.06).toFixed(1) + ' mm', sx0, ty + 44);

      vignette(ctx);
      hud(ctx, relay, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 08 — QUARRY · occupancy mapping
// ---------------------------------------------------------------------------
const quarry = (() => {
  const cols = 20;
  const rows = 12;
  const tw = 28;
  const th = 14;
  const r = mulberry32(919);
  const heights = [];
  for (let i = 0; i < cols * rows; i++) heights.push(r());
  return {
    id: 'quarry',
    code: '08',
    title: 'Quarry',
    task: 'volumetric occupancy · sparse returns, moving ground plane',
    metricLabel: 'VOXEL IoU',
    metric: (t) => (0.847 + wave(t, 2, 0.15) * 0.008).toFixed(3),
    draw(ctx, t) {
      ground(ctx);
      // Centred on the lattice's own axis rather than the canvas: with
      // cols != rows the diamond is lopsided and W/2 runs it off the frame.
      const ox = W / 2 - ((cols - rows) / 2) * tw;
      const oy = 100;
      const sweep = ph(t, 1) * (cols + rows + 6) - 3;

      for (let j = 0; j < rows; j++) {
        for (let i = 0; i < cols; i++) {
          const hRaw = heights[j * cols + i];
          const carve = 0.5 + 0.5 * Math.sin(i * 0.4 + j * 0.3 + wave(t, 1) * 2.2);
          const h = 8 + hRaw * 62 * carve;
          const x = ox + (i - j) * tw;
          const y = oy + (i + j) * th - h;
          const scanned = i + j < sweep;
          const edge = Math.abs(i + j - sweep) < 1.2;

          // Top face
          ctx.beginPath();
          ctx.moveTo(x, y);
          ctx.lineTo(x + tw, y + th);
          ctx.lineTo(x, y + th * 2);
          ctx.lineTo(x - tw, y + th);
          ctx.closePath();
          ctx.fillStyle = edge ? C.phosphor : scanned ? '#2e343d' : C.worldFaint;
          ctx.fill();
          ctx.strokeStyle = edge ? C.phosphor : scanned ? C.phosphorFaint : 'rgba(237,238,240,0.05)';
          ctx.lineWidth = 1;
          ctx.stroke();
          // Left face
          ctx.beginPath();
          ctx.moveTo(x - tw, y + th);
          ctx.lineTo(x, y + th * 2);
          ctx.lineTo(x, y + th * 2 + h);
          ctx.lineTo(x - tw, y + th + h);
          ctx.closePath();
          ctx.fillStyle = scanned ? '#1a1e25' : '#12151a';
          ctx.fill();
          // Right face
          ctx.beginPath();
          ctx.moveTo(x + tw, y + th);
          ctx.lineTo(x, y + th * 2);
          ctx.lineTo(x, y + th * 2 + h);
          ctx.lineTo(x + tw, y + th + h);
          ctx.closePath();
          ctx.fillStyle = scanned ? '#22262e' : '#161a20';
          ctx.fill();
        }
      }
      vignette(ctx);
      hud(ctx, quarry, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 09 — ORBIT · collision avoidance
// ---------------------------------------------------------------------------
const orbit = (() => {
  const r = mulberry32(1223);
  const debris = [];
  for (let i = 0; i < 30; i++) {
    debris.push({
      a: r(),
      rad: 70 + r() * 210,
      sp: (1 + Math.floor(r() * 3)) * (r() > 0.5 ? 1 : -1),
      sz: 3 + r() * 7,
      threat: r() > 0.78,
    });
  }
  return {
    id: 'orbit',
    code: '09',
    title: 'Orbit',
    task: 'collision avoidance · 30 tracks, 2 s decision window',
    metricLabel: 'MIN SEPARATION',
    metric: (t) => (41 + Math.abs(wave(t, 2)) * 12).toFixed(0) + ' m',
    draw(ctx, t) {
      ground(ctx);
      const cx = W / 2;
      const cy = H / 2;

      // Range rings
      ctx.strokeStyle = 'rgba(237,238,240,0.07)';
      ctx.lineWidth = 1;
      for (let i = 1; i <= 5; i++) {
        ctx.beginPath();
        ctx.arc(cx, cy, i * 56, 0, TAU);
        ctx.stroke();
      }
      ctx.beginPath();
      for (let i = 0; i < 12; i++) {
        const a = (i / 12) * TAU;
        ctx.moveTo(cx, cy);
        ctx.lineTo(cx + Math.cos(a) * 290, cy + Math.sin(a) * 290);
      }
      ctx.stroke();

      // Radar sweep
      const sa = ph(t, 1) * TAU;
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(sa);
      const grad = ctx.createLinearGradient(0, 0, 290, 0);
      grad.addColorStop(0, 'rgba(212,248,92,0.22)');
      grad.addColorStop(1, 'rgba(212,248,92,0)');
      ctx.fillStyle = grad;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.arc(0, 0, 290, -0.5, 0);
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = C.phosphorDim;
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(0, 0);
      ctx.lineTo(290, 0);
      ctx.stroke();
      ctx.restore();

      for (const d of debris) {
        const a = (d.a + ph(t, d.sp)) * TAU;
        const x = cx + Math.cos(a) * d.rad;
        const y = cy + Math.sin(a) * d.rad * 0.72;
        ctx.fillStyle = d.threat ? C.ember : C.world;
        ctx.fillRect(x - d.sz / 2, y - d.sz / 2, d.sz, d.sz);
        if (d.threat) {
          bracket(ctx, x - 13, y - 13, 26, 26, C.ember, { lw: 1.2, corner: 6 });
          ctx.strokeStyle = 'rgba(255,90,61,0.35)';
          ctx.setLineDash([3, 4]);
          ctx.beginPath();
          ctx.moveTo(x, y);
          ctx.lineTo(cx, cy);
          ctx.stroke();
          ctx.setLineDash([]);
        } else {
          ctx.strokeStyle = C.phosphorFaint;
          ctx.lineWidth = 1;
          ctx.beginPath();
          ctx.arc(x, y, 9, 0, TAU);
          ctx.stroke();
        }
      }

      // Own craft + avoidance vector
      const dodge = wave(t, 3) * 26;
      ctx.fillStyle = C.porcelain;
      ctx.beginPath();
      ctx.moveTo(cx + dodge, cy - 11);
      ctx.lineTo(cx + dodge + 8, cy + 8);
      ctx.lineTo(cx + dodge - 8, cy + 8);
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = C.phosphor;
      ctx.lineWidth = 1.4;
      ctx.beginPath();
      ctx.moveTo(cx + dodge, cy);
      ctx.lineTo(cx + dodge + wave(t, 3, 0.25) * 40, cy - 44);
      ctx.stroke();

      vignette(ctx);
      hud(ctx, orbit, t);
    },
  };
})();

// ---------------------------------------------------------------------------
// 10 — PARSE · symbol recognition
// ---------------------------------------------------------------------------
const parse = (() => {
  const glyphs = '⌁⌂⌘⍜⎔⎈⌬⏣◈◇◆⬡⬢▤▥▩◫⧉⧗⧖'.split('');
  const r = mulberry32(1721);
  const items = [];
  for (let i = 0; i < 56; i++) {
    items.push({
      x: 0.05 + r() * 0.9,
      p: r(),
      sp: 1 + Math.floor(r() * 2), // integer, so the drift wraps on the loop
      g: glyphs[Math.floor(r() * glyphs.length)],
      size: 26 + r() * 28,
      conf: 0.6 + r() * 0.39,
      rot: (r() - 0.5) * 0.45,
    });
  }
  const out = 'ΣΞ∮⌁⎔◈⬡▩⧉∴';
  return {
    id: 'parse',
    code: '10',
    title: 'Parse',
    task: 'symbol recognition · unseen glyph sets, adversarial noise',
    metricLabel: 'TOP-1',
    metric: (t) => (97.4 + wave(t, 2, 0.4) * 0.3).toFixed(1) + ' %',
    draw(ctx, t) {
      ground(ctx);
      grid(ctx, 48);

      // --- Scan band: a real sweeping aperture, not a hairline -------------
      const by = ph(t, 1) * (H + 220) - 110;
      const bh = 96;
      const bg = ctx.createLinearGradient(0, by - bh, 0, by);
      bg.addColorStop(0, 'rgba(212,248,92,0)');
      bg.addColorStop(1, 'rgba(212,248,92,0.16)');
      ctx.fillStyle = bg;
      ctx.fillRect(0, by - bh, W, bh);
      ctx.strokeStyle = 'rgba(212,248,92,0.3)';
      ctx.lineWidth = 1;
      ctx.setLineDash([6, 6]);
      ctx.beginPath();
      ctx.moveTo(0, by - bh + 0.5);
      ctx.lineTo(W, by - bh + 0.5);
      ctx.stroke();
      ctx.setLineDash([]);
      ctx.strokeStyle = C.phosphor;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.moveTo(0, by);
      ctx.lineTo(W, by);
      for (let gx = 24; gx < W; gx += 48) {
        ctx.moveTo(gx + 0.5, by);
        ctx.lineTo(gx + 0.5, by - 7);
      }
      ctx.stroke();
      mono(ctx, 10, 700);
      ctx.fillStyle = C.phosphor;
      ctx.fillText('SCAN ' + String(Math.floor(ph(t, 1) * 512)).padStart(3, '0'), 30, by - 10);

      for (const it of items) {
        // Glyphs drift up, the aperture sweeps down: state changes read crisply.
        const y = ((((it.p - ph(t, it.sp)) % 1) + 1) % 1) * (H + 200) - 100;
        const x = it.x * W;
        const d = by - y;
        const locking = d >= 0 && d < 200;
        const done = d >= 200;
        const weak = it.conf < 0.66;
        const col = weak ? C.plasma : C.phosphor;
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate(it.rot);
        ctx.font = `400 ${it.size}px "JetBrains Mono", ui-monospace, monospace`;
        ctx.textAlign = 'center';
        ctx.fillStyle = locking ? C.porcelain : done ? '#9aa0a8' : '#7b818a';
        ctx.fillText(it.g, 0, 0);
        ctx.restore();
        ctx.textAlign = 'left';
        const s = it.size;
        if (locking) {
          bracket(ctx, x - s * 0.62, y - s * 0.82, s * 1.24, s * 1.08, col, {
            lw: 1.5,
            corner: 8,
          });
          meter(ctx, x - s * 0.62, y + s * 0.34, s * 1.24, it.conf, col);
          mono(ctx, 10, 700);
          ctx.fillStyle = col;
          ctx.fillText(
            weak ? 'AMBIG' : (it.conf * 100).toFixed(1),
            x - s * 0.62,
            y - s * 0.82 - 5,
          );
        } else if (done) {
          // Confirmed — kept, but demoted to a single tick
          ctx.fillStyle = col;
          ctx.globalAlpha = 0.55;
          ctx.fillRect(x - s * 0.4, y + s * 0.3, s * 0.8, 2);
          ctx.globalAlpha = 1;
        }
      }

      // --- Live decode ------------------------------------------------------
      const n = Math.floor(ph(t, 1) * (out.length + 1));
      const pw = 348;
      const panY = H - 142;
      const panH = 80;
      ctx.fillStyle = 'rgba(8,9,11,0.92)';
      ctx.fillRect(38, panY, pw, panH);
      ctx.strokeStyle = 'rgba(237,238,240,0.14)';
      ctx.lineWidth = 1;
      ctx.strokeRect(38.5, panY + 0.5, pw - 1, panH - 1);
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('DECODE · STREAM 0x1F', 50, panY + 18);
      const txt = out.slice(0, n);
      ctx.font = '500 26px "JetBrains Mono", ui-monospace, monospace';
      ctx.fillStyle = C.phosphor;
      ctx.fillText(txt, 50, panY + 50);
      if (Math.sin(t * 8) > 0) {
        ctx.fillStyle = C.phosphorDim;
        ctx.fillText('▌', 50 + ctx.measureText(txt).width, panY + 50);
      }
      // Per-symbol confidence, one pip each
      for (let i = 0; i < out.length; i++) {
        ctx.fillStyle = i < n ? C.phosphor : 'rgba(237,238,240,0.13)';
        ctx.fillRect(50 + i * 22, panY + 62, 16, 5);
      }

      // Candidate stack for the symbol currently being committed
      const cx = 38 + pw + 14;
      const cwid = 196;
      ctx.fillStyle = 'rgba(8,9,11,0.92)';
      ctx.fillRect(cx, panY, cwid, panH);
      ctx.strokeStyle = 'rgba(237,238,240,0.14)';
      ctx.strokeRect(cx + 0.5, panY + 0.5, cwid - 1, panH - 1);
      mono(ctx, 10, 600);
      ctx.fillStyle = C.greyDim;
      ctx.fillText('CANDIDATES', cx + 12, panY + 18);
      const top1 = out[Math.max(0, n - 1)];
      const cands = [top1, glyphs[(n * 5) % glyphs.length], glyphs[(n * 11 + 3) % glyphs.length]];
      const scores = [0.97, 0.02, 0.01];
      for (let i = 0; i < 3; i++) {
        const ry = panY + 36 + i * 17;
        ctx.font = `400 15px "JetBrains Mono", ui-monospace, monospace`;
        ctx.fillStyle = i === 0 ? C.phosphor : C.greyDim;
        ctx.fillText(cands[i], cx + 12, ry);
        meter(ctx, cx + 36, ry - 5, 100, scores[i], i === 0 ? C.phosphor : C.plasma);
        mono(ctx, 10, 500);
        ctx.fillStyle = i === 0 ? C.porcelain : C.greyDim;
        ctx.fillText(scores[i].toFixed(2), cx + 146, ry);
      }

      vignette(ctx);
      hud(ctx, parse, t);
    },
  };
})();

export const SCENES = [drift, canopy, hallway, swarm, lattice, tide, relay, quarry, orbit, parse];
