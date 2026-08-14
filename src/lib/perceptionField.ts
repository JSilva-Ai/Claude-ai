/**
 * Perception Field — the hero renderer.
 *
 * Concept: a depth sensor sweeping an unknown surface. Wavefronts propagate
 * outward from a slowly drifting sensor origin; points return a value as the
 * front crosses them and decay behind it, so the geometry is *inferred over
 * time* rather than simply displayed. That is the thesis of the lab, drawn.
 *
 * Cost: one buffer, two draw calls, no per-frame allocation, no dependencies.
 * Degrades to a static CSS field when WebGL2 is unavailable or the visitor
 * prefers reduced motion.
 */

import { create, lookAt, multiply, perspective, type Mat4 } from './mat4';

const VERT = /* glsl */ `#version 300 es
precision highp float;

in vec2 a_grid;      // position on the sampled plane, [-1, 1]
in vec2 a_seed;      // per-point randomness: .x confidence, .y jitter phase

uniform mat4 u_viewProj;
uniform float u_time;
uniform vec2 u_origin;      // sensor origin on the plane
uniform float u_dpr;
uniform float u_reveal;     // 0..1 load choreography
uniform float u_aspect;
uniform float u_resolved;  // 0 = scanning, 1 = settled

out float v_intensity;
out float v_conf;
out float v_depth;

// Deterministic surface. Layered sines rather than noise textures: no fetch,
// no upload, identical every reload — the terrain is part of the identity.
float surface(vec2 p) {
  float h = 0.0;
  h += 0.42 * sin(p.x * 1.7 + 0.6) * cos(p.y * 1.4 - 0.3);
  h += 0.22 * sin(p.x * 3.3 - p.y * 2.1 + 1.7);
  h += 0.11 * cos(p.x * 6.1 + p.y * 5.4);
  h += 0.05 * sin(p.x * 12.0 - p.y * 9.0);
  // A shallow basin keeps the silhouette from reading as generic noise.
  h -= 0.5 * exp(-dot(p, p) * 0.55);
  return h;
}

void main() {
  vec2 p = a_grid * vec2(u_aspect, 1.0) * 7.2;

  // Breathing drift — the surface is alive but never busy.
  p += vec2(sin(u_time * 0.06 + a_seed.y * 6.283) * 0.03,
            cos(u_time * 0.05 + a_seed.y * 6.283) * 0.03);

  float h = surface(p);
  vec3 world = vec3(p.x, h, p.y);

  // --- Sweep -------------------------------------------------------------
  // Three concurrent wavefronts at phase offsets. Ahead of a front a point is
  // unknown; the instant it is crossed it returns at full strength, then decays.
  float d = distance(p, u_origin);
  float intensity = 0.0;
  for (int i = 0; i < 3; i++) {
    float phase = float(i) * 0.3333;
    float r = fract(u_time * 0.062 + phase) * 18.0;
    float delta = d - r;
    // Behind the front (delta < 0): exponential decay. Ahead: hard cutoff.
    float behind = exp(delta * 0.55) * step(delta, 0.0);
    float front = exp(-delta * delta * 7.0);
    intensity = max(intensity, max(behind * 0.62, front));
  }

  // Once resolved, the surface holds its return instead of decaying — the
  // closing state of the narrative the hero opens.
  intensity = mix(intensity, max(intensity, 0.62 + 0.38 * sin(d * 0.9 - u_time * 0.35)), u_resolved);

  // Confidence gates the return — a real sensor does not resolve every point.
  float conf = a_seed.x;
  intensity *= mix(0.34, 1.0, smoothstep(0.15, 0.95, conf));

  // Load choreography: the field resolves outward from the centre.
  float revealGate = smoothstep(0.0, 1.0, u_reveal * 2.4 - d * 0.1);
  intensity *= revealGate;

  // Returned points lift slightly toward the sensor — the surface "answers".
  world.y += intensity * 0.16;

  vec4 clip = u_viewProj * vec4(world, 1.0);
  gl_Position = clip;

  float depth = clip.w;
  v_depth = depth;
  v_intensity = intensity;
  v_conf = conf;

  // Size attenuation, clamped so distant points stay legible as single pixels
  // and near points never bloom into blobs.
  float size = (2.5 + intensity * 3.6) * u_dpr * (7.6 / max(depth, 0.9));
  gl_PointSize = clamp(size, 1.0 * u_dpr, 7.0 * u_dpr);
}
`;

