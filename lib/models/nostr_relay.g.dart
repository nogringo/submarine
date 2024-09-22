// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nostr_relay.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNostrRelayCollection on Isar {
  IsarCollection<NostrRelay> get nostrRelays => this.collection();
}

const NostrRelaySchema = CollectionSchema(
  name: r'NostrRelay',
  id: 162787285317052775,
  properties: {
    r'encryptedUrl': PropertySchema(
      id: 0,
      name: r'encryptedUrl',
      type: IsarType.string,
    ),
    r'pubkey': PropertySchema(
      id: 1,
      name: r'pubkey',
      type: IsarType.string,
    )
  },
  estimateSize: _nostrRelayEstimateSize,
  serialize: _nostrRelaySerialize,
  deserialize: _nostrRelayDeserialize,
  deserializeProp: _nostrRelayDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _nostrRelayGetId,
  getLinks: _nostrRelayGetLinks,
  attach: _nostrRelayAttach,
  version: '3.1.0+1',
);

int _nostrRelayEstimateSize(
  NostrRelay object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.encryptedUrl.length * 3;
  bytesCount += 3 + object.pubkey.length * 3;
  return bytesCount;
}

void _nostrRelaySerialize(
  NostrRelay object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.encryptedUrl);
  writer.writeString(offsets[1], object.pubkey);
}

NostrRelay _nostrRelayDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NostrRelay(
    reader.readString(offsets[1]),
    reader.readString(offsets[0]),
  );
  object.id = id;
  return object;
}

P _nostrRelayDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _nostrRelayGetId(NostrRelay object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _nostrRelayGetLinks(NostrRelay object) {
  return [];
}

void _nostrRelayAttach(IsarCollection<dynamic> col, Id id, NostrRelay object) {
  object.id = id;
}

extension NostrRelayQueryWhereSort
    on QueryBuilder<NostrRelay, NostrRelay, QWhere> {
  QueryBuilder<NostrRelay, NostrRelay, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NostrRelayQueryWhere
    on QueryBuilder<NostrRelay, NostrRelay, QWhereClause> {
  QueryBuilder<NostrRelay, NostrRelay, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NostrRelayQueryFilter
    on QueryBuilder<NostrRelay, NostrRelay, QFilterCondition> {
  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'encryptedUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'encryptedUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'encryptedUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'encryptedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      encryptedUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'encryptedUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pubkey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pubkey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pubkey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition> pubkeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pubkey',
        value: '',
      ));
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterFilterCondition>
      pubkeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pubkey',
        value: '',
      ));
    });
  }
}

extension NostrRelayQueryObject
    on QueryBuilder<NostrRelay, NostrRelay, QFilterCondition> {}

extension NostrRelayQueryLinks
    on QueryBuilder<NostrRelay, NostrRelay, QFilterCondition> {}

extension NostrRelayQuerySortBy
    on QueryBuilder<NostrRelay, NostrRelay, QSortBy> {
  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> sortByEncryptedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedUrl', Sort.asc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> sortByEncryptedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedUrl', Sort.desc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> sortByPubkey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubkey', Sort.asc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> sortByPubkeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubkey', Sort.desc);
    });
  }
}

extension NostrRelayQuerySortThenBy
    on QueryBuilder<NostrRelay, NostrRelay, QSortThenBy> {
  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenByEncryptedUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedUrl', Sort.asc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenByEncryptedUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'encryptedUrl', Sort.desc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenByPubkey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubkey', Sort.asc);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QAfterSortBy> thenByPubkeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pubkey', Sort.desc);
    });
  }
}

extension NostrRelayQueryWhereDistinct
    on QueryBuilder<NostrRelay, NostrRelay, QDistinct> {
  QueryBuilder<NostrRelay, NostrRelay, QDistinct> distinctByEncryptedUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'encryptedUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<NostrRelay, NostrRelay, QDistinct> distinctByPubkey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pubkey', caseSensitive: caseSensitive);
    });
  }
}

extension NostrRelayQueryProperty
    on QueryBuilder<NostrRelay, NostrRelay, QQueryProperty> {
  QueryBuilder<NostrRelay, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NostrRelay, String, QQueryOperations> encryptedUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'encryptedUrl');
    });
  }

  QueryBuilder<NostrRelay, String, QQueryOperations> pubkeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pubkey');
    });
  }
}
