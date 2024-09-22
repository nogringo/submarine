import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:submarine/custom_field/custom_field_editor/custom_field_editor_page.dart';
import 'package:submarine/custom_field/custom_field_history/custom_field_history_page.dart';
import 'package:submarine/custom_field/custom_field_viewer/custom_field_viewer_controller.dart';
import 'package:submarine/extensions.dart';
import 'package:submarine/models/custom_field.dart';
import 'package:toastification/toastification.dart';

class CustomFieldViewerPage extends StatelessWidget {
  final CustomField customField;
  final CustomFieldVersion? customFieldVersion;

  const CustomFieldViewerPage(
      {super.key, required this.customField, this.customFieldVersion});

  @override
  Widget build(BuildContext context) {
    Get.put(CustomFieldViewerController(customField));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 8,
        title: IconButton.filledTonal(
          onPressed: Get.back,
          icon: const Icon(Icons.close),
        ),
        actions: [
          if (customFieldVersion == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () {
                  Get.to(() => CustomFieldEditorPage(
                      customFieldVersion: customField.history.last));
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text("Edit"),
              ),
            ),
          IconButton.filled(
            onPressed: CustomFieldViewerController.to.copyCustomField,
            icon: GetBuilder<CustomFieldViewerController>(builder: (c) {
              return Icon(
                c.isCustomFieldCopied ? Icons.check : Icons.copy,
                color: Get.theme.colorScheme.onPrimary,
              );
            }),
          ),
          const SizedBox(width: 8),
          if (customFieldVersion == null && false)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filled(
                onPressed: CustomFieldViewerController.to.deleteCustomField,
                icon: Icon(
                  Icons.delete_outlined,
                  color: Get.theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          const SizedBox(height: 16),
          Text(
            customFieldVersion?.name ?? customField.name,
            style: Get.textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GetBuilder<CustomFieldViewerController>(builder: (c) {
              return Column(
                children: (customFieldVersion?.fields ?? c.customField.fields)
                    .map(
                      (field) => FieldView(field),
                    )
                    .cast<Widget>()
                    .toList()
                    .interspersed(const SizedBox(height: 2)),
              );
            }),
          ),
          const SizedBox(height: 16),
          if (customFieldVersion == null) HistoryView(customField: customField),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.customField,
  });

  final CustomField customField;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.onSurface,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (customField.wasEdited)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Row(
                children: [
                  const Text("Modified"),
                  const SizedBox(width: 8),
                  Badge(
                    label: Text(
                      (customField.history.length - 1).toString(),
                      style: TextStyle(
                        color: Get.theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    backgroundColor: Get.theme.colorScheme.primaryContainer,
                  ),
                ],
              ),
              subtitle: Text(DateFormat().format(customField.date)),
            ),
          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text("Created"),
            subtitle: Text(
              DateFormat().format(customField.history.first.date),
            ),
          ),
          if (customField.wasEdited)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton.tonal(
                onPressed: () {
                  Get.to(
                    () => CustomFieldHistoryPage(
                      customField: customField,
                    ),
                  );
                },
                child: const Text("View item history"),
              ),
            ),
        ],
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
        title: Text(
          field.name,
          style: const TextStyle(fontSize: 12.0),
        ),
        subtitle: GetBuilder<CustomFieldViewerController>(builder: (c) {
          bool hideFieldValue =
              field.hidden && !c.visibleFields.contains(field);
          return Text(hideFieldValue ? '●' * 8 : field.value);
        }),
        trailing: field.hidden
            ? IconButton(
                onPressed: () =>
                    CustomFieldViewerController.to.toogleFieldVisibility(field),
                icon: const Icon(Icons.visibility),
              )
            : null,
        onTap: () async {
          await Clipboard.setData(
            ClipboardData(text: field.value),
          );

          toastification.show(
            style: ToastificationStyle.simple,
            title: Text("${field.name} copied"),
            alignment: Alignment.bottomCenter,
            autoCloseDuration: const Duration(seconds: 4),
            applyBlurEffect: true,
          );
        },
      ),
    );
  }
}

// TODO add feature: copy encrypted item