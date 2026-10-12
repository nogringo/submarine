import { describe, expect, it } from "vitest";
import { filterOptions } from "./item-filters";

describe("filterOptions", () => {
  it("offers the types there are, in the app's order, between the favorites and the trash", () => {
    expect(filterOptions([2, 1, 3], "all").map((option) => option.filter)).toEqual([
      "all",
      "favorites",
      1,
      3,
      2,
      "trash",
    ]);
  });

  it("keeps the type chosen, emptied since", () => {
    expect(filterOptions([1], 8).map((option) => option.filter)).toEqual([
      "all",
      "favorites",
      1,
      8,
      "trash",
    ]);
  });

  it("names them as the app's chips", () => {
    expect(filterOptions([5], "all").map((option) => option.label)).toEqual([
      "filterAllShort",
      "filterFavorites",
      "filterSshKeys",
      "filterTrash",
    ]);
  });
});
