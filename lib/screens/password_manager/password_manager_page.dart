import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/password_manager/password_manager_controller.dart';
import 'package:window_manager/window_manager.dart';
import 'package:submarine/widgets/share_secret_dialog.dart';
import 'package:submarine/widgets/user_dialog.dart';

class PasswordManagerPage extends StatelessWidget {
  const PasswordManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PasswordManagerController>(
      init: PasswordManagerController(),
      builder: (controller) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: DragToMoveArea(
              child: AppBar(
                title: Text(appTitle),
                actions: [
                  Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => showUserDialog(context),
                        child: NPicture(ndk: Repository.to.ndk),
                      ),
                    ),
                  ),
                  if (!kIsWeb && GetPlatform.isDesktop)
                    SizedBox(
                      width: 154,
                      child: WindowCaption(
                        brightness: Theme.of(context).brightness,
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.secrets.isEmpty) {
              return Center(
                child: Text(
                  "No secrets found.\nTap + to create your first secret.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.refreshSecrets,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 100, right: 16, left: 16),
                itemCount: controller.secrets.length,
                itemBuilder: (context, index) {
                  final secret = controller.secrets[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    clipBehavior: Clip.antiAlias,
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
                    child: ListTile(
                      contentPadding: EdgeInsets.only(right: 4, left: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        secret.title?.isNotEmpty == true
                            ? secret.title!
                            : "Untitled",
                      ),
                      trailing: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                        // padding: EdgeInsetsGeometry.zero,
                        // menuPadding: EdgeInsetsGeometry.zero,
                        onSelected: (value) {
                          if (value == 'delete' && secret.id != null) {
                            _showDeleteDialog(context, controller, secret.id!);
                          } else if (value == 'share') {
                            final eventId = controller.getEventId(secret.id!);
                            if (eventId != null) {
                              showDialog(
                                context: context,
                                builder: (context) => ShareSecretDialog(
                                  eventId: eventId,
                                  secretTitle: secret.title ?? 'Secret',
                                ),
                              );
                            }
                          } else if (value == 'edit') {
                            final eventId = controller.getEventId(secret.id!);
                            if (eventId != null) {
                              Get.toNamed(
                                AppRoutes.editSecret.replaceAll(
                                  ':eventId',
                                  eventId,
                                ),
                              );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        final eventId = controller.getEventId(secret.id!);
                        if (eventId != null) {
                          Get.toNamed(
                            AppRoutes.secretDetail.replaceAll(
                              ':eventId',
                              eventId,
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.toNamed(AppRoutes.createSecret);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PasswordManagerController controller,
    String secretId,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Secret'),
        content: Text(
          'Are you sure you want to delete this secret? All versions of this secret will be permanently deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSecret(secretId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
