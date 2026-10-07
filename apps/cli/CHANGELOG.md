## 0.1.0

- First release.
- A subset of the Bitwarden CLI: `sync`, `status`, `list items`, `get`,
  `create`, `edit`, `delete`, `restore`, `encode`, `generate`, `import` and
  `export`, with the global flags `--pretty`, `--raw`, `--quiet` and
  `--version`.
- `add` creates a login from its options, and asks for the rest.
- Local first: changes are saved in the cache, and `sync` sends them.
- `sync` fetches the vault's relay list (NIP-65), and the vault moves to the
  relays it names.
- `sync --force` reads the whole vault from every relay, then gives each relay
  what it lacks.
- `relay list`, `relay add` and `relay remove` show and change the vault's
  relay list.
- `import bitwardenjson` reads a Bitwarden JSON export, password protected or
  not. `export` writes `json` by default, where bw writes CSV, and
  `encrypted_json` protects the file with a password.
