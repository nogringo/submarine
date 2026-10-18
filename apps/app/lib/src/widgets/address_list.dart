import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ndk/ndk.dart' show SignerRequestCancelledException;

import '../context.dart';
import '../items/field_tile.dart';
import 'context_menus.dart';
import 'dialog_buttons.dart';
import 'settings_tile.dart';

/// What an [AddressList] says, of relays or of servers. The texts about
/// private addresses, saving and syncing are for the lists that have them.
typedef AddressTexts = ({
  String title,
  String description,
  String add,
  String address,
  String invalid,
  String alreadyListed,
  String remove,
  String keep,
  String added,
  String removed,
  String needOne,
  String? private,
  ({String title, String description})? keepPrivate,
  String? saveFailed,
  String? waitForSync,
});

/// The page of the addresses of a list, public or private. Keeps the changes
/// in a draft, saved as a single list.
class AddressList extends StatefulWidget {
  const AddressList({
    super.key,
    required this.header,
    required this.public,
    this.private,
    this.defaults,
    this.editable = true,
    required this.parse,
    required this.icon,
    required this.hint,
    required this.texts,
    this.status,
    this.problem,
    required this.save,
  });

  final Widget header;
  final List<String> public;

  /// Null for a list without private addresses.
  final List<String>? private;

  /// What Reset puts back, for a list that has defaults.
  final List<String>? defaults;

  /// Whether saving cannot replace a newer list.
  final bool editable;

  /// An address as the user types it, normalized, or null if invalid.
  final String? Function(String text) parse;
  final IconData icon;
  final String hint;
  final AddressTexts texts;

  /// What a listed address shows while the draft keeps it, if anything.
  final (String, IconData) Function(String url)? status;

  /// What went wrong with a listed address, if anything.
  final String? Function(String url)? problem;
  final Future<void> Function(List<String> public, List<String> private) save;

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  final _removed = <String>{};

  /// Whether each address to add is private.
  final _added = <String, bool>{};
  var _saving = false;
  String? _saveError;

  bool get _changed => _removed.isNotEmpty || _added.isNotEmpty;

  List<String> get _listed => [...widget.public, ...?widget.private];

  List<String> _draft(List<String> listed, {required bool private}) => [
    for (final url in listed)
      if (!_removed.contains(url)) url,
    for (final MapEntry(key: url, value: isPrivate) in _added.entries)
      if (isPrivate == private) url,
  ];

  void _discard() => setState(() {
    _removed.clear();
    _added.clear();
    _saveError = null;
  });

  void _reset(List<String> defaults) => setState(() {
    final listed = _listed;
    _removed
      ..clear()
      ..addAll(listed.where((url) => !defaults.contains(url)));
    _added
      ..clear()
      ..addEntries([
        for (final url in defaults)
          if (!listed.contains(url)) MapEntry(url, false),
      ]);
    _saveError = null;
  });

