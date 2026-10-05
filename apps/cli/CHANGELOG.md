## 0.1.0

- First release.
- A subset of the Bitwarden CLI: `sync`, `status`, `list items`, `get`,
  `create`, `edit`, `delete`, `restore`, `encode` and `generate`, with the
  global flags `--pretty`, `--raw`, `--quiet` and `--version`.
- `add` creates a login from its options, and asks for the rest.
- Local first: changes are saved in the cache, and `sync` sends them.
