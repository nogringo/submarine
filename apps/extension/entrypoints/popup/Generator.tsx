import casino from "@material-design-icons/svg/outlined/casino.svg";
import closeIcon from "@material-design-icons/svg/round/close.svg";
import refresh from "@material-design-icons/svg/round/refresh.svg";
import { useId } from "react";
import {
  TextField as AriaTextField,
  Dialog,
  DialogTrigger,
  Heading,
  Input,
  Label,
  Modal,
  ModalOverlay,
  Slider,
  SliderFill,
  SliderThumb,
  SliderTrack,
  ToggleButton,
  ToggleButtonGroup,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, IconButton } from "@/components/Button";
import { CopyButton } from "@/components/CopyButton";
import { CountField } from "@/components/CountField";
import { PasswordText } from "@/components/FieldCard";
import { Page, PageHeader } from "@/components/Page";
import { SwitchTile } from "@/components/ToggleTile";
import {
  maxMinCount,
  type PassphraseOptions,
  type PasswordOptions,
  passwordLengths,
  type UsernameOptions,
  wordCounts,
} from "@/lib/generator";
import { useGenerator } from "@/lib/use-generator";
import "@/components/Chip.css";
import "./Generator.css";

/** The generator on a page of its own, from the drawer, as the app's Generator tab. */
export function GeneratorPage({ onBack }: { onBack: () => void }) {
  const { formatMessage: t } = useIntl();
  return (
    <Page className="generator-page" onBack={onBack}>
      <div className="page-content">
        <PageHeader title={t({ id: "generator" })} />
        <Generator />
      </div>
    </Page>
  );
}

/**
 * The button of a form's field that opens the generator in a sheet, as the app's form on a phone,
 * of usernames with `username`, and `onUse` the value chosen.
 */
export function GenerateButton({
  username = false,
  onUse,
}: {
  username?: boolean;
  onUse: (value: string) => void;
}) {
  const { formatMessage: t } = useIntl();
  return (
    <DialogTrigger>
      <IconButton
        icon={casino}
        label={t({ id: username ? "generateUsername" : "generatePassword" })}
      />
      <ModalOverlay className="sheet-overlay" isDismissable>
        <Modal className="sheet">
          <Dialog className="sheet-dialog">
            {({ close }) => (
              <>
                <div className="sheet-header">
                  <Heading slot="title" className="sheet-title">
                    {t({ id: username ? "generateUsername" : "generator" })}
                  </Heading>
                  <IconButton icon={closeIcon} label={t({ id: "close" })} onPress={close} />
                </div>
                <Generator
                  username={username}
                  onUse={(value) => {
                    close();
                    onUse(value);
                  }}
                />
              </>
            )}
          </Dialog>
        </Modal>
      </ModalOverlay>
    </DialogTrigger>
  );
}

const characterSets = [
  { id: "uppercase", text: "A-Z", label: "uppercaseLetters" },
  { id: "lowercase", text: "a-z", label: "lowercaseLetters" },
  { id: "numbers", text: "0-9", label: "digits" },
  { id: "special", text: "!@#$%^&*", label: "specialCharacters" },
] as const;

/**
 * A value generated with the generator's last options, of usernames with `username`, and the options
 * to change them, as the app's. `onUse` adds the button that uses the value.
 */
