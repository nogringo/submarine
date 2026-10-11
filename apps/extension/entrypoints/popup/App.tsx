import { useEffect, useState } from "react";
import { callCore, type LockState, type Vault } from "@/lib/core";
import { useSync } from "@/lib/use-sync";
import "./App.css";
import { Home } from "./Home";
import { LockScreen } from "./LockScreen";
import { OpenVault } from "./OpenVault";
import { Welcome } from "./Welcome";

export function App() {
  const [lock, setLock] = useState<LockState>();
  const [vaults, setVaults] = useState<Vault[]>();
  const [opening, setOpening] = useState(false);
  const sync = useSync();

  // biome-ignore lint/correctness/useExhaustiveDependencies: another popup may lock or unlock.
  useEffect(() => {
    callCore("lockState", {}).then(setLock);
  }, [sync.revision]);
  const unlocked = lock?.locked === false;
  useEffect(() => {
    // Locking lets go of them.
    if (unlocked) callCore("vaults", {}).then(setVaults);
    else setVaults(undefined);
  }, [unlocked]);

  if (lock?.locked) {
    return <LockScreen onUnlocked={() => setLock({ ...lock, locked: false })} />;
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
      onLock={() => {
        setLock({ ...lock, locked: true });
        void callCore("lock", {});
      }}
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
