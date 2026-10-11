import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:ndk/ndk.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:nostr_passwords/nostr_passwords.dart' show generatePassphrase;
import 'package:submarine_extension_core/core.dart';
import 'package:submarine_extension_core/device_key.dart';
import 'package:submarine_extension_core/js_crypto.dart';
import 'package:submarine_extension_core/js_events.dart';
import 'package:submarine_extension_core/js_storage.dart';
import 'package:submarine_extension_core/sync.dart';
import 'package:submarine_extension_core/totp.dart';
import 'package:submarine_extension_core/vaults.dart';

void main() {
  const local = JsStorage.local();
  final deviceKey = DeviceKey(local, const JsStorage.session());
  final vaults = Vaults(local, const JsEventSignerFactory(), deviceKey);
  Future<VaultSync>? opening;
  // The database opens once a popup asks for the sync or the items, not at
  // each wake.
  Future<VaultSync> sync() => opening ??= _openSync(vaults);
  // Whether a popup is open, for the sync to start again once unlocked.
  var popupOpen = false;
  final core = Core({
    'lockState': (_) async => {
      'hasPassword': await deviceKey.hasPassword,
      'locked': await deviceKey.locked,
    },
    'setLockPassword': (args) async {
      await deviceKey.setPassword(args['password'] as String);
      emitVaultsChanged();
      return null;
    },
    'lock': (_) async {
      await deviceKey.lock();
      final closing = opening;
      opening = null;
      await (await closing)?.close();
      emitVaultsChanged();
      return null;
    },
    'unlock': (args) async {
      if (!await deviceKey.unlock(args['password'] as String)) {
        throw CoreException('wrongLockPassword');
      }
      if (popupOpen) await (await sync()).start();
      emitVaultsChanged();
      return null;
    },
    'generatePassphrase': (_) async => generatePassphrase(),
    'vaults': (_) => vaults.list(),
    'addVault': (args) async {
      final vault = await vaults.add(
        key: args['key'] as String,
        password: args['password'] as String?,
        name: args['name'] as String,
        color: args['color'] as int,
      );
      if (opening != null) await (await sync()).update();
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
      await (await opening)?.stop();
      return null;
    },
    'syncNow': (args) async =>
        (await sync()).syncNow(pubkey: args['vault'] as String?),
    'syncStates': (_) async => (await sync()).states(),
    'items': (args) async => (await sync()).items(
      pubkey: args['vault'] as String?,
      query: args['query'] as String? ?? '',
    ),
    'totp': (args) async => totp(
      args['key'] as String,
      DateTime.fromMillisecondsSinceEpoch(args['at'] as int),
    ),
    'item': (args) async => (await sync()).item(
      pubkey: args['vault'] as String,
      id: args['id'] as String,
    ),
  });
  globalContext['submarineCore'] = createJSInteropWrapper(_JsCore(core));
}

Future<VaultSync> _openSync(Vaults vaults) async {
  // The ndk cache, the sync coverage and the versions opened, together: the
  // coverage must never outlive the cache it describes.
  final database = await databaseFactoryWebWorker.openDatabase('submarine');
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
