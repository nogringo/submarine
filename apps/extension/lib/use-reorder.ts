import { type KeyboardEvent, type PointerEvent, useEffect, useRef, useState } from "react";

/**
 * Rows moved by their handles, dragged with the pointer or moved with the up and down arrow keys.
 * The children of `rows` are the rows of `keys`, in order; `move` takes a row to the index `to`.
 */
export function useReorder(keys: string[], move: (key: string, to: number) => void) {
  const rows = useRef<HTMLDivElement>(null);
  const handles = useRef(new Map<string, HTMLButtonElement>());
  // A new one at each move, the same row moved twice included.
  const [focusHandle, setFocusHandle] = useState<{ key: string }>();
  const [dragging, setDragging] = useState<string>();
  useEffect(() => {
    // Moved in the page, the handle may have lost the focus.
    if (focusHandle) handles.current.get(focusHandle.key)?.focus();
  }, [focusHandle]);

  const moveTo = (key: string, to: number) => {
    const from = keys.indexOf(key);
    if (from < 0 || to < 0 || to >= keys.length || to === from) return;
    move(key, to);
    setFocusHandle({ key });
  };

  /** Moves the row dragged to the row under the pointer. */
  const dragOver = (key: string, y: number) => {
    const rects = [...(rows.current?.children ?? [])].map((row) => row.getBoundingClientRect());
    const below = rects.findIndex((rect) => y < rect.top + rect.height / 2);
    const from = keys.indexOf(key);
    moveTo(key, below < 0 ? keys.length - 1 : below > from ? below - 1 : below);
  };
  useEffect(() => {
    if (!dragging) return;
    // On the window: moved in the page, the handle would lose a pointer capture.
    const follow = (event: globalThis.PointerEvent) => dragOver(dragging, event.clientY);
    const drop = () => setDragging(undefined);
    window.addEventListener("pointermove", follow);
    window.addEventListener("pointerup", drop);
    window.addEventListener("pointercancel", drop);
    return () => {
      window.removeEventListener("pointermove", follow);
      window.removeEventListener("pointerup", drop);
      window.removeEventListener("pointercancel", drop);
    };
  });

  /** The props of the handle of the row `key`, a button. */
  const handleProps = (key: string) => ({
    ref: (handle: HTMLButtonElement | null) => {
      if (handle) handles.current.set(key, handle);
      else handles.current.delete(key);
    },
    onKeyDown: (event: KeyboardEvent) => {
      const index = keys.indexOf(key);
      if (event.key === "ArrowUp") moveTo(key, index - 1);
      else if (event.key === "ArrowDown") moveTo(key, index + 1);
      else return;
      event.preventDefault();
    },
    onPointerDown: (event: PointerEvent) => {
      if (event.button !== 0) return;
      event.preventDefault();
      setDragging(key);
    },
  });

  return { rows, dragging, handleProps };
}
