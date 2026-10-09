import 'package:flutter/material.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../context.dart';
import '../mail/mail_settings.dart';
import '../theme/theme.dart';
import '../vaults/vaults.dart';
import 'item_fields.dart';

/// A custom field in the item form, with the [field] it edits, whose other
/// keys are kept.
class EditedField {
  EditedField(this.field, {this.isNew = false, this.generate})
    : name = field.name ?? '',
      value = TextEditingController(
        text: field.type == FieldType.boolean || field.type == FieldType.linked
            ? null
            : field.value,
      ),
      checked = field.value == 'true',
      linkedId = field.linkedId;

  final Field field;
  final bool isNew;

  /// Makes up a new value, for a field added with a made-up one.
  final String Function()? generate;
  String name;

  /// The value of a field that is neither a checkbox nor linked.
  final TextEditingController value;

  /// The value of a checkbox.
  bool checked;

  LinkedIdType? linkedId;
  var hidden = true;

  FieldType get type => field.type;

  /// What saving would write, to tell whether the field changed.
  Object get state => (name, value.text, checked, linkedId);

  Field toField() => field
    ..name = name
    ..value = switch (type) {
      FieldType.boolean => '$checked',
      FieldType.linked => field.value,
      _ => value.text.isEmpty ? null : value.text,
    }
    ..linkedId = type == FieldType.linked ? linkedId : field.linkedId;
}

/// The custom fields of an item of [type], as Bitwarden's form edits them:
/// added with a type and a label, renamed, deleted and reordered. A login can
/// also get a made-up first name, last name or birth date, and an email
/// address of its own.
class CustomFieldsEditor extends StatelessWidget {
  const CustomFieldsEditor({
    super.key,
    required this.type,
    required this.fields,
    required this.onChanged,
  });

  final CipherType type;

  /// Changed in place, then [onChanged] is called.
  final List<EditedField> fields;
  final VoidCallback onChanged;

