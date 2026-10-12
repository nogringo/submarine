import { readdir, readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { defineWxtModule } from "wxt/modules";

/** The browsers name these two languages of the app by their region. */
const browserLocales: Record<string, string> = { pt: "pt_PT", zh: "zh_CN" };

/**
 * What the browser and the stores show, in each of the app's languages: the app's tagline as the
 * description, and the keyboard shortcuts.
 */
export default defineWxtModule((wxt) => {
  const l10n = resolve(wxt.config.root, "../app/lib/l10n");
  const ownL10n = resolve(wxt.config.root, "l10n");

  wxt.hook("build:manifestGenerated", (_, manifest) => {
    manifest.default_locale = "en";
    manifest.description = "__MSG_description__";
  });

  wxt.hook("build:publicAssets", async (_, assets) => {
    for (const file of await readdir(l10n)) {
      const locale = file.match(/^app_(.+)\.arb$/)?.[1];
      if (!locale) continue;
      const { welcomeTagline } = JSON.parse(await readFile(resolve(l10n, file), "utf8"));
      const { commandFillLogin } = JSON.parse(
        await readFile(resolve(ownL10n, `extension_${locale}.arb`), "utf8"),
      );
      assets.push({
        relativeDest: `_locales/${browserLocales[locale] ?? locale}/messages.json`,
        contents: JSON.stringify({
          description: { message: welcomeTagline },
          commandFillLogin: { message: commandFillLogin },
        }),
      });
    }
  });
});
