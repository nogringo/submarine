import { ToggleButton, ToggleButtonGroup } from "react-aria-components";
import { useIntl } from "react-intl";
import type { ItemFilter } from "@/lib/core";
import type { FilterOption } from "@/lib/item-filters";
import "./Chip.css";
import "./FilterChips.css";

/** The filters of the items as the app's chips, one chosen, in a row that scrolls sideways. */
export function FilterChips({
  options,
  selected,
  onChange,
}: {
  options: FilterOption[];
  selected: ItemFilter;
  onChange: (filter: ItemFilter) => void;
}) {
  const { formatMessage: t } = useIntl();
  return (
    <div
      className="filter-chips"
      // A mouse wheel scrolls up and down only.
      onWheel={(event) => {
        if (event.deltaX === 0) event.currentTarget.scrollLeft += event.deltaY;
      }}
    >
      <ToggleButtonGroup
        aria-label={t({ id: "itemFilters" })}
        selectionMode="single"
        disallowEmptySelection
        selectedKeys={[selected]}
        onSelectionChange={(keys) => {
          const [filter] = keys;
          if (filter !== undefined) onChange(filter as ItemFilter);
        }}
        className="filter-chips-group"
      >
        {options.map(({ filter, label }) => (
          <ToggleButton key={filter} id={filter} className="chip">
            {t({ id: label })}
          </ToggleButton>
        ))}
      </ToggleButtonGroup>
    </div>
  );
}
