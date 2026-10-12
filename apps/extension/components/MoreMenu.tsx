import moreHoriz from "@material-design-icons/svg/round/more_horiz.svg";
import type { ReactElement } from "react";
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
          {actions.flatMap((action) => [
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
          ])}
        </Menu>
      </Popover>
    </MenuTrigger>
  );
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
