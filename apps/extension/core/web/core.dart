import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:ndk/ndk.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:nostr_passwords/nostr_passwords.dart'
    show
        generateBirthDate,
        generateFirstName,
        generateLastName,
        generatePassphrase;
import 'package:submarine_extension_core/auto_lock.dart';
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:submarine_extension_core/js_crypto.dart';
import 'package:submarine_extension_core/js_events.dart';
import 'package:submarine_extension_core/js_lock_alarm.dart';
import 'package:submarine_extension_core/js_storage.dart';
import 'package:submarine_extension_core/reopenable.dart';
import 'package:submarine_extension_core/sync.dart';
import 'package:submarine_extension_core/totp.dart';
import 'package:submarine_extension_core/vaults.dart';

void main() {
  const local = JsStorage.local();
  const session = JsStorage.session();
  final deviceKey = DeviceKey(local, session);
  final autoLock = AutoLock(deviceKey, local, session, const JsLockAlarm());
  final vaults = Vaults(local, const JsEventSignerFactory(), deviceKey);
  // The database opens once a popup asks for the sync or the items, not at
  // each wake.
  final syncs = Reopenable(() => _openSync(vaults), (sync) => sync.close());
  Future<VaultSync> sync() => syncs.open();
  // Whether a popup is open, for the sync to start again once unlocked.
  var popupOpen = false;
  Future<void> lock() async {
    await deviceKey.lock();
    autoLock.cancel();
    await syncs.close();
    emitVaultsChanged();
  }

  final core = Core(
    before: () async {
      if (await autoLock.expired()) await lock();
    },
    {
      'lockState': (_) async => {
        'hasPassword': await deviceKey.hasPassword,
        'locked': await deviceKey.locked,
      },
      'setLockPassword': (args) async {
        await deviceKey.setPassword(args['password'] as String);
        await autoLock.used();
        emitVaultsChanged();
        return null;
      },
      'changeLockPassword': (args) async {
        final changed = await deviceKey.changePassword(
          args['current'] as String,
          args['password'] as String,
        );
        if (!changed) throw CoreException('wrongLockPassword');
        return null;
      },
      'removeLockPassword': (args) async {
        if (!await deviceKey.removePassword(args['current'] as String)) {
          throw CoreException('wrongLockPassword');
        }
        autoLock.cancel();
        emitVaultsChanged();
        return null;
      },
      'forgetVaults': (_) async {
        autoLock.cancel();
        await vaults.forget();
        // Every vault goes: the ndk cache, the sync coverage and the versions.
        await syncs.close(
          () => databaseFactoryWebWorker.deleteDatabase(_databaseName),
        );
        await deviceKey.forget();
        emitVaultsChanged();
        return null;
      },
      'lock': (_) async {
        await lock();
        return null;
      },
      'unlock': (args) async {
        if (!await deviceKey.unlock(args['password'] as String)) {
          throw CoreException('wrongLockPassword');
        }
        await autoLock.used();
        if (popupOpen) await (await sync()).start();
        emitVaultsChanged();
        return null;
      },
      'used': (_) async {
        await autoLock.used();
        return null;
      },
      // What the lock alarm wakes the background for: [Core.before] locks.
      'lockIfIdle': (_) async => null,
      'lockTimeout': (_) async => (await autoLock.timeout()).name,
      'setLockTimeout': (args) async {
        await autoLock.setTimeout(
          LockTimeout.values.byName(args['timeout'] as String),
        );
        return null;
      },
      'generatePassphrase': (_) async => generatePassphrase(),
      'generateValue': (args) async => switch (args['kind']) {
        'firstName' => generateFirstName(),
        'lastName' => generateLastName(),
        'birthDate' => generateBirthDate(),
        final kind => throw CoreException('unknownKind', '$kind'),
      },
      'vaults': (_) => vaults.list(),
      'addVault': (args) async {
        final vault = await vaults.add(
          key: args['key'] as String,
          password: args['password'] as String?,
          name: args['name'] as String,
          color: args['color'] as int,
        );
        if (syncs.current case final current?) await (await current).update();
        return vault;
      },
      'editVault': (args) => vaults.edit(
        args['vault'] as String,
        name: args['name'] as String?,
        color: args['color'] as int?,
      ),
      'removeVault': (args) async {
        final record = await vaults.remove(args['vault'] as String);
        await (await sync()).forget(record);
        emitVaultsChanged();
        return null;
      },
      'startSync': (_) async {
        popupOpen = true;
        if (!await deviceKey.locked) await (await sync()).start();
        return null;
      },
      'stopSync': (_) async {
        popupOpen = false;
        await (await syncs.current)?.stop();
        if (await autoLock.locksOnClose() && !await deviceKey.locked) {
          await lock();
        }
        return null;
      },
      'syncNow': (args) async =>
          (await sync()).syncNow(pubkey: args['vault'] as String?),
      'syncStates': (_) async => (await sync()).states(),
      'items': (args) async => (await sync()).items(
        pubkey: args['vault'] as String?,
        query: args['query'] as String? ?? '',
        url: args['url'] as String?,
        filter: args['filter'] ?? 'all',
      ),
      'itemTypes': (args) async =>
          (await sync()).itemTypes(pubkey: args['vault'] as String?),
      'createItem': (args) async => {
        'id': await (await sync()).createItem(
          pubkey: args['vault'] as String,
          cipher: args['cipher'] as Map<String, dynamic>,
        ),
      },
      'updateItem': (args) async {
        await (await sync()).updateItem(
          pubkey: args['vault'] as String,
          base: args['base'] as List<Object?>,
          cipher: args['cipher'] as Map<String, dynamic>,
        );
        return null;
      },
      'setFavorite': (args) async {
        await (await sync()).setFavorite(
          pubkey: args['vault'] as String,
          id: args['id'] as String,
          favorite: args['favorite'] as bool,
        );
        return null;
      },
      'trashItem': (args) async {
        await (await sync()).trashItem(
          pubkey: args['vault'] as String,
          id: args['id'] as String,
        );
        return null;
      },
      'restoreItem': (args) async {
        await (await sync()).restoreItem(
          pubkey: args['vault'] as String,
          id: args['id'] as String,
        );
        return null;
      },
      'deleteItem': (args) async {
        await (await sync()).deleteItem(
          pubkey: args['vault'] as String,
          id: args['id'] as String,
        );
        return null;
      },
      'totp': (args) async => totp(
        args['key'] as String,
        DateTime.fromMillisecondsSinceEpoch(args['at'] as int),
      ),
      'item': (args) async => (await sync()).item(
        pubkey: args['vault'] as String,
        id: args['id'] as String,
      ),
    },
  );
  globalContext['submarineCore'] = createJSInteropWrapper(_JsCore(core));
}

const _databaseName = 'submarine';

Future<VaultSync> _openSync(Vaults vaults) async {
  // The ndk cache, the sync coverage and the versions opened, together: the
  // coverage must never outlive the cache it describes.
  final database = await databaseFactoryWebWorker.openDatabase(_databaseName);
  final ndk = Ndk(
    NdkConfig(
      eventVerifier: JsEventVerifier(),
      eventSignerFactory: const JsEventSignerFactory(),
      cache: SembastCacheManager(database),
      // The vaults' relays only: no bootstrap relay learns about the vaults.
      bootstrapRelays: [],
      logLevel: LogLevel.warning,
    ),
  );
  return VaultSync(
    ndk: ndk,
    database: database,
    vaults: vaults,
    onChanged: emitVaultsChanged,
  );
}

@JSExport()
class _JsCore {
  _JsCore(this._core);

  final Core _core;

  JSPromise<JSString> call(String method, String args) =>
      _core.handle(method, args).then((reply) => reply.toJS).toJS;
}
