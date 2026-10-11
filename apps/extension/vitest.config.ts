import { configDefaults, defineConfig } from "vitest/config";
import { WxtVitest } from "wxt/testing/vitest-plugin";
import { arbPlugin } from "./modules/arb";

export default defineConfig({
  test: {
    projects: [
      {
        plugins: [WxtVitest(), arbPlugin()],
        test: { name: "unit", exclude: [...configDefaults.exclude, "e2e/**"] },
      },
      {
        test: {
          name: "e2e",
          include: ["e2e/**/*.test.ts"],
          testTimeout: 30_000,
          hookTimeout: 60_000,
        },
      },
    ],
  },
});
