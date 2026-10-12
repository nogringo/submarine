import { useEffect, useState } from "react";

/** The tab the popup opened over, and the address of its page. */
export interface Page {
  tabId: number;
  url: string;
}

/**
 * The page the popup opened over, which `activeTab` lets it read and fill. Undefined until read,
 * null without one.
 */
export function usePage(): Page | null | undefined {
  const [page, setPage] = useState<Page | null>();
  useEffect(() => {
    void browser.tabs.query({ active: true, currentWindow: true }).then(
      ([tab]) => setPage(tab?.id !== undefined && tab.url ? { tabId: tab.id, url: tab.url } : null),
      () => setPage(null),
    );
  }, []);
  return page;
}
