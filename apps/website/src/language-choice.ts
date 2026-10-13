const key = "language-chosen";

/** Storage can be missing or throw, in a private window or with site data blocked. */
export function rememberLanguageChoice() {
  try {
    localStorage.setItem(key, "1");
  } catch {}
}

export function hasChosenLanguage(): boolean {
  try {
    return localStorage.getItem(key) !== null;
  } catch {
    return false;
  }
}
