# submarine

Command-line client for Submarine, a password manager built on Nostr.

## Setup

The vault key is read from `SUBMARINE_NSEC` (an nsec, or a hex private key).
It is never written to disk.

```sh
export SUBMARINE_NSEC=nsec1...
```

By default, the vault lives on these relays:

- `wss://relay.nmail.li`
- `wss://nos.lol`
- `wss://nostr.mom`
- `wss://relay.primal.net`
- `wss://relay.nos.social`
- `wss://offchain.pub`
- `wss://relay.coinos.io`
- `wss://nostr-pub.wellorder.net`
- `wss://relay.ditto.pub`

Some relays, like `relay.nmail.li` and `relay.ditto.pub`, serve gift wraps to
their recipient only: the CLI authenticates to them as the vault key (NIP-42).

To use other relays, list them in `~/.config/submarine/config.json` (under
`$XDG_CONFIG_HOME` or `%APPDATA%` when set):

```json
{ "relays": ["wss://relay.example.com"] }
```

`--relay` overrides both for one command, and can be repeated.

## Usage

From `apps/cli`:

```sh
dart run bin/submarine.dart sync
dart run bin/submarine.dart add Boulanger --uri https://www.boulanger.com --username alice@example.com
dart run bin/submarine.dart list items --search boulanger
dart run bin/submarine.dart get password boulanger
```

`add` asks for whatever the options leave out, and always for the password,
which is not echoed. When stdin is piped, it reads one line per question.

### Bitwarden CLI compatibility

These commands behave like their `bw` counterparts, so a script written for
the Bitwarden CLI runs on Submarine as long as it sticks to them:

- `sync`, `sync --last`
- `status`: `unlocked` when `SUBMARINE_NSEC` is set, `unauthenticated`
  otherwise. `userId` is the vault's public key, in hex.
- `list items`, with `--search` and `--trash`
- `get item|username|password|uri|notes <id>`, where `<id>` is an item id or
  a search term
- the global flags `--pretty`, `--raw` and `--quiet`

Output is the same: JSON items, bare values for `get password` and the like,
errors on stderr with exit code 1, and no final newline when the output is
piped. Searching ignores case and accents and looks in the name, username,
hostnames and notes. Other `bw` commands and objects fail with an error.

`list` and `get` read the local cache only, they never go to the relays.
`sync` fetches what changed on the relays since the last sync. Until the first
sync, `list` and `get` refuse to run. Items saved with `add` are in the cache
right away.

The vault's gift wraps, still encrypted, are cached in `~/.cache/submarine`
(under `$XDG_CACHE_HOME` or `%LOCALAPPDATA%` when set). Passwords are decrypted
in memory only. Delete the whole folder to start over from the relays.
