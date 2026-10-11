import { useEffect, useState } from "react";
import { callCore, type Vault } from "@/lib/core";
import { forgetOpenedItem } from "@/lib/opened-item";
import { useLockState } from "@/lib/use-lock-state";
import { useReportUse } from "@/lib/use-report-use";
import { useSync } from "@/lib/use-sync";
import "./App.css";
import { Home } from "./Home";
import { LockScreen } from "./LockScreen";
import { OpenVault } from "./OpenVault";
import { Welcome } from "./Welcome";

export function App() {
  const [vaults, setVaults] = useState<Vault[]>();
  const [opening, setOpening] = useState(false);
  const sync = useSync();
  // Read again as the core tells: another popup or the lock delay may lock or unlock.
  const { lock, read: readLock, lockNow } = useLockState(sync.revision);
  const unlocked = lock?.locked === false;
  useReportUse(unlocked && lock.hasPassword);
  useEffect(() => {
    // Locking lets go of them.
    if (unlocked) callCore("vaults", {}).then(setVaults);
    else setVaults(undefined);
  }, [unlocked]);
  useEffect(() => {
    // However they locked, a popup sees it before unlocking them.
    if (lock?.locked) void forgetOpenedItem();
  }, [lock?.locked]);

  if (lock?.locked) {
    return <LockScreen onChanged={readLock} />;
  }
  if (!lock || !vaults) return null;
  if (opening) {
    return (
      <OpenVault
        vaultCount={vaults.length}
        onOpened={(vault) => {
          setVaults([...vaults, vault]);
          setOpening(false);
        }}
        onCancel={() => setOpening(false)}
      />
    );
  }
  if (vaults.length === 0) return <Welcome onOpenVault={() => setOpening(true)} />;
  return (
    <Home
      vaults={vaults}
      sync={sync}
      hasLockPassword={lock.hasPassword}
      onLock={lockNow}
      onOpenVault={() => setOpening(true)}
      onVaultChanged={(vault) =>
        setVaults((vaults) => vaults?.map((each) => (each.pubkey === vault.pubkey ? vault : each)))
      }
      onVaultRemoved={(pubkey) =>
        setVaults((vaults) => vaults?.filter((vault) => vault.pubkey !== pubkey))
      }
    />
  );
}
