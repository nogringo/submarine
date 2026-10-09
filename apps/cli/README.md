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
- `wss://relay.primal.net`
- `wss://relay.nos.social`
- `wss://relay.coinos.io`
- `wss://relay.ditto.pub`
- `wss://auth.nostr1.com`
- `wss://relay.nostr.com`
- `wss://nostr.oxtr.dev`
- `wss://nostr.data.haus`
- `wss://purplerelay.com`
- `wss://relay.nostr.wirednet.jp`

Some relays, like `relay.nmail.li` and `relay.ditto.pub`, serve gift wraps to
their recipient only: the CLI authenticates to them as the vault key (NIP-42).

To use other relays, list them in `~/.config/submarine/config.json` (under
`$XDG_CONFIG_HOME` or `%APPDATA%` when set):

```json
{ "relays": ["wss://relay.example.com"] }
```

`--relay` overrides both for one command, and can be repeated.

Once the vault has a relay list (NIP-65), it lives on the relays the list
names instead. `sync` fetches that list from the relays above, from the relays
of the list it already knows and from the indexers `purplepag.es`,
`user.kindpag.es` and `indexer.coracle.social`.

`relay list` shows the relays the vault lives on, and `relay add` and
`relay remove` change its relay list. While the vault has none, they start from
the relays above. A relay the list adds gets a copy of the vault. `--private`
encrypts a relay in the list, for the vault only to see. `--read` and `--write`
mark a relay for other clients: Submarine reads and writes on every relay. The
list is saved locally, and `sync` sends it.

```sh
dart run bin/submarine.dart relay add wss://relay.example.com --private
dart run bin/submarine.dart relay remove wss://relay.nmail.li
dart run bin/submarine.dart relay list --pretty
```

`server list` shows the Blossom servers the vault keeps its files on, and
`server add` and `server remove` change its server list (BUD-03). While the
vault has none, they start from `blossom.nmail.li`, `blossom.yakihonne.com`,
`blossom.ditto.pub` and `nostr.download`. `--private` encrypts a server in the
list, for the vault only to see. The list lives on the vault's relays: `sync`
fetches it with the items, and sends it once changed.

```sh
dart run bin/submarine.dart server add files.example.com --private
dart run bin/submarine.dart server remove https://nostr.download
dart run bin/submarine.dart server list --pretty
```

## Usage

From `apps/cli`:

```sh
dart run bin/submarine.dart sync
dart run bin/submarine.dart add Boulanger --uri https://www.boulanger.com --username alice@example.com
dart run bin/submarine.dart list items --search boulanger
dart run bin/submarine.dart get password boulanger
dart run bin/submarine.dart get totp boulanger
dart run bin/submarine.dart generate -ulns --length 20
dart run bin/submarine.dart generate -p --words 5 --separator space
```

`add` asks for whatever the options leave out, and always for the password,
which is not echoed. When stdin is piped, it reads one line per question.

`create` saves an item from its JSON, base64 encoded by `encode`, as
`bw create` does. `get template` prints JSON to start from:

```sh
dart run bin/submarine.dart get template item \
  | jq '.name = "Boulanger" | .login = {username: "alice@example.com", password: "Tr0ub4dor&3"}' \
  | dart run bin/submarine.dart encode \
  | dart run bin/submarine.dart create item
```

`edit` replaces an item with the JSON `get item` prints, base64 encoded by
`encode`, as `bw edit` does. To change the password of the Boulanger item:

```sh
dart run bin/submarine.dart get item boulanger \
  | jq '.login.password = "Tr0ub4dor&3"' \
  | dart run bin/submarine.dart encode \
  | dart run bin/submarine.dart edit item <id>
```

As in Bitwarden, the replaced password goes to the item's password history,
which keeps the last 5, and `edit` refuses an item that changed since it was
read.

`delete` moves an item to the trash, which `list items --trash` shows and
`restore` takes it out of. `delete --permanent` asks the relays to delete every
version of the item, and other devices drop them at their next sync. Unlike
Bitwarden, the trash is never emptied on its own.

`import` adds the items of a Bitwarden JSON export to the vault, and `export`
writes the vault as one, which Bitwarden imports. The trash is left out, and
an export restricted to a Bitwarden account cannot be imported. A password
protected export asks for its password, unless `--passwordfile` or
`--passwordenv` gives it:

```sh
dart run bin/submarine.dart import bitwardenjson bitwarden_export.json
dart run bin/submarine.dart export --output ~/Downloads/
dart run bin/submarine.dart export --password --output vault.json
dart run bin/submarine.dart --raw export --password hunter2 > vault.json
```

`export` names the file as Bitwarden does, readable by its owner only.
`--password` protects it, and asks for the password when given no value.

### Bitwarden CLI compatibility

These commands behave like their `bw` counterparts, so a script written for
the Bitwarden CLI runs on Submarine as long as it sticks to them:

- `sync`, `sync --force` and `sync --last`
- `status`: `unlocked` when `SUBMARINE_NSEC` is set, `unauthenticated`
  otherwise. `userId` is the vault's public key, in hex. `unsentEvents` counts
  the changes no relay accepted yet.
- `list items`, with `--search` and `--trash`
- `get item|username|password|uri|totp|notes <id>`, where `<id>` is an item
  id or a search term
- `get template <object>`, for `item`, `item.field`, `item.login`,
  `item.login.uri`, `item.card`, `item.identity`, `item.securenote`,
  `item.bankaccount`, `item.driverslicense` and `item.passport`
- `create item [encodedJson]`
- `edit item <id> [encodedJson]`, where `<id>` is an item id
- `encode`
- `generate`, with all of its options and defaults, without a vault key
- `delete item <id>`, with `--permanent`, and `restore item <id>`, where
  `<id>` is an item id
- `import bitwardenjson <input>`, with `--formats`, `--passwordenv` and
  `--passwordfile`. It is the only format.
- `export`, with `--output`, `--password` and `--format json|encrypted_json`.
  The default format is `json`, where bw writes CSV, and `encrypted_json`
  needs `--password`, as a vault has no account key to encrypt with.
- the global flags `--pretty`, `--raw`, `--quiet` and `--version`

Output is the same: JSON items, bare values for `get password` and the like,
errors on stderr with exit code 1, and no final newline when the output is
piped. Searching ignores case and accents and looks in the name, username,
hostnames and notes. Other `bw` commands and objects fail with an error.

Submarine is local first: its cache is a local relay. `add`, `create`, `edit`,
`delete`, `restore` and `import` save their change in it and never wait for the
network.
`sync` fetches the vault's relay list, sends to its relays the changes none
accepted yet, then fetches what changed since the last sync. `list`, `get` and `export` read the cache only.
Until the first sync, they refuse to run, except `get template`.

`sync --force` reads the whole vault from each of its relays, then gives the
cache and each relay what it lacks, such as what a relay dropped over time.
Nothing is sent before every relay answered, and a relay that did not give all
it holds gets nothing. The command fails with the relays left out, if any.

The vault's gift wraps, still encrypted, are cached in `~/.cache/submarine`
(under `$XDG_CACHE_HOME` or `%LOCALAPPDATA%` when set). Passwords are decrypted
in memory only. Delete the whole folder to start over from the relays.
