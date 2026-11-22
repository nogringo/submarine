import { readFileSync, writeFileSync } from "node:fs";
import { minifySync } from "rolldown/experimental";

// Firefox Add-ons rejects renamed code as obfuscated, and its linter refuses a file of 5 MiB or more.
const path = process.argv[2];
if (path === undefined) throw new Error("Usage: node scripts/strip-whitespace.ts <file>");
const { code, errors } = minifySync(path, readFileSync(path, "utf8"), {
  compress: false,
  mangle: false,
  codegen: { removeWhitespace: true },
});
if (errors.length > 0) {
  throw new Error(errors.map((error) => error.message).join("\n"));
}
writeFileSync(path, code);
