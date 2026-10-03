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
dart run bin/submarine.dart add Boulanger --uri https://www.boulanger.com --username alice@example.com
dart run bin/submarine.dart list
dart run bin/submarine.dart get boulanger
```

`add` asks for whatever the options leave out, and always for the password,
which is not echoed. When stdin is piped, it reads one line per question.

`get` finds an item by name, ignoring case, or by id. When several items share
the name, it lists their ids.

Before reading the vault, `list` and `get` fetch what changed on the relays
since the last run. The vault's gift wraps, still encrypted, are cached in
`~/.cache/submarine` (under `$XDG_CACHE_HOME` or `%LOCALAPPDATA%` when set).
Passwords are decrypted in memory only. Delete the whole folder to start over
from the relays.