  /// Adds a field with a made-up value to a login, or a field of a type and a
  /// label of choice, as a menu under [button] picks.
  Future<void> _add(BuildContext button) async {
    if (type != CipherType.login) return _addCustom(button);
    final l10n = button.l10n;
    final muted = button.palette.muted;
    final madeUp = [
      (l10n.firstName, generateFirstName),
      (l10n.lastName, generateLastName),
      (l10n.dateOfBirth, generateBirthDate),
    ];
    final overlay =
        Navigator.of(button).overlay!.context.findRenderObject()! as RenderBox;
    final box = button.findRenderObject()! as RenderBox;
    final bounds = box.localToGlobal(Offset.zero, ancestor: overlay) & box.size;
    PopupMenuItem<int> item(int value, IconData icon, String label) =>
        PopupMenuItem(
          value: value,
          child: Row(
            children: [
              Icon(icon, size: 20, color: muted),
              const SizedBox(width: 12),
              Flexible(child: Text(label)),
            ],
          ),
        );
    final choice = await showMenu<int>(
      context: button,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(bounds.left, bounds.bottom + 4, 0, 0),
        Offset.zero & overlay.size,
      ),
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
      items: [
        item(-1, Icons.text_fields_rounded, l10n.customField),
        const PopupMenuDivider(),
        for (final (index, (label, _)) in madeUp.indexed)
          item(index, Icons.casino_outlined, label),
        item(-2, Icons.alternate_email_rounded, l10n.emailAddressField),
      ],
    );
    if (choice == null || !button.mounted) return;
    if (choice == -1) return _addCustom(button);
    if (choice == -2) return _addMailbox(button);
    final (name, generate) = madeUp[choice];
    fields.add(
      EditedField(
        Field(name: name, value: generate()),
        generate: generate,
      ),
    );
    onChanged();
  }

  /// Adds an address at the bridge of the settings, and the key of its mailbox
  /// in a hidden field.
  void _addMailbox(BuildContext context) {
    final l10n = context.l10n;
    final mailbox = generateMailbox(
      MailSettings.of(context).bridge,
      signerFactory: Vaults.of(context).ndk.config.eventSignerFactory,
    );
    fields.addAll([
      EditedField(Field(name: l10n.email, value: mailbox.address)),
      EditedField(
        Field(
          name: l10n.mailboxKey,
          value: mailbox.key,
          type: FieldType.hidden,
        ),
      ),
    ]);
    onChanged();
  }

  Future<void> _addCustom(BuildContext context) async {
    final linkedIds = _linkedIds(type);
    final added = await showDialog<(FieldType, String)>(
      context: context,
      builder: (context) => _FieldDialog(
        types: [
          FieldType.text,
          FieldType.hidden,
          FieldType.boolean,
          if (linkedIds.isNotEmpty) FieldType.linked,
        ],
      ),
    );
    if (added case (final type, final name)) {
      fields.add(
        EditedField(
          Field(
            name: name,
            type: type,
            linkedId: type == FieldType.linked ? linkedIds.first : null,
          ),
          isNew: true,
        ),
      );
      onChanged();
    }
  }

  Future<void> _edit(BuildContext context, EditedField field) async {
    final edited = await showDialog<(FieldType, String)>(
      context: context,
      builder: (context) => _FieldDialog(
        label: field.name,
        onDelete: () {
          fields.remove(field);
          onChanged();
          // Its text field lets go of it at the next frame.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => field.value.dispose(),
          );
        },
      ),
    );
    if (edited case (_, final name)) {
      field.name = name;
      onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
          child: Text(
            l10n.customFields,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.palette.muted,
            ),
          ),
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          buildDefaultDragHandles: false,
          onReorderItem: (from, to) {
            fields.insert(to, fields.removeAt(from));
            onChanged();
          },
          children: [
            for (final (index, field) in fields.indexed)
              Padding(
                key: ObjectKey(field),
                padding: const EdgeInsets.only(bottom: 12),
                child: _FieldRow(
                  field: field,
                  linkedIds: _linkedIds(type),
                  reorderIndex: fields.length > 1 ? index : null,
                  onChanged: onChanged,
                  onEdit: () => _edit(context, field),
                ),
              ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Builder(
            builder: (button) => TextButton.icon(
              onPressed: () => _add(button),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addField),
            ),
          ),
        ),
      ],
    );
  }
}

