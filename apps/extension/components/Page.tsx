import arrowBack from "@material-design-icons/svg/round/arrow_back.svg";
import { type ReactNode, type Ref, useEffect, useRef } from "react";
import { useIntl } from "react-intl";
import { IconButton } from "./Button";
import "./Page.css";

/** A page over the list, its back button above `children`, until `onBack` or Escape. */
export function Page({
  className,
  onBack,
  backRef,
  children,
}: {
  className: string;
  onBack: () => void;
  backRef?: Ref<HTMLButtonElement>;
  children: ReactNode;
}) {
  const { formatMessage: t } = useIntl();
  useEffect(() => {
    const goBack = (event: KeyboardEvent) => {
      if (event.key !== "Escape" || event.defaultPrevented) return;
      // Rather than the browser closing the popup.
      event.preventDefault();
      onBack();
    };
    document.addEventListener("keydown", goBack);
    return () => document.removeEventListener("keydown", goBack);
  }, [onBack]);
  return (
    <section className={`page ${className}`}>
      <div className="page-bar">
        <IconButton ref={backRef} icon={arrowBack} label={t({ id: "back" })} onPress={onBack} />
      </div>
      {children}
    </section>
  );
}

/** The top of a page: `mark`, then `title` over `children`. */
export function PageHeader({
  mark,
  title,
  children,
}: {
  mark: ReactNode;
  title: string;
  children: ReactNode;
}) {
  const heading = useRef<HTMLHeadingElement>(null);
  useEffect(() => {
    // A screen reader reads the title, the first thing the page shows.
    heading.current?.focus();
  }, []);
  return (
    <header className="page-header">
      {mark}
      <div className="page-heading">
        <h1 ref={heading} tabIndex={-1} className="page-title">
          {title}
        </h1>
        {children}
      </div>
    </header>
  );
}
