// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'core_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get fullName => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  List<String> get favoriteVenueIds => throw _privateConstructorUsedError;
  List<String> get preferredCategories => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String email,
      String? fullName,
      UserRole role,
      List<String> favoriteVenueIds,
      List<String> preferredCategories});
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? role = null,
    Object? favoriteVenueIds = null,
    Object? preferredCategories = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      favoriteVenueIds: null == favoriteVenueIds
          ? _value.favoriteVenueIds
          : favoriteVenueIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredCategories: null == preferredCategories
          ? _value.preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String email,
      String? fullName,
      UserRole role,
      List<String> favoriteVenueIds,
      List<String> preferredCategories});
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? email = null,
    Object? fullName = freezed,
    Object? role = null,
    Object? favoriteVenueIds = null,
    Object? preferredCategories = null,
  }) {
    return _then(_$ProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: freezed == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      favoriteVenueIds: null == favoriteVenueIds
          ? _value._favoriteVenueIds
          : favoriteVenueIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredCategories: null == preferredCategories
          ? _value._preferredCategories
          : preferredCategories // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.email,
      this.fullName,
      this.role = UserRole.user,
      final List<String> favoriteVenueIds = const [],
      final List<String> preferredCategories = const []})
      : _favoriteVenueIds = favoriteVenueIds,
        _preferredCategories = preferredCategories;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String email;
  @override
  final String? fullName;
  @override
  @JsonKey()
  final UserRole role;
  final List<String> _favoriteVenueIds;
  @override
  @JsonKey()
  List<String> get favoriteVenueIds {
    if (_favoriteVenueIds is EqualUnmodifiableListView)
      return _favoriteVenueIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteVenueIds);
  }

  final List<String> _preferredCategories;
  @override
  @JsonKey()
  List<String> get preferredCategories {
    if (_preferredCategories is EqualUnmodifiableListView)
      return _preferredCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredCategories);
  }

  @override
  String toString() {
    return 'Profile(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, email: $email, fullName: $fullName, role: $role, favoriteVenueIds: $favoriteVenueIds, preferredCategories: $preferredCategories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.role, role) || other.role == role) &&
            const DeepCollectionEquality()
                .equals(other._favoriteVenueIds, _favoriteVenueIds) &&
            const DeepCollectionEquality()
                .equals(other._preferredCategories, _preferredCategories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      email,
      fullName,
      role,
      const DeepCollectionEquality().hash(_favoriteVenueIds),
      const DeepCollectionEquality().hash(_preferredCategories));

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile implements Profile {
  const factory _Profile(
      {required final String id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String email,
      final String? fullName,
      final UserRole role,
      final List<String> favoriteVenueIds,
      final List<String> preferredCategories}) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get email;
  @override
  String? get fullName;
  @override
  UserRole get role;
  @override
  List<String> get favoriteVenueIds;
  @override
  List<String> get preferredCategories;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Venue _$VenueFromJson(Map<String, dynamic> json) {
  return _Venue.fromJson(json);
}

/// @nodoc
mixin _$Venue {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  VenueType get venueType => throw _privateConstructorUsedError;
  String? get address =>
      throw _privateConstructorUsedError; // PostGIS point as lat/lng
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  String? get websiteUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get partnerNotes => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Venue to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VenueCopyWith<Venue> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VenueCopyWith<$Res> {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) then) =
      _$VenueCopyWithImpl<$Res, Venue>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String? ownerId,
      String name,
      VenueType venueType,
      String? address,
      double? latitude,
      double? longitude,
      String? websiteUrl,
      String? imageUrl,
      String? partnerNotes,
      bool isActive});
}

/// @nodoc
class _$VenueCopyWithImpl<$Res, $Val extends Venue>
    implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = freezed,
    Object? name = null,
    Object? venueType = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? websiteUrl = freezed,
    Object? imageUrl = freezed,
    Object? partnerNotes = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      venueType: null == venueType
          ? _value.venueType
          : venueType // ignore: cast_nullable_to_non_nullable
              as VenueType,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerNotes: freezed == partnerNotes
          ? _value.partnerNotes
          : partnerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VenueImplCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$$VenueImplCopyWith(
          _$VenueImpl value, $Res Function(_$VenueImpl) then) =
      __$$VenueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String? ownerId,
      String name,
      VenueType venueType,
      String? address,
      double? latitude,
      double? longitude,
      String? websiteUrl,
      String? imageUrl,
      String? partnerNotes,
      bool isActive});
}

