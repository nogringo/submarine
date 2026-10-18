import { useEffect, useState } from "react";
import { callCore, type Vault } from "@/lib/core";
import { tabAction } from "@/lib/import-export";
import { forgetOpenedItem } from "@/lib/opened-item";
import { useLockState } from "@/lib/use-lock-state";
import { useReportUse } from "@/lib/use-report-use";
import { useSync } from "@/lib/use-sync";
import { AddVault, type AddVaultChoice } from "./AddVault";
import "./App.css";
import { Home } from "./Home";
import { ImportExportPage } from "./ImportExport";
import { LockScreen } from "./LockScreen";
import { Welcome } from "./Welcome";

export function App() {
  const [vaults, setVaults] = useState<Vault[]>();
  const [adding, setAdding] = useState<AddVaultChoice>();
  // Here, for a vault just added to show at once, as in the app.
  const [selected, setSelected] = useState<string>();
  const [fileAction] = useState(tabAction);
  const sync = useSync();
  // Read again as the core tells: another popup or the lock delay may lock or unlock.
  const { lock, read: readLock, lockNow } = useLockState(sync.revision);
  const unlocked = lock?.locked === false;
  useReportUse(unlocked && lock.hasPassword);
  useEffect(() => {
    // Locking lets go of them.
    if (unlocked) callCore("vaults", {}).then(setVaults);
    else {
      setVaults(undefined);
      setSelected(undefined);
    }
  }, [unlocked]);
  useEffect(() => {
    // However they locked, a popup sees it before unlocking them.
    if (lock?.locked) void forgetOpenedItem();
  }, [lock?.locked]);

  if (lock?.locked) {
    return <LockScreen onChanged={readLock} />;
  }
  if (!lock || !vaults) return null;
  if (adding) {
    return (
      <AddVault
        choice={adding}
        vaultCount={vaults.length}
        onAdded={(vault) => {
          setVaults([...vaults, vault]);
          setSelected(vault.pubkey);
          setAdding(undefined);
        }}
        onCancel={() => setAdding(undefined)}
      />
    );
  }
  if (vaults.length === 0) return <Welcome onAddVault={setAdding} />;
  if (fileAction) return <ImportExportPage vaults={vaults} action={fileAction} />;
  return (
    <Home
      vaults={vaults}
      selected={selected}
      onSelect={setSelected}
      sync={sync}
      hasLockPassword={lock.hasPassword}
      onLock={lockNow}
      onAddVault={setAdding}
      onVaultChanged={(vault) =>
        setVaults((vaults) => vaults?.map((each) => (each.pubkey === vault.pubkey ? vault : each)))
      }
      onVaultRemoved={(pubkey) =>
        setVaults((vaults) => vaults?.filter((vault) => vault.pubkey !== pubkey))
      }
    />
  );
}
