import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["src/**/*.test.ts"],
    // Its cache keeps what import.meta.glob found, missing an ARB file or policy added since.
    fsModuleCache: false,
  },
});
