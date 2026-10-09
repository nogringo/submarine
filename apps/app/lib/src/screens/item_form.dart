import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show SignerRequestCancelledException;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../generator/generator_sheet.dart';
import '../items/custom_fields_editor.dart';
import '../items/item_fields.dart';
import '../items/item_filter.dart';
import '../mail/mail_settings.dart';
import '../router.dart';
import '../theme/theme.dart';
import '../vaults/vault_controller.dart';
import '../vaults/vaults.dart';
import '../widgets/vault_dropdown.dart';
import 'item_detail.dart';

/// Creates an item of [type], one of the [formTypes], or edits the item
/// [itemId]. Only the name, the notes, the favorite, the custom fields and the
/// fields of a login or a card are edited: the rest of the item is kept.
class ItemForm extends StatefulWidget {
  const ItemForm({
    super.key,
    required this.vaultId,
    required this.filter,
    this.itemId,
    this.type = CipherType.login,
  });

  /// The vaults whose items are listed, where the form goes back to.
  final String vaultId;
  final ItemFilter filter;
  final String? itemId;

  /// The type of the item created, when not editing one.
  final CipherType type;

  /// Whether the form on screen may be left, asking first if that loses changes.
  static FutureOr<bool> confirmExit() {
    final form = _FormState._shown;
    if (form == null || form._leaving || !form._changed) return true;
    return form._confirmDiscard();
  }

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey();

  /// The item last found, which the form keeps editing while the lock closes
  /// the vaults and they read their items again.
  VaultItem? _entry;

  Widget _form(VaultItem entry) => _Form(
    key: _formKey,
    vaultId: widget.vaultId,
    filter: widget.filter,
    type: entry.item.cipher.type,
    entry: entry,
  );

  @override
  Widget build(BuildContext context) {
    final itemId = widget.itemId;
    if (itemId == null) {
      return _Form(
        vaultId: widget.vaultId,
        filter: widget.filter,
        type: widget.type,
      );
    }
    final vaults = Vaults.of(context);
    final reading =
        vaults.closed ||
        vaults.select(widget.vaultId).any((vault) => !vault.loaded);
    _entry =
        vaults.findItem(widget.vaultId, itemId) ?? (reading ? _entry : null);
    return switch (_entry) {
      final entry? => _form(entry),
      null => ItemOrMissing(
        vaultId: widget.vaultId,
        itemId: itemId,
        builder: _form,
      ),
    };
  }
}

class _Form extends StatefulWidget {
  const _Form({
    super.key,
    required this.vaultId,
    required this.filter,
    required this.type,
    this.entry,
  });

  final String vaultId;
  final ItemFilter filter;
  final CipherType type;
  final VaultItem? entry;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  static _FormState? _shown;

  /// The version being edited, rather than one synced meanwhile: saving over
  /// it keeps both, as a conflict, instead of losing the other.
  late final Item? _original = widget.entry?.item;

  /// The vault of [_original], found again after the lock reopens the vaults.
  late final String? _originalVaultId = widget.entry?.vault.pubkey;

  /// A copy, as the item's own cipher is the one on screen.
  late final Cipher? _cipher = switch (_original) {
    final item? => Cipher.fromJson(item.current.data),
    null => null,
  };

  final _name = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _totp = TextEditingController();
  final _notes = TextEditingController();

  /// Each website field, with the URI it edits, whose match setting is kept.
  final _uris = <(LoginUri?, TextEditingController)>[];
  final _cardholder = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardExpYear = TextEditingController();
  final _cardCode = TextEditingController();
  String? _cardBrand;
  String? _cardExpMonth;

  /// The values the dropdowns offer, with the Bitwarden value each stands
  /// for, null for the item's own value that stands for none.
  late final List<(String, String?)> _cardBrands;
  late final List<(String, String?)> _cardExpMonths;
  final _fields = <EditedField>[];
  var _favorite = false;
  String? _chosenVaultId;
  var _passwordHidden = true;
  var _cardNumberHidden = true;
  var _cardCodeHidden = true;
  var _saving = false;

  /// Set by Cancel or a save, which leave without asking.
  var _leaving = false;
  String? _nameError;
  String? _saveError;
  late final List<Object?> _initialValues;

  CipherType get _type => widget.type;

  List<TextEditingController> get _controllers => [
    _name,
    _username,
    _password,
    _totp,
    _notes,
    for (final (_, controller) in _uris) controller,
    _cardholder,
    _cardNumber,
    _cardExpYear,
    _cardCode,
    for (final field in _fields) field.value,
  ];

  /// What [_save] would write, so an empty website field changes nothing.
  List<Object?> get _values => [
    _name.text.trim(),
    _username.text,
    _password.text,
    _totp.text,
    _notes.text,
    _favorite,
    for (final (_, controller) in _uris)
      if (controller.text.trim() case final text when text.isNotEmpty) text,
    _cardholder.text,
    _cardNumber.text,
    _cardBrand,
    _cardExpMonth,
    _cardExpYear.text,
    _cardCode.text,
    for (final field in _fields) field.state,
  ];