  Future<void> _save(List<String> public, List<String> private) async {
    final failed = widget.texts.saveFailed;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.save(public, private);
      if (mounted) {
        setState(() {
          _removed.clear();
          _added.clear();
        });
      }
    } on SignerRequestCancelledException {
      // Cancelled by the user: the draft stays, to save again.
    } catch (_) {
      if (mounted) setState(() => _saveError = failed);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _add(List<String> draft) async {
    final added = await showDialog<(String, bool)>(
      context: context,
      builder: (context) => _AddAddressDialog(
        texts: widget.texts,
        hint: widget.hint,
        parse: widget.parse,
        listed: (url) =>
            draft.any((listed) => (widget.parse(listed) ?? listed) == url),
      ),
    );
    if (added case (final url, final private) when mounted) {
      setState(() => _added[url] = private);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final texts = widget.texts;
    final editable = widget.editable && !_saving;
    final defaults = widget.defaults;
    var public = _draft(widget.public, private: false);
    final private = _draft(widget.private ?? [], private: true);
    final empty = public.isEmpty && private.isEmpty;
    final isDefault =
        defaults != null &&
        private.isEmpty &&
        setEquals(public.toSet(), defaults.toSet());
    // Saved in their own order, so that the list is the defaults again.
    if (isDefault) public = defaults;
    final message =
        _saveError ??
        (!widget.editable
            ? texts.waitForSync
            : empty
            ? texts.needOne
            : null);
    IconButton removeButton(VoidCallback remove) => IconButton(
      tooltip: texts.remove,
      onPressed: editable ? () => setState(remove) : null,
      icon: const Icon(Icons.close_rounded, size: 20),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SettingsWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widget.header,
                  const SizedBox(height: 28),
                  Text(
                    texts.description,
                    style: TextStyle(fontSize: 13, color: palette.muted),
                  ),
                  const SizedBox(height: 12),
                  FieldCard(
                    children: [
                      for (final (listed, isPrivate) in [
                        (widget.public, false),
                        (widget.private ?? [], true),
                      ])
                        for (final url in listed)
                          if (_removed.contains(url))
                            _AddressTile(
                              url: url,
                              icon: widget.icon,
                              note: isPrivate ? texts.private : null,
                              status: (
                                texts.removed,
                                Icons.remove_circle_outline_rounded,
                              ),
                              removed: true,
                              action: IconButton(
                                tooltip: texts.keep,
                                onPressed: editable
                                    ? () => setState(() => _removed.remove(url))
                                    : null,
                                icon: const Icon(Icons.undo_rounded, size: 20),
                              ),
                            )
                          else
                            _AddressTile(
                              url: url,
                              icon: widget.icon,
                              note: isPrivate ? texts.private : null,
                              status: widget.status?.call(url),
                              problem: widget.problem?.call(url),
                              action: removeButton(() => _removed.add(url)),
                            ),
                      for (final MapEntry(key: url, value: isPrivate)
                          in _added.entries)
                        _AddressTile(
                          url: url,
                          icon: widget.icon,
                          note: isPrivate ? texts.private : null,
                          status: (
                            texts.added,
                            Icons.add_circle_outline_rounded,
                          ),
                          action: removeButton(() => _added.remove(url)),
                        ),
                      SettingsTile(
                        leading: Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: editable ? palette.signal : palette.muted,
                        ),
                        title: Text(
                          texts.add,
                          style: editable
                              ? null
                              : TextStyle(color: palette.muted),
                        ),
                        onTap: editable
                            ? () => _add([...public, ...private])
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(),
        Padding(
          // Clear of the system navigation bar, the app drawing edge to edge.
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            12 + MediaQuery.paddingOf(context).bottom,
          ),
          child: SettingsWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Next to the buttons it explains, wherever the list scrolled.
                if (message != null) ...[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      color: _saveError == null
                          ? palette.muted
                          : palette.danger,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                DialogButtons(
                  children: [
                    if (defaults != null)
                      TextButton(
                        onPressed: editable && !isDefault
                            ? () => _reset(defaults)
                            : null,
                        child: Text(l10n.resetMailRelays),
                      ),
                    TextButton(
                      onPressed: _changed && !_saving ? _discard : null,
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: _changed && editable && !empty
                          ? () => _save(public, private)
                          : null,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The draft shows in [status], so that the row keeps its height.
class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.url,
    required this.icon,
    this.note,
    this.status,
    this.problem,
    this.removed = false,
    required this.action,
  });

  final String url;
  final IconData icon;

  /// Under the address, that it is private.
  final String? note;
  final (String, IconData)? status;

  /// Under the address and [note].
  final String? problem;
  final bool removed;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final note = this.note;
    final problem = this.problem;
    return SettingsTile(
      leading: Icon(icon, size: 20, color: palette.muted),
      title: Text(
        url.replaceFirst(RegExp('^(wss|https)://'), ''),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: removed ? palette.muted : null,
          decoration: removed ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: note == null && problem == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note != null) Text(note),
                if (problem != null)
                  Text(problem, style: TextStyle(color: palette.danger)),
              ],
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status case (final text, final statusIcon)) ...[
            // Spelled out in the wide layout, a tooltip in the narrow one.
            if (context.isWide) ...[
              Icon(statusIcon, size: 16, color: palette.muted),
              const SizedBox(width: 6),
              Text(text, style: TextStyle(fontSize: 13, color: palette.muted)),
            ] else
              Tooltip(
                message: text,
                child: Icon(statusIcon, size: 16, color: palette.muted),
              ),
            const SizedBox(width: 4),
          ],
          action,
        ],
      ),
    );
  }
}

/// Gives the address to add, and whether it is private.
class _AddAddressDialog extends StatefulWidget {
  const _AddAddressDialog({
    required this.texts,
    required this.hint,
    required this.parse,
    required this.listed,
  });

  final AddressTexts texts;
  final String hint;
  final String? Function(String text) parse;

  /// Whether the draft lists the normalized address.
  final bool Function(String url) listed;

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  final _url = TextEditingController();
  var _private = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _submit() {
    final texts = widget.texts;
    final url = widget.parse(_url.text);
    final error = url == null
        ? texts.invalid
        : widget.listed(url)
        ? texts.alreadyListed
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, (url!, _private));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final texts = widget.texts;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                texts.add,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 20),
              TextField(
                contextMenuBuilder: textFieldMenu,
                controller: _url,
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.url,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: texts.address,
                  hintText: widget.hint,
                  errorText: _error,
                ),
              ),
              if (texts.keepPrivate
                  case (:final title, :final description)?) ...[
                const SizedBox(height: 16),
                // The switch takes its name from the text.
                MergeSemantics(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 13,
                                color: palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _private,
                        onChanged: (private) =>
                            setState(() => _private = private),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              DialogButtons(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(onPressed: _submit, child: Text(l10n.add)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
