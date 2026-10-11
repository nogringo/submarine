import visibility from "@material-design-icons/svg/outlined/visibility.svg";
import visibilityOff from "@material-design-icons/svg/outlined/visibility_off.svg";
import { useState } from "react";
import {
  TextField as AriaTextField,
  FieldError,
  Group,
  Input,
  Label,
  Text,
  type TextFieldProps,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { IconButton } from "./Button";
import "./TextField.css";

/**
 * A labelled field, with its help below and its error in place of the help. A secret field is
 * hidden until shown, by its own button or by `shown`; a mono one is written in the font that tells
 * every character apart.
 */
export function TextField({
  label,
  description,
  error,
  placeholder,
  secret,
  mono,
  shown: shownProp,
  onShownChange,
  ...props
}: Omit<TextFieldProps, "children" | "isInvalid"> & {
  label: string;
  description?: string;
  error?: string;
  placeholder?: string;
  secret?: boolean;
  mono?: boolean;
  /** For several secret fields shown together. */
  shown?: boolean;
  onShownChange?: (shown: boolean) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [ownShown, setOwnShown] = useState(false);
  const shown = shownProp ?? ownShown;
  const setShown = onShownChange ?? setOwnShown;
  return (
    <AriaTextField
      {...props}
      className="text-field"
      isInvalid={error !== undefined}
      validationBehavior="aria"
    >
      <Label className="text-field-label">{label}</Label>
      <Group className="text-field-box">
        <Input
          className={mono ? "text-field-input mono" : "text-field-input"}
          type={secret && !shown ? "password" : "text"}
          placeholder={placeholder}
          spellCheck={secret ? false : undefined}
          autoCorrect={secret ? "off" : undefined}
        />
        {secret && (
          <IconButton
            icon={shown ? visibilityOff : visibility}
            label={t({ id: shown ? "hide" : "show" })}
            onPress={() => setShown(!shown)}
          />
        )}
      </Group>
      {error === undefined && description && (
        <Text slot="description" className="text-field-description">
          {description}
        </Text>
      )}
      <FieldError className="text-field-error">{error}</FieldError>
    </AriaTextField>
  );
}
