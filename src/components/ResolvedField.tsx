import { useEffect, useRef } from 'react';
import { createPerceptionField } from '../lib/perceptionField';
import { usePointer, useReducedMotion } from '../lib/hooks';

/**
 * The closing bookend. The hero opens on a surface being inferred; this is
 * the same surface, returned. Mounted only in the contact section, and only
 * once it is close to the viewport — the hero owns the GPU until then.
 */
export function ResolvedField() {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const pointer = usePointer();
  const reduced = useReducedMotion();

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    let handle: { destroy(): void } | null = null;
    const obs = new IntersectionObserver(
      (entries) => {
        if (!entries[0].isIntersecting || handle) return;
        handle = createPerceptionField(canvas, {
          pointer: pointer.current,
          animate: !reduced,
          mode: 'resolved',
        });
        obs.disconnect();
      },
      { rootMargin: '25% 0px' },
    );
    obs.observe(canvas);

    return () => {
      obs.disconnect();
      handle?.destroy();
    };
  }, [pointer, reduced]);

  return (
    <div className="contact__field" aria-hidden="true">
      <canvas ref={canvasRef} />
      <div className="contact__field-scrim" />
    </div>
  );
}
