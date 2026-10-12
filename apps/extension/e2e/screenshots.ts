/**
 * Takes the stores' screenshots, 1280 by 800, of two demo vaults published to the relays, and the
 * Chrome Web Store's promo tile, into `store/`. Run with `pnpm screenshots`.
 */
import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve } from "node:path";
import { generateSecretKey, nip19 } from "nostr-tools";
import type { Browser } from "puppeteer";
import { type Extension, launch } from "./extension.ts";
import { setTheme } from "./theme.ts";
import { publishItems } from "./vault-items.ts";

const root = resolve(import.meta.dirname, "..");
const out = resolve(root, "store");

const personal = generateSecretKey();
const work = generateSecretKey();
await publishItems(personal, [
  {
    type: 1,
    name: "Email",
    login: {
      username: "alex@example.com",
      password: "tide-lantern-orbit-42",
      totp: "JBSWY3DPEHPK3PXP",
      uris: [{ uri: "https://mail.example.com" }],
    },
  },
  {
    type: 1,
    name: "Bank",
    login: {
      username: "alex.martin",
      password: "Kp8#vR2!mQ7w",
      uris: [{ uri: "https://bank.example.com" }],
    },
  },
  {
    type: 3,
    name: "Debit card",
    card: {
      cardholderName: "Alex Martin",
      brand: "Visa",
      number: "4111111111111111",
      expMonth: "3",
      expYear: "2029",
      code: "123",
    },
  },
  { type: 2, name: "Home Wi-Fi", notes: "Network: Lighthouse", secureNote: { type: 0 } },
  {
    type: 4,
    name: "Alex Martin",
    identity: { firstName: "Alex", lastName: "Martin", email: "alex@example.com" },
  },
]);
await publishItems(work, [
  {
    type: 1,
    name: "Team chat",
    login: {
      username: "alex",
      password: "harbor-quiet-maple-7",
      uris: [{ uri: "https://chat.example.com" }],
    },
  },
  { type: 2, name: "Office door code", notes: "4096", secureNote: { type: 0 } },
]);

const extension = await launch("chrome");
const { popup } = extension;
try {
  await popup.setViewport({ width: 380, height: 600, deviceScaleFactor: 2 });
  // The sonar's ping and the fields' labels would be caught halfway.
  await popup.emulateMediaFeatures([{ name: "prefers-reduced-motion", value: "reduce" }]);
  await openVault(extension, personal, "Personal");
  await extension.click("button[aria-label=Vaults]");
  await openVault(extension, work, "Work");
  await popup.waitForFunction(() => document.querySelectorAll(".item-row").length === 7, {
    timeout: 30_000,
  });
  await mkdir(out, { recursive: true });
  await promoTile(extension.browser);

  await shoot(extension, "light", 1, "All your vaults in your browser", [
    "Search your logins, cards and notes, across every vault you open.",
  ]);

  await extension.click(".item-row[aria-label=Email]");
  await extension.click(".field-tile:has(.field-value.password) button[aria-label=Show]");
  // A code about to change shows its countdown in red.
  await popup.waitForFunction(
    () => Number(document.querySelector(".totp-seconds")?.textContent) >= 20,
    { timeout: 30_000 },
  );
  await shoot(extension, "dark", 2, "Copy in one click", [
    "Usernames, passwords and two-factor codes.",
    "The clipboard empties itself after a delay.",
  ]);
  await extension.press("Escape");

  await extension.click(".item-row[aria-label='Debit card']");
  await shoot(extension, "light", 3, "Every item, in detail", [
    "Cards, notes, identities and SSH keys, as you saved them in the Submarine app.",
  ]);
  await extension.press("Escape");

  await extension.click("button[aria-label=Vaults]");
  await extension.click(".drawer button::-p-text(Settings)");
  await extension.click(".settings button::-p-text(Set up)");
  await extension.fill("[role=dialog] input[name=password]", "a long lock password");
  await extension.fill("[role=dialog] input[name=confirmation]", "a long lock password");
  await extension.click("[role=dialog] button[type=submit]");
  await popup.waitForSelector("[role=dialog]", { hidden: true });
  await extension.press("Escape");
  await extension.click("button[aria-label=Lock]");
  await popup.waitForSelector("input[name=password]");
  await shoot(extension, "dark", 4, "Locked while you are away", [
    "Behind your password, after the delay you choose.",
  ]);
} finally {
  await extension.browser.close();
}

