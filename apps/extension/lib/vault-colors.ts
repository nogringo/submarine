/** The colors a vault can take, as in the app, in ARGB. */
export const vaultColors = [
  { argb: 0xff2f6fd0, name: "vaultColorBlue" },
  { argb: 0xffb95a22, name: "vaultColorOrange" },
  { argb: 0xff2a7f61, name: "vaultColorGreen" },
  { argb: 0xff8a4fbf, name: "vaultColorPurple" },
  { argb: 0xffb8336a, name: "vaultColorPink" },
  { argb: 0xff5b6b7a, name: "vaultColorGray" },
] as const;

/** The color of a new vault: the next one, as in the app. */
export function defaultVaultColor(vaultCount: number): number {
  return vaultColors[vaultCount % vaultColors.length]?.argb ?? vaultColors[0].argb;
}

export function cssColor(argb: number): string {
  return `#${(argb & 0xffffff).toString(16).padStart(6, "0")}`;
}
