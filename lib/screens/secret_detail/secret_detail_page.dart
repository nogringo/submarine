import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:submarine/models/mail.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/models/field.dart';
import 'package:submarine/models/text_field.dart' as model;
import 'package:submarine/models/secret_text_field.dart';
import 'package:submarine/models/otp_field.dart';
import 'package:submarine/screens/secret_detail/compact_email_view.dart';
import 'package:submarine/screens/secret_detail/secret_detail_controller.dart';
import 'package:submarine/widgets/area_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/models/secret_history_item.dart';
import 'package:submarine/utils/toast_helper.dart';

class SecretDetailPage extends StatelessWidget {
  const SecretDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String eventId = Get.parameters['eventId']!;

    return GetBuilder<SecretDetailController>(
      init: SecretDetailController(eventId: eventId),
      tag: eventId, // Use eventId as tag to ensure unique controller instances
      builder: (controller) {
        if (controller.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (controller.secret == null) {
          return Scaffold(body: Center(child: Text('Secret not found')));
        }

        final secret = controller.secret!;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: DragToMoveArea(
              child: AppBar(
                title: Text(secret.title ?? 'Secret Details'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      if (controller.eventId != null) {
                        Get.toNamed(
                          AppRoutes.editSecret.replaceAll(
                            ':eventId',
                            controller.eventId!,
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => _showShareDialog(context, controller),
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
                  children: [
                    SelectableText(secret.note!, style: TextStyle(height: 1.5)),
                  ],
                ),

              if (controller.hasNostrMail) MailboxView(controller: controller),

              // Secret History
              SizedBox(height: 16),
              AreaView(
                title: 'Version History',
                children: [
                  SizedBox(height: 8),
                  Obx(() {
                    if (controller.isLoadingHistory.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (controller.secretHistory.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No history available',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.secretHistory
                          .asMap()
                          .entries
                          .map(
                            (entry) => _buildHistoryItem(
                              context,
                              entry.value,
                              entry.key == 0,
                              controller,
                              secret,
                            ),
                          )
                          .toList(),
                    );
                  }),
                ],
              ),

              SizedBox(height: 100),
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
            ToastHelper.showSuccess(
              context: context,
              title: 'Copied',
              description: '$name copied to clipboard',
              duration: const Duration(seconds: 2),
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
            ToastHelper.showSuccess(
              context: context,
              title: 'Copied',
              description: 'OTP code copied to clipboard',
              duration: const Duration(seconds: 2),
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
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    SecretHistoryItem item,
    bool isLatest,
    SecretDetailController controller,
    Secret displayedSecret,
  ) {
    final isDisplayed = item.eventId == controller.eventId;

    // Determine styling based on state
    final backgroundColor = isDisplayed
        ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
        : isLatest
        ? Theme.of(
            context,
          ).colorScheme.secondaryContainer.withValues(alpha: 0.2)
        : Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);

    final borderColor = isDisplayed
        ? Theme.of(context).colorScheme.primary
        : isLatest
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);

    return Container(
      margin: EdgeInsets.only(top: 12),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isDisplayed) {
              Get.offNamed(
                AppRoutes.secretDetail.replaceAll(':eventId', item.eventId),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isDisplayed ? 2 : 1,
              ),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon container
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDisplayed
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                            : isLatest
                            ? Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDisplayed
                            ? Icons.remove_red_eye
                            : isLatest
                            ? Icons.star_rounded
                            : Icons.access_time_filled,
                        size: 18,
                        color: isDisplayed
                            ? Theme.of(context).colorScheme.primary
                            : isLatest
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.formattedDate,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: isDisplayed || isLatest
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                              ),
                              if (isDisplayed) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'VIEWING',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ] else if (isLatest) ...[
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'LATEST',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            _getChangeSummary(
                              item,
                              isLatest
                                  ? null
                                  : controller.secretHistory.firstOrNull,
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    if (!isDisplayed) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getChangeSummary(
    SecretHistoryItem item,
    SecretHistoryItem? previousItem,
  ) {
    final changes = <String>[];

    // Check title change
    if (previousItem != null &&
        item.secret.title != previousItem.secret.title) {
      changes.add('Title changed');
    }

    // Check fields count
    final currentFieldCount = item.secret.fields?.length ?? 0;
    final previousFieldCount = previousItem?.secret.fields?.length ?? 0;

    if (previousItem == null) {
      changes.add(
        'Initial version with $currentFieldCount field${currentFieldCount == 1 ? '' : 's'}',
      );
    } else if (currentFieldCount != previousFieldCount) {
      if (currentFieldCount > previousFieldCount) {
        changes.add(
          '${currentFieldCount - previousFieldCount} field${(currentFieldCount - previousFieldCount) == 1 ? '' : 's'} added',
        );
      } else {
        changes.add(
          '${previousFieldCount - currentFieldCount} field${(previousFieldCount - currentFieldCount) == 1 ? '' : 's'} removed',
        );
      }
    }

    // Check note change
    if (previousItem != null && item.secret.note != previousItem.secret.note) {
      changes.add('Note updated');
    }

    // Check URLs
    final currentUrlCount = item.secret.urls?.length ?? 0;
    final previousUrlCount = previousItem?.secret.urls?.length ?? 0;

    if (previousItem != null && currentUrlCount != previousUrlCount) {
      changes.add('URLs modified');
    }

    return changes.isEmpty ? 'No changes' : changes.join(', ');
  }
}

class MailboxView extends StatelessWidget {
  final SecretDetailController controller;
  const MailboxView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AreaView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Mailbox", style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              onPressed: () {
                controller.fetchEmails();
              },
              icon: Icon(Icons.refresh),
            ),
          ],
        ),
        ...controller.emails.map(
          (e) => CompactEmailView(
            email: e,
            onTap: () => _showFullEmail(context, e),
          ),
        ),
      ],
    );
  }

  void _showFullEmail(BuildContext context, Mail email) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Email icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Subject and date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _extractSubject(email.event.content),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: theme.textTheme.bodySmall?.color,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatFullTimestamp(email.event.createdAt),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  color: theme.textTheme.bodyMedium?.color,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Email body
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildClickableContent(
                        context,
                        _extractBody(email.event.content),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractSubject(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      if (line.toLowerCase().startsWith('subject:')) {
        return line.substring(8).trim();
      }
    }
    return lines.isNotEmpty && lines.first.isNotEmpty
        ? lines.first
        : 'No subject';
  }

  String _extractBody(String content) {
    if (content.toLowerCase().contains('subject:')) {
      final subjectEnd = content.indexOf('\n');
      if (subjectEnd != -1) {
        return content.substring(subjectEnd + 1).trim();
      }
    }
    return content;
  }

  String _formatFullTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildClickableContent(BuildContext context, String content) {
    final urlRegex = RegExp(
      r'https?://[^\s<>"{}|\\^\[\]`]+',
      caseSensitive: false,
    );

    final matches = urlRegex.allMatches(content).toList();

    if (matches.isEmpty) {
      return SelectableText(
        content,
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      // Add text before the URL
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: content.substring(lastEnd, match.start),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      }

      // Add the URL as a clickable link
      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.tryParse(url);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
        ),
      );

      lastEnd = match.end;
    }

    // Add any remaining text
    if (lastEnd < content.length) {
      spans.add(
        TextSpan(
          text: content.substring(lastEnd),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return SelectableText.rich(TextSpan(children: spans));
  }
}

void _showShareDialog(BuildContext context, SecretDetailController controller) {
  // Load follows when dialog opens
  Repository.to.loadFollows();
  controller.filteredFollows.value = Repository.to.follows;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Secret',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.shareRecipientController,
                decoration: InputDecoration(
                  hintText: 'npub1... or hex public key',
                  label: Text('Recipient'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller.searchController,
                onChanged: controller.filterFollows,
                decoration: InputDecoration(
                  hintText: 'Search follows...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (Repository.to.isLoadingFollows.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (controller.filteredFollows.isEmpty) {
                    return Center(
                      child: Text(
                        Repository.to.follows.isEmpty
                            ? 'No follows found'
                            : 'No matches found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.filteredFollows.length,
                    itemBuilder: (context, index) {
                      final follow = controller.filteredFollows[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: follow.picture != null
                              ? NetworkImage(follow.picture!)
                              : null,
                          child: follow.picture == null
                              ? Text(follow.displayName[0].toUpperCase())
                              : null,
                        ),
                        title: Text(follow.displayName),
                        subtitle: follow.nip05 != null
                            ? Text(follow.nip05!)
                            : Text(
                                follow.npub,
                                style: TextStyle(fontFamily: 'monospace'),
                              ),
                        onTap: () => controller.selectFollow(follow),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      controller.shareRecipientController.clear();
                      controller.searchController.clear();
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  SizedBox(width: 16),
                  Obx(
                    () => FilledButton(
                      onPressed: controller.isSharing.value
                          ? null
                          : () => controller.shareSecret(),
                      child: controller.isSharing.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
