import { describe, expect, it } from "vitest";
import { downloadKind, parseRelease } from "./release";

describe("downloadKind", () => {
  it.each([
    ["submarine-0.1.0-android.apk", "android.apk"],
    ["submarine-0.1.0-windows-setup.exe", "windows-setup.exe"],
    ["submarine-cli-0.1.0-linux-x64.tar.gz", "cli-linux-x64.tar.gz"],
    ["submarine-0.0.9-android.apk", undefined],
    ["submarine-extension-0.1.0-chrome.zip", undefined],
  ])("reads %s as %s", (file, kind) => {
    expect(downloadKind(file, "0.1.0")).toBe(kind);
  });
});

describe("parseRelease", () => {
  it("keeps the version, the date and the downloads by kind", () => {
    const release = parseRelease({
      tag_name: "v0.1.0",
      published_at: "2026-10-12T10:00:00Z",
      html_url: "https://github.com/nogringo/submarine/releases/tag/v0.1.0",
      assets: [
        {
          name: "submarine-0.1.0-macos.dmg",
          browser_download_url: "https://example.com/submarine-0.1.0-macos.dmg",
        },
      ],
    });
    expect(release.version).toBe("0.1.0");
    expect(release.publishedAt.toISOString()).toBe("2026-10-12T10:00:00.000Z");
    expect(release.downloads.get("macos.dmg")).toBe(
      "https://example.com/submarine-0.1.0-macos.dmg",
    );
  });
});