const FRAG = /* glsl */ `#version 300 es
precision highp float;

in float v_intensity;
in float v_conf;
in float v_depth;

uniform vec3 u_phosphor;
uniform vec3 u_plasma;
uniform vec3 u_rest;

out vec4 outColor;

void main() {
  // Round point with a soft edge; cheaper and sharper than a texture.
  vec2 uv = gl_PointCoord * 2.0 - 1.0;
  float r2 = dot(uv, uv);
  if (r2 > 1.0) discard;
  float alpha = smoothstep(1.0, 0.15, r2);

  // Unresolved points sit near the ground colour. Returns run phosphor.
  // Plasma appears only in the mid band, as depth cue — never as a gradient.
  vec3 col = u_rest;
  col = mix(col, u_plasma, smoothstep(0.05, 0.45, v_intensity) * 0.5);
  col = mix(col, u_phosphor, smoothstep(0.35, 1.0, v_intensity));

  // Distance fog to ink keeps the horizon from forming a hard edge.
  float fog = 1.0 - smoothstep(16.0, 46.0, v_depth);

  float a = alpha * fog * (0.55 + v_intensity * 0.85) * (0.5 + v_conf * 0.5);
  outColor = vec4(col * (0.95 + v_intensity * 0.75), a);
}
`;

function compile(gl: WebGL2RenderingContext, type: number, src: string): WebGLShader | null {
  const sh = gl.createShader(type);
  if (!sh) return null;
  gl.shaderSource(sh, src);
  gl.compileShader(sh);
  if (!gl.getShaderParameter(sh, gl.COMPILE_STATUS)) {
    if (import.meta.env.DEV) console.warn(gl.getShaderInfoLog(sh));
    gl.deleteShader(sh);
    return null;
  }
  return sh;
}

export interface FieldHandle {
  destroy(): void;
}

export interface FieldOptions {
  /** Pointer parallax target, normalised -1..1. Read each frame. */
  pointer: { x: number; y: number };
  /** Set false to render a single resolved frame and stop. */
  animate: boolean;
  /**
   * 'scan' — the hero: geometry inferred over time, decaying behind the front.
   * 'resolved' — the closing section: the same surface, fully returned.
   */
  mode?: 'scan' | 'resolved';
  onReady?: () => void;
}

