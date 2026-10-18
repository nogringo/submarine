import {
  type KeyboardEvent,
  type PointerEvent,
  useEffect,
  useLayoutEffect,
  useRef,
  useState,
} from "react";

const slide = { duration: 200, easing: "cubic-bezier(0.2, 0, 0, 1)" };

const reducedMotion = () => matchMedia("(prefers-reduced-motion: reduce)").matches;

/** The top of `row` where the layout puts it, without the slide or the drag moving it. */
const layoutTop = (row: Element) =>
  row.getBoundingClientRect().top - new DOMMatrixReadOnly(getComputedStyle(row).transform).m42;

/**
 * Rows moved by their handles, dragged with the pointer or moved with the up and down arrow keys.
 * The children of `rows` are the rows of `keys`, in order; `move` takes a row to the index `to`,
 * and returns whether it did.
 * The dragged row follows the pointer and the others slide to their new place, as in Flutter.
 */
export function useReorder(keys: string[], move: (key: string, to: number) => boolean) {
  const rows = useRef<HTMLDivElement>(null);
  const handles = useRef(new Map<string, HTMLButtonElement>());
  // A new one at each move, the same row moved twice included.
  const [focusHandle, setFocusHandle] = useState<{ key: string }>();
  const [dragging, setDragging] = useState<string>();
  // The pointer, and how far below the top of the dragged row it holds it.
  const pointer = useRef({ y: 0, grab: 0 });
  // Where the rows showed before a move, to slide them from there.
  const tops = useRef<Map<string, number | undefined>>(undefined);
  const slides = useRef(new Map<string, Animation>());
  useEffect(() => {
    // Moved in the page, the handle may have lost the focus.
    if (focusHandle) handles.current.get(focusHandle.key)?.focus();
  }, [focusHandle]);

  const rowOf = (key: string) =>
    rows.current?.children[keys.indexOf(key)] as HTMLElement | undefined;

  const slideFrom = (key: string, row: HTMLElement, shift: number) => {
    if (!shift || reducedMotion()) return;
    slides.current.set(
      key,
      row.animate([{ transform: `translateY(${shift}px)` }, { transform: "none" }], slide),
    );
  };

  /** Puts the dragged row under the pointer, inside the list. */
  const follow = (key: string) => {
    const row = rowOf(key);
    const list = rows.current;
    if (!row || !list) return;
    row.style.transform = "";
    const bounds = list.getBoundingClientRect();
    const top = Math.min(
      Math.max(pointer.current.y - pointer.current.grab, bounds.top),
      bounds.bottom - row.offsetHeight,
    );
    row.style.transform = `translateY(${top - row.getBoundingClientRect().top}px)`;
  };

  useLayoutEffect(() => {
    const before = tops.current;
    tops.current = undefined;
    if (before) {
      for (const key of keys) {
        const row = rowOf(key);
        const first = before.get(key);
        if (!row || key === dragging || first === undefined) continue;
        slides.current.get(key)?.cancel();
        slideFrom(key, row, first - row.getBoundingClientRect().top);
      }
    }
    if (dragging) follow(dragging);
  });

  const moveTo = (key: string, to: number) => {
    const from = keys.indexOf(key);
    if (from < 0 || to < 0 || to >= keys.length || to === from) return;
    const before = new Map(keys.map((each) => [each, rowOf(each)?.getBoundingClientRect().top]));
    if (!move(key, to)) return;
    tops.current = before;
    setFocusHandle({ key });
  };

  /** Moves the row dragged to the row under the pointer. */
  const dragOver = (key: string, y: number) => {
    const rects = [...(rows.current?.children ?? [])].map((row) => ({
      top: layoutTop(row),
      height: row.getBoundingClientRect().height,
    }));
    const below = rects.findIndex((rect) => y < rect.top + rect.height / 2);
    const from = keys.indexOf(key);
    moveTo(key, below < 0 ? keys.length - 1 : below > from ? below - 1 : below);
  };
  useEffect(() => {
    if (!dragging) return;
    // On the window: moved in the page, the handle would lose a pointer capture.
    const onMove = (event: globalThis.PointerEvent) => {
      pointer.current.y = event.clientY;
      follow(dragging);
      dragOver(dragging, event.clientY);
    };
    const drop = () => {
      const row = rowOf(dragging);
      if (row) {
        const lifted = row.getBoundingClientRect().top;
        row.style.transform = "";
        slideFrom(dragging, row, lifted - row.getBoundingClientRect().top);
      }
      setDragging(undefined);
    };
    window.addEventListener("pointermove", onMove);
    window.addEventListener("pointerup", drop);
    window.addEventListener("pointercancel", drop);
    return () => {
      window.removeEventListener("pointermove", onMove);
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
      slides.current.get(key)?.cancel();
      const row = rowOf(key);
      pointer.current = {
        y: event.clientY,
        grab: row ? event.clientY - row.getBoundingClientRect().top : 0,
      };
      setDragging(key);
    },
  });

  return { rows, dragging, handleProps };
}
