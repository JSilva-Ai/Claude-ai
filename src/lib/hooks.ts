import { useEffect, useRef, useState } from 'react';

/**
 * Scroll reveal. One shared IntersectionObserver for the whole document
 * rather than one per element — this is the difference between a smooth
 * scroll and a janky one on a long page.
 */
let sharedObserver: IntersectionObserver | null = null;

function getObserver(): IntersectionObserver {
  if (!sharedObserver) {
    sharedObserver = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            (entry.target as HTMLElement).dataset.reveal = 'in';
            sharedObserver!.unobserve(entry.target);
          }
        }
      },
      { rootMargin: '0px 0px -12% 0px', threshold: 0.01 },
    );
  }
  return sharedObserver;
}

export function useReveal<T extends HTMLElement>() {
  const ref = useRef<T>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    // Already past the fold on load (deep link / refresh mid-page): show it.
    if (el.getBoundingClientRect().top < window.innerHeight * 0.9) {
      el.dataset.reveal = 'in';
      return;
    }
    const obs = getObserver();
    obs.observe(el);
    return () => obs.unobserve(el);
  }, []);
  return ref;
}

export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(() =>
    typeof window !== 'undefined'
      ? window.matchMedia('(prefers-reduced-motion: reduce)').matches
      : false,
  );
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    const on = () => setReduced(mq.matches);
    mq.addEventListener('change', on);
    return () => mq.removeEventListener('change', on);
  }, []);
  return reduced;
}

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() =>
    typeof window !== 'undefined' ? window.matchMedia(query).matches : false,
  );
  useEffect(() => {
    const mq = window.matchMedia(query);
    const on = () => setMatches(mq.matches);
    on();
    mq.addEventListener('change', on);
    return () => mq.removeEventListener('change', on);
  }, [query]);
  return matches;
}

/**
 * Normalised pointer position (-1..1) written into a stable ref. Deliberately
 * not state: the hero reads it inside its own rAF loop, so React never
 * re-renders on pointer move.
 */
export function usePointer() {
  const pointer = useRef({ x: 0, y: 0 });
  useEffect(() => {
    if (window.matchMedia('(pointer: coarse)').matches) return;
    const on = (e: PointerEvent) => {
      pointer.current.x = (e.clientX / window.innerWidth) * 2 - 1;
      pointer.current.y = (e.clientY / window.innerHeight) * 2 - 1;
    };
    window.addEventListener('pointermove', on, { passive: true });
    return () => window.removeEventListener('pointermove', on);
  }, []);
  return pointer;
}

/** Current scroll offset in px, rAF-throttled. */
export function useScrollY(): number {
  const [y, setY] = useState(0);
  useEffect(() => {
    let raf = 0;
    const on = () => {
      if (raf) return;
      raf = requestAnimationFrame(() => {
        setY(window.scrollY);
        raf = 0;
      });
    };
    on();
    window.addEventListener('scroll', on, { passive: true });
    return () => {
      window.removeEventListener('scroll', on);
      if (raf) cancelAnimationFrame(raf);
    };
  }, []);
  return y;
}

/** Tracks which section id is currently in the viewport, for nav state. */
export function useActiveSection(ids: string[]): string {
  const [active, setActive] = useState(ids[0] ?? '');
  useEffect(() => {
    const obs = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio);
        if (visible[0]) setActive(visible[0].target.id);
      },
      { rootMargin: '-45% 0px -45% 0px', threshold: 0 },
    );
    for (const id of ids) {
      const el = document.getElementById(id);
      if (el) obs.observe(el);
    }
    return () => obs.disconnect();
  }, [ids]);
  return active;
}
