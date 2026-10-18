/** A part of the text of a message: plain, or a web link. */
export type TextPart = { text: string; url?: URL };

// Its last character is not the punctuation of the sentence around it.
const link = /https?:\/\/[^\s<>"]*[^\s<>"'.,;:!?()[\]]/g;

/** `text` cut around its web links, as the app finds them. */
export function textParts(text: string): TextPart[] {
  const parts: TextPart[] = [];
  let start = 0;
  for (const match of text.matchAll(link)) {
    const url = URL.parse(match[0]);
    if (!url?.hostname) continue;
    if (match.index > start) parts.push({ text: text.slice(start, match.index) });
    parts.push({ text: match[0], url });
    start = match.index + match[0].length;
  }
  if (start < text.length) parts.push({ text: text.slice(start) });
  return parts;
}

/** `subject` as the name of a `.eml` file, without the characters file systems refuse. */
export function emlFileName(subject: string): string {
  // biome-ignore lint/suspicious/noControlCharactersInRegex: file systems refuse them.
  const cleaned = subject.replace(/[\\/:*?"<>|\u0000-\u001f]/g, "_").trim();
  const name = [...new Intl.Segmenter().segment(cleaned)]
    .slice(0, 80)
    .map(({ segment }) => segment)
    .join("");
  return `${name || "email"}.eml`;
}