/// @nodoc
class __$$VenueImplCopyWithImpl<$Res>
    extends _$VenueCopyWithImpl<$Res, _$VenueImpl>
    implements _$$VenueImplCopyWith<$Res> {
  __$$VenueImplCopyWithImpl(
      _$VenueImpl _value, $Res Function(_$VenueImpl) _then)
      : super(_value, _then);

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? ownerId = freezed,
    Object? name = null,
    Object? venueType = null,
    Object? address = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? websiteUrl = freezed,
    Object? imageUrl = freezed,
    Object? partnerNotes = freezed,
    Object? isActive = null,
  }) {
    return _then(_$VenueImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      venueType: null == venueType
          ? _value.venueType
          : venueType // ignore: cast_nullable_to_non_nullable
              as VenueType,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      websiteUrl: freezed == websiteUrl
          ? _value.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      partnerNotes: freezed == partnerNotes
          ? _value.partnerNotes
          : partnerNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VenueImpl implements _Venue {
  const _$VenueImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.ownerId,
      required this.name,
      required this.venueType,
      this.address,
      this.latitude,
      this.longitude,
      this.websiteUrl,
      this.imageUrl,
      this.partnerNotes,
      this.isActive = true});

  factory _$VenueImpl.fromJson(Map<String, dynamic> json) =>
      _$$VenueImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? ownerId;
  @override
  final String name;
  @override
  final VenueType venueType;
  @override
  final String? address;
// PostGIS point as lat/lng
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? websiteUrl;
  @override
  final String? imageUrl;
  @override
  final String? partnerNotes;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Venue(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, ownerId: $ownerId, name: $name, venueType: $venueType, address: $address, latitude: $latitude, longitude: $longitude, websiteUrl: $websiteUrl, imageUrl: $imageUrl, partnerNotes: $partnerNotes, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VenueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.venueType, venueType) ||
                other.venueType == venueType) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.partnerNotes, partnerNotes) ||
                other.partnerNotes == partnerNotes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      ownerId,
      name,
      venueType,
      address,
      latitude,
      longitude,
      websiteUrl,
      imageUrl,
      partnerNotes,
      isActive);

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VenueImplCopyWith<_$VenueImpl> get copyWith =>
      __$$VenueImplCopyWithImpl<_$VenueImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VenueImplToJson(
      this,
    );
  }
}

abstract class _Venue implements Venue {
  const factory _Venue(
      {required final String id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? ownerId,
      required final String name,
      required final VenueType venueType,
      final String? address,
      final double? latitude,
      final double? longitude,
      final String? websiteUrl,
      final String? imageUrl,
      final String? partnerNotes,
      final bool isActive}) = _$VenueImpl;

  factory _Venue.fromJson(Map<String, dynamic> json) = _$VenueImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get ownerId;
  @override
  String get name;
  @override
  VenueType get venueType;
  @override
  String? get address; // PostGIS point as lat/lng
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  String? get websiteUrl;
  @override
  String? get imageUrl;
  @override
  String? get partnerNotes;
  @override
  bool get isActive;

  /// Create a copy of Venue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VenueImplCopyWith<_$VenueImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  EventCategory get category => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int? get durationMinutes =>
      throw _privateConstructorUsedError; // External IDs (TMDB, Spotify, Eventbrite, etc.)
  Map<String, dynamic> get externalIds =>
      throw _privateConstructorUsedError; // Static metadata (genres, directors, release year, etc.)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      EventCategory category,
      String title,
      String? description,
      String? imageUrl,
      int? durationMinutes,
      Map<String, dynamic> externalIds,
      Map<String, dynamic> metadata,
      EventStatus status});
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? durationMinutes = freezed,
    Object? externalIds = null,
    Object? metadata = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      externalIds: null == externalIds
          ? _value.externalIds
          : externalIds // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      EventCategory category,
      String title,
      String? description,
      String? imageUrl,
      int? durationMinutes,
      Map<String, dynamic> externalIds,
      Map<String, dynamic> metadata,
      EventStatus status});
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = null,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? durationMinutes = freezed,
    Object? externalIds = null,
    Object? metadata = null,
    Object? status = null,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      externalIds: null == externalIds
          ? _value._externalIds
          : externalIds // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.category,
      required this.title,
      this.description,
      this.imageUrl,
      this.durationMinutes,
      final Map<String, dynamic> externalIds = const {},
      final Map<String, dynamic> metadata = const {},
      this.status = EventStatus.published})
      : _externalIds = externalIds,
        _metadata = metadata;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final EventCategory category;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final int? durationMinutes;
// External IDs (TMDB, Spotify, Eventbrite, etc.)
  final Map<String, dynamic> _externalIds;
// External IDs (TMDB, Spotify, Eventbrite, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get externalIds {
    if (_externalIds is EqualUnmodifiableMapView) return _externalIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_externalIds);
  }

// Static metadata (genres, directors, release year, etc.)
  final Map<String, dynamic> _metadata;
