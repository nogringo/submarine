// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $NostrEventTable extends NostrEvent
    with TableInfo<$NostrEventTable, NostrEventData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NostrEventTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pubkeyMeta = const VerificationMeta('pubkey');
  @override
  late final GeneratedColumn<String> pubkey = GeneratedColumn<String>(
      'pubkey', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<int> kind = GeneratedColumn<int>(
      'kind', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sigMeta = const VerificationMeta('sig');
  @override
  late final GeneratedColumn<String> sig = GeneratedColumn<String>(
      'sig', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pubkey, createdAt, kind, tags, content, sig];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nostr_event';
  @override
  VerificationContext validateIntegrity(Insertable<NostrEventData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pubkey')) {
      context.handle(_pubkeyMeta,
          pubkey.isAcceptableOrUnknown(data['pubkey']!, _pubkeyMeta));
    } else if (isInserting) {
      context.missing(_pubkeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('sig')) {
      context.handle(
          _sigMeta, sig.isAcceptableOrUnknown(data['sig']!, _sigMeta));
    } else if (isInserting) {
      context.missing(_sigMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  NostrEventData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NostrEventData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      pubkey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pubkey'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      sig: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sig'])!,
    );
  }

  @override
  $NostrEventTable createAlias(String alias) {
    return $NostrEventTable(attachedDatabase, alias);
  }
}

