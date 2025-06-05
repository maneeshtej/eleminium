// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlaylistCollection on Isar {
  IsarCollection<Playlist> get playlists => this.collection();
}

const PlaylistSchema = CollectionSchema(
  name: r'Playlist',
  id: 4190497698144499986,
  properties: {
    r'playlistName': PropertySchema(
      id: 0,
      name: r'playlistName',
      type: IsarType.string,
    )
  },
  estimateSize: _playlistEstimateSize,
  serialize: _playlistSerialize,
  deserialize: _playlistDeserialize,
  deserializeProp: _playlistDeserializeProp,
  idName: r'id',
  indexes: {
    r'playlistName': IndexSchema(
      id: 2973069029140208061,
      name: r'playlistName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'playlistName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'videos': LinkSchema(
      id: -1749196620107190767,
      name: r'videos',
      target: r'Video',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _playlistGetId,
  getLinks: _playlistGetLinks,
  attach: _playlistAttach,
  version: '3.1.0+1',
);

int _playlistEstimateSize(
  Playlist object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.playlistName.length * 3;
  return bytesCount;
}

void _playlistSerialize(
  Playlist object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.playlistName);
}

Playlist _playlistDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Playlist();
  object.id = id;
  object.playlistName = reader.readString(offsets[0]);
  return object;
}

P _playlistDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _playlistGetId(Playlist object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _playlistGetLinks(Playlist object) {
  return [object.videos];
}

void _playlistAttach(IsarCollection<dynamic> col, Id id, Playlist object) {
  object.id = id;
  object.videos.attach(col, col.isar.collection<Video>(), r'videos', id);
}

extension PlaylistByIndex on IsarCollection<Playlist> {
  Future<Playlist?> getByPlaylistName(String playlistName) {
    return getByIndex(r'playlistName', [playlistName]);
  }

  Playlist? getByPlaylistNameSync(String playlistName) {
    return getByIndexSync(r'playlistName', [playlistName]);
  }

  Future<bool> deleteByPlaylistName(String playlistName) {
    return deleteByIndex(r'playlistName', [playlistName]);
  }

  bool deleteByPlaylistNameSync(String playlistName) {
    return deleteByIndexSync(r'playlistName', [playlistName]);
  }

  Future<List<Playlist?>> getAllByPlaylistName(
      List<String> playlistNameValues) {
    final values = playlistNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'playlistName', values);
  }

  List<Playlist?> getAllByPlaylistNameSync(List<String> playlistNameValues) {
    final values = playlistNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'playlistName', values);
  }

  Future<int> deleteAllByPlaylistName(List<String> playlistNameValues) {
    final values = playlistNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'playlistName', values);
  }

  int deleteAllByPlaylistNameSync(List<String> playlistNameValues) {
    final values = playlistNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'playlistName', values);
  }

  Future<Id> putByPlaylistName(Playlist object) {
    return putByIndex(r'playlistName', object);
  }

  Id putByPlaylistNameSync(Playlist object, {bool saveLinks = true}) {
    return putByIndexSync(r'playlistName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPlaylistName(List<Playlist> objects) {
    return putAllByIndex(r'playlistName', objects);
  }

  List<Id> putAllByPlaylistNameSync(List<Playlist> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'playlistName', objects, saveLinks: saveLinks);
  }
}

extension PlaylistQueryWhereSort on QueryBuilder<Playlist, Playlist, QWhere> {
  QueryBuilder<Playlist, Playlist, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlaylistQueryWhere on QueryBuilder<Playlist, Playlist, QWhereClause> {
  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> idBetween(
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

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> playlistNameEqualTo(
      String playlistName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'playlistName',
        value: [playlistName],
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterWhereClause> playlistNameNotEqualTo(
      String playlistName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistName',
              lower: [],
              upper: [playlistName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistName',
              lower: [playlistName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistName',
              lower: [playlistName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistName',
              lower: [],
              upper: [playlistName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlaylistQueryFilter
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {
  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      playlistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      playlistNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'playlistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> playlistNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'playlistName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      playlistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistName',
        value: '',
      ));
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      playlistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'playlistName',
        value: '',
      ));
    });
  }
}

extension PlaylistQueryObject
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {}

extension PlaylistQueryLinks
    on QueryBuilder<Playlist, Playlist, QFilterCondition> {
  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videos(
      FilterQuery<Video> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'videos');
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videosLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'videos', length, true, length, true);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'videos', 0, true, 0, true);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'videos', 0, false, 999999, true);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'videos', 0, true, length, include);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition>
      videosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'videos', length, include, 999999, true);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterFilterCondition> videosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'videos', lower, includeLower, upper, includeUpper);
    });
  }
}

extension PlaylistQuerySortBy on QueryBuilder<Playlist, Playlist, QSortBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> sortByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }
}

extension PlaylistQuerySortThenBy
    on QueryBuilder<Playlist, Playlist, QSortThenBy> {
  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByPlaylistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.asc);
    });
  }

  QueryBuilder<Playlist, Playlist, QAfterSortBy> thenByPlaylistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistName', Sort.desc);
    });
  }
}

extension PlaylistQueryWhereDistinct
    on QueryBuilder<Playlist, Playlist, QDistinct> {
  QueryBuilder<Playlist, Playlist, QDistinct> distinctByPlaylistName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistName', caseSensitive: caseSensitive);
    });
  }
}

extension PlaylistQueryProperty
    on QueryBuilder<Playlist, Playlist, QQueryProperty> {
  QueryBuilder<Playlist, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Playlist, String, QQueryOperations> playlistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistName');
    });
  }
}
