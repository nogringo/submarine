import add from "@material-design-icons/svg/round/add.svg";
import layers from "@material-design-icons/svg/round/layers.svg";
import type { Vault } from "@/lib/core";
import { cssColor } from "@/lib/vault-colors";
import { Icon } from "./Icon";
import "./VaultAvatar.css";

// The vault's name is beside its avatar, or labels the control around it.

export function initialOf(name: string): string {
  return [...name.trim()][0]?.toUpperCase() ?? "?";
}

/** A vault's tile: its initial on its color. */
export function VaultAvatar({ vault, size }: { vault: Vault; size: number }) {
  return (
    <span
      className="vault-avatar"
      style={{ width: size, height: size, background: cssColor(vault.color), fontSize: size * 0.4 }}
      aria-hidden="true"
    >
      {initialOf(vault.name)}
    </span>
  );
}

/** The small mark of a vault on an item, where several vaults are shown, named for a screen reader. */
export function VaultBadge({ vault, size = 16 }: { vault: Vault; size?: number }) {
  return (
    <span
      className="vault-badge"
      style={{ width: size, height: size, background: cssColor(vault.color), fontSize: size * 0.5 }}
      role="img"
      aria-label={vault.name}
    >
      <span aria-hidden="true">{initialOf(vault.name)}</span>
    </span>
  );
}

export function AllVaultsAvatar({ size }: { size: number }) {
  return (
    <span className="vault-avatar all" style={{ width: size, height: size }} aria-hidden="true">
      <Icon src={layers} size={size * 0.5} />
    </span>
  );
}

/** Stands in the place of a vault's avatar, to open a vault. */
export function OpenVaultMark({ size }: { size: number }) {
  return (
    <span className="open-vault-mark" style={{ width: size, height: size }} aria-hidden="true">
      <Icon src={add} size={size * 0.5} />
    </span>
  );
}
