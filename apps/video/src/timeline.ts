/**
 * The scenes of the video and the text each shows, by the id of its message in the site's or the
 * app's catalogs, in seconds. The subtitles and the soundtrack follow it too.
 */

export const fps = 30;

export type Scene =
  | "intro"
  | "desktop"
  | "devices"
  | "encrypted"
  | "key"
  | "relays"
  | "openSource"
  | "outro";

/** In order, back to back. The desktop and phone takes of apps/app/tool/video_test.dart last 29 and 9 seconds. */
export const scenes: { scene: Scene; seconds: number }[] = [
  { scene: "intro", seconds: 6.5 },
  { scene: "desktop", seconds: 29.5 },
  { scene: "devices", seconds: 9.5 },
  { scene: "encrypted", seconds: 7 },
  { scene: "key", seconds: 5 },
  { scene: "relays", seconds: 13.5 },
  { scene: "openSource", seconds: 6.5 },
  { scene: "outro", seconds: 6 },
];

export interface Caption {
  /** Seconds into its scene. */
  from: number;
  to: number;
  title: string;
  body?: string;
}

/** What each scene says, in turn. */
export const captions: Record<Scene, Caption[]> = {
  intro: [
    { from: 2.1, to: 3.2, title: "passwordManager" },
    { from: 3.2, to: 6.5, title: "welcomeTagline" },
  ],
  desktop: [
    { from: 0, to: 7.5, title: "featureVaults" },
    { from: 7.5, to: 15, title: "featureCodes" },
    { from: 15, to: 21, title: "featureClipboard" },
    { from: 21, to: 29.5, title: "featureGenerator" },
  ],
  devices: [{ from: 0, to: 9.5, title: "devicesTitle", body: "devicesBody" }],
  encrypted: [{ from: 0, to: 7, title: "howEncryptedTitle", body: "howEncryptedBody" }],
  key: [{ from: 0, to: 5, title: "howKeyTitle" }],
  relays: [
    { from: 0, to: 8.5, title: "howRelaysTitle", body: "howRelaysBody" },
    { from: 8.5, to: 13.5, title: "whySpofTitle" },
  ],
  openSource: [{ from: 0, to: 6.5, title: "openSourceTitle", body: "openSourceBody" }],
  outro: [{ from: 1.6, to: 6, title: "footerLicense" }],
};

/** The platforms the devices scene names. */
export const platforms = ["android", "windows", "macos", "linux", "web"];

/** Seconds into the video at which each scene starts. */
export function starts(): Record<Scene, number> {
  let at = 0;
  const result = {} as Record<Scene, number>;
  for (const { scene, seconds } of scenes) {
    result[scene] = at;
    at += seconds;
  }
  return result;
}

export const duration = scenes.reduce((sum, { seconds }) => sum + seconds, 0);

/** Seconds into its scene at which a sonar pings, as the soundtrack hears them. */
export const pings: Partial<Record<Scene, number[]>> = {
  intro: [0.8, 4],
  outro: [0.3, 3.5],
};
