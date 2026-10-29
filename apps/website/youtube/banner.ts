import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import opentype, { type Font, type Path } from "opentype.js";
import sharp from "sharp";

/**
 * The YouTube channel's banner and profile picture, written next to this script: the sonar, the
 * wordmark and the app's tagline, as the site shows them.
 */

const app = new URL("../../app/", import.meta.url);
const out = (name: string) => fileURLToPath(new URL(name, import.meta.url));

const width = 2560;
const height = 1440;
const colors = {
  background: "#0b1e2d",
  glow: "#1d4a70",
  line: "#284b6b",
  rings: "#a0b5c5",
  signal: "#ffd23f",
  text: "#eaf0f4",
  muted: "#a0b5c5",
};

// Every device shows the middle 1546 by 423, TVs alone the whole picture: the text stays in it.
const logoSize = 168;
const gap = 40;
const wordmarkSize = 156;
const taglineSize = 50;
const rowCenter = 668;
const taglineBaseline = 830;
const ringStart = 190;
const ringStep = 150;
const blips = [
  { ring: 7, degrees: 7, size: 9 },
  { ring: 8, degrees: -3, size: 7 },
  { ring: 8, degrees: 16, size: 7 },
];

async function font(name: string): Promise<Font> {
  return opentype.parse((await readFile(new URL(`fonts/${name}`, app))).buffer);
}

function capHeight(font: Font, size: number): number {
  return ((font.tables.os2?.sCapHeight ?? 700) / font.unitsPerEm) * size;
}

// opentype.js 2.0 prints a coordinate such as 1931.0000000000002 as NaN, so paths are written here.
function pathData(path: Path): string {
  const n = (...values: number[]) => values.map((value) => value.toFixed(2)).join(" ");
  return path.commands
    .map((command) => {
      switch (command.type) {
        case "M":
        case "L":
          return command.type + n(command.x, command.y);
        case "Q":
          return `Q${n(command.x1, command.y1, command.x, command.y)}`;
        case "C":
          return `C${n(command.x1, command.y1, command.x2, command.y2, command.x, command.y)}`;
        default:
          return "Z";
      }
    })
    .join("");
}

const stencil = await font("SairaStencilOne-Regular.ttf");
const text = await font("AtkinsonHyperlegibleNext-Regular.ttf");
const { welcomeTagline: tagline } = JSON.parse(
  await readFile(new URL("lib/l10n/app_en.arb", app), "utf8"),
) as { welcomeTagline: string };

const left = (width - logoSize - gap - stencil.getAdvanceWidth("Submarine", wordmarkSize)) / 2;
const logoX = left + logoSize / 2;
const wordmarkBaseline = rowCenter + capHeight(stencil, wordmarkSize) / 2;
const wordmark = pathData(
  stencil.getPath("Submarine", left + logoSize + gap, wordmarkBaseline, wordmarkSize),
);
const taglineLeft = (width - text.getAdvanceWidth(tagline, taglineSize)) / 2;
const taglinePath = pathData(text.getPath(tagline, taglineLeft, taglineBaseline, taglineSize));

const rings = Array.from({ length: 14 }, (_, i) => {
  const opacity = Math.max(0.12, 1 - i * 0.075).toFixed(2);
  return `<circle r="${ringStart + i * ringStep}" stroke-opacity="${opacity}"/>`;
}).join("");
const signals = blips
  .map(({ ring, degrees, size }) => {
    const radius = ringStart + ring * ringStep;
    const angle = (degrees * Math.PI) / 180;
    const x = (radius * Math.cos(angle)).toFixed(1);
    const y = (radius * Math.sin(angle)).toFixed(1);
    return `<circle cx="${x}" cy="${y}" r="${size}"/>`;
  })
  .join("");

const banner = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
  <defs>
    <radialGradient id="glow" cx="${logoX}" cy="${rowCenter}" r="900" gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="${colors.glow}" stop-opacity=".55"/>
      <stop offset="1" stop-color="${colors.glow}" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="100%" height="100%" fill="${colors.background}"/>
  <rect width="100%" height="100%" fill="url(#glow)"/>
  <g transform="translate(${logoX} ${rowCenter})">
    <g fill="none" stroke="${colors.line}" stroke-width="4">${rings}</g>
    <g fill="${colors.signal}" fill-opacity=".8">${signals}</g>
  </g>
  <g transform="translate(${logoX} ${rowCenter}) scale(${logoSize / 200})">
    <g fill="none" stroke="${colors.rings}" stroke-width="15">
      <circle r="32"/>
      <circle r="86"/>
    </g>
    <circle fill="${colors.signal}" r="18"/>
    <circle fill="${colors.signal}" cx="34" cy="-49" r="11"/>
  </g>
  <path fill="${colors.text}" d="${wordmark}"/>
  <path fill="${colors.muted}" d="${taglinePath}"/>
</svg>`;

await sharp(Buffer.from(banner)).removeAlpha().png().toFile(out("banner.png"));

// YouTube shows it mostly under 48 px, where the full sonar blurs, so the small one, as the icons.
await sharp(fileURLToPath(new URL("icon/sonar-small.svg", app)))
  .resize(800)
  .removeAlpha()
  .png()
  .toFile(out("avatar.png"));