// Static metadata (genres, directors, release year, etc.)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @JsonKey()
  final EventStatus status;

  @override
  String toString() {
    return 'Event(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, title: $title, description: $description, imageUrl: $imageUrl, durationMinutes: $durationMinutes, externalIds: $externalIds, metadata: $metadata, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality()
                .equals(other._externalIds, _externalIds) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      category,
      title,
      description,
      imageUrl,
      durationMinutes,
      const DeepCollectionEquality().hash(_externalIds),
      const DeepCollectionEquality().hash(_metadata),
      status);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event implements Event {
  const factory _Event(
      {required final String id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final EventCategory category,
      required final String title,
      final String? description,
      final String? imageUrl,
      final int? durationMinutes,
      final Map<String, dynamic> externalIds,
      final Map<String, dynamic> metadata,
      final EventStatus status}) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  EventCategory get category;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  int? get durationMinutes; // External IDs (TMDB, Spotify, Eventbrite, etc.)
  @override
  Map<String, dynamic>
      get externalIds; // Static metadata (genres, directors, release year, etc.)
  @override
  Map<String, dynamic> get metadata;
  @override
  EventStatus get status;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Showtime _$ShowtimeFromJson(Map<String, dynamic> json) {
  return _Showtime.fromJson(json);
}

/// @nodoc
mixin _$Showtime {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get venueId => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  int? get capacity => throw _privateConstructorUsedError;
  int get ticketsSold =>
      throw _privateConstructorUsedError; // Flexible attributes: language, subtitles, format (3D/IMAX), age restrictions
  Map<String, dynamic> get attributes => throw _privateConstructorUsedError;
  String get bookingUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  EventStatus get status => throw _privateConstructorUsedError;

  /// Serializes this Showtime to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Showtime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShowtimeCopyWith<Showtime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShowtimeCopyWith<$Res> {
  factory $ShowtimeCopyWith(Showtime value, $Res Function(Showtime) then) =
      _$ShowtimeCopyWithImpl<$Res, Showtime>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String venueId,
      String eventId,
      DateTime startTime,
      DateTime? endTime,
      double? price,
      int? capacity,
      int ticketsSold,
      Map<String, dynamic> attributes,
      String bookingUrl,
      String? imageUrl,
      EventStatus status});
}

/// @nodoc
class _$ShowtimeCopyWithImpl<$Res, $Val extends Showtime>
    implements $ShowtimeCopyWith<$Res> {
  _$ShowtimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Showtime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? venueId = null,
    Object? eventId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? price = freezed,
    Object? capacity = freezed,
    Object? ticketsSold = null,
    Object? attributes = null,
    Object? bookingUrl = null,
    Object? imageUrl = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      ticketsSold: null == ticketsSold
          ? _value.ticketsSold
          : ticketsSold // ignore: cast_nullable_to_non_nullable
              as int,
      attributes: null == attributes
          ? _value.attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      bookingUrl: null == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShowtimeImplCopyWith<$Res>
    implements $ShowtimeCopyWith<$Res> {
  factory _$$ShowtimeImplCopyWith(
          _$ShowtimeImpl value, $Res Function(_$ShowtimeImpl) then) =
      __$$ShowtimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      DateTime updatedAt,
      String venueId,
      String eventId,
      DateTime startTime,
      DateTime? endTime,
      double? price,
      int? capacity,
      int ticketsSold,
      Map<String, dynamic> attributes,
      String bookingUrl,
      String? imageUrl,
      EventStatus status});
}

/// @nodoc
class __$$ShowtimeImplCopyWithImpl<$Res>
    extends _$ShowtimeCopyWithImpl<$Res, _$ShowtimeImpl>
    implements _$$ShowtimeImplCopyWith<$Res> {
  __$$ShowtimeImplCopyWithImpl(
      _$ShowtimeImpl _value, $Res Function(_$ShowtimeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Showtime
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? venueId = null,
    Object? eventId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? price = freezed,
    Object? capacity = freezed,
    Object? ticketsSold = null,
    Object? attributes = null,
    Object? bookingUrl = null,
    Object? imageUrl = freezed,
    Object? status = null,
  }) {
    return _then(_$ShowtimeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      capacity: freezed == capacity
          ? _value.capacity
          : capacity // ignore: cast_nullable_to_non_nullable
              as int?,
      ticketsSold: null == ticketsSold
          ? _value.ticketsSold
          : ticketsSold // ignore: cast_nullable_to_non_nullable
              as int,
      attributes: null == attributes
          ? _value._attributes
          : attributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      bookingUrl: null == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as EventStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShowtimeImpl implements _Showtime {
  const _$ShowtimeImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.venueId,
      required this.eventId,
      required this.startTime,
      this.endTime,
      this.price,
      this.capacity,
      this.ticketsSold = 0,
      final Map<String, dynamic> attributes = const {},
      required this.bookingUrl,
      this.imageUrl,
      this.status = EventStatus.published})
      : _attributes = attributes;

  factory _$ShowtimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShowtimeImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String venueId;
  @override
  final String eventId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final double? price;
  @override
  final int? capacity;
  @override
  @JsonKey()
  final int ticketsSold;
// Flexible attributes: language, subtitles, format (3D/IMAX), age restrictions
  final Map<String, dynamic> _attributes;
// Flexible attributes: language, subtitles, format (3D/IMAX), age restrictions
  @override
  @JsonKey()
  Map<String, dynamic> get attributes {
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_attributes);
  }

  @override
  final String bookingUrl;
  @override
  final String? imageUrl;
  @override
  @JsonKey()
  final EventStatus status;

  @override
  String toString() {
    return 'Showtime(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, venueId: $venueId, eventId: $eventId, startTime: $startTime, endTime: $endTime, price: $price, capacity: $capacity, ticketsSold: $ticketsSold, attributes: $attributes, bookingUrl: $bookingUrl, imageUrl: $imageUrl, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShowtimeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.capacity, capacity) ||
                other.capacity == capacity) &&
            (identical(other.ticketsSold, ticketsSold) ||
                other.ticketsSold == ticketsSold) &&
            const DeepCollectionEquality()
                .equals(other._attributes, _attributes) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      updatedAt,
      venueId,
      eventId,
      startTime,
      endTime,
      price,
      capacity,
      ticketsSold,
      const DeepCollectionEquality().hash(_attributes),
      bookingUrl,
      imageUrl,
      status);

  /// Create a copy of Showtime
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShowtimeImplCopyWith<_$ShowtimeImpl> get copyWith =>
      __$$ShowtimeImplCopyWithImpl<_$ShowtimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShowtimeImplToJson(
      this,
    );
  }
}

