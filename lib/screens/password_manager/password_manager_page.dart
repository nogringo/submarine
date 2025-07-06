import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/password_manager/password_manager_controller.dart';
import 'package:window_manager/window_manager.dart';

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
                child: Obx(() => GestureDetector(
                  onTap: () => _showProfilePopup(context, controller),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: NetworkImage(
                      controller.userProfilePicture.value.isNotEmpty
                          ? controller.userProfilePicture.value
                          : _getRoboHashUrl(),
                    ),
                  ),
                )),
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
                    margin: EdgeInsets.only(bottom: 8),
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
                        onSelected: (value) {
                          if (value == 'delete' && secret.id != null) {
                            _showDeleteDialog(context, controller, secret.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // TODO: Navigate to secret detail page
                      },
                    ),
                  );
                },
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.toNamed(AppRoutes.createPassword);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, PasswordManagerController controller, String secretId) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Secret'),
        content: Text('Are you sure you want to delete this secret? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
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

  String _getRoboHashUrl() {
    final publicKey = Repository.to.publicKey ?? 'default';
    return 'https://robohash.org/$publicKey';
  }

  String _truncatePublicKey(String publicKey) {
    if (publicKey.length <= 16) return publicKey;
    return '${publicKey.substring(0, 8)}...${publicKey.substring(publicKey.length - 8)}';
  }

  void _showProfilePopup(BuildContext context, PasswordManagerController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile picture
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: NetworkImage(
                  controller.userProfilePicture.value.isNotEmpty
                      ? controller.userProfilePicture.value
                      : _getRoboHashUrl(),
                ),
              ),
              SizedBox(height: 16),
              
              // User name
              Text(
                controller.userName.value.isNotEmpty 
                    ? controller.userName.value 
                    : 'Anonymous User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              
              // Public key (truncated)
              Text(
                _truncatePublicKey(Repository.to.publicKey ?? ''),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              
              // Divider(),
              SizedBox(height: 8),
              
              // Sign out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showLogoutConfirmation(context);
                  },
                  icon: Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    'Sign out',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Sign out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Repository.to.logOut();
              Get.offAllNamed(AppRoutes.signIn);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
