import { useCallback, useEffect, useRef, useState } from "react";
import { callCore } from "./core";
import { type GeneratorSettings, readGeneratorSettings, saveGeneratorSettings } from "./generator";

/**
 * A value generated with the generator's last settings, a username with `username`, and those
 * settings, both undefined until read. `change` shows new settings at once, then generates with them
 * and saves them for the next time, as the core applied them, the last change winning.
 */
export function useGenerator(username: boolean) {
  const [generated, setGenerated] = useState<{ value: string; settings: GeneratorSettings }>();
  const lastRequest = useRef(0);
  const generate = useCallback(
    (settings: object, save: boolean) => {
      const thisRequest = ++lastRequest.current;
      void callCore("generate", { settings, username }).then((generated) => {
        if (thisRequest !== lastRequest.current) return;
        setGenerated(generated);
        if (save) void saveGeneratorSettings(generated.settings);
      });
    },
    [username],
  );
  useEffect(() => {
    void readGeneratorSettings().then((saved) => generate(saved, false));
  }, [generate]);
  const change = (settings: GeneratorSettings) => {
    // A chip that stays selected changes nothing, and keeps the value, as in the app.
    if (!generated || JSON.stringify(settings) === JSON.stringify(generated.settings)) return;
    setGenerated({ ...generated, settings });
    generate(settings, true);
  };
  const regenerate = () => {
    if (generated) generate(generated.settings, false);
  };
  return { value: generated?.value, settings: generated?.settings, change, regenerate };
}
