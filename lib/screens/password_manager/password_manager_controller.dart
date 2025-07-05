import 'dart:async';
import 'package:get/get.dart';
import 'package:ndk/entities.dart';
import 'package:sembast/sembast.dart';
import 'package:submarine/models/decrypted_event.dart';
import 'package:submarine/models/secret.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/services/database_service.dart';
import 'package:submarine/services/stores.dart';

class PasswordManagerController extends GetxController {
  static PasswordManagerController get to => Get.find();

  final RxList<Secret> secrets = <Secret>[].obs;
  final RxBool isLoading = false.obs;
  final RxString userProfilePicture = ''.obs;
  final RxString userName = ''.obs;

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
      final secretsList = snapshots.map((snapshot) {
        final decryptedEvent = DecryptedSecretEvent.fromJson(snapshot.value);
        return {
          'secret': Secret.fromJson(decryptedEvent.secret),
          'createdAt': decryptedEvent.createdAt,
        };
      }).toList();

      // Sort by createdAt (newest first)
      secretsList.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
      
      secrets.value = secretsList.map((item) => item['secret'] as Secret).toList();

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
      // Find the event ID for this secret
      final db = await DatabaseService().database;
      final records = await secretsStore.find(db);
      
      String? eventIdToDelete;
      for (final record in records) {
        final decryptedEvent = DecryptedSecretEvent.fromJson(record.value);
        final secret = Secret.fromJson(decryptedEvent.secret);
        if (secret.id == secretId) {
          eventIdToDelete = record.key;
          break;
        }
      }

      if (eventIdToDelete == null) return;

      // Create deletion event (kind 5)
      final loggedAccount = Repository.to.ndk.accounts.getLoggedAccount()!;
      final deletionEvent = Nip01Event(
        pubKey: loggedAccount.pubkey,
        kind: 5,
        tags: [['e', eventIdToDelete]],
        content: '',
      );

      await loggedAccount.signer.sign(deletionEvent);

      // Remove from local database
      await secretsStore.record(eventIdToDelete).delete(db);

      // Broadcast deletion event
      Repository.to.ndk.broadcast.broadcast(nostrEvent: deletionEvent);

    } catch (e) {
      // Handle error
      Get.snackbar('Error', 'Failed to delete secret');
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
}
