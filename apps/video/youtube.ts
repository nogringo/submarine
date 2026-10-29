/**
 * Writes what YouTube asks of the video into out/youtube/, in each language of the app and the site,
 * from their catalogs: the title and description in <language>.txt, the subtitles in
 * <language>.srt. Run with `pnpm youtube`.
 */
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import { captions, scenes, starts } from "./src/timeline.ts";

type Messages = Record<string, string>;

/** By BCP 47 tag: app_pt_BR.arb holds the pt-BR messages. */
async function catalogs(folder: URL, prefix: string): Promise<Map<string, Messages>> {
  const files = (await readdir(folder)).filter(
    (file) => file.startsWith(prefix) && file.endsWith(".arb"),
  );
  return new Map(
    await Promise.all(
      files.map(
        async (file) =>
          [
            file.slice(prefix.length, -4).replace("_", "-"),
            JSON.parse(await readFile(new URL(file, folder), "utf8")) as Messages,
          ] as const,
      ),
    ),
  );
}

const app = await catalogs(new URL("../app/lib/l10n/", import.meta.url), "app_");
const website = await catalogs(new URL("../website/l10n/", import.meta.url), "website_");
const out = new URL("out/youtube/", import.meta.url);
await mkdir(out, { recursive: true });

for (const language of app.keys()) {
  const t = (id: string) => {
    const message = website.get(language)?.[id] ?? app.get(language)?.[id];
    if (message === undefined) throw new Error(`No message ${id} in ${language}`);
    return message;
  };
  const site = `https://submarine.li/${language === "en" ? "" : `${language.toLowerCase()}/`}`;
  const description = [
    t("homeDescription"),
    "",
    t("downloadApp"),
    `${site}download`,
    "",
    t("seeSourceCode"),
    "https://github.com/nogringo/submarine",
    "",
    t("auditTitle"),
    t("auditBody"),
  ];
  await writeFile(
    new URL(`${language}.txt`, out),
    `${t("homeTitle")}\n\n${description.join("\n")}\n`,
  );
  await writeFile(new URL(`${language}.srt`, out), subtitles(t, /^(ja|zh)/.test(language)));
}

/**
 * The captions of the timeline as SRT cues, two short lines at most, each given its share of time,
 * a short one a little more than its length.
 */
function subtitles(t: (id: string) => string, ideographic: boolean): string {
  const longest = ideographic ? 40 : 84;
  const at = starts();
  const cues: { from: number; to: number; text: string }[] = [];
  for (const { scene } of scenes) {
    for (const caption of captions[scene]) {
      const sentences = [t(caption.title), ...(caption.body ? sentencesOf(t(caption.body)) : [])];
      const texts: string[] = [];
      for (const sentence of sentences) {
        const last = texts.at(-1);
        if (last !== undefined && last.length + sentence.length < longest) {
          texts[texts.length - 1] = `${last}${ideographic ? "" : " "}${sentence}`;
        } else {
          texts.push(sentence);
        }
      }
      const weight = (text: string) => text.length + 25;
      const total = texts.reduce((sum, text) => sum + weight(text), 0);
      let from = at[scene] + caption.from;
      const length = caption.to - caption.from;
      for (const text of texts) {
        const to = from + (length * weight(text)) / total;
        cues.push({ from, to, text: ideographic ? text : twoLines(text) });
        from = to;
      }
    }
  }
  return cues
    .map((cue, i) => `${i + 1}\n${timestamp(cue.from)} --> ${timestamp(cue.to)}\n${cue.text}\n`)
    .join("\n");
}

function sentencesOf(text: string): string[] {
  return text.split(/(?<=[.!?。！？])\s*/).filter(Boolean);
}

/** `text` broken at the space nearest its middle, once longer than a line. */
function twoLines(text: string): string {
  if (text.length <= 42) return text;
  const middle = text.length / 2;
  let best = -1;
  for (let i = text.indexOf(" "); i !== -1; i = text.indexOf(" ", i + 1)) {
    if (best === -1 || Math.abs(i - middle) < Math.abs(best - middle)) best = i;
  }
  return best === -1 ? text : `${text.slice(0, best)}\n${text.slice(best + 1)}`;
}

function timestamp(seconds: number): string {
  const ms = Math.round(seconds * 1000);
  const pad = (value: number, size = 2) => String(value).padStart(size, "0");
  return `${pad(Math.floor(ms / 3_600_000))}:${pad(Math.floor(ms / 60_000) % 60)}:${pad(Math.floor(ms / 1000) % 60)},${pad(ms % 1000, 3)}`;
}
