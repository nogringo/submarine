import { readFile } from "node:fs/promises";
import { createRequire } from "node:module";
import type { APIRoute } from "astro";
import opentype from "opentype.js";
import sharp from "sharp";

/**
 * The picture a link to the site shows when shared: the sonar, the wordmark and the app. No other
 * text, so one picture serves every language.
 */
export const width = 1200;
export const height = 630;

const colors = { background: "#0b1e2d", rings: "#a0b5c5", signal: "#ffd23f", text: "#eaf0f4" };
const outline = "#648098";

const logoSize = 112;
const gap = 28;
const fontSize = 104;
const rowCenter = 125;
const shot = { x: 100, y: 230, width: 1000, radius: 16 };

// Not woff2: opentype.js reads woff only. Paths from the build's directory, apps/website.
const fontFile = createRequire(import.meta.url).resolve(
  "@fontsource/saira-stencil-one/files/saira-stencil-one-latin-400-normal.woff",
);
const screenshotFile = "../app/screenshots/desktop-dark.png";

export const GET: APIRoute = async () => {
  const font = opentype.parse((await readFile(fontFile)).buffer);
  const capHeight = ((font.tables.os2?.sCapHeight ?? 700) / font.unitsPerEm) * fontSize;
  const left = (width - logoSize - gap - font.getAdvanceWidth("Submarine", fontSize)) / 2;
  const wordmark = font
    .getPath("Submarine", left + logoSize + gap, rowCenter + capHeight / 2, fontSize)
    .toPathData(2);
  const scale = logoSize / 200;
  const logoX = left + logoSize / 2;

  const background = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
    <rect width="100%" height="100%" fill="${colors.background}"/>
    <g transform="translate(${logoX} ${rowCenter}) scale(${scale})">
      <g fill="none" stroke="${colors.rings}" stroke-width="15">
        <circle r="32"/>
        <circle r="86"/>
      </g>
      <circle fill="${colors.signal}" r="18"/>
      <circle fill="${colors.signal}" cx="34" cy="-49" r="11"/>
    </g>
    <path fill="${colors.text}" d="${wordmark}"/>
  </svg>`;

  // Bleeds off the bottom, only its top corners rounded.
  const shotHeight = height - shot.y;
  const corners = `<svg xmlns="http://www.w3.org/2000/svg" width="${shot.width}" height="${shotHeight}">
    <rect width="100%" height="${shotHeight + shot.radius}" rx="${shot.radius}"/>
  </svg>`;
  const screenshot = await sharp(screenshotFile)
    .resize({ width: shot.width })
    .extract({ left: 0, top: 0, width: shot.width, height: shotHeight })
    .composite([{ input: Buffer.from(corners), blend: "dest-in" }])
    .png()
    .toBuffer();
  const border = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
    <rect x="${shot.x - 1}" y="${shot.y - 1}" width="${shot.width + 2}" height="${shotHeight + shot.radius + 2}"
      rx="${shot.radius + 1}" fill="none" stroke="${outline}" stroke-width="2"/>
  </svg>`;

  const png = await sharp(Buffer.from(background))
    .composite([
      { input: screenshot, left: shot.x, top: shot.y },
      { input: Buffer.from(border), left: 0, top: 0 },
    ])
    .png()
    .toBuffer();
  return new Response(new Uint8Array(png), { headers: { "Content-Type": "image/png" } });
};
