import app from "../../app/lib/l10n/app_en.arb";
import website from "../../website/l10n/website_en.arb";

const catalog = { ...app, ...website };

/** The English message `id` of the site, or of the app. */
export function t(id: string): string {
  const message = catalog[id];
  if (message === undefined) throw new Error(`No message ${id}`);
  return message;
}
