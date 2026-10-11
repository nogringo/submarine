import { useEffect, useState } from "react";
import { callCore, type Vault } from "@/lib/core";
import { useSync } from "@/lib/use-sync";
import "./App.css";
import { Home } from "./Home";
import { OpenVault } from "./OpenVault";
import { Welcome } from "./Welcome";

export function App() {
  const [vaults, setVaults] = useState<Vault[]>();
  const [opening, setOpening] = useState(false);
  const sync = useSync();

  useEffect(() => {
    callCore("vaults", {}).then(setVaults);
  }, []);

  if (!vaults) return null;
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