async function openVault({ click, fill, popup }: Extension, key: Uint8Array, name: string) {
  await click("button::-p-text(Open a vault)");
  await fill("input[name=key]", nip19.nsecEncode(key));
  await fill("input[name=name]", name);
  await click("button[type=submit]");
  await popup.waitForSelector("input[name=key]", { hidden: true });
  await popup.waitForSelector(".home-title");
}

/** Lays the popup as it stands, in `theme`, beside its caption, into `store/screenshot-<n>.png`. */
async function shoot(
  { browser, popup }: Extension,
  theme: "light" | "dark",
  n: number,
  title: string,
  lines: string[],
) {
  await setTheme(popup, theme);
  await popup.evaluate(() => (document.activeElement as HTMLElement | null)?.blur());
  const shot = await popup.screenshot({
    clip: { x: 0, y: 0, width: 380, height: 600 },
    encoding: "base64",
  });
  await setTheme(popup, null);
  const rings = [1, 2, 3, 4]
    .map((ring) => `<circle cx="988" cy="400" r="${ring * 150}" />`)
    .join("");
  await render(
    browser,
    `screenshot-${n}.png`,
    1280,
    800,
    `<style>
  body { background: radial-gradient(circle at 988px 400px, #143651, #0b1e2d 70%); }
  svg { position: absolute; inset: 0; }
  circle { fill: none; stroke: #244868; stroke-width: 2; }
  .caption { position: absolute; left: 96px; top: 0; bottom: 0; width: 520px;
    display: flex; flex-direction: column; justify-content: center; }
  .wordmark { font-size: 28px; }
  h1 { margin: 24px 0 0; font-size: 52px; line-height: 1.15; font-weight: 700; }
  p { margin: 20px 0 0; font-size: 24px; line-height: 1.45; color: #a0b5c5; }
  img { position: absolute; left: 760px; top: 40px; width: 456px; height: 720px;
    border-radius: 16px; outline: 1px solid #284b6b; box-shadow: 0 24px 64px rgb(0 0 0 / 0.5); }
</style>
<svg width="1280" height="800">${rings}</svg>
<div class="caption">
  <div class="wordmark">Submarine</div>
  <h1>${title}</h1>
  ${lines.map((line) => `<p>${line}</p>`).join("")}
</div>
<img src="data:image/png;base64,${shot}" alt="">`,
  );
}

/** The small promo tile of the Chrome Web Store, 440 by 280, into `store/promo-tile.png`. */
async function promoTile(browser: Browser) {
  const sonar = (await readFile(resolve(root, "../app/icon/sonar.svg"))).toString("base64");
  await render(
    browser,
    "promo-tile.png",
    440,
    280,
    `<style>
  body { display: flex; align-items: center; gap: 24px; padding: 0 36px; background: #0b1e2d; }
  img { width: 112px; height: 112px; border-radius: 25px; }
  .wordmark { font-size: 34px; }
  p { margin: 6px 0 0; font-size: 20px; color: #a0b5c5; }
</style>
<img src="data:image/svg+xml;base64,${sonar}" alt="">
<div><div class="wordmark">Submarine</div><p>Password Manager</p></div>`,
  );
}

/** Renders `body` in Submarine's fonts, `width` by `height`, into `store/<file>`. */
async function render(browser: Browser, file: string, width: number, height: number, body: string) {
  const font = async (path: string) =>
    `data:font/woff2;base64,${(await readFile(resolve(root, "node_modules", path))).toString("base64")}`;
  const text = await font(
    "@fontsource-variable/atkinson-hyperlegible-next/files/atkinson-hyperlegible-next-latin-wght-normal.woff2",
  );
  const wordmark = await font(
    "@fontsource/saira-stencil-one/files/saira-stencil-one-latin-400-normal.woff2",
  );
  const page = await browser.newPage();
  try {
    await page.setViewport({ width, height });
    await page.setContent(
      `<!doctype html>
<style>
  @font-face { font-family: Text; src: url(${text}); font-weight: 200 800; }
  @font-face { font-family: Wordmark; src: url(${wordmark}); }
  * { box-sizing: border-box; }
  body { margin: 0; width: ${width}px; height: ${height}px; overflow: hidden; position: relative;
    color: #eaf0f4; font-family: Text; }
  .wordmark { font-family: Wordmark; letter-spacing: 3px; color: #ffd23f; text-transform: uppercase; }
</style>
${body}`,
      { waitUntil: "load" },
    );
    await page.evaluate(() => document.fonts.ready);
    await writeFile(resolve(out, file), await page.screenshot());
  } finally {
    await page.close();
  }
}
