import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import type { Plugin } from "vite";
import { addViteConfig, defineWxtModule } from "wxt/modules";

function messagesOf(arb: string): Record<string, string> {
  const entries = Object.entries(JSON.parse(arb) as Record<string, string>);
  return Object.fromEntries(entries.filter(([key]) => !key.startsWith("@")));
}

/** Imports an ARB file as its messages alone, without their descriptions. */
export function arbPlugin(): Plugin {
  return {
    name: "submarine:arb",
    enforce: "pre",
    transform(code, id) {
      if (!id.endsWith(".arb")) return;
      return { code: `export default ${JSON.stringify(messagesOf(code))};`, map: null };
    },
  };
}

/**
 * The app's ARB files and the extension's own, imported by the extension and typed by their message
 * ids.
 */
export default defineWxtModule((wxt) => {
  const l10n = resolve(wxt.config.root, "../app/lib/l10n");
  const ownL10n = resolve(wxt.config.root, "l10n");

  addViteConfig(wxt, () => ({
    plugins: [arbPlugin()],
    server: { fs: { allow: [wxt.config.root, l10n] } },
  }));

  wxt.hook("prepare:types", async (_, entries) => {
    const ids = [
      ...Object.keys(messagesOf(await readFile(resolve(l10n, "app_en.arb"), "utf8"))),
      ...Object.keys(messagesOf(await readFile(resolve(ownL10n, "extension_en.arb"), "utf8"))),
    ];
    entries.push({
      path: "types/messages.d.ts",
      text: `declare global {
  namespace FormatjsIntl {
    interface Message {
      ids: ${ids.map((id) => JSON.stringify(id)).join(" | ")};
    }
  }
}

export {};
`,
      tsReference: true,
    });
  });
});
