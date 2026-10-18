import closeIcon from "@material-design-icons/svg/round/close.svg";
import type { ReactNode } from "react";
import { Dialog, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { IconButton } from "./Button";
import "./Sheet.css";

/**
 * The app's bottom sheet, as on a phone, opened by a DialogTrigger or by `isOpen`: its title, then
 * `actions` and a close button, above `children`.
 */
export function Sheet({
  title,
  actions,
  isOpen,
  onOpenChange,
  children,
}: {
  title: string;
  actions?: ReactNode;
  isOpen?: boolean;
  onOpenChange?: (isOpen: boolean) => void;
  children: (close: () => void) => ReactNode;
}) {
  const { formatMessage: t } = useIntl();
  return (
    <ModalOverlay
      className="sheet-overlay"
      isDismissable
      isOpen={isOpen}
      onOpenChange={onOpenChange}
    >
      <Modal className="sheet">
        <Dialog className="sheet-dialog">
          {({ close }) => (
            <>
              <div className="sheet-header">
                <Heading slot="title" className="sheet-title">
                  {title}
                </Heading>
                <div className="sheet-actions">
                  {actions}
                  <IconButton icon={closeIcon} label={t({ id: "close" })} onPress={close} />
                </div>
              </div>
              {children(close)}
            </>
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