export function createPerceptionField(
  canvas: HTMLCanvasElement,
  opts: FieldOptions,
): FieldHandle | null {
  const gl = canvas.getContext('webgl2', {
    antialias: false,
    alpha: true,
    depth: false,
    powerPreference: 'high-performance',
    failIfMajorPerformanceCaveat: false,
  });
  if (!gl) return null;

  const vs = compile(gl, gl.VERTEX_SHADER, VERT);
  const fs = compile(gl, gl.FRAGMENT_SHADER, FRAG);
  if (!vs || !fs) return null;

  const prog = gl.createProgram()!;
  gl.attachShader(prog, vs);
  gl.attachShader(prog, fs);
  gl.linkProgram(prog);
  gl.deleteShader(vs);
  gl.deleteShader(fs);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) {
    if (import.meta.env.DEV) console.warn(gl.getProgramInfoLog(prog));
    return null;
  }

  // --- Geometry ------------------------------------------------------------
  // Point budget scales with device capability. A phone renders a sparser but
  // compositionally identical field — not a degraded one.
  const coarse = window.matchMedia('(pointer: coarse)').matches;
  const lowCores = (navigator.hardwareConcurrency ?? 8) <= 4;
  const density = coarse || lowCores ? 150 : 264;
  const count = density * density;

  const data = new Float32Array(count * 4);
  let i = 0;
  for (let y = 0; y < density; y++) {
    for (let x = 0; x < density; x++) {
      // Jittered lattice — a pure grid reads as a mesh, jitter reads as samples.
      const jx = (Math.random() - 0.5) * 1.35;
      const jy = (Math.random() - 0.5) * 1.35;
      data[i++] = ((x + 0.5 + jx) / density) * 2 - 1;
      data[i++] = ((y + 0.5 + jy) / density) * 2 - 1;
      data[i++] = Math.random(); // confidence
      data[i++] = Math.random(); // phase
    }
  }

  const vao = gl.createVertexArray();
  gl.bindVertexArray(vao);
  const buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, data, gl.STATIC_DRAW);

  const aGrid = gl.getAttribLocation(prog, 'a_grid');
  const aSeed = gl.getAttribLocation(prog, 'a_seed');
  gl.enableVertexAttribArray(aGrid);
  gl.vertexAttribPointer(aGrid, 2, gl.FLOAT, false, 16, 0);
  gl.enableVertexAttribArray(aSeed);
  gl.vertexAttribPointer(aSeed, 2, gl.FLOAT, false, 16, 8);
  gl.bindVertexArray(null);

  const u = {
    viewProj: gl.getUniformLocation(prog, 'u_viewProj'),
    time: gl.getUniformLocation(prog, 'u_time'),
    origin: gl.getUniformLocation(prog, 'u_origin'),
    dpr: gl.getUniformLocation(prog, 'u_dpr'),
    reveal: gl.getUniformLocation(prog, 'u_reveal'),
    aspect: gl.getUniformLocation(prog, 'u_aspect'),
    resolved: gl.getUniformLocation(prog, 'u_resolved'),
    phosphor: gl.getUniformLocation(prog, 'u_phosphor'),
    plasma: gl.getUniformLocation(prog, 'u_plasma'),
    rest: gl.getUniformLocation(prog, 'u_rest'),
  };

  const proj = create();
  const view = create();
  const viewProj: Mat4 = create();

  let dpr = 1;
  let width = 0;
  let height = 0;

  function resize() {
    // Cap DPR at 1.75: beyond that the field costs fill rate no one can see.
    dpr = Math.min(window.devicePixelRatio || 1, 1.75);
    const rect = canvas.getBoundingClientRect();
    const w = Math.max(1, Math.round(rect.width * dpr));
    const h = Math.max(1, Math.round(rect.height * dpr));
    if (w === width && h === height) return;
    width = w;
    height = h;
    canvas.width = w;
    canvas.height = h;
    gl!.viewport(0, 0, w, h);
  }

  const ro = new ResizeObserver(resize);
  ro.observe(canvas);
  resize();

  gl.enable(gl.BLEND);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
  gl.clearColor(0, 0, 0, 0);

  let raf = 0;
  let start = performance.now();
  let visible = true;
  let ready = false;
  // Eased pointer — raw pointer values make the camera feel nervous.
  let px = 0;
  let py = 0;

  const io = new IntersectionObserver(
    (entries) => {
      visible = entries[0].isIntersecting;
      if (visible && opts.animate && !raf) {
        // Resume without a time jump.
        start = performance.now() - elapsed * 1000;
        raf = requestAnimationFrame(frame);
      } else if (!visible && raf) {
        cancelAnimationFrame(raf);
        raf = 0;
      }
    },
    { threshold: 0 },
  );
  io.observe(canvas);

  let elapsed = 0;

  function frame(now: number) {
    raf = opts.animate ? requestAnimationFrame(frame) : 0;
    elapsed = (now - start) / 1000;
    draw(elapsed);
  }

  function draw(t: number) {
    const aspect = width / height || 1;

    px += (opts.pointer.x - px) * 0.045;
    py += (opts.pointer.y - py) * 0.045;

    // Slow orbit. The camera is a sensor on a rail, not a showreel move.
    const resolved = opts.mode === 'resolved';
    const orbit = t * (resolved ? 0.017 : 0.028);
    const eyeX = Math.sin(orbit) * (resolved ? 2.4 : 1.6) + px * 1.15;
    const eyeY = (resolved ? 2.3 : 3.4) + Math.sin(t * 0.045) * 0.26 - py * 0.7;
    const eyeZ = (resolved ? 7.2 : 8.4) + Math.cos(orbit) * 0.9;

    perspective(proj, (48 * Math.PI) / 180, aspect, 0.1, 60);
    lookAt(view, [eyeX, eyeY, eyeZ], [0, -0.55, 0], [0, 1, 0]);
    multiply(viewProj, proj, view);

    // Sensor origin drifts on a lissajous so sweeps never repeat visibly.
    const ox = Math.sin(t * 0.11) * 3.1;
    const oy = Math.cos(t * 0.077) * 2.4;

    const reveal = ready ? 1 : Math.min(1, t / 2.4);
    if (!ready && reveal >= 1) ready = true;

    gl!.clear(gl!.COLOR_BUFFER_BIT);
    gl!.useProgram(prog);
    gl!.bindVertexArray(vao);
    gl!.uniformMatrix4fv(u.viewProj, false, viewProj);
    gl!.uniform1f(u.time, t);
    gl!.uniform2f(u.origin, ox, oy);
    gl!.uniform1f(u.dpr, dpr);
    gl!.uniform1f(u.reveal, reveal);
    gl!.uniform1f(u.aspect, Math.max(aspect, 1.0));
    gl!.uniform1f(u.resolved, opts.mode === 'resolved' ? 1 : 0);
    gl!.uniform3f(u.phosphor, 0.831, 0.973, 0.361);
    gl!.uniform3f(u.plasma, 0.482, 0.361, 1.0);
    gl!.uniform3f(u.rest, 0.55, 0.60, 0.69);
    gl!.drawArrays(gl!.POINTS, 0, count);
  }

  if (opts.animate) {
    raf = requestAnimationFrame(frame);
  } else {
    // Reduced motion: one fully-resolved frame, composed as a still.
    ready = true;
    draw(6.2);
  }

  opts.onReady?.();

  return {
    destroy() {
      if (raf) cancelAnimationFrame(raf);
      ro.disconnect();
      io.disconnect();
      gl!.deleteBuffer(buf);
      gl!.deleteVertexArray(vao);
      gl!.deleteProgram(prog);
    },
  };
}