abstract class _Showtime implements Showtime {
  const factory _Showtime(
      {required final String id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String venueId,
      required final String eventId,
      required final DateTime startTime,
      final DateTime? endTime,
      final double? price,
      final int? capacity,
      final int ticketsSold,
      final Map<String, dynamic> attributes,
      required final String bookingUrl,
      final String? imageUrl,
      final EventStatus status}) = _$ShowtimeImpl;

  factory _Showtime.fromJson(Map<String, dynamic> json) =
      _$ShowtimeImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get venueId;
  @override
  String get eventId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  double? get price;
  @override
  int? get capacity;
  @override
  int get ticketsSold; // Flexible attributes: language, subtitles, format (3D/IMAX), age restrictions
  @override
  Map<String, dynamic> get attributes;
  @override
  String get bookingUrl;
  @override
  String? get imageUrl;
  @override
  EventStatus get status;

  /// Create a copy of Showtime
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShowtimeImplCopyWith<_$ShowtimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OutboundClick _$OutboundClickFromJson(Map<String, dynamic> json) {
  return _OutboundClick.fromJson(json);
}

/// @nodoc
mixin _$OutboundClick {
  String get id => throw _privateConstructorUsedError;
  DateTime get clickedAt => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get showtimeId => throw _privateConstructorUsedError;

  /// Serializes this OutboundClick to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OutboundClick
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OutboundClickCopyWith<OutboundClick> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OutboundClickCopyWith<$Res> {
  factory $OutboundClickCopyWith(
          OutboundClick value, $Res Function(OutboundClick) then) =
      _$OutboundClickCopyWithImpl<$Res, OutboundClick>;
  @useResult
  $Res call(
      {String id, DateTime clickedAt, String? userId, String? showtimeId});
}

/// @nodoc
class _$OutboundClickCopyWithImpl<$Res, $Val extends OutboundClick>
    implements $OutboundClickCopyWith<$Res> {
  _$OutboundClickCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OutboundClick
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clickedAt = null,
    Object? userId = freezed,
    Object? showtimeId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clickedAt: null == clickedAt
          ? _value.clickedAt
          : clickedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      showtimeId: freezed == showtimeId
          ? _value.showtimeId
          : showtimeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OutboundClickImplCopyWith<$Res>
    implements $OutboundClickCopyWith<$Res> {
  factory _$$OutboundClickImplCopyWith(
          _$OutboundClickImpl value, $Res Function(_$OutboundClickImpl) then) =
      __$$OutboundClickImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id, DateTime clickedAt, String? userId, String? showtimeId});
}

/// @nodoc
class __$$OutboundClickImplCopyWithImpl<$Res>
    extends _$OutboundClickCopyWithImpl<$Res, _$OutboundClickImpl>
    implements _$$OutboundClickImplCopyWith<$Res> {
  __$$OutboundClickImplCopyWithImpl(
      _$OutboundClickImpl _value, $Res Function(_$OutboundClickImpl) _then)
      : super(_value, _then);

  /// Create a copy of OutboundClick
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clickedAt = null,
    Object? userId = freezed,
    Object? showtimeId = freezed,
  }) {
    return _then(_$OutboundClickImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clickedAt: null == clickedAt
          ? _value.clickedAt
          : clickedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      showtimeId: freezed == showtimeId
          ? _value.showtimeId
          : showtimeId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OutboundClickImpl implements _OutboundClick {
  const _$OutboundClickImpl(
      {required this.id,
      required this.clickedAt,
      this.userId,
      this.showtimeId});

  factory _$OutboundClickImpl.fromJson(Map<String, dynamic> json) =>
      _$$OutboundClickImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime clickedAt;
  @override
  final String? userId;
  @override
  final String? showtimeId;

  @override
  String toString() {
    return 'OutboundClick(id: $id, clickedAt: $clickedAt, userId: $userId, showtimeId: $showtimeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OutboundClickImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clickedAt, clickedAt) ||
                other.clickedAt == clickedAt) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.showtimeId, showtimeId) ||
                other.showtimeId == showtimeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, clickedAt, userId, showtimeId);

  /// Create a copy of OutboundClick
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OutboundClickImplCopyWith<_$OutboundClickImpl> get copyWith =>
      __$$OutboundClickImplCopyWithImpl<_$OutboundClickImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OutboundClickImplToJson(
      this,
    );
  }
}

