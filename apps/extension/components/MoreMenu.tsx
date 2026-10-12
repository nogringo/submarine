import moreHoriz from "@material-design-icons/svg/round/more_horiz.svg";
import { type ReactElement, useRef } from "react";
import { Menu, MenuItem, MenuTrigger, Popover, Separator } from "react-aria-components";
import { IconButton } from "./Button";
import { Icon } from "./Icon";
import "./MoreMenu.css";

export interface MenuAction<K extends string> {
  id: K;
  label: string;
  icon: string;
  /** In red, as the app shows an action that destroys. */
  danger?: boolean;
  /** A line above it, as the app sets a group apart. */
  separated?: boolean;
}

/** `actions` in a menu that `trigger`, a button, opens below it, as the app's menus. */
export function ActionMenu<K extends string>({
  trigger,
  actions,
  onAction,
  placement = "bottom end",
}: {
  trigger: ReactElement;
  actions: MenuAction<K>[];
  onAction: (id: K) => void;
  placement?: "bottom start" | "bottom end";
}) {
  return (
    <MenuTrigger>
      {trigger}
      <Popover className="more-menu-popover" placement={placement}>
        <Menu className="more-menu" onAction={(id) => onAction(id as K)}>
          {menuItems(actions)}
        </Menu>
      </Popover>
    </MenuTrigger>
  );
}

/**
 * `actions` in a menu at `x` and `y` in the window, where a right click opens it, its first action
 * focused, until `onClose`.
 */
export function ContextMenu<K extends string>({
  x,
  y,
  label,
  actions,
  onAction,
  onClose,
}: {
  x: number;
  y: number;
  label: string;
  actions: MenuAction<K>[];
  onAction: (id: K) => void;
  onClose: () => void;
}) {
  const anchor = useRef<HTMLSpanElement>(null);
  return (
    <>
      <span ref={anchor} className="context-menu-anchor" style={{ left: x, top: y }} />
      <Popover
        className="more-menu-popover"
        // A dialog, which a MenuTrigger would name after its button.
        aria-label={label}
        triggerRef={anchor}
        placement="bottom start"
        offset={0}
        isOpen
        onOpenChange={(open) => {
          if (!open) onClose();
        }}
      >
        <Menu
          className="more-menu"
          aria-label={label}
          autoFocus="first"
          onAction={(id) => onAction(id as K)}
          onClose={onClose}
        >
          {menuItems(actions)}
        </Menu>
      </Popover>
    </>
  );
}

function menuItems<K extends string>(actions: MenuAction<K>[]) {
  return actions.flatMap((action) => [
    ...(action.separated
      ? [<Separator key={`${action.id}-separator`} className="more-menu-separator" />]
      : []),
    <MenuItem
      key={action.id}
      id={action.id}
      textValue={action.label}
      className={action.danger ? "more-menu-item danger" : "more-menu-item"}
    >
      <Icon src={action.icon} size={20} />
      {action.label}
    </MenuItem>,
  ]);
}

/** The app's More actions button, its `actions` in a menu below it. */
export function MoreMenu<K extends string>({
  label,
  actions,
  onAction,
  isDisabled,
}: {
  label: string;
  actions: MenuAction<K>[];
  onAction: (id: K) => void;
  isDisabled?: boolean;
}) {
  return (
    <ActionMenu
      trigger={<IconButton icon={moreHoriz} label={label} isDisabled={isDisabled} />}
      actions={actions}
      onAction={onAction}
    />
  );
}
