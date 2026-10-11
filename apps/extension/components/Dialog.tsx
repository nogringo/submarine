import type { ReactNode } from "react";
import { Dialog, Heading, Modal, ModalOverlay } from "react-aria-components";
import { TextButton } from "./Button";
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