  bool get _changed => !listEquals(_values, _initialValues);

  @override
  void initState() {
    super.initState();
    _shown = this;
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
    final card = cipher?.card;
    _cardholder.text = card?.cardholderName ?? '';
    _cardNumber.text = card?.number ?? '';
    _cardBrand = _nonEmpty(card?.brand);
    _cardExpMonth = _nonEmpty(card?.expMonth);
    _cardExpYear.text = card?.expYear ?? '';
    _cardCode.text = card?.code ?? '';
    _cardBrands = _keeping(
      _bitwardenCardBrands,
      _cardBrand,
      (brand, stored) => brand.toLowerCase() == stored.toLowerCase(),
    );
    _cardExpMonths = _keeping(
      [for (var month = 1; month <= 12; month++) '$month'],
      _cardExpMonth,
      (month, stored) => int.tryParse(stored) == int.parse(month),
    );
    _fields.addAll([
      for (final field in cipher?.fields ?? const <Field>[]) EditedField(field),
    ]);
    _initialValues = _values;
  }

  @override
  void dispose() {
    if (identical(_shown, this)) _shown = null;
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  VaultController _vaultOf(Vaults vaults) =>
      vaults.byPubkey(_originalVaultId ?? _chosenVaultId ?? widget.vaultId) ??
      vaults.all.first;

  void _leave(String location) {
    _leaving = true;
    context.go(location);
  }

  void _close() => _leave(
    vaultPath(widget.vaultId, filter: widget.filter, itemId: _original?.id),
  );

  Future<bool> _confirmDiscard() async {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChanges),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Widget _visibilityButton(bool hidden, VoidCallback toggle) => IconButton(
    tooltip: hidden ? context.l10n.show : context.l10n.hide,
    onPressed: () => setState(toggle),
    icon: Icon(
      hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    ),
  );

  Future<void> _generateUsername() async {
    final username = await showGenerator(context, username: true);
    if (username != null && mounted) _username.text = username;
  }

  Future<void> _generatePassword() async {
    final password = await showGenerator(context);
    if (password != null && mounted) _password.text = password;
  }

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
    final vaults = Vaults.of(context);
    final vault = _vaultOf(vaults);
    final mail = MailSettings.of(context);
    final cipher = (_cipher ?? Cipher(type: _type, name: name))
      ..name = name
      ..notes = valueOf(_notes)
      ..favorite = _favorite
      ..fields = [for (final field in _fields) field.toField()];
    switch (_type) {
      case CipherType.login:
        (cipher.login ??= Login())
          ..username = valueOf(_username)
          ..password = valueOf(_password)
          ..totp = valueOf(_totp)
          ..uris = [
            for (final (uri, controller) in _uris)
              if (controller.text.trim() case final text when text.isNotEmpty)
                (uri ?? LoginUri(null))..uri = text,
          ];
      case CipherType.card:
        (cipher.card ??= PaymentCard())
          ..cardholderName = valueOf(_cardholder)
          ..number = valueOf(_cardNumber)
          ..brand = _cardBrand
          ..expMonth = _cardExpMonth
          ..expYear = valueOf(_cardExpYear)
          ..code = valueOf(_cardCode);
      case CipherType.secureNote:
        cipher.secureNote ??= SecureNote();
    }

    setState(() => _saving = true);
    try {
      final item = switch (_original) {
        final original? => await vault.updateItem(original, cipher),
        null => await vault.createItem(cipher),
      };
      await _publishNewMailboxes(vaults, mail, cipher);
      if (!mounted) return;
      _leave(
        vaultPath(
          widget.vaultId == allVaultsId ? allVaultsId : vault.pubkey,
          filter: widget.filter.matches(item.cipher)
              ? widget.filter
              : ItemFilter.all,
          itemId: item.id,
        ),
      );
    } on SignerRequestCancelledException {
      if (mounted) setState(() => _saving = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveError = l10n.itemSaveFailed;
        });
      }
    }
  }

  Future<void> _publishNewMailboxes(
    Vaults vaults,
    MailSettings mail,
    Cipher cipher,
  ) async {
    final signerFactory = vaults.ndk.config.eventSignerFactory;
    final known = {
      if (_original case final original?)
        for (final (:key, address: _) in mailboxesOf(
          original.cipher,
          signerFactory: signerFactory,
        ))
          key,
    };
    for (final (:key, address: _) in mailboxesOf(
      cipher,
      signerFactory: signerFactory,
    )) {
      if (known.contains(key)) continue;
      await publishMailboxLists(
        vaults.ndk,
        key,
        relays: mail.urls(MailList.address),
        inboxRelays: mail.urls(MailList.inbox),
        blossomServers: mail.urls(MailList.servers),
        indexers: vaults.indexers,
      );
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
                      _original != null
                          ? l10n.editItem
                          : switch (_type) {
                              CipherType.card => l10n.newCard,
                              CipherType.secureNote => l10n.newSecureNote,
                              _ => l10n.newLogin,
                            },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ListenableBuilder(
                    listenable: Listenable.merge(_controllers),
                    builder: (context, _) => FilledButton(
                      onPressed: _saving || !_changed ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                      child: Text(l10n.save),
                    ),
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
                        VaultDropdown(
                          value: _vaultOf(vaults),
                          onChanged: (vault) =>
                              setState(() => _chosenVaultId = vault.pubkey),
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
                      if (_type == CipherType.login) ...[
                        TextField(
                          controller: _username,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.username,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.generateUsername,
                                  onPressed: _generateUsername,
                                  icon: const Icon(Icons.casino_outlined),
                                ),
                                const SizedBox(width: 4),
                              ],
                            ),
                          ),
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
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _visibilityButton(
                                  _passwordHidden,
                                  () => _passwordHidden = !_passwordHidden,
                                ),
                                IconButton(
                                  tooltip: l10n.generatePassword,
                                  onPressed: _generatePassword,
                                  icon: const Icon(Icons.casino_outlined),
                                ),
                                const SizedBox(width: 4),
                              ],
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
                      if (_type == CipherType.card) ...[
                        TextField(
                          controller: _cardholder,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.cardholderName,
                          ),
                        ),
                        gap,
                        TextField(
                          controller: _cardNumber,
                          obscureText: _cardNumberHidden,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          style: monoStyle,
                          decoration: InputDecoration(
                            labelText: l10n.cardNumber,
                            suffixIcon: _visibilityButton(
                              _cardNumberHidden,
                              () => _cardNumberHidden = !_cardNumberHidden,
                            ),
                          ),
                        ),
                        gap,
                        _Dropdown(
                          label: l10n.cardBrand,
                          value: _cardBrand,
                          options: [
                            for (final (value, brand) in _cardBrands)
                              (
                                value,
                                brand == null
                                    ? value
                                    : cardBrandLabel(l10n, brand),
                              ),
                          ],
                          onChanged: (brand) =>
                              setState(() => _cardBrand = brand),
                        ),
                        gap,
                        _Dropdown(
                          label: l10n.cardExpMonth,
                          value: _cardExpMonth,
                          options: [
                            for (final (value, month) in _cardExpMonths)
                              (
                                value,
                                month == null
                                    ? value
                                    : _monthLabel(context, int.parse(month)),
                              ),
                          ],
                          onChanged: (month) =>
                              setState(() => _cardExpMonth = month),
                        ),
                        gap,
                        TextField(
                          controller: _cardExpYear,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: l10n.cardExpYear,
                            hintText: l10n.cardExpYearHint,
                          ),
                        ),
                        gap,
                        TextField(
                          controller: _cardCode,
                          obscureText: _cardCodeHidden,
                          autocorrect: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          style: monoStyle,
                          decoration: InputDecoration(
                            labelText: l10n.cardCode,
                            suffixIcon: _visibilityButton(
                              _cardCodeHidden,
                              () => _cardCodeHidden = !_cardCodeHidden,
                            ),
                          ),
                        ),
                        gap,
                      ],
                      TextField(
                        controller: _notes,
                        minLines: _type == CipherType.secureNote ? 8 : 3,
                        maxLines: _type == CipherType.secureNote ? 20 : 10,
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
                      gap,
                      CustomFieldsEditor(
                        type: _type,
                        fields: _fields,
                        onChanged: () => setState(() {}),
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

/// Bitwarden's card brands, in the order of its form.
const _bitwardenCardBrands = [
  'Visa',
  'Mastercard',
  'Amex',
  'Discover',
  'Diners Club',
  'JCB',
  'Maestro',
  'UnionPay',
  'RuPay',
  'Other',
];

String _monthLabel(BuildContext context, int month) {
  final name = DateFormat.MMMM(Localizations.localeOf(context).toLanguageTag())
      .format(DateTime(2000, month));
  return '${'$month'.padLeft(2, '0')} ($name)';
}

String? _nonEmpty(String? text) => text == null || text.isEmpty ? null : text;

/// Pairs each of [values] with itself, but puts [stored] in place of the one
/// it [matches], or adds it alone if it matches none: a dropdown left
/// untouched then saves what the item had, "04" rather than "4" for instance.
List<(String, String?)> _keeping(
  List<String> values,
  String? stored,
  bool Function(String value, String stored) matches,
) => [
  for (final value in values)
    (stored != null && matches(value, stored) ? stored : value, value),
  if (stored != null && !values.any((value) => matches(value, stored)))
    (stored, null),
];

/// A value to pick among [options], each with its label, or none.
class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<(String, String)> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    borderRadius: BorderRadius.circular(12),
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem(
        child: Text(
          context.l10n.notSet,
          style: TextStyle(color: context.palette.muted),
        ),
      ),
      for (final (value, text) in options)
        DropdownMenuItem(
          value: value,
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: onChanged,
  );
}
