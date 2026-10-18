import { describe, expect, it } from "vitest";
import { emlFileName, textParts } from "./mail";

describe("textParts", () => {
  it("finds the web links, without the punctuation of the sentence", () => {
    const parts = textParts(
      "Confirm at https://shop.example/confirm?code=1. Thanks (https://a.example)",
    );
    expect(parts.map(({ text, url }) => [text, url?.hostname])).toEqual([
      ["Confirm at ", undefined],
      ["https://shop.example/confirm?code=1", "shop.example"],
      [". Thanks (", undefined],
      ["https://a.example", "a.example"],
      [")", undefined],
    ]);
  });

  it("leaves a text without links whole", () => {
    expect(textParts("No link, ftp://a.example")).toEqual([{ text: "No link, ftp://a.example" }]);
  });
});

describe("emlFileName", () => {
  it("replaces the characters file systems refuse", () => {
    expect(emlFileName('Re: your order 12/3 "now"')).toBe("Re_ your order 12_3 _now_.eml");
  });

  it("names an email without a subject", () => {
    expect(emlFileName("  ")).toBe("email.eml");
  });

  it("keeps 80 characters", () => {
    expect(emlFileName("é".repeat(100))).toBe(`${"é".repeat(80)}.eml`);
  });
});
