---
description: Move your passwords from Bitwarden to Submarine in a few minutes, with their custom fields and two-factor codes, and take them back out whenever you want.
---

# Import your passwords from Bitwarden

Submarine reads Bitwarden's export file, so moving your passwords takes a few minutes. Nothing changes in your Bitwarden account: the import only copies your items.

## 1. Export your vault from Bitwarden

1. In the Bitwarden web vault, open Tools, then Export vault. The Bitwarden apps have the same command in their settings or menus.
2. Choose the .json format. You can also choose the encrypted .json format protected by a password of your choice: Submarine opens it too.
3. Confirm with your Bitwarden master password, and save the file.

An encrypted export restricted to your Bitwarden account does not work: only Bitwarden can open it. Choose the password protected type instead.

## 2. Import the file into Submarine

1. Open Submarine, and create or open the vault your passwords should go into.
2. Go to **Settings**, then **Import and export**, and press **Import** next to **Import from Bitwarden**.
3. Pick the file. If it is protected by a password, enter that password.
4. Check how many items were found, choose the vault if you have several, and press **Import**.

Your items are encrypted on your device, then synced to your other devices like any other change.

## 3. Delete the export file

A .json export without a password is not encrypted: anyone who gets it can read all your passwords. Delete it once the import is done, and empty your computer's trash. Do not send it by email.

## What is imported

- Logins, cards, secure notes, identities, SSH keys and Bitwarden's other item types, with their custom fields and their two-factor authentication codes.
- Logins, cards and secure notes can be edited in Submarine. The other types are kept and shown, but cannot be edited yet.
- Passkeys are kept and shown, but Submarine cannot sign in with them yet.
- Folders are not imported: Submarine keeps items apart by vault instead.
- Attached files are not part of Bitwarden's export, so they stay in Bitwarden.

## Coming from another password manager

Submarine reads Bitwarden's format only. Bitwarden itself imports from most password managers, such as 1Password, LastPass, KeePass or your browser. With a free Bitwarden account, import your passwords there first, then follow the steps above.

## Leaving Submarine

Submarine exports in the same format. In **Settings**, then **Import and export**, **Export a vault** saves a Bitwarden file, protected by a password or not encrypted, that Bitwarden and other password managers can import. The trash is left out.

New to Submarine? [Download it](/download), or read [how it protects your passwords](/security).
