import { DialogTrigger } from "react-aria-components";
import { TextButton } from "@/components/Button";
import { MessageDialog } from "@/components/Dialog";
import { Sonar } from "@/components/Sonar";
import "./Welcome.css";

/** Shown until a vault is opened. */
export function Welcome() {
  return (
    <main className="welcome">
      <Sonar size={220} />
      <h1 className="wordmark">Submarine</h1>
      <p className="tagline">Your passwords, encrypted and synced. No account needed.</p>
      <DialogTrigger>
        <TextButton muted>Built on Nostr</TextButton>
        <MessageDialog title="Built on Nostr" close="Close">
          Your vaults live on Nostr relays: open servers that anyone can run, and that only see
          encrypted data. A vault key is a Nostr key, so a Nostr signer can hold it.
        </MessageDialog>
      </DialogTrigger>
    </main>
  );
}
