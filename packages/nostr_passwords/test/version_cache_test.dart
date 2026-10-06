import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';
import 'package:test/test.dart';

void main() {
  final github = Envelope(
    id: 'item',
    type: 'item',
    rev: 'rev',
    parents: const [],
    modifiedAt: DateTime.utc(2026, 10, 6),
    data: {'type': 1, 'name': 'GitHub', 'notes': 'Recovery codes in the safe'},
  );

  group('VersionCache', () {
    late _MemoryStore store;
    late String key;

    setUp(() {
      store = _MemoryStore();
      key = newCacheKey();
    });

    test('reads back what it wrote, encrypted in the store', () async {
      await VersionCache(store, key).write({'wrap': github});

      final versions = await VersionCache(store, key).read();
      expect(versions.keys, ['wrap']);
      expect(versions['wrap']!.toJson(), github.toJson());
      expect(store.entries['wrap'], isNot(contains('Recovery')));
    });

    test('skips what another key wrote', () async {
      await VersionCache(store, newCacheKey()).write({'wrap': github});

      expect(await VersionCache(store, key).read(), isEmpty);
    });

    test('skips an entry moved to another gift wrap', () async {
      await VersionCache(store, key).write({'wrap': github});
      store.entries['other wrap'] = store.entries.remove('wrap')!;

      expect(await VersionCache(store, key).read(), isEmpty);
    });

    test('remove drops the entries of the gift wraps', () async {
      final cache = VersionCache(store, key);
      await cache.write({'wrap': github, 'other wrap': github});

      await cache.remove(['wrap']);

      expect((await cache.read()).keys, ['other wrap']);
    });

    group('sealed', () {
      late _CountingSigner signer;

      setUp(() => signer = _CountingSigner());

      test('is locked until the signer opens its key', () async {
        final cache = VersionCache.sealed(
          store,
          await sealCacheKey(key, signer),
          signer,
        );
        expect(cache.locked, isTrue);
        expect(cache.key, isNull);
        expect(cache.read, throwsA(isA<CacheLockedException>()));
        expect(signer.decryptions, 0);

        expect(await cache.unlock(), isTrue);
        expect(await cache.unlock(), isTrue);

        expect(cache.locked, isFalse);
        expect(cache.key, key);
        expect(signer.decryptions, 1);
      });

      test('reads what the plain key wrote', () async {
        await VersionCache(store, key).write({'wrap': github});
        final cache = VersionCache.sealed(
          store,
          await sealCacheKey(key, signer),
          signer,
        );

        await cache.unlock();

        expect((await cache.read())['wrap']!.toJson(), github.toJson());
      });

      test('stays locked when the signer refuses, until asked again', () async {
        final cache = VersionCache.sealed(
          store,
          await sealCacheKey(key, signer),
          signer,
        );
        signer.refuses = true;

        expect(await cache.unlock(), isFalse);
        expect(cache.locked, isTrue);

        signer.refuses = false;
        expect(await cache.unlock(), isTrue);
        expect(signer.decryptions, 2);
      });

      test('stays locked when sealed by another vault', () async {
        final other = _CountingSigner();
        final cache = VersionCache.sealed(
          store,
          await sealCacheKey(key, other),
          signer,
        );

        expect(await cache.unlock(), isFalse);
      });
    });
  });

  group('Vault with a cache', () {
    late Ndk ndk;
    late _CountingSigner signer;
    late _MemoryStore store;
    late String key;

    setUp(() {
      ndk = Ndk.emptyBootstrapRelaysConfig();
      signer = _CountingSigner();
      store = _MemoryStore();
      key = newCacheKey();
    });

    tearDown(() => ndk.destroy());

    Vault vaultWith(VersionCache? cache) => Vault(
      ndk: ndk,
      signer: signer,
      relays: ['ws://127.0.0.1:1'],
      indexers: const [],
      cache: cache,
    );

    /// Gift wraps another device published, as a sync brings them in.
    Future<void> synced(List<String> names) async {
      final other = vaultWith(null);
      for (final name in names) {
        await other.createItem(Cipher(type: CipherType.secureNote, name: name));
      }
      signer.decryptions = 0;
    }

    List<String> names(List<Item> items) =>
        [for (final item in items) item.cipher.name]..sort();

    test(
      'asks the signer once for each gift wrap, not at each start',
      () async {
        await synced(['GitHub', 'Wi-Fi']);

        expect(names(await vaultWith(VersionCache(store, key)).items()), [
          'GitHub',
          'Wi-Fi',
        ]);
        expect(signer.decryptions, 2);
        expect(store.entries, hasLength(2));

        final restarted = vaultWith(VersionCache(store, key));
        expect(names(await restarted.items()), ['GitHub', 'Wi-Fi']);
        expect(signer.decryptions, 2);
      },
    );

    test('keeps what it writes, which it then never asks to open', () async {
      final vault = vaultWith(VersionCache(store, key));
      final created = await vault.createItem(
        Cipher(type: CipherType.secureNote, name: 'GitHub'),
      );
      final [item] = await vault.items();
      await vault.updateItem(item, item.cipher..notes = 'Recovery codes');

      final [restarted] = await vaultWith(VersionCache(store, key)).items();
      expect(restarted.id, created.id);
      expect(restarted.cipher.notes, 'Recovery codes');
      expect(signer.decryptions, 0);
    });

    test('openedItems leaves out what the signer has yet to open', () async {
      await synced(['GitHub']);
      final vault = vaultWith(VersionCache(store, key));

      expect(await vault.openedItems(), isEmpty);
      expect(signer.decryptions, 0);

      expect(await vault.open(), isTrue);
      expect(names(await vault.openedItems()), ['GitHub']);
      expect(await vault.open(), isFalse);
      expect(signer.decryptions, 1);
    });

    test('open asks for a gift wrap once while it opens', () async {
      await synced(['GitHub']);
      final vault = vaultWith(VersionCache(store, key));

      await Future.wait([vault.open(), vault.open()]);

      expect(signer.decryptions, 1);
    });

    test('deleteItem drops the versions of the item from the cache', () async {
      final vault = vaultWith(VersionCache(store, key));
      await vault.createItem(
        Cipher(type: CipherType.secureNote, name: 'Wi-Fi'),
      );
      final [item] = await vault.items();
      await vault.updateItem(item, item.cipher..notes = 'Guest network');
      await vault.createItem(
        Cipher(type: CipherType.secureNote, name: 'GitHub'),
      );

      await vault.deleteItem(
        (await vault.items()).firstWhere((item) => item.cipher.name == 'Wi-Fi'),
      );

      expect(store.entries, hasLength(1));
      expect(names(await vaultWith(VersionCache(store, key)).items()), [
        'GitHub',
      ]);
    });

    test('a sealed cache shows nothing until the signer opens it', () async {
      await synced(['GitHub', 'Wi-Fi']);
      final sealed = await sealCacheKey(key, signer);
      final vault = vaultWith(VersionCache.sealed(store, sealed, signer));

      expect(vault.items, throwsA(isA<CacheLockedException>()));
      expect(vault.open, throwsA(isA<CacheLockedException>()));
      expect(await vault.openedItems(), isEmpty);
      expect(signer.decryptions, 0);

      await vault.cache!.unlock();
      expect(names(await vault.items()), ['GitHub', 'Wi-Fi']);
      expect(signer.decryptions, 3);

      final restarted = vaultWith(VersionCache.sealed(store, sealed, signer));
      await restarted.cache!.unlock();
      expect(names(await restarted.items()), ['GitHub', 'Wi-Fi']);
      expect(signer.decryptions, 4);
    });
  });
}

class _MemoryStore implements VersionStore {
  final entries = <String, String>{};

  @override
  Future<Map<String, String>> read() async => {...entries};

  @override
  Future<void> write(Map<String, String> entries) async =>
      this.entries.addAll(entries);

  @override
  Future<void> remove(Iterable<String> wrapIds) async =>
      wrapIds.forEach(entries.remove);
}

/// A vault key that counts what it decrypts, as a remote signer would be asked.
class _CountingSigner extends Bip340EventSigner {
  factory _CountingSigner() {
    final (privateKey, publicKey) = const Bip340EventSignerFactory()
        .generateKeyPair();
    return _CountingSigner._(privateKey, publicKey);
  }

  _CountingSigner._(String privateKey, String publicKey)
    : super(privateKey: privateKey, publicKey: publicKey);

  var decryptions = 0;
  var refuses = false;

  @override
  Future<String?> decryptNip44({
    required String ciphertext,
    required String senderPubKey,
  }) async {
    decryptions++;
    if (refuses) throw SignerRequestRejectedException(requestId: 'refused');
    return super.decryptNip44(
      ciphertext: ciphertext,
      senderPubKey: senderPubKey,
    );
  }
}
