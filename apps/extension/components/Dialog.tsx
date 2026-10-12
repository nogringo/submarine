import type { ReactNode } from "react";
import { Dialog, Heading, Modal, ModalOverlay } from "react-aria-components";
import { FilledButton, TextButton } from "./Button";
import "./Dialog.css";

/** A dialog with a title, a message and a Close button, opened by a DialogTrigger. */
export function MessageDialog({
  title,
  close,
  children,
}: {
  title: string;
  close: string;
  children: ReactNode;
}) {
  return (
    <ModalOverlay className="dialog-overlay" isDismissable>
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Heading slot="title" className="dialog-title">
            {title}
          </Heading>
          <div className="dialog-content">{children}</div>
          <div className="dialog-actions">
            <TextButton slot="close">{close}</TextButton>
          </div>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/**
 * A dialog asking to confirm an action that destroys, opened by a DialogTrigger, or by `isOpen` from
 * a menu.
 */
export function ConfirmDialog({
  title,
  cancel,
  confirm,
  onConfirm,
  isOpen,
  onOpenChange,
  children,
}: {
  title: string;
  cancel: string;
  confirm: string;
  onConfirm: () => void;
  isOpen?: boolean;
  onOpenChange?: (isOpen: boolean) => void;
  children?: ReactNode;
}) {
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable
      isOpen={isOpen}
      onOpenChange={onOpenChange}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog" role="alertdialog">
          {({ close }) => (
            <>
              <Heading slot="title" className="dialog-title">
                {title}
              </Heading>
              {children && <div className="dialog-content">{children}</div>}
              <div className="dialog-actions">
                <TextButton slot="close">{cancel}</TextButton>
                <FilledButton
                  danger
                  onPress={() => {
                    close();
                    onConfirm();
                  }}
                >
                  {confirm}
                </FilledButton>
              </div>
            </>
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
