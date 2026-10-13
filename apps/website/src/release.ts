export type Release = {
  version: string;
  publishedAt: Date;
  page: string;
  /** Their address, by the end of the file's name: "android.apk", "cli-linux-x64.tar.gz". */
  downloads: Map<string, string>;
};

type GitHubRelease = {
  tag_name: string;
  published_at: string;
  html_url: string;
  assets: { name: string; browser_download_url: string }[];
};

/** "submarine-0.1.0-android.apk" and "submarine-cli-0.1.0-linux-x64.tar.gz" by their kind. */
export function downloadKind(file: string, version: string): string | undefined {
  const app = `submarine-${version}-`;
  const cli = `submarine-cli-${version}-`;
  if (file.startsWith(app)) return file.slice(app.length);
  if (file.startsWith(cli)) return `cli-${file.slice(cli.length)}`;
  return undefined;
}

export function parseRelease(json: GitHubRelease): Release {
  const version = json.tag_name.replace(/^v/, "");
  const downloads = new Map<string, string>();
  for (const asset of json.assets) {
    const kind = downloadKind(asset.name, version);
    if (kind) downloads.set(kind, asset.browser_download_url);
  }
  return { version, publishedAt: new Date(json.published_at), page: json.html_url, downloads };
}

let latest: Promise<Release | undefined> | undefined;

/**
 * The latest release, read once per build. Undefined when GitHub cannot be reached, the download
 * links then lead to the release page. GITHUB_TOKEN lifts the API's limit in CI.
 */
export function latestRelease(): Promise<Release | undefined> {
  latest ??= fetch("https://api.github.com/repos/nogringo/submarine/releases/latest", {
    headers: {
      accept: "application/vnd.github+json",
      ...(process.env.GITHUB_TOKEN && { authorization: `Bearer ${process.env.GITHUB_TOKEN}` }),
    },
  })
    .then(async (response) => {
      if (!response.ok) throw new Error(`GitHub answered ${response.status}`);
      return parseRelease((await response.json()) as GitHubRelease);
    })
    .catch((error: unknown) => {
      console.warn(`No latest release, the download links lead to its page: ${error}`);
      return undefined;
    });
  return latest;
}
