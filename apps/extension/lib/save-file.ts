/** Downloads `content` as the file `name`, of the media `type`. */
export function saveFile(name: string, content: string, type: string) {
  const url = URL.createObjectURL(new Blob([content], { type }));
  const link = document.createElement("a");
  link.href = url;
  link.download = name;
  link.click();
  // Firefox reads it once the click has returned.
  setTimeout(() => URL.revokeObjectURL(url), 60_000);
}
