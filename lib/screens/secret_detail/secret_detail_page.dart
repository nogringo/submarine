import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/field.dart';
import 'package:submarine/models/text_field.dart' as model;
import 'package:submarine/models/secret_text_field.dart';
import 'package:submarine/models/otp_field.dart';
import 'package:submarine/screens/secret_detail/secret_detail_controller.dart';
import 'package:submarine/widgets/area_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class SecretDetailPage extends StatelessWidget {
  const SecretDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Secret secret = Get.arguments as Secret;

    return GetBuilder<SecretDetailController>(
      init: SecretDetailController(secret: secret),
      builder: (controller) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: DragToMoveArea(
              child: AppBar(
                title: Text(secret.title ?? 'Secret Details'),
                actions: [
                  // IconButton(
                  //   icon: Icon(Icons.edit),
                  //   onPressed: () {
                  //     // TODO: Navigate to edit page
                  //   },
                  // ),
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
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 8),
            children: [
              if (secret.fields != null && secret.fields!.isNotEmpty)
                AreaView(
                  padding: 0,
                  children: secret.fields!
                      .map(
                        (field) =>
                            _buildFieldWidget(field, controller, context),
                      )
                      .toList(),
                ),
              if (secret.fields != null && secret.fields!.isNotEmpty)
                SizedBox(height: 16),

              if (secret.urls != null && secret.urls!.isNotEmpty) ...[
                AreaView(
                  title: 'Websites',
                  children: [
                    ...secret.urls!.map((url) => _buildUrlWidget(url, context)),
                  ],
                ),
                SizedBox(height: 16),
              ],

              if (secret.note != null && secret.note!.isNotEmpty)
                AreaView(
                  title: 'Note',
                  children: [SelectableText(secret.note!, style: TextStyle(height: 1.5))],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldWidget(
    Field field,
    SecretDetailController controller,
    BuildContext context,
  ) {
    if (field is model.TextField) {
      return _buildTextFieldWidget(
        field.name,
        field.value,
        false,
        controller,
        context,
      );
    } else if (field is SecretTextField) {
      return _buildTextFieldWidget(
        field.name,
        field.value,
        true,
        controller,
        context,
      );
    } else if (field is OTPField) {
      return _buildOTPFieldWidget(field, controller, context);
    }
    return SizedBox.shrink();
  }

  Widget _buildTextFieldWidget(
    String name,
    String value,
    bool isSecret,
    SecretDetailController controller,
    BuildContext context,
  ) {
    final fieldKey = '${name}_$isSecret';
    final isVisible = controller.fieldVisibility[fieldKey] ?? false;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: value));
            toastification.show(
              context: context,
              title: Text('Copied'),
              description: Text('$name copied to clipboard'),
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 2),
              alignment: Alignment.bottomCenter,
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onInverseSurface),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isSecret && !isVisible ? '••••••••' : value,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: isSecret ? 'monospace' : null,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSecret)
                  IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => controller.toggleFieldVisibility(fieldKey),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFieldWidget(
    OTPField field,
    SecretDetailController controller,
    BuildContext context,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: controller.currentOTP.value));
            toastification.show(
              context: context,
              title: Text('Copied'),
              description: Text('OTP code copied to clipboard'),
              type: ToastificationType.success,
              style: ToastificationStyle.flat,
              autoCloseDuration: const Duration(seconds: 2),
              alignment: Alignment.bottomCenter,
              backgroundColor: Theme.of(context).colorScheme.inverseSurface,
              foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
              icon: Icon(Icons.check, color: Theme.of(context).colorScheme.onInverseSurface),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.currentOTP.value,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Obx(
                      () => LinearProgressIndicator(
                        value: controller.otpProgress.value,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUrlWidget(String url, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.link,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
