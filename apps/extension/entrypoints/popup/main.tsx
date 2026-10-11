import { StrictMode } from "react";
import { I18nProvider } from "react-aria-components";
import { createRoot } from "react-dom/client";
import { IntlProvider } from "react-intl";
import "@/assets/theme.css";
import { loadMessages, pickLocale } from "@/lib/i18n";
import { App } from "./App";

const root = document.getElementById("root");
if (root) {
  const locale = pickLocale(navigator.languages);
  document.documentElement.lang = locale;
  const messages = await loadMessages(locale);
  createRoot(root).render(
    <StrictMode>
      <IntlProvider locale={locale} messages={messages}>
        <I18nProvider locale={locale}>
          <App />
        </I18nProvider>
      </IntlProvider>
    </StrictMode>,
  );
}