abstract class _OutboundClick implements OutboundClick {
  const factory _OutboundClick(
      {required final String id,
      required final DateTime clickedAt,
      final String? userId,
      final String? showtimeId}) = _$OutboundClickImpl;

  factory _OutboundClick.fromJson(Map<String, dynamic> json) =
      _$OutboundClickImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get clickedAt;
  @override
  String? get userId;
  @override
  String? get showtimeId;

  /// Create a copy of OutboundClick
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OutboundClickImplCopyWith<_$OutboundClickImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrganizerInvite _$OrganizerInviteFromJson(Map<String, dynamic> json) {
  return _OrganizerInvite.fromJson(json);
}

/// @nodoc
mixin _$OrganizerInvite {
  String get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get venueId => throw _privateConstructorUsedError;
  String get invitedBy => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  DateTime? get acceptedAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this OrganizerInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrganizerInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrganizerInviteCopyWith<OrganizerInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrganizerInviteCopyWith<$Res> {
  factory $OrganizerInviteCopyWith(
          OrganizerInvite value, $Res Function(OrganizerInvite) then) =
      _$OrganizerInviteCopyWithImpl<$Res, OrganizerInvite>;
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String venueId,
      String invitedBy,
      String email,
      String role,
      String token,
      DateTime? acceptedAt,
      DateTime? expiresAt});
}

/// @nodoc
class _$OrganizerInviteCopyWithImpl<$Res, $Val extends OrganizerInvite>
    implements $OrganizerInviteCopyWith<$Res> {
  _$OrganizerInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrganizerInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? venueId = null,
    Object? invitedBy = null,
    Object? email = null,
    Object? role = null,
    Object? token = null,
    Object? acceptedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      invitedBy: null == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrganizerInviteImplCopyWith<$Res>
    implements $OrganizerInviteCopyWith<$Res> {
  factory _$$OrganizerInviteImplCopyWith(_$OrganizerInviteImpl value,
          $Res Function(_$OrganizerInviteImpl) then) =
      __$$OrganizerInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      DateTime createdAt,
      String venueId,
      String invitedBy,
      String email,
      String role,
      String token,
      DateTime? acceptedAt,
      DateTime? expiresAt});
}

/// @nodoc
class __$$OrganizerInviteImplCopyWithImpl<$Res>
    extends _$OrganizerInviteCopyWithImpl<$Res, _$OrganizerInviteImpl>
    implements _$$OrganizerInviteImplCopyWith<$Res> {
  __$$OrganizerInviteImplCopyWithImpl(
      _$OrganizerInviteImpl _value, $Res Function(_$OrganizerInviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrganizerInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? venueId = null,
    Object? invitedBy = null,
    Object? email = null,
    Object? role = null,
    Object? token = null,
    Object? acceptedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$OrganizerInviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      invitedBy: null == invitedBy
          ? _value.invitedBy
          : invitedBy // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      acceptedAt: freezed == acceptedAt
          ? _value.acceptedAt
          : acceptedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrganizerInviteImpl implements _OrganizerInvite {
  const _$OrganizerInviteImpl(
      {required this.id,
      required this.createdAt,
      required this.venueId,
      required this.invitedBy,
      required this.email,
      this.role = 'editor',
      required this.token,
      this.acceptedAt,
      this.expiresAt});

  factory _$OrganizerInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrganizerInviteImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime createdAt;
  @override
  final String venueId;
  @override
  final String invitedBy;
  @override
  final String email;
  @override
  @JsonKey()
  final String role;
  @override
  final String token;
  @override
  final DateTime? acceptedAt;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'OrganizerInvite(id: $id, createdAt: $createdAt, venueId: $venueId, invitedBy: $invitedBy, email: $email, role: $role, token: $token, acceptedAt: $acceptedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrganizerInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.invitedBy, invitedBy) ||
                other.invitedBy == invitedBy) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.acceptedAt, acceptedAt) ||
                other.acceptedAt == acceptedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, venueId,
      invitedBy, email, role, token, acceptedAt, expiresAt);

  /// Create a copy of OrganizerInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrganizerInviteImplCopyWith<_$OrganizerInviteImpl> get copyWith =>
      __$$OrganizerInviteImplCopyWithImpl<_$OrganizerInviteImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrganizerInviteImplToJson(
      this,
    );
  }
}

abstract class _OrganizerInvite implements OrganizerInvite {
  const factory _OrganizerInvite(
      {required final String id,
      required final DateTime createdAt,
      required final String venueId,
      required final String invitedBy,
      required final String email,
      final String role,
      required final String token,
      final DateTime? acceptedAt,
      final DateTime? expiresAt}) = _$OrganizerInviteImpl;

  factory _OrganizerInvite.fromJson(Map<String, dynamic> json) =
      _$OrganizerInviteImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get createdAt;
  @override
  String get venueId;
  @override
  String get invitedBy;
  @override
  String get email;
  @override
  String get role;
  @override
  String get token;
  @override
  DateTime? get acceptedAt;
  @override
  DateTime? get expiresAt;

  /// Create a copy of OrganizerInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrganizerInviteImplCopyWith<_$OrganizerInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Listing _$ListingFromJson(Map<String, dynamic> json) {
  return _Listing.fromJson(json);
}

/// @nodoc
mixin _$Listing {
  String get showtimeId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  double? get price => throw _privateConstructorUsedError;
  Map<String, dynamic> get showtimeAttributes =>
      throw _privateConstructorUsedError;
  String get bookingUrl => throw _privateConstructorUsedError;
  String? get showtimeImageUrl => throw _privateConstructorUsedError;
  String get eventId => throw _privateConstructorUsedError;
  EventCategory get category => throw _privateConstructorUsedError;
  String get eventTitle => throw _privateConstructorUsedError;
  String? get eventDescription => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  Map<String, dynamic> get eventMetadata => throw _privateConstructorUsedError;
  EventStatus? get eventStatus => throw _privateConstructorUsedError;
  String get venueId => throw _privateConstructorUsedError;
  String get venueName => throw _privateConstructorUsedError;
  VenueType get venueType => throw _privateConstructorUsedError;
  String? get venueAddress => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  String? get venueImageUrl => throw _privateConstructorUsedError;

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingCopyWith<Listing> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingCopyWith<$Res> {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) then) =
      _$ListingCopyWithImpl<$Res, Listing>;
  @useResult
  $Res call(
      {String showtimeId,
      DateTime startTime,
      DateTime? endTime,
      double? price,
      Map<String, dynamic> showtimeAttributes,
      String bookingUrl,
      String? showtimeImageUrl,
      String eventId,
      EventCategory category,
      String eventTitle,
      String? eventDescription,
      String? imageUrl,
      int? durationMinutes,
      Map<String, dynamic> eventMetadata,
      EventStatus? eventStatus,
      String venueId,
      String venueName,
      VenueType venueType,
      String? venueAddress,
      double longitude,
      double latitude,
      String? venueImageUrl});
}

/// @nodoc
class _$ListingCopyWithImpl<$Res, $Val extends Listing>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showtimeId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? price = freezed,
    Object? showtimeAttributes = null,
    Object? bookingUrl = null,
    Object? showtimeImageUrl = freezed,
    Object? eventId = null,
    Object? category = null,
    Object? eventTitle = null,
    Object? eventDescription = freezed,
    Object? imageUrl = freezed,
    Object? durationMinutes = freezed,
    Object? eventMetadata = null,
    Object? eventStatus = freezed,
    Object? venueId = null,
    Object? venueName = null,
    Object? venueType = null,
    Object? venueAddress = freezed,
    Object? longitude = null,
    Object? latitude = null,
    Object? venueImageUrl = freezed,
  }) {
    return _then(_value.copyWith(
      showtimeId: null == showtimeId
          ? _value.showtimeId
          : showtimeId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      showtimeAttributes: null == showtimeAttributes
          ? _value.showtimeAttributes
          : showtimeAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      bookingUrl: null == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String,
      showtimeImageUrl: freezed == showtimeImageUrl
          ? _value.showtimeImageUrl
          : showtimeImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
      eventDescription: freezed == eventDescription
          ? _value.eventDescription
          : eventDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      eventMetadata: null == eventMetadata
          ? _value.eventMetadata
          : eventMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      eventStatus: freezed == eventStatus
          ? _value.eventStatus
          : eventStatus // ignore: cast_nullable_to_non_nullable
              as EventStatus?,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: null == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String,
      venueType: null == venueType
          ? _value.venueType
          : venueType // ignore: cast_nullable_to_non_nullable
              as VenueType,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      venueImageUrl: freezed == venueImageUrl
          ? _value.venueImageUrl
          : venueImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingImplCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$$ListingImplCopyWith(
          _$ListingImpl value, $Res Function(_$ListingImpl) then) =
      __$$ListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String showtimeId,
      DateTime startTime,
      DateTime? endTime,
      double? price,
      Map<String, dynamic> showtimeAttributes,
      String bookingUrl,
      String? showtimeImageUrl,
      String eventId,
      EventCategory category,
      String eventTitle,
      String? eventDescription,
      String? imageUrl,
      int? durationMinutes,
      Map<String, dynamic> eventMetadata,
      EventStatus? eventStatus,
      String venueId,
      String venueName,
      VenueType venueType,
      String? venueAddress,
      double longitude,
      double latitude,
      String? venueImageUrl});
}

