import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:submarine/custom_field/custom_field_viewer/custom_field_viewer_page.dart';
import 'package:submarine/models/custom_field.dart';

class CustomFieldHistoryPage extends StatelessWidget {
  final CustomField customField;

  const CustomFieldHistoryPage({super.key, required this.customField});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
      ),
      body: ListView.builder(
        itemCount: customField.history.length,
        itemBuilder: (context, i) {
          return ListTile(
            title: Text(DateFormat().format(customField.history[i].date)),
            onTap: () {
              Get.to(
                () => CustomFieldViewerPage(
                  customField: customField,
                  customFieldVersion: customField.history[i],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
