import 'package:sembast_web/sembast_web.dart';

import 'sync_database.dart';

Future<Database> openSyncDatabase() =>
    databaseFactoryWeb.openDatabase(syncDatabaseName);
