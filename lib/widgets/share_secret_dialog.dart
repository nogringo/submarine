import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/models/follow.dart';
import 'package:submarine/repository.dart';
import 'package:toastification/toastification.dart';
import 'package:nip19/nip19.dart';

class ShareSecretDialog extends StatefulWidget {
  final String eventId;
  final String secretTitle;

  const ShareSecretDialog({
    super.key,
    required this.eventId,
    required this.secretTitle,
  });

  @override
  State<ShareSecretDialog> createState() => _ShareSecretDialogState();
}

class _ShareSecretDialogState extends State<ShareSecretDialog> {
  final shareRecipientController = TextEditingController();
  final searchController = TextEditingController();
  final isSharing = false.obs;
  final filteredFollows = <Follow>[].obs;

  @override
  void initState() {
    super.initState();
    _loadFollows();
  }

  @override
  void dispose() {
    shareRecipientController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _loadFollows() async {
    await Repository.to.loadFollows();
    filteredFollows.value = Repository.to.follows;
  }

  void _filterFollows(String query) {
    if (query.isEmpty) {
      filteredFollows.value = Repository.to.follows;
      return;
    }

    final lowerQuery = query.toLowerCase();
    filteredFollows.value = Repository.to.follows.where((follow) {
      final name = follow.displayName.toLowerCase();
      final nip05 = (follow.nip05 ?? '').toLowerCase();
      final npub = follow.pubkey.toLowerCase();

      return name.contains(lowerQuery) ||
          nip05.contains(lowerQuery) ||
          npub.contains(lowerQuery);
    }).toList();
  }

  void _selectFollow(Follow follow) {
    shareRecipientController.text = follow.pubkey;
    searchController.clear();
    _filterFollows('');
  }

  Future<void> _shareSecret() async {
    final recipientInput = shareRecipientController.text.trim();
    if (recipientInput.isEmpty) {
      toastification.show(
        context: context,
        title: Text('Error'),
        description: Text('Please enter a recipient'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    String recipientPubkey;
    try {
      // Check if input is npub
      if (recipientInput.startsWith('npub')) {
        recipientPubkey = Nip19.npubToHex(recipientInput);
      } else if (recipientInput.length == 64 && _isHex(recipientInput)) {
        // Already a hex pubkey
        recipientPubkey = recipientInput;
      } else {
        throw Exception('Invalid public key format');
      }
    } catch (e) {
      toastification.show(
        context: context,
        title: Text('Error'),
        description: Text('Invalid public key format'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    isSharing.value = true;
    try {
      await Repository.to.shareSecret(
        eventId: widget.eventId,
        recipientPubkey: recipientPubkey,
      );

      shareRecipientController.clear();
      if (mounted) {
        Get.back(); // Close the dialog

        toastification.show(
          context: context,
          title: Text('Success'),
          description: Text('${widget.secretTitle} shared successfully'),
          type: ToastificationType.success,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        toastification.show(
          context: context,
          title: Text('Error'),
          description: Text('Failed to share secret: ${e.toString()}'),
          type: ToastificationType.error,
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      isSharing.value = false;
    }
  }

  bool _isHex(String input) {
    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(input);
  }

  @override
  Widget build(BuildContext context) {
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
              'Share ${widget.secretTitle}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            TextField(
              controller: shareRecipientController,
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
              controller: searchController,
              onChanged: _filterFollows,
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

                if (filteredFollows.isEmpty) {
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
                  itemCount: filteredFollows.length,
                  itemBuilder: (context, index) {
                    final follow = filteredFollows[index];
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
                      onTap: () => _selectFollow(follow),
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
                    shareRecipientController.clear();
                    searchController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                SizedBox(width: 16),
                Obx(
                  () => FilledButton(
                    onPressed: isSharing.value ? null : _shareSecret,
                    child: isSharing.value
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
  }
}
