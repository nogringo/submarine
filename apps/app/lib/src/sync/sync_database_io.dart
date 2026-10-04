import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

import 'sync_database.dart';

/// Next to ndk_drift's cache, in the application support directory.
Future<Database> openSyncDatabase() async {
  final directory = await getApplicationSupportDirectory();
  return databaseFactoryIo.openDatabase(
    directory.uri.resolve('$syncDatabaseName.db').toFilePath(),
  );
}
