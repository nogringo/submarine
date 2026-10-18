import { createContext, type ReactNode, useCallback, useContext, useRef, useState } from "react";
import { I18nProvider } from "react-aria-components";
import { IntlProvider } from "react-intl";
import { loadMessages, type Messages, pickLocale, saveChosenLocale } from "./i18n";

interface Language {
  locale: string;
  messages: Messages;
}

/** The language chosen on this device, else the first of the browser's the app speaks, loaded. */
export async function loadLanguage(chosen: string | undefined): Promise<Language> {
  const locale = chosen ?? pickLocale(navigator.languages);
  return { locale, messages: await loadMessages(locale) };
}

const ChosenLocale = createContext<{
  chosen: string | undefined;
  choose: (locale: string | undefined) => void;
}>({ chosen: undefined, choose: () => {} });

/** The language chosen in the settings, undefined to follow the browser's, and how to change it. */
export function useChosenLocale() {
  return useContext(ChosenLocale);
}

/**
 * Shows `children` in `language`, then in the one chosen once its messages are loaded, the last
 * chosen winning.
 */
export function LocaleProvider({
  chosen: initiallyChosen,
  language: initialLanguage,
  children,
}: {
  chosen: string | undefined;
  language: Language;
  children: ReactNode;
}) {
  const [chosen, setChosen] = useState(initiallyChosen);
  const [{ locale, messages }, setLanguage] = useState(initialLanguage);
  const lastChoice = useRef(0);
  const choose = useCallback((locale: string | undefined) => {
    const thisChoice = ++lastChoice.current;
    setChosen(locale);
    void saveChosenLocale(locale);
    void loadLanguage(locale).then((language) => {
      if (thisChoice !== lastChoice.current) return;
      document.documentElement.lang = language.locale;
      setLanguage(language);
    });
  }, []);
  return (
    <ChosenLocale.Provider value={{ chosen, choose }}>
      <IntlProvider locale={locale} messages={messages}>
        <I18nProvider locale={locale}>{children}</I18nProvider>
      </IntlProvider>
    </ChosenLocale.Provider>
  );
}
