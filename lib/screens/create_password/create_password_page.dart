import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/screens/create_password/create_password_controller.dart';

class CreatePasswordPage extends StatelessWidget {
  const CreatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreatePasswordController>(
      init: CreatePasswordController(),
      builder: (c) {
        return Scaffold(
          appBar: AppBar(
            title: Text("New Password"),
            actions: [
              FilledButton(
                onPressed: c.isCreatingPassword ? null : c.createPassword,
                child: Text("Create"),
              ),
              SizedBox(width: 8),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 8),
            children: [
              AreaView(
                children: [
                  TextField(
                    controller: c.titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              SizedBox(height: 16),
              AreaView(
                padding: 0,
                children: [
                  Builder(
                    builder: (context) {
                      final children = c.fields.map((field) {
                        return TextField(
                          key: ValueKey(field.name),
                          controller: field.value,
                          decoration: InputDecoration(
                            labelText: field.name,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          obscureText: !field.visible,
                          maxLines: !field.visible ? 1 : null,
                          keyboardType: !field.visible
                              ? null
                              : TextInputType.multiline,
                        );
                      }).toList();

                      if (c.isReorderMode) {
                        return ReorderableListView(
                          shrinkWrap: true,
                          onReorder: c.onReorder,
                          proxyDecorator: (child, index, animation) {
                            return Material(
                              color: Colors.transparent,
                              child: child,
                            );
                          },
                          children: children,
                        );
                      }

                      return Column(children: children);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: c.showNewFieldDialog,
                          child: Text("New field"),
                        ),
                        TextButton(onPressed: null, child: Text("Add 2FA")),
                        Spacer(),
                        IconButton(
                          onPressed: c.toggleReorderMode,
                          icon: Icon(Icons.swap_vert),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              AreaView(
                title: "Websites",
                children: [
                  SizedBox(height: 16),
                  ...c.websites.map((website) {
                    return TextField(
                      controller: website,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          onPressed: () => c.removeWebsite(website),
                          icon: Icon(Icons.close),
                        ),
                      ),
                    );
                  }),
                  TextField(
                    controller: c.newWebsiteController,
                    decoration: InputDecoration(
                      hintText: "https://new-site.com",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: c.addWebsite,
                        icon: Icon(Icons.add),
                      ),
                    ),
                    onSubmitted: (_) => c.addWebsite(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              AreaView(
                title: "Note",
                children: [
                  TextField(
                    controller: c.noteController,
                    decoration: InputDecoration(
                      hintText: 'A note',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AreaView extends StatelessWidget {
  final double padding;
  final String? title;
  final List<Widget> children;

  const AreaView({
    super.key,
    this.title,
    required this.children,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Text(title!, style: Theme.of(context).textTheme.titleMedium),
          ...children,
        ],
      ),
    );
  }
}

class FieldView extends StatelessWidget {
  final String name;
  final String value;
  final bool isSecret;

  const FieldView({
    super.key,
    this.name = "",
    this.value = "",
    this.isSecret = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: name);
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Field name",
                border: InputBorder.none,
              ),
            ),
            TextField(),
          ],
        ),
      ),
    );
  }
}