/// The fields of an item of [type] that a custom field can be linked to, in
/// the order of Bitwarden's form.
List<LinkedIdType> _linkedIds(CipherType type) => switch (type) {
  CipherType.login => const [
    LinkedIdType.loginUsername,
    LinkedIdType.loginPassword,
  ],
  CipherType.card => const [
    LinkedIdType.cardCardholderName,
    LinkedIdType.cardNumber,
    LinkedIdType.cardBrand,
    LinkedIdType.cardExpMonth,
    LinkedIdType.cardExpYear,
    LinkedIdType.cardCode,
  ],
  _ => const [],
};

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.field,
    required this.linkedIds,
    required this.reorderIndex,
    required this.onChanged,
    required this.onEdit,
  });

  final EditedField field;
  final List<LinkedIdType> linkedIds;

  /// Where the field is in the list, when there are others to move it among.
  final int? reorderIndex;
  final VoidCallback onChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final name = field.name;
    final input = switch (field.type) {
      FieldType.boolean => CheckboxListTile(
        value: field.checked,
        onChanged: (checked) {
          field.checked = checked ?? false;
          onChanged();
        },
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(name),
        tileColor: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.line),
        ),
      ),
      FieldType.linked => DropdownButtonFormField<LinkedIdType>(
        initialValue: field.linkedId,
        isExpanded: true,
        borderRadius: BorderRadius.circular(12),
        decoration: InputDecoration(labelText: name),
        items: [
          for (final id in [
            ...linkedIds,
            if (field.linkedId case final stored?
                when !linkedIds.contains(stored))
              stored,
          ])
            DropdownMenuItem(
              value: id,
              child: Text(linkedFieldLabel(l10n, id) ?? '${id.value}'),
            ),
        ],
        onChanged: (id) {
          field.linkedId = id;
          onChanged();
        },
      ),
      FieldType.hidden => TextField(
        controller: field.value,
        autofocus: field.isNew,
        obscureText: field.hidden,
        autocorrect: false,
        enableSuggestions: false,
        keyboardType: TextInputType.visiblePassword,
        style: monoStyle,
        decoration: InputDecoration(
          labelText: name,
          suffixIcon: IconButton(
            tooltip: field.hidden ? l10n.show : l10n.hide,
            onPressed: () {
              field.hidden = !field.hidden;
              onChanged();
            },
            icon: Icon(
              field.hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
      _ => TextField(
        controller: field.value,
        autofocus: field.isNew,
        decoration: InputDecoration(
          labelText: name,
          suffixIcon: switch (field.generate) {
            final generate? => IconButton(
              tooltip: l10n.regenerate,
              onPressed: () => field.value.text = generate(),
              icon: const Icon(Icons.refresh_rounded),
            ),
            null => null,
          },
        ),
      ),
    };
    return Row(
      children: [
        Expanded(child: input),
        const SizedBox(width: 4),
        IconButton(
          tooltip: l10n.editFieldNamed(name),
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        if (reorderIndex case final index?)
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Tooltip(
                message: l10n.reorderField(name),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: palette.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bitwarden's dialog adding a custom field of one of [types], or renaming
/// the field [label] when [onDelete] is set. It returns the type and the
/// label chosen, the type being of no use when renaming.
class _FieldDialog extends StatefulWidget {
  const _FieldDialog({this.types = const [], this.label, this.onDelete});

  final List<FieldType> types;
  final String? label;
  final VoidCallback? onDelete;

  @override
  State<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends State<_FieldDialog> {
  late final _label = TextEditingController(text: widget.label);
  late var _type = widget.types.firstOrNull ?? FieldType.text;

  bool get _adding => widget.onDelete == null;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  void _submit() {
    final label = _label.text.trim();
    if (label.isNotEmpty) Navigator.pop(context, (_type, label));
  }

  String _typeName(AppLocalizations l10n, FieldType type) => switch (type) {
    FieldType.hidden => l10n.fieldTypeHidden,
    FieldType.boolean => l10n.fieldTypeCheckbox,
    FieldType.linked => l10n.fieldTypeLinked,
    _ => l10n.fieldTypeText,
  };

  String _typeHelp(AppLocalizations l10n, FieldType type) => switch (type) {
    FieldType.hidden => l10n.hiddenFieldHelp,
    FieldType.boolean => l10n.checkboxFieldHelp,
    FieldType.linked => l10n.linkedFieldHelp,
    _ => l10n.textFieldHelp,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                _adding ? l10n.addField : l10n.editField,
                style: Theme.of(context).dialogTheme.titleTextStyle,
              ),
              const SizedBox(height: 20),
              if (_adding) ...[
                DropdownButtonFormField<FieldType>(
                  initialValue: _type,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  decoration: InputDecoration(
                    labelText: l10n.fieldType,
                    helperText: _typeHelp(l10n, _type),
                    helperMaxLines: 3,
                  ),
                  items: [
                    for (final type in widget.types)
                      DropdownMenuItem(
                        value: type,
                        child: Text(_typeName(l10n, type)),
                      ),
                  ],
                  onChanged: (type) => setState(() => _type = type!),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _label,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.fieldLabel,
                  helperText: _adding && _type == FieldType.linked
                      ? l10n.linkedFieldLabelHelp
                      : null,
                  helperMaxLines: 3,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.onDelete case final onDelete?)
                    IconButton(
                      tooltip: l10n.deleteFieldNamed(widget.label ?? ''),
                      color: context.palette.danger,
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  ListenableBuilder(
                    listenable: _label,
                    builder: (context, _) => FilledButton(
                      onPressed: _label.text.trim().isEmpty ? null : _submit,
                      child: Text(_adding ? l10n.add : l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