/// @nodoc
class __$$ListingImplCopyWithImpl<$Res>
    extends _$ListingCopyWithImpl<$Res, _$ListingImpl>
    implements _$$ListingImplCopyWith<$Res> {
  __$$ListingImplCopyWithImpl(
      _$ListingImpl _value, $Res Function(_$ListingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showtimeId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? price = freezed,
    Object? showtimeAttributes = null,
    Object? bookingUrl = null,
    Object? showtimeImageUrl = freezed,
    Object? eventId = null,
    Object? category = null,
    Object? eventTitle = null,
    Object? eventDescription = freezed,
    Object? imageUrl = freezed,
    Object? durationMinutes = freezed,
    Object? eventMetadata = null,
    Object? eventStatus = freezed,
    Object? venueId = null,
    Object? venueName = null,
    Object? venueType = null,
    Object? venueAddress = freezed,
    Object? longitude = null,
    Object? latitude = null,
    Object? venueImageUrl = freezed,
  }) {
    return _then(_$ListingImpl(
      showtimeId: null == showtimeId
          ? _value.showtimeId
          : showtimeId // ignore: cast_nullable_to_non_nullable
              as String,
      startTime: null == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double?,
      showtimeAttributes: null == showtimeAttributes
          ? _value._showtimeAttributes
          : showtimeAttributes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      bookingUrl: null == bookingUrl
          ? _value.bookingUrl
          : bookingUrl // ignore: cast_nullable_to_non_nullable
              as String,
      showtimeImageUrl: freezed == showtimeImageUrl
          ? _value.showtimeImageUrl
          : showtimeImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EventCategory,
      eventTitle: null == eventTitle
          ? _value.eventTitle
          : eventTitle // ignore: cast_nullable_to_non_nullable
              as String,
      eventDescription: freezed == eventDescription
          ? _value.eventDescription
          : eventDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      eventMetadata: null == eventMetadata
          ? _value._eventMetadata
          : eventMetadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      eventStatus: freezed == eventStatus
          ? _value.eventStatus
          : eventStatus // ignore: cast_nullable_to_non_nullable
              as EventStatus?,
      venueId: null == venueId
          ? _value.venueId
          : venueId // ignore: cast_nullable_to_non_nullable
              as String,
      venueName: null == venueName
          ? _value.venueName
          : venueName // ignore: cast_nullable_to_non_nullable
              as String,
      venueType: null == venueType
          ? _value.venueType
          : venueType // ignore: cast_nullable_to_non_nullable
              as VenueType,
      venueAddress: freezed == venueAddress
          ? _value.venueAddress
          : venueAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      venueImageUrl: freezed == venueImageUrl
          ? _value.venueImageUrl
          : venueImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingImpl implements _Listing {
  const _$ListingImpl(
      {required this.showtimeId,
      required this.startTime,
      this.endTime,
      this.price,
      required final Map<String, dynamic> showtimeAttributes,
      required this.bookingUrl,
      this.showtimeImageUrl,
      required this.eventId,
      required this.category,
      required this.eventTitle,
      this.eventDescription,
      this.imageUrl,
      this.durationMinutes,
      required final Map<String, dynamic> eventMetadata,
      this.eventStatus,
      required this.venueId,
      required this.venueName,
      required this.venueType,
      this.venueAddress,
      required this.longitude,
      required this.latitude,
      this.venueImageUrl})
      : _showtimeAttributes = showtimeAttributes,
        _eventMetadata = eventMetadata;

  factory _$ListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingImplFromJson(json);

  @override
  final String showtimeId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  @override
  final double? price;
  final Map<String, dynamic> _showtimeAttributes;
  @override
  Map<String, dynamic> get showtimeAttributes {
    if (_showtimeAttributes is EqualUnmodifiableMapView)
      return _showtimeAttributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_showtimeAttributes);
  }

  @override
  final String bookingUrl;
  @override
  final String? showtimeImageUrl;
  @override
  final String eventId;
  @override
  final EventCategory category;
  @override
  final String eventTitle;
  @override
  final String? eventDescription;
  @override
  final String? imageUrl;
  @override
  final int? durationMinutes;
  final Map<String, dynamic> _eventMetadata;
  @override
  Map<String, dynamic> get eventMetadata {
    if (_eventMetadata is EqualUnmodifiableMapView) return _eventMetadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_eventMetadata);
  }

  @override
  final EventStatus? eventStatus;
  @override
  final String venueId;
  @override
  final String venueName;
  @override
  final VenueType venueType;
  @override
  final String? venueAddress;
  @override
  final double longitude;
  @override
  final double latitude;
  @override
  final String? venueImageUrl;

  @override
  String toString() {
    return 'Listing(showtimeId: $showtimeId, startTime: $startTime, endTime: $endTime, price: $price, showtimeAttributes: $showtimeAttributes, bookingUrl: $bookingUrl, showtimeImageUrl: $showtimeImageUrl, eventId: $eventId, category: $category, eventTitle: $eventTitle, eventDescription: $eventDescription, imageUrl: $imageUrl, durationMinutes: $durationMinutes, eventMetadata: $eventMetadata, eventStatus: $eventStatus, venueId: $venueId, venueName: $venueName, venueType: $venueType, venueAddress: $venueAddress, longitude: $longitude, latitude: $latitude, venueImageUrl: $venueImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingImpl &&
            (identical(other.showtimeId, showtimeId) ||
                other.showtimeId == showtimeId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.price, price) || other.price == price) &&
            const DeepCollectionEquality()
                .equals(other._showtimeAttributes, _showtimeAttributes) &&
            (identical(other.bookingUrl, bookingUrl) ||
                other.bookingUrl == bookingUrl) &&
            (identical(other.showtimeImageUrl, showtimeImageUrl) ||
                other.showtimeImageUrl == showtimeImageUrl) &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.eventTitle, eventTitle) ||
                other.eventTitle == eventTitle) &&
            (identical(other.eventDescription, eventDescription) ||
                other.eventDescription == eventDescription) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality()
                .equals(other._eventMetadata, _eventMetadata) &&
            (identical(other.eventStatus, eventStatus) ||
                other.eventStatus == eventStatus) &&
            (identical(other.venueId, venueId) || other.venueId == venueId) &&
            (identical(other.venueName, venueName) ||
                other.venueName == venueName) &&
            (identical(other.venueType, venueType) ||
                other.venueType == venueType) &&
            (identical(other.venueAddress, venueAddress) ||
                other.venueAddress == venueAddress) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.venueImageUrl, venueImageUrl) ||
                other.venueImageUrl == venueImageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        showtimeId,
        startTime,
        endTime,
        price,
        const DeepCollectionEquality().hash(_showtimeAttributes),
        bookingUrl,
        showtimeImageUrl,
        eventId,
        category,
        eventTitle,
        eventDescription,
        imageUrl,
        durationMinutes,
        const DeepCollectionEquality().hash(_eventMetadata),
        eventStatus,
        venueId,
        venueName,
        venueType,
        venueAddress,
        longitude,
        latitude,
        venueImageUrl
      ]);

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      __$$ListingImplCopyWithImpl<_$ListingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingImplToJson(
      this,
    );
  }
}

abstract class _Listing implements Listing {
  const factory _Listing(
      {required final String showtimeId,
      required final DateTime startTime,
      final DateTime? endTime,
      final double? price,
      required final Map<String, dynamic> showtimeAttributes,
      required final String bookingUrl,
      final String? showtimeImageUrl,
      required final String eventId,
      required final EventCategory category,
      required final String eventTitle,
      final String? eventDescription,
      final String? imageUrl,
      final int? durationMinutes,
      required final Map<String, dynamic> eventMetadata,
      final EventStatus? eventStatus,
      required final String venueId,
      required final String venueName,
      required final VenueType venueType,
      final String? venueAddress,
      required final double longitude,
      required final double latitude,
      final String? venueImageUrl}) = _$ListingImpl;

  factory _Listing.fromJson(Map<String, dynamic> json) = _$ListingImpl.fromJson;

  @override
  String get showtimeId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  double? get price;
  @override
  Map<String, dynamic> get showtimeAttributes;
  @override
  String get bookingUrl;
  @override
  String? get showtimeImageUrl;
  @override
  String get eventId;
  @override
  EventCategory get category;
  @override
  String get eventTitle;
  @override
  String? get eventDescription;
  @override
  String? get imageUrl;
  @override
  int? get durationMinutes;
  @override
  Map<String, dynamic> get eventMetadata;
  @override
  EventStatus? get eventStatus;
  @override
  String get venueId;
  @override
  String get venueName;
  @override
  VenueType get venueType;
  @override
  String? get venueAddress;
  @override
  double get longitude;
  @override
  double get latitude;
  @override
  String? get venueImageUrl;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
