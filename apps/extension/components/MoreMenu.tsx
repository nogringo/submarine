import moreHoriz from "@material-design-icons/svg/round/more_horiz.svg";
import { Menu, MenuItem, MenuTrigger, Popover } from "react-aria-components";
import { IconButton } from "./Button";
import { Icon } from "./Icon";
import "./MoreMenu.css";

export interface MenuAction<K extends string> {
  id: K;
  label: string;
  icon: string;
  /** In red, as the app shows an action that destroys. */
  danger?: boolean;
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
    <MenuTrigger>
      <IconButton icon={moreHoriz} label={label} isDisabled={isDisabled} />
      <Popover className="more-menu-popover" placement="bottom end">
        <Menu className="more-menu" items={actions} onAction={(id) => onAction(id as K)}>
          {(action) => (
            <MenuItem
              id={action.id}
              textValue={action.label}
              className={action.danger ? "more-menu-item danger" : "more-menu-item"}
            >
              <Icon src={action.icon} size={20} />
              {action.label}
            </MenuItem>
          )}
        </Menu>
      </Popover>
    </MenuTrigger>
  );
}
