type WorkerGlobals = typeof globalThis & {
  importScripts?: (...urls: string[]) => void;
};

export default defineBackground(() => {
  (globalThis as WorkerGlobals).importScripts?.("/core.js");
});
