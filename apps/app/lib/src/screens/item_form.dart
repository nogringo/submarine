import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../items/item_filter.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/vault_avatar.dart';
import 'item_detail.dart';

/// Creates a login, or edits the item [itemId]. Only the name, the notes, the
/// favorite and a login's fields are edited: the rest of the item is kept.
class ItemForm extends StatelessWidget {
  const ItemForm({
    super.key,
    required this.vaultId,
    required this.filter,
    this.itemId,
  });

  /// The vaults whose items are listed, where the form goes back to.
  final String vaultId;
  final ItemFilter filter;
  final String? itemId;

  @override
  Widget build(BuildContext context) {
    final itemId = this.itemId;
    if (itemId == null) return _Form(vaultId: vaultId, filter: filter);
    return ItemOrMissing(
      vaultId: vaultId,
      itemId: itemId,
      builder: (entry) => _Form(vaultId: vaultId, filter: filter, entry: entry),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.vaultId, required this.filter, this.entry});

  final String vaultId;
  final ItemFilter filter;
  final VaultItem? entry;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  /// The version being edited, rather than one synced meanwhile: saving over
  /// it keeps both, as a conflict, instead of losing the other.
  late final VaultItem? _original = widget.entry;

  /// A copy, as the item's own cipher is the one on screen.
  late final Cipher? _cipher = switch (_original) {
    final entry? => Cipher.fromJson(entry.item.current.data),
    null => null,
  };

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _totp = TextEditingController();
  final _notes = TextEditingController();

  /// Each website field, with the URI it edits, whose match setting is kept.
  final _uris = <(LoginUri?, TextEditingController)>[];
  var _favorite = false;
  VaultController? _chosenVault;
  var _passwordHidden = true;
  var _saving = false;
  String? _nameError;
  String? _saveError;

  bool get _isLogin => (_cipher?.type ?? CipherType.login) == CipherType.login;

  @override
  void initState() {
    super.initState();
    final cipher = _cipher;
    final login = cipher?.login;
    _name.text = cipher?.name ?? '';
    _username.text = login?.username ?? '';
    _password.text = login?.password ?? '';
    _totp.text = login?.totp ?? '';
    _notes.text = cipher?.notes ?? '';
    _favorite = cipher?.favorite ?? false;
    _uris.addAll([
      for (final uri in login?.uris ?? const <LoginUri>[])
        (uri, TextEditingController(text: uri.uri)),
    ]);
    if (_uris.isEmpty) _uris.add((null, TextEditingController()));
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _username,
      _password,
      _totp,
      _notes,
      for (final (_, controller) in _uris) controller,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  VaultController _vaultOf(Vaults vaults) =>
      _original?.vault ??
      _chosenVault ??
      vaults.byPubkey(widget.vaultId) ??
      vaults.all.first;

  void _close() => context.go(
    vaultPath(
      widget.vaultId,
      filter: widget.filter,
      itemId: _original?.item.id,
    ),
  );

  Future<void> _save() async {
    if (_saving) return;
    final l10n = context.l10n;
    final name = _name.text.trim();
    setState(() {
      _nameError = name.isEmpty ? l10n.itemNameRequired : null;
      _saveError = null;
    });
    if (_nameError != null) return;

    String? valueOf(TextEditingController controller) =>
        controller.text.isEmpty ? null : controller.text;
    final vault = _vaultOf(Vaults.of(context));
    final cipher = (_cipher ?? Cipher(type: CipherType.login, name: name))
      ..name = name
      ..notes = valueOf(_notes)
      ..favorite = _favorite;
    if (_isLogin) {
      (cipher.login ??= Login())
        ..username = valueOf(_username)
        ..password = valueOf(_password)
        ..totp = valueOf(_totp)
        ..uris = [
          for (final (uri, controller) in _uris)
            if (controller.text.trim() case final text when text.isNotEmpty)
              (uri ?? LoginUri(null))..uri = text,
        ];
    }

    setState(() => _saving = true);
    try {
      final item = switch (_original) {
        final entry? => await vault.updateItem(entry.item, cipher),
        null => await vault.createItem(cipher),
      };
      if (!mounted) return;
      context.go(
        vaultPath(
          widget.vaultId == allVaultsId ? allVaultsId : vault.pubkey,
          filter: widget.filter.matches(item.cipher)
              ? widget.filter
              : ItemFilter.all,
          itemId: item.id,
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = l10n.itemSaveFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final theme = Theme.of(context);
    final vaults = Vaults.of(context);
    const gap = SizedBox(height: 20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 20, 10),
              child: Row(
                children: [
                  TextButton(onPressed: _close, child: Text(l10n.cancel)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _original == null ? l10n.newLogin : l10n.editItem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: Text(l10n.save),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: Theme(
            data: theme.copyWith(
              inputDecorationTheme: theme.inputDecorationTheme.copyWith(
                fillColor: palette.surface,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_saveError case final error?) ...[
                        Text(error, style: TextStyle(color: palette.danger)),
                        gap,
                      ],
                      if (_original == null && vaults.all.length > 1) ...[
                        DropdownButtonFormField<VaultController>(
                          initialValue: _vaultOf(vaults),
                          borderRadius: BorderRadius.circular(12),
                          decoration: InputDecoration(labelText: l10n.vault),
                          items: [
                            for (final vault in vaults.all)
                              DropdownMenuItem(
                                value: vault,
                                child: Row(
                                  children: [
                                    VaultAvatar(vault: vault, size: 24),
                                    const SizedBox(width: 12),
                                    Text(vault.name),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (vault) =>
                              setState(() => _chosenVault = vault),
                        ),
                        gap,
                      ],
                      TextField(
                        controller: _name,
                        autofocus: _original == null,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.itemName,
                          errorText: _nameError,
                        ),
                      ),
                      gap,
                      if (_isLogin) ...[
                        TextField(
                          controller: _username,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(labelText: l10n.username),
                        ),
                        gap,
                        TextField(
                          controller: _password,
                          obscureText: _passwordHidden,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          style: monoStyle,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            suffixIcon: IconButton(
                              tooltip: _passwordHidden ? l10n.show : l10n.hide,
                              onPressed: () => setState(
                                () => _passwordHidden = !_passwordHidden,
                              ),
                              icon: Icon(
                                _passwordHidden
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        gap,
                        TextField(
                          controller: _totp,
                          autocorrect: false,
                          enableSuggestions: false,
                          textInputAction: TextInputAction.next,
                          style: monoStyle,
                          decoration: InputDecoration(
                            labelText: l10n.authenticatorKey,
                            hintText: l10n.authenticatorKeyHint,
                            hintStyle: monoStyle.copyWith(color: palette.muted),
                          ),
                        ),
                        gap,
                        for (final (_, controller) in _uris) ...[
                          TextField(
                            controller: controller,
                            autocorrect: false,
                            enableSuggestions: false,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.website,
                              hintText: 'https://',
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setState(
                              () => _uris.add((null, TextEditingController())),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: Text(l10n.addWebsite),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _notes,
                        minLines: 3,
                        maxLines: 10,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: l10n.notes),
                      ),
                      gap,
                      SwitchListTile(
                        value: _favorite,
                        onChanged: (favorite) =>
                            setState(() => _favorite = favorite),
                        title: Text(l10n.favorite),
                        tileColor: palette.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: palette.line),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
