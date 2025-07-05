import 'package:sembast/sembast.dart';

// Store for secrets
final secretsStore = stringMapStoreFactory.store('secrets');

// Store for deleted event IDs
final deletedEventsStore = stringMapStoreFactory.store('deleted_events');