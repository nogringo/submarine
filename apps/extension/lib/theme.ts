export const themes = ["system", "light", "dark"] as const;

export type Theme = (typeof themes)[number];

/** The app's key and names, in `storage.local`. */
const themeKey = "theme";

/** The theme chosen on this device, the system's until one is. */
export async function readTheme(): Promise<Theme> {
  const saved = (await browser.storage.local.get(themeKey))[themeKey];
  return themes.find((theme) => theme === saved) ?? "system";
}

export async function saveTheme(theme: Theme) {
  await browser.storage.local.set({ [themeKey]: theme });
}

/** Shows the page in `theme`, which theme.css reads from the root. */
export function showTheme(theme: Theme) {
  if (theme === "system") delete document.documentElement.dataset.theme;
  else document.documentElement.dataset.theme = theme;
}
