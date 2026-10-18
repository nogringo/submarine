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
    required this.hint,
    required this.texts,
    this.status,
    this.problem,
    this.moveLabel,
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
  final String hint;
  final AddressTexts texts;

  /// What a listed address shows while the draft keeps it, if anything.
  final (String, IconData) Function(String url)? status;

  /// What went wrong with a listed address, if anything.
  final String? Function(String url)? problem;

  /// The tooltip of the handle moving an address, for a list whose order
  /// counts. Private addresses stay after the public ones, as published.
  final String Function(String host)? moveLabel;
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

  /// The order of the rows once one was moved.
  List<String>? _order;

  List<String> get _listed => [...widget.public, ...?widget.private];

  /// The listed and added addresses of a group, in the order of the draft.
  List<String> _rows(List<String> listed, {required bool private}) {
    final rows = [
      ...listed,
      for (final MapEntry(key: url, value: isPrivate) in _added.entries)
        if (isPrivate == private) url,
    ];
    final order = _order;
    if (order == null) return rows;
    return [
      for (final url in order)
        if (rows.contains(url)) url,
      for (final url in rows)
        if (!order.contains(url)) url,
    ];
  }

  void _discard() => setState(() {
    _removed.clear();
    _added.clear();
    _order = null;
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
    _order = [...defaults];
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
          _order = null;
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

  Widget _row(
    String url, {
    required int index,
    required bool isPrivate,
    required int groupLength,
    required bool editable,
  }) {
    final palette = context.palette;
    final texts = widget.texts;
    final note = isPrivate ? texts.private : null;
    final removed = _removed.contains(url);
    final moveLabel = widget.moveLabel;
    final handle = moveLabel != null && groupLength > 1 && !removed
        ? ReorderableDragStartListener(
            index: index,
            enabled: editable,
            child: MouseRegion(
              cursor: editable ? SystemMouseCursors.grab : MouseCursor.defer,
              child: Tooltip(
                message: moveLabel(_host(url)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: palette.muted,
                  ),
                ),
              ),
            ),
          )
        : null;
    IconButton removeButton(VoidCallback remove) => IconButton(
      tooltip: texts.remove,
      onPressed: editable ? () => setState(remove) : null,
      icon: const Icon(Icons.close_rounded, size: 20),
    );
    final listed = (isPrivate ? widget.private ?? [] : widget.public).contains(
      url,
    );
    if (!listed) {
      return _AddressTile(
        url: url,
        note: note,
        status: (texts.added, Icons.add_circle_outline_rounded),
        action: removeButton(() => _added.remove(url)),
        handle: handle,
      );
    }
    if (removed) {
      return _AddressTile(
        url: url,
        note: note,
        status: (texts.removed, Icons.remove_circle_outline_rounded),
        removed: true,
        action: IconButton(
          tooltip: texts.keep,
          onPressed: editable
              ? () => setState(() => _removed.remove(url))
              : null,
          icon: const Icon(Icons.undo_rounded, size: 20),
        ),
        handle: handle,
      );
    }
    return _AddressTile(
      url: url,
      note: note,
      status: widget.status?.call(url),
      problem: widget.problem?.call(url),
      action: removeButton(() => _removed.add(url)),
      handle: handle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final texts = widget.texts;
    final editable = widget.editable && !_saving;
    final defaults = widget.defaults;
    final publicRows = _rows(widget.public, private: false);
    final rows = [...publicRows, ..._rows(widget.private ?? [], private: true)];
    final public = [
      for (final url in publicRows)
        if (!_removed.contains(url)) url,
    ];
    final private = [
      for (final url in rows.skip(publicRows.length))
        if (!_removed.contains(url)) url,
    ];
    final changed =
        !listEquals(public, widget.public) ||
        !listEquals(private, widget.private ?? const []);
    final empty = public.isEmpty && private.isEmpty;
    final isDefault =
        defaults != null && private.isEmpty && listEquals(public, defaults);
    final message =
        _saveError ??
        (!widget.editable
            ? texts.waitForSync
            : empty
            ? texts.needOne
            : null);
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
                      if (rows.isNotEmpty)
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          buildDefaultDragHandles: false,
                          onReorderItem: (from, to) {
                            // Within the group of the address moved.
                            final (first, last) = from < publicRows.length
                                ? (0, publicRows.length - 1)
                                : (publicRows.length, rows.length - 1);
                            final order = [...rows];
                            order.insert(
                              to.clamp(first, last),
                              order.removeAt(from),
                            );
                            setState(() => _order = order);
                          },
                          children: [
                            for (final (index, url) in rows.indexed)
                              Column(
                                key: ValueKey(url),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (index > 0) const Divider(),
                                  _row(
                                    url,
                                    index: index,
                                    isPrivate: index >= publicRows.length,
                                    groupLength: index < publicRows.length
                                        ? publicRows.length
                                        : rows.length - publicRows.length,
                                    editable: editable,
                                  ),
                                ],
                              ),
                          ],
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
                      onPressed: changed && !_saving ? _discard : null,
                      child: Text(l10n.cancel),
                    ),
                    FilledButton(
                      onPressed: changed && editable && !empty
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
    this.note,
    this.status,
    this.problem,
    this.removed = false,
    required this.action,
    this.handle,
  });

  final String url;

  /// Under the address, that it is private.
  final String? note;
  final (String, IconData)? status;

  /// Under the address and [note].
  final String? problem;
  final bool removed;
  final Widget action;
  final Widget? handle;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final note = this.note;
    final problem = this.problem;
    return SettingsTile(
      title: Text(
        _host(url),
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
          ?handle,
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

String _host(String url) => url.replaceFirst(RegExp('^(wss|https)://'), '');