class NostrEventData extends DataClass implements Insertable<NostrEventData> {
  final String id;
  final String pubkey;
  final DateTime createdAt;
  final int kind;
  final String tags;
  final String content;
  final String sig;
  const NostrEventData(
      {required this.id,
      required this.pubkey,
      required this.createdAt,
      required this.kind,
      required this.tags,
      required this.content,
      required this.sig});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pubkey'] = Variable<String>(pubkey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['kind'] = Variable<int>(kind);
    map['tags'] = Variable<String>(tags);
    map['content'] = Variable<String>(content);
    map['sig'] = Variable<String>(sig);
    return map;
  }

  NostrEventCompanion toCompanion(bool nullToAbsent) {
    return NostrEventCompanion(
      id: Value(id),
      pubkey: Value(pubkey),
      createdAt: Value(createdAt),
      kind: Value(kind),
      tags: Value(tags),
      content: Value(content),
      sig: Value(sig),
    );
  }

  factory NostrEventData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NostrEventData(
      id: serializer.fromJson<String>(json['id']),
      pubkey: serializer.fromJson<String>(json['pubkey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      kind: serializer.fromJson<int>(json['kind']),
      tags: serializer.fromJson<String>(json['tags']),
      content: serializer.fromJson<String>(json['content']),
      sig: serializer.fromJson<String>(json['sig']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pubkey': serializer.toJson<String>(pubkey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'kind': serializer.toJson<int>(kind),
      'tags': serializer.toJson<String>(tags),
      'content': serializer.toJson<String>(content),
      'sig': serializer.toJson<String>(sig),
    };
  }

  NostrEventData copyWith(
          {String? id,
          String? pubkey,
          DateTime? createdAt,
          int? kind,
          String? tags,
          String? content,
          String? sig}) =>
      NostrEventData(
        id: id ?? this.id,
        pubkey: pubkey ?? this.pubkey,
        createdAt: createdAt ?? this.createdAt,
        kind: kind ?? this.kind,
        tags: tags ?? this.tags,
        content: content ?? this.content,
        sig: sig ?? this.sig,
      );
  NostrEventData copyWithCompanion(NostrEventCompanion data) {
    return NostrEventData(
      id: data.id.present ? data.id.value : this.id,
      pubkey: data.pubkey.present ? data.pubkey.value : this.pubkey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      kind: data.kind.present ? data.kind.value : this.kind,
      tags: data.tags.present ? data.tags.value : this.tags,
      content: data.content.present ? data.content.value : this.content,
      sig: data.sig.present ? data.sig.value : this.sig,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventData(')
          ..write('id: $id, ')
          ..write('pubkey: $pubkey, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('tags: $tags, ')
          ..write('content: $content, ')
          ..write('sig: $sig')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pubkey, createdAt, kind, tags, content, sig);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NostrEventData &&
          other.id == this.id &&
          other.pubkey == this.pubkey &&
          other.createdAt == this.createdAt &&
          other.kind == this.kind &&
          other.tags == this.tags &&
          other.content == this.content &&
          other.sig == this.sig);
}

class NostrEventCompanion extends UpdateCompanion<NostrEventData> {
  final Value<String> id;
  final Value<String> pubkey;
  final Value<DateTime> createdAt;
  final Value<int> kind;
  final Value<String> tags;
  final Value<String> content;
  final Value<String> sig;
  final Value<int> rowid;
  const NostrEventCompanion({
    this.id = const Value.absent(),
    this.pubkey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.kind = const Value.absent(),
    this.tags = const Value.absent(),
    this.content = const Value.absent(),
    this.sig = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NostrEventCompanion.insert({
    required String id,
    required String pubkey,
    required DateTime createdAt,
    required int kind,
    required String tags,
    required String content,
    required String sig,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        pubkey = Value(pubkey),
        createdAt = Value(createdAt),
        kind = Value(kind),
        tags = Value(tags),
        content = Value(content),
        sig = Value(sig);
  static Insertable<NostrEventData> custom({
    Expression<String>? id,
    Expression<String>? pubkey,
    Expression<DateTime>? createdAt,
    Expression<int>? kind,
    Expression<String>? tags,
    Expression<String>? content,
    Expression<String>? sig,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pubkey != null) 'pubkey': pubkey,
      if (createdAt != null) 'created_at': createdAt,
      if (kind != null) 'kind': kind,
      if (tags != null) 'tags': tags,
      if (content != null) 'content': content,
      if (sig != null) 'sig': sig,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NostrEventCompanion copyWith(
      {Value<String>? id,
      Value<String>? pubkey,
      Value<DateTime>? createdAt,
      Value<int>? kind,
      Value<String>? tags,
      Value<String>? content,
      Value<String>? sig,
      Value<int>? rowid}) {
    return NostrEventCompanion(
      id: id ?? this.id,
      pubkey: pubkey ?? this.pubkey,
      createdAt: createdAt ?? this.createdAt,
      kind: kind ?? this.kind,
      tags: tags ?? this.tags,
      content: content ?? this.content,
      sig: sig ?? this.sig,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pubkey.present) {
      map['pubkey'] = Variable<String>(pubkey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(kind.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sig.present) {
      map['sig'] = Variable<String>(sig.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NostrEventCompanion(')
          ..write('id: $id, ')
          ..write('pubkey: $pubkey, ')
          ..write('createdAt: $createdAt, ')
          ..write('kind: $kind, ')
          ..write('tags: $tags, ')
          ..write('content: $content, ')
          ..write('sig: $sig, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NostrRelayTable extends NostrRelay
    with TableInfo<$NostrRelayTable, NostrRelayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NostrRelayTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [url];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nostr_relay';
  @override
  VerificationContext validateIntegrity(Insertable<NostrRelayData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  NostrRelayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NostrRelayData(
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
    );
  }

  @override
  $NostrRelayTable createAlias(String alias) {
    return $NostrRelayTable(attachedDatabase, alias);
  }
}

class NostrRelayData extends DataClass implements Insertable<NostrRelayData> {
  final String url;
  const NostrRelayData({required this.url});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    return map;
  }

  NostrRelayCompanion toCompanion(bool nullToAbsent) {
    return NostrRelayCompanion(
      url: Value(url),
    );
  }

  factory NostrRelayData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NostrRelayData(
      url: serializer.fromJson<String>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
    };
  }

  NostrRelayData copyWith({String? url}) => NostrRelayData(
        url: url ?? this.url,
      );
  NostrRelayData copyWithCompanion(NostrRelayCompanion data) {
    return NostrRelayData(
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NostrRelayData(')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => url.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NostrRelayData && other.url == this.url);
}

class NostrRelayCompanion extends UpdateCompanion<NostrRelayData> {
  final Value<String> url;
  final Value<int> rowid;
  const NostrRelayCompanion({
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NostrRelayCompanion.insert({
    required String url,
    this.rowid = const Value.absent(),
  }) : url = Value(url);
  static Insertable<NostrRelayData> custom({
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NostrRelayCompanion copyWith({Value<String>? url, Value<int>? rowid}) {
    return NostrRelayCompanion(
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NostrRelayCompanion(')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelayEventLinksTable extends RelayEventLinks
    with TableInfo<$RelayEventLinksTable, RelayEventLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelayEventLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES nostr_event(id) NOT NULL');
  static const VerificationMeta _relayUrlMeta =
      const VerificationMeta('relayUrl');
  @override
  late final GeneratedColumn<String> relayUrl = GeneratedColumn<String>(
      'relay_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'REFERENCES nostr_relay(url) NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [eventId, relayUrl];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relay_event_links';
  @override
  VerificationContext validateIntegrity(Insertable<RelayEventLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('relay_url')) {
      context.handle(_relayUrlMeta,
          relayUrl.isAcceptableOrUnknown(data['relay_url']!, _relayUrlMeta));
    } else if (isInserting) {
      context.missing(_relayUrlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId, relayUrl};
  @override
  RelayEventLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelayEventLink(
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      relayUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relay_url'])!,
    );
  }

  @override
  $RelayEventLinksTable createAlias(String alias) {
    return $RelayEventLinksTable(attachedDatabase, alias);
  }
}

class RelayEventLink extends DataClass implements Insertable<RelayEventLink> {
  final String eventId;
  final String relayUrl;
  const RelayEventLink({required this.eventId, required this.relayUrl});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['relay_url'] = Variable<String>(relayUrl);
    return map;
  }

  RelayEventLinksCompanion toCompanion(bool nullToAbsent) {
    return RelayEventLinksCompanion(
      eventId: Value(eventId),
      relayUrl: Value(relayUrl),
    );
  }

  factory RelayEventLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelayEventLink(
      eventId: serializer.fromJson<String>(json['eventId']),
      relayUrl: serializer.fromJson<String>(json['relayUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'relayUrl': serializer.toJson<String>(relayUrl),
    };
  }

  RelayEventLink copyWith({String? eventId, String? relayUrl}) =>
      RelayEventLink(
        eventId: eventId ?? this.eventId,
        relayUrl: relayUrl ?? this.relayUrl,
      );
  RelayEventLink copyWithCompanion(RelayEventLinksCompanion data) {
    return RelayEventLink(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      relayUrl: data.relayUrl.present ? data.relayUrl.value : this.relayUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelayEventLink(')
          ..write('eventId: $eventId, ')
          ..write('relayUrl: $relayUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, relayUrl);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelayEventLink &&
          other.eventId == this.eventId &&
          other.relayUrl == this.relayUrl);
}

class RelayEventLinksCompanion extends UpdateCompanion<RelayEventLink> {
  final Value<String> eventId;
  final Value<String> relayUrl;
  final Value<int> rowid;
  const RelayEventLinksCompanion({
    this.eventId = const Value.absent(),
    this.relayUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelayEventLinksCompanion.insert({
    required String eventId,
    required String relayUrl,
    this.rowid = const Value.absent(),
  })  : eventId = Value(eventId),
        relayUrl = Value(relayUrl);
  static Insertable<RelayEventLink> custom({
    Expression<String>? eventId,
    Expression<String>? relayUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (relayUrl != null) 'relay_url': relayUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelayEventLinksCompanion copyWith(
      {Value<String>? eventId, Value<String>? relayUrl, Value<int>? rowid}) {
    return RelayEventLinksCompanion(
      eventId: eventId ?? this.eventId,
      relayUrl: relayUrl ?? this.relayUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (relayUrl.present) {
      map['relay_url'] = Variable<String>(relayUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelayEventLinksCompanion(')
          ..write('eventId: $eventId, ')
          ..write('relayUrl: $relayUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NostrEventTable nostrEvent = $NostrEventTable(this);
  late final $NostrRelayTable nostrRelay = $NostrRelayTable(this);
  late final $RelayEventLinksTable relayEventLinks =
      $RelayEventLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [nostrEvent, nostrRelay, relayEventLinks];
}

typedef $$NostrEventTableCreateCompanionBuilder = NostrEventCompanion Function({
  required String id,
  required String pubkey,
  required DateTime createdAt,
  required int kind,
  required String tags,
  required String content,
  required String sig,
  Value<int> rowid,
});
typedef $$NostrEventTableUpdateCompanionBuilder = NostrEventCompanion Function({
  Value<String> id,
  Value<String> pubkey,
  Value<DateTime> createdAt,
  Value<int> kind,
  Value<String> tags,
  Value<String> content,
  Value<String> sig,
  Value<int> rowid,
});

final class $$NostrEventTableReferences
    extends BaseReferences<_$AppDatabase, $NostrEventTable, NostrEventData> {
  $$NostrEventTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RelayEventLinksTable, List<RelayEventLink>>
      _relayEventLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.relayEventLinks,
              aliasName: $_aliasNameGenerator(
                  db.nostrEvent.id, db.relayEventLinks.eventId));

  $$RelayEventLinksTableProcessedTableManager get relayEventLinksRefs {
    final manager =
        $$RelayEventLinksTableTableManager($_db, $_db.relayEventLinks)
            .filter((f) => f.eventId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_relayEventLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$NostrEventTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NostrEventTable> {
  $$NostrEventTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get pubkey => $state.composableBuilder(
      column: $state.table.pubkey,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get sig => $state.composableBuilder(
      column: $state.table.sig,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter relayEventLinksRefs(
      ComposableFilter Function($$RelayEventLinksTableFilterComposer f) f) {
    final $$RelayEventLinksTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $state.db.relayEventLinks,
            getReferencedColumn: (t) => t.eventId,
            builder: (joinBuilder, parentComposers) =>
                $$RelayEventLinksTableFilterComposer(ComposerState($state.db,
                    $state.db.relayEventLinks, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$NostrEventTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NostrEventTable> {
  $$NostrEventTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get pubkey => $state.composableBuilder(
      column: $state.table.pubkey,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get kind => $state.composableBuilder(
      column: $state.table.kind,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get tags => $state.composableBuilder(
      column: $state.table.tags,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get sig => $state.composableBuilder(
      column: $state.table.sig,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$NostrEventTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NostrEventTable,
    NostrEventData,
    $$NostrEventTableFilterComposer,
    $$NostrEventTableOrderingComposer,
    $$NostrEventTableCreateCompanionBuilder,
    $$NostrEventTableUpdateCompanionBuilder,
    (NostrEventData, $$NostrEventTableReferences),
    NostrEventData,
    PrefetchHooks Function({bool relayEventLinksRefs})> {
  $$NostrEventTableTableManager(_$AppDatabase db, $NostrEventTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NostrEventTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NostrEventTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> pubkey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> kind = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> sig = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NostrEventCompanion(
            id: id,
            pubkey: pubkey,
            createdAt: createdAt,
            kind: kind,
            tags: tags,
            content: content,
            sig: sig,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String pubkey,
            required DateTime createdAt,
            required int kind,
            required String tags,
            required String content,
            required String sig,
            Value<int> rowid = const Value.absent(),
          }) =>
              NostrEventCompanion.insert(
            id: id,
            pubkey: pubkey,
            createdAt: createdAt,
            kind: kind,
            tags: tags,
            content: content,
            sig: sig,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NostrEventTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({relayEventLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (relayEventLinksRefs) db.relayEventLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (relayEventLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$NostrEventTableReferences
                            ._relayEventLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$NostrEventTableReferences(db, table, p0)
                                .relayEventLinksRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.eventId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$NostrEventTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NostrEventTable,
    NostrEventData,
    $$NostrEventTableFilterComposer,
    $$NostrEventTableOrderingComposer,
    $$NostrEventTableCreateCompanionBuilder,
    $$NostrEventTableUpdateCompanionBuilder,
    (NostrEventData, $$NostrEventTableReferences),
    NostrEventData,
    PrefetchHooks Function({bool relayEventLinksRefs})>;
typedef $$NostrRelayTableCreateCompanionBuilder = NostrRelayCompanion Function({
  required String url,
  Value<int> rowid,
});
typedef $$NostrRelayTableUpdateCompanionBuilder = NostrRelayCompanion Function({
  Value<String> url,
  Value<int> rowid,
});

final class $$NostrRelayTableReferences
    extends BaseReferences<_$AppDatabase, $NostrRelayTable, NostrRelayData> {
  $$NostrRelayTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RelayEventLinksTable, List<RelayEventLink>>
      _relayEventLinksRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.relayEventLinks,
              aliasName: $_aliasNameGenerator(
                  db.nostrRelay.url, db.relayEventLinks.relayUrl));

  $$RelayEventLinksTableProcessedTableManager get relayEventLinksRefs {
    final manager =
        $$RelayEventLinksTableTableManager($_db, $_db.relayEventLinks)
            .filter((f) => f.relayUrl.url($_item.url));

    final cache =
        $_typedResult.readTableOrNull(_relayEventLinksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$NostrRelayTableFilterComposer
    extends FilterComposer<_$AppDatabase, $NostrRelayTable> {
  $$NostrRelayTableFilterComposer(super.$state);
  ColumnFilters<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter relayEventLinksRefs(
      ComposableFilter Function($$RelayEventLinksTableFilterComposer f) f) {
    final $$RelayEventLinksTableFilterComposer composer =
        $state.composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.url,
            referencedTable: $state.db.relayEventLinks,
            getReferencedColumn: (t) => t.relayUrl,
            builder: (joinBuilder, parentComposers) =>
                $$RelayEventLinksTableFilterComposer(ComposerState($state.db,
                    $state.db.relayEventLinks, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$NostrRelayTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $NostrRelayTable> {
  $$NostrRelayTableOrderingComposer(super.$state);
  ColumnOrderings<String> get url => $state.composableBuilder(
      column: $state.table.url,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$NostrRelayTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NostrRelayTable,
    NostrRelayData,
    $$NostrRelayTableFilterComposer,
    $$NostrRelayTableOrderingComposer,
    $$NostrRelayTableCreateCompanionBuilder,
    $$NostrRelayTableUpdateCompanionBuilder,
    (NostrRelayData, $$NostrRelayTableReferences),
    NostrRelayData,
    PrefetchHooks Function({bool relayEventLinksRefs})> {
  $$NostrRelayTableTableManager(_$AppDatabase db, $NostrRelayTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$NostrRelayTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$NostrRelayTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> url = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NostrRelayCompanion(
            url: url,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String url,
            Value<int> rowid = const Value.absent(),
          }) =>
              NostrRelayCompanion.insert(
            url: url,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$NostrRelayTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({relayEventLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (relayEventLinksRefs) db.relayEventLinks
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (relayEventLinksRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$NostrRelayTableReferences
                            ._relayEventLinksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$NostrRelayTableReferences(db, table, p0)
                                .relayEventLinksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.relayUrl == item.url),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$NostrRelayTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NostrRelayTable,
    NostrRelayData,
    $$NostrRelayTableFilterComposer,
    $$NostrRelayTableOrderingComposer,
    $$NostrRelayTableCreateCompanionBuilder,
    $$NostrRelayTableUpdateCompanionBuilder,
    (NostrRelayData, $$NostrRelayTableReferences),
    NostrRelayData,
    PrefetchHooks Function({bool relayEventLinksRefs})>;
typedef $$RelayEventLinksTableCreateCompanionBuilder = RelayEventLinksCompanion
    Function({
  required String eventId,
  required String relayUrl,
  Value<int> rowid,
});
typedef $$RelayEventLinksTableUpdateCompanionBuilder = RelayEventLinksCompanion
    Function({
  Value<String> eventId,
  Value<String> relayUrl,
  Value<int> rowid,
});

final class $$RelayEventLinksTableReferences extends BaseReferences<
    _$AppDatabase, $RelayEventLinksTable, RelayEventLink> {
  $$RelayEventLinksTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $NostrEventTable _eventIdTable(_$AppDatabase db) =>
      db.nostrEvent.createAlias(
          $_aliasNameGenerator(db.relayEventLinks.eventId, db.nostrEvent.id));

  $$NostrEventTableProcessedTableManager? get eventId {
    if ($_item.eventId == null) return null;
    final manager = $$NostrEventTableTableManager($_db, $_db.nostrEvent)
        .filter((f) => f.id($_item.eventId!));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $NostrRelayTable _relayUrlTable(_$AppDatabase db) =>
      db.nostrRelay.createAlias(
          $_aliasNameGenerator(db.relayEventLinks.relayUrl, db.nostrRelay.url));

  $$NostrRelayTableProcessedTableManager? get relayUrl {
    if ($_item.relayUrl == null) return null;
    final manager = $$NostrRelayTableTableManager($_db, $_db.nostrRelay)
        .filter((f) => f.url($_item.relayUrl!));
    final item = $_typedResult.readTableOrNull(_relayUrlTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RelayEventLinksTableFilterComposer
    extends FilterComposer<_$AppDatabase, $RelayEventLinksTable> {
  $$RelayEventLinksTableFilterComposer(super.$state);
  $$NostrEventTableFilterComposer get eventId {
    final $$NostrEventTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $state.db.nostrEvent,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$NostrEventTableFilterComposer(ComposerState($state.db,
                $state.db.nostrEvent, joinBuilder, parentComposers)));
    return composer;
  }

  $$NostrRelayTableFilterComposer get relayUrl {
    final $$NostrRelayTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.relayUrl,
        referencedTable: $state.db.nostrRelay,
        getReferencedColumn: (t) => t.url,
        builder: (joinBuilder, parentComposers) =>
            $$NostrRelayTableFilterComposer(ComposerState($state.db,
                $state.db.nostrRelay, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$RelayEventLinksTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $RelayEventLinksTable> {
  $$RelayEventLinksTableOrderingComposer(super.$state);
  $$NostrEventTableOrderingComposer get eventId {
    final $$NostrEventTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $state.db.nostrEvent,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$NostrEventTableOrderingComposer(ComposerState($state.db,
                $state.db.nostrEvent, joinBuilder, parentComposers)));
    return composer;
  }

  $$NostrRelayTableOrderingComposer get relayUrl {
    final $$NostrRelayTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.relayUrl,
        referencedTable: $state.db.nostrRelay,
        getReferencedColumn: (t) => t.url,
        builder: (joinBuilder, parentComposers) =>
            $$NostrRelayTableOrderingComposer(ComposerState($state.db,
                $state.db.nostrRelay, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$RelayEventLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RelayEventLinksTable,
    RelayEventLink,
    $$RelayEventLinksTableFilterComposer,
    $$RelayEventLinksTableOrderingComposer,
    $$RelayEventLinksTableCreateCompanionBuilder,
    $$RelayEventLinksTableUpdateCompanionBuilder,
    (RelayEventLink, $$RelayEventLinksTableReferences),
    RelayEventLink,
    PrefetchHooks Function({bool eventId, bool relayUrl})> {
  $$RelayEventLinksTableTableManager(
      _$AppDatabase db, $RelayEventLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$RelayEventLinksTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$RelayEventLinksTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> eventId = const Value.absent(),
            Value<String> relayUrl = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RelayEventLinksCompanion(
            eventId: eventId,
            relayUrl: relayUrl,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String eventId,
            required String relayUrl,
            Value<int> rowid = const Value.absent(),
          }) =>
              RelayEventLinksCompanion.insert(
            eventId: eventId,
            relayUrl: relayUrl,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RelayEventLinksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({eventId = false, relayUrl = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (eventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eventId,
                    referencedTable:
                        $$RelayEventLinksTableReferences._eventIdTable(db),
                    referencedColumn:
                        $$RelayEventLinksTableReferences._eventIdTable(db).id,
                  ) as T;
                }
                if (relayUrl) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.relayUrl,
                    referencedTable:
                        $$RelayEventLinksTableReferences._relayUrlTable(db),
                    referencedColumn:
                        $$RelayEventLinksTableReferences._relayUrlTable(db).url,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RelayEventLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RelayEventLinksTable,
    RelayEventLink,
    $$RelayEventLinksTableFilterComposer,
    $$RelayEventLinksTableOrderingComposer,
    $$RelayEventLinksTableCreateCompanionBuilder,
    $$RelayEventLinksTableUpdateCompanionBuilder,
    (RelayEventLink, $$RelayEventLinksTableReferences),
    RelayEventLink,
    PrefetchHooks Function({bool eventId, bool relayUrl})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NostrEventTableTableManager get nostrEvent =>
      $$NostrEventTableTableManager(_db, _db.nostrEvent);
  $$NostrRelayTableTableManager get nostrRelay =>
      $$NostrRelayTableTableManager(_db, _db.nostrRelay);
  $$RelayEventLinksTableTableManager get relayEventLinks =>
      $$RelayEventLinksTableTableManager(_db, _db.relayEventLinks);
}