function Generator({
  username = false,
  onUse,
}: {
  username?: boolean;
  onUse?: (value: string) => void;
}) {
  const { formatMessage: t } = useIntl();
  const { value, settings, change, regenerate } = useGenerator(username);
  const includeLabel = useId();
  if (value === undefined || settings === undefined) return null;
  const isPassword = settings.type === "password";
  const { password, passphrase } = settings;
  const setPassword = (changes: Partial<PasswordOptions>) =>
    change({ ...settings, password: { ...password, ...changes } });
  const setPassphrase = (changes: Partial<PassphraseOptions>) =>
    change({ ...settings, passphrase: { ...passphrase, ...changes } });
  const setUsername = (changes: Partial<UsernameOptions>) =>
    change({ ...settings, username: { ...settings.username, ...changes } });
  return (
    <div className="generator">
      <div className="generator-preview">
        <PasswordText value={value} />
        <IconButton icon={refresh} label={t({ id: "regenerate" })} onPress={regenerate} />
        <CopyButton value={value} sensitive={!username} />
      </div>
      {username ? (
        <div className="generator-options">
          <SwitchTile
            label={t({ id: "usernameCapitalize" })}
            isSelected={settings.username.capitalize}
            onChange={(capitalize) => setUsername({ capitalize })}
          />
          <SwitchTile
            label={t({ id: "usernameIncludeNumber" })}
            isSelected={settings.username.includeNumber}
            onChange={(includeNumber) => setUsername({ includeNumber })}
          />
        </div>
      ) : (
        <>
          <ToggleButtonGroup
            selectionMode="single"
            disallowEmptySelection
            selectedKeys={[settings.type]}
            onSelectionChange={(keys) => {
              const [type] = keys;
              if (type === "password" || type === "passphrase") change({ ...settings, type });
            }}
            className="chips generator-types"
          >
            <ToggleButton id="password" className="chip">
              {t({ id: "password" })}
            </ToggleButton>
            <ToggleButton id="passphrase" className="chip">
              {t({ id: "passphrase" })}
            </ToggleButton>
          </ToggleButtonGroup>
          {isPassword ? (
            <div className="generator-options">
              <CountField
                label={t({ id: "passwordLength" })}
                value={password.length}
                min={passwordLengths.min}
                max={passwordLengths.max}
                onChange={(length) => setPassword({ length })}
              />
              <Slider
                className="generator-slider"
                aria-label={t({ id: "passwordLength" })}
                minValue={passwordLengths.min}
                maxValue={passwordLengths.max}
                value={password.length}
                onChange={(length) => setPassword({ length })}
              >
                <SliderTrack className="slider-track">
                  <div className="slider-line">
                    <SliderFill className="slider-fill" />
                  </div>
                  <SliderThumb className="slider-thumb" />
                </SliderTrack>
              </Slider>
              <span id={includeLabel} className="generator-label">
                {t({ id: "includeCharacters" })}
              </span>
              {/* The last set chosen stays chosen, as in Bitwarden. */}
              <ToggleButtonGroup
                aria-labelledby={includeLabel}
                selectionMode="multiple"
                disallowEmptySelection
                selectedKeys={characterSets.filter(({ id }) => password[id]).map(({ id }) => id)}
                onSelectionChange={(keys) =>
                  setPassword(Object.fromEntries(characterSets.map(({ id }) => [id, keys.has(id)])))
                }
                className="chips"
              >
                {characterSets.map(({ id, text, label }) => (
                  <ToggleButton
                    key={id}
                    id={id}
                    // Named by what it shows too, for voice control.
                    aria-label={`${t({ id: label })}, ${text}`}
                    className="chip"
                  >
                    {text}
                  </ToggleButton>
                ))}
              </ToggleButtonGroup>
              <CountField
                label={t({ id: "minNumbers" })}
                value={password.minNumber}
                min={1}
                max={maxMinCount}
                isDisabled={!password.numbers}
                onChange={(minNumber) => setPassword({ minNumber })}
              />
              <CountField
                label={t({ id: "minSpecial" })}
                value={password.minSpecial}
                min={1}
                max={maxMinCount}
                isDisabled={!password.special}
                onChange={(minSpecial) => setPassword({ minSpecial })}
              />
              <SwitchTile
                label={t({ id: "avoidAmbiguous" })}
                isSelected={password.avoidAmbiguous}
                onChange={(avoidAmbiguous) => setPassword({ avoidAmbiguous })}
              />
            </div>
          ) : (
            <div className="generator-options">
              <CountField
                label={t({ id: "numberOfWords" })}
                value={passphrase.numWords}
                min={wordCounts.min}
                max={wordCounts.max}
                onChange={(numWords) => setPassphrase({ numWords })}
              />
              <AriaTextField
                className="generator-separator"
                value={passphrase.wordSeparator}
                maxLength={1}
                onChange={(wordSeparator) => setPassphrase({ wordSeparator })}
              >
                <Label className="generator-separator-label">{t({ id: "wordSeparator" })}</Label>
                <Input
                  className="generator-separator-input"
                  autoComplete="off"
                  spellCheck={false}
                />
              </AriaTextField>
              <SwitchTile
                label={t({ id: "capitalize" })}
                isSelected={passphrase.capitalize}
                onChange={(capitalize) => setPassphrase({ capitalize })}
              />
              <SwitchTile
                label={t({ id: "includeNumber" })}
                isSelected={passphrase.includeNumber}
                onChange={(includeNumber) => setPassphrase({ includeNumber })}
              />
            </div>
          )}
        </>
      )}
      {onUse && (
        <div className="generator-use">
          <FilledButton onPress={() => onUse(value)}>
            {t({
              id: username ? "useUsername" : isPassword ? "usePassword" : "usePassphrase",
            })}
          </FilledButton>
        </div>
      )}
    </div>
  );
}
