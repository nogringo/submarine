import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewFieldDialog extends StatefulWidget {
  final Function(String name, bool visible) onAdd;

  const NewFieldDialog({super.key, required this.onAdd});

  @override
  State<NewFieldDialog> createState() => _NewFieldDialogState();
}

class _NewFieldDialogState extends State<NewFieldDialog> {
  final _nameController = TextEditingController();
  bool _isObscure = false;
  bool _isFieldNameEmpty = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldNameChanged);
  }

  void _onFieldNameChanged() {
    setState(() {
      _isFieldNameEmpty = _nameController.text.trim().isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add New Field"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: "Field Name",
            ),
            autofocus: true,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text("Obscure text"),
              Spacer(),
              Switch(
                value: _isObscure,
                onChanged: (value) {
                  setState(() {
                    _isObscure = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isFieldNameEmpty 
              ? null 
              : () {
                  widget.onAdd(_nameController.text.trim(), !_isObscure);
                  Get.back();
                },
          child: Text("Add"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}