import accountBalance from "@material-design-icons/svg/outlined/account_balance.svg";
import badge from "@material-design-icons/svg/outlined/badge.svg";
import directionsCar from "@material-design-icons/svg/outlined/directions_car.svg";
import lock from "@material-design-icons/svg/outlined/lock.svg";
import stickyNote from "@material-design-icons/svg/outlined/sticky_note_2.svg";
import creditCard from "@material-design-icons/svg/round/credit_card.svg";
import language from "@material-design-icons/svg/round/language.svg";
import menuBook from "@material-design-icons/svg/round/menu_book.svg";
import terminal from "@material-design-icons/svg/round/terminal.svg";
import type { ItemSummary, Vault } from "@/lib/core";
import { Icon } from "./Icon";
import { initialOf, VaultBadge } from "./VaultAvatar";
import "./ItemIcon.css";

/** By Bitwarden's cipher type, as in the app. */
const typeIcons: Record<number, string> = {
  1: language,
  2: stickyNote,
  3: creditCard,
  4: badge,
  5: terminal,
  6: accountBalance,
  7: directionsCar,
  8: menuBook,
};

/** A login's initial, the type's icon for the rest. `vault` adds its badge. */
export function ItemIcon({
  item,
  vault,
  size = 40,
}: {
  item: ItemSummary;
  vault?: Vault;
  size?: number;
}) {
  return (
    <span className="item-icon">
      <span
        className="item-icon-tile"
        style={{ width: size, height: size, fontSize: size * 0.4 }}
        aria-hidden="true"
      >
        {item.type === 1 && item.name.trim() ? (
          initialOf(item.name)
        ) : (
          <Icon src={typeIcons[item.type] ?? lock} size={size * 0.5} />
        )}
      </span>
      {/* Overflows the tile: items line up whether they show a badge or not. */}
      {vault && (
        <span className="item-icon-badge">
          <VaultBadge vault={vault} />
        </span>
      )}
    </span>
  );
}
