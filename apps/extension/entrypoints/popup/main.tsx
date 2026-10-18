import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "@/assets/theme.css";
import { readChosenLocale } from "@/lib/i18n";
import { LocaleProvider, loadLanguage } from "@/lib/use-locale";
import { App } from "./App";

const root = document.getElementById("root");
if (root) {
  const chosen = await readChosenLocale();
  const language = await loadLanguage(chosen);
  document.documentElement.lang = language.locale;
  createRoot(root).render(
    <StrictMode>
      <LocaleProvider chosen={chosen} language={language}>
        <App />
      </LocaleProvider>
    </StrictMode>,
  );
}
