import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/custom_field/custom_field_editor/custom_field_editor_controller.dart';
import 'package:submarine/extensions.dart';
import 'package:submarine/models/custom_field.dart';

class CustomFieldEditorPage extends StatelessWidget {
  final CustomFieldVersion? customFieldVersion;

  const CustomFieldEditorPage({super.key, this.customFieldVersion});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomFieldEditorController(
      customFieldVersion: customFieldVersion,
    ));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: IconButton.filledTonal(
          onPressed: Get.back,
          icon: const Icon(Icons.close),
        ),
        actions: [
          FilledButton(
            onPressed: CustomFieldEditorController.to.save,
            child: Text(customFieldVersion == null ? "Create" : "Save"),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GetBuilder<CustomFieldEditorController>(builder: (c) {
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          children: [
            const TitleView(),
            if (c.fields.isNotEmpty) const FieldsView(),
            const NewFieldForm(),
          ],
        );
      }),
    );
  }
}

class TitleView extends StatelessWidget {
  const TitleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: TextField(
          controller: CustomFieldEditorController.to.titleController,
          textCapitalization: TextCapitalization.sentences,
          style: Get.textTheme.displaySmall,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
            filled: true,
            fillColor: Get.theme.colorScheme.secondaryContainer,
            hintText: "Title",
          ),
        ),
      ),
    );
  }
}

class FieldsView extends StatelessWidget {
  const FieldsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GetBuilder<CustomFieldEditorController>(builder: (c) {
          return Column(
            children: c.fields
                .map(
                  (field) => FieldView(field),
                )
                .cast<Widget>()
                .toList()
                .interspersed(const SizedBox(height: 2)),
          );
        }),
      ),
    );
  }
}

class FieldView extends StatelessWidget {
  final Field field;

  const FieldView(this.field, {super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Get.theme.colorScheme.secondaryContainer,
      child: ListTile(
        title: TextField(
          controller: TextEditingController(text: field.name),
          style: const TextStyle(fontSize: 12.0),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Name",
            isDense: true,
          ),
          onChanged: (value) {
            field.name = value;
          },
        ),
        subtitle: GetBuilder<CustomFieldEditorController>(builder: (c) {
          final isObscureText =
              field.hidden && !c.visibleFields.contains(field);
          return TextField(
            controller: TextEditingController(text: field.value),
            obscureText: isObscureText,
            maxLines: isObscureText ? 1 : null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Text",
              isDense: true,
            ),
            onChanged: (value) {
              field.value = value;
            },
          );
        }),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (field.hidden)
              GetBuilder<CustomFieldEditorController>(builder: (c) {
                return IconButton(
                  onPressed: () {
                    c.toogleFieldVisibility(field);
                  },
                  icon: Icon(
                    c.visibleFields.contains(field)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                );
              }),
            IconButton(
              onPressed: () {
                CustomFieldEditorController.to.removeField(field);
              },
              icon: const Icon(Icons.delete_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class NewFieldForm extends StatelessWidget {
  const NewFieldForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: CustomFieldEditorController.to.newFieldNameController,
            style: const TextStyle(fontSize: 12.0),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 12,
                right: 12,
                left: 12,
                bottom: 4,
              ),
              border: InputBorder.none,
              hintText: "Name",
              isDense: true,
            ),
          ),
          TextField(
            controller: CustomFieldEditorController.to.newFieldValueController,
            maxLines: null,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 4,
                bottom: 12,
                right: 12,
                left: 12,
              ),
              border: InputBorder.none,
              hintText: "Text",
              isDense: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Hidden"),
                GetBuilder<CustomFieldEditorController>(builder: (c) {
                  return Switch(
                    value: c.isNewFieldHidden,
                    onChanged: (value) {
                      c.isNewFieldHidden = !c.isNewFieldHidden;
                      c.update();
                    },
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: CustomFieldEditorController.to.addNewField,
              child: const Text("Add"),
            ),
          ),
        ],
      ),
    );
  }
}
