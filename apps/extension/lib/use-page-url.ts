import { useEffect, useState } from "react";

/**
 * The address of the page the popup opened over, which `activeTab` lets it read. Undefined until
 * read, null without one.
 */
export function usePageUrl(): string | null | undefined {
  const [url, setUrl] = useState<string | null>();
  useEffect(() => {
    void browser.tabs.query({ active: true, currentWindow: true }).then(
      ([tab]) => setUrl(tab?.url ?? null),
      () => setUrl(null),
    );
  }, []);
  return url;
}
