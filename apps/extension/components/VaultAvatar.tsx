import add from "@material-design-icons/svg/round/add.svg";
import layers from "@material-design-icons/svg/round/layers.svg";
import type { Vault } from "@/lib/core";
import { cssColor } from "@/lib/vault-colors";
import { Icon } from "./Icon";
import "./VaultAvatar.css";

// The vault's name is beside its avatar, or labels the control around it.

/** A vault's tile: its initial on its color. */
export function VaultAvatar({ vault, size }: { vault: Vault; size: number }) {
  const initial = [...vault.name.trim()][0]?.toUpperCase() ?? "?";
  return (
    <span
      className="vault-avatar"
      style={{ width: size, height: size, background: cssColor(vault.color), fontSize: size * 0.4 }}
      aria-hidden="true"
    >
      {initial}
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
