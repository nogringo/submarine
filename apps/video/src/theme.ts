import wordmark from "@fontsource/saira-stencil-one/files/saira-stencil-one-latin-400-normal.woff2";
import mono from "@fontsource-variable/atkinson-hyperlegible-mono/files/atkinson-hyperlegible-mono-latin-wght-normal.woff2";
import text from "@fontsource-variable/atkinson-hyperlegible-next/files/atkinson-hyperlegible-next-latin-wght-normal.woff2";
import { loadFont } from "@remotion/fonts";

/** The app's dark palette. */
export const colors = {
  background: "#0b1e2d",
  surface: "#10283b",
  raised: "#183652",
  line: "#284b6b",
  outline: "#648098",
  glow: "#143651",
  text: "#eaf0f4",
  muted: "#a0b5c5",
  accent: "#ffd23f",
  symbol: "#8cc8ff",
  danger: "#ff9585",
};

export const fonts = {
  text: "Atkinson Hyperlegible Next",
  mono: "Atkinson Hyperlegible Mono",
  wordmark: "Saira Stencil One",
};

loadFont({ family: fonts.text, url: text, weight: "200 800" });
loadFont({ family: fonts.mono, url: mono, weight: "200 800" });
loadFont({ family: fonts.wordmark, url: wordmark });
