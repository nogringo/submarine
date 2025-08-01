import 'dart:async';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:sembast/sembast.dart' as sembast;
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';
import 'package:submarine/utils/toast_helper.dart';

class PasswordManagerController extends GetxController {
  static PasswordManagerController get to => Get.find();

  final RxList<Secret> secrets = <Secret>[].obs;
  final RxBool isLoading = false.obs;
  final RxString userProfilePicture = ''.obs;
  final RxString userName = ''.obs;
  final Map<String, String> _secretEventIds = {}; // secretId -> eventId

  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    _listenToSecrets();
    _fetchUserMetadata();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _listenToSecrets() async {
    isLoading.value = true;

    final db = await DatabaseService().database;

    // Listen to changes in the secrets store
    _subscription = secretsStore.query().onSnapshots(db).listen((snapshots) {
      final allSecrets = snapshots.map((snapshot) {
        final decryptedEvent = DecryptedSecretEvent.fromJson(snapshot.value);
        final secret = Secret.fromJson(decryptedEvent.secret);

        return {
          'secret': secret,
          'createdAt': decryptedEvent.createdAt,
          'eventId': snapshot.key,
        };
      }).toList();

      // Group by secret ID and keep only the latest version
      final latestSecrets = <String, Map<String, dynamic>>{};

      for (final item in allSecrets) {
        final secret = item['secret'] as Secret;
        if (secret.id != null) {
          final existingItem = latestSecrets[secret.id!];
          if (existingItem == null ||
              (item['createdAt'] as int) > (existingItem['createdAt'] as int)) {
            latestSecrets[secret.id!] = item;
          }
        }
      }

      // Store the mapping of secretId -> eventId for the latest versions
      _secretEventIds.clear();
      for (final item in latestSecrets.values) {
        final secret = item['secret'] as Secret;
        if (secret.id != null) {
          _secretEventIds[secret.id!] = item['eventId'] as String;
        }
      }

      // Sort by createdAt (newest first)
      final secretsList = latestSecrets.values.toList();
      secretsList.sort(
        (a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int),
      );

      secrets.value = secretsList
          .map((item) => item['secret'] as Secret)
          .toList();

      if (isLoading.value) {
        isLoading.value = false;
      }
    });
  }

  Future<void> refreshSecrets() async {
    // The stream will automatically update, but we can trigger a manual refresh if needed
    final db = await DatabaseService().database;
    final records = await secretsStore.find(db);

    secrets.value = records.map((record) {
      final decryptedEvent = DecryptedSecretEvent.fromJson(record.value);
      return Secret.fromJson(decryptedEvent.secret);
    }).toList();
  }

  Future<void> deleteSecret(String secretId) async {
    try {
      // Find ALL event IDs for this secret (all versions)
      final db = await DatabaseService().database;
      final records = await secretsStore.find(
        db,
        finder: sembast.Finder(
          filter: sembast.Filter.equals('secret.id', secretId),
        ),
      );

      if (records.isEmpty) return;

      final loggedAccount = Repository.to.ndk.accounts.getLoggedAccount()!;
      
      // Create deletion events for each version
      for (final record in records) {
        final eventId = record.key;
        
        // Create deletion event (kind 5) for this version
        final deletionEvent = Nip01Event(
          pubKey: loggedAccount.pubkey,
          kind: 5,
          tags: [
            ['e', eventId],
          ],
          content: '',
        );

        await loggedAccount.signer.sign(deletionEvent);

        // Remove from local database
        await secretsStore.record(eventId).delete(db);

        // Broadcast deletion event
        Repository.to.ndk.broadcast.broadcast(nostrEvent: deletionEvent);
      }
      
      ToastHelper.showSuccess(
        context: Get.context!,
        title: 'Success',
        description: '${records.length} version${records.length > 1 ? 's' : ''} deleted',
      );
    } catch (e) {
      // Handle error
      ToastHelper.showError(
        context: Get.context!,
        title: 'Error',
        description: 'Failed to delete secret: ${e.toString()}',
      );
    }
  }

  Future<void> _fetchUserMetadata() async {
    try {
      final publicKey = Repository.to.publicKey;
      if (publicKey == null) return;

      // Load user metadata using NDK
      final metadata = await Repository.to.ndk.metadata.loadMetadata(publicKey);
      if (metadata != null) {
        userProfilePicture.value = metadata.picture ?? '';
        userName.value = metadata.name ?? '';
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String? getEventId(String secretId) {
    return _secretEventIds[secretId];
  }
}
