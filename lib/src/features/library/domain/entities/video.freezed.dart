// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Video {

 int get id; String get youtubeId; String get title; String get channelName; String get thumbnailUrl; int get durationSeconds; int get lastWatchedPositionSeconds; DateTime get addedAt; DateTime? get lastPlayedAt;
/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoCopyWith<Video> get copyWith => _$VideoCopyWithImpl<Video>(this as Video, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Video&&(identical(other.id, id) || other.id == id)&&(identical(other.youtubeId, youtubeId) || other.youtubeId == youtubeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.lastWatchedPositionSeconds, lastWatchedPositionSeconds) || other.lastWatchedPositionSeconds == lastWatchedPositionSeconds)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,youtubeId,title,channelName,thumbnailUrl,durationSeconds,lastWatchedPositionSeconds,addedAt,lastPlayedAt);

@override
String toString() {
  return 'Video(id: $id, youtubeId: $youtubeId, title: $title, channelName: $channelName, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds, lastWatchedPositionSeconds: $lastWatchedPositionSeconds, addedAt: $addedAt, lastPlayedAt: $lastPlayedAt)';
}


}

/// @nodoc
abstract mixin class $VideoCopyWith<$Res>  {
  factory $VideoCopyWith(Video value, $Res Function(Video) _then) = _$VideoCopyWithImpl;
@useResult
$Res call({
 int id, String youtubeId, String title, String channelName, String thumbnailUrl, int durationSeconds, int lastWatchedPositionSeconds, DateTime addedAt, DateTime? lastPlayedAt
});




}
/// @nodoc
class _$VideoCopyWithImpl<$Res>
    implements $VideoCopyWith<$Res> {
  _$VideoCopyWithImpl(this._self, this._then);

  final Video _self;
  final $Res Function(Video) _then;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? youtubeId = null,Object? title = null,Object? channelName = null,Object? thumbnailUrl = null,Object? durationSeconds = null,Object? lastWatchedPositionSeconds = null,Object? addedAt = null,Object? lastPlayedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,youtubeId: null == youtubeId ? _self.youtubeId : youtubeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,lastWatchedPositionSeconds: null == lastWatchedPositionSeconds ? _self.lastWatchedPositionSeconds : lastWatchedPositionSeconds // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Video].
extension VideoPatterns on Video {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Video value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Video value)  $default,){
final _that = this;
switch (_that) {
case _Video():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Video value)?  $default,){
final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String youtubeId,  String title,  String channelName,  String thumbnailUrl,  int durationSeconds,  int lastWatchedPositionSeconds,  DateTime addedAt,  DateTime? lastPlayedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that.id,_that.youtubeId,_that.title,_that.channelName,_that.thumbnailUrl,_that.durationSeconds,_that.lastWatchedPositionSeconds,_that.addedAt,_that.lastPlayedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String youtubeId,  String title,  String channelName,  String thumbnailUrl,  int durationSeconds,  int lastWatchedPositionSeconds,  DateTime addedAt,  DateTime? lastPlayedAt)  $default,) {final _that = this;
switch (_that) {
case _Video():
return $default(_that.id,_that.youtubeId,_that.title,_that.channelName,_that.thumbnailUrl,_that.durationSeconds,_that.lastWatchedPositionSeconds,_that.addedAt,_that.lastPlayedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String youtubeId,  String title,  String channelName,  String thumbnailUrl,  int durationSeconds,  int lastWatchedPositionSeconds,  DateTime addedAt,  DateTime? lastPlayedAt)?  $default,) {final _that = this;
switch (_that) {
case _Video() when $default != null:
return $default(_that.id,_that.youtubeId,_that.title,_that.channelName,_that.thumbnailUrl,_that.durationSeconds,_that.lastWatchedPositionSeconds,_that.addedAt,_that.lastPlayedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Video extends Video {
  const _Video({required this.id, required this.youtubeId, required this.title, required this.channelName, required this.thumbnailUrl, required this.durationSeconds, required this.lastWatchedPositionSeconds, required this.addedAt, this.lastPlayedAt}): super._();
  

@override final  int id;
@override final  String youtubeId;
@override final  String title;
@override final  String channelName;
@override final  String thumbnailUrl;
@override final  int durationSeconds;
@override final  int lastWatchedPositionSeconds;
@override final  DateTime addedAt;
@override final  DateTime? lastPlayedAt;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoCopyWith<_Video> get copyWith => __$VideoCopyWithImpl<_Video>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Video&&(identical(other.id, id) || other.id == id)&&(identical(other.youtubeId, youtubeId) || other.youtubeId == youtubeId)&&(identical(other.title, title) || other.title == title)&&(identical(other.channelName, channelName) || other.channelName == channelName)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.lastWatchedPositionSeconds, lastWatchedPositionSeconds) || other.lastWatchedPositionSeconds == lastWatchedPositionSeconds)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.lastPlayedAt, lastPlayedAt) || other.lastPlayedAt == lastPlayedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,youtubeId,title,channelName,thumbnailUrl,durationSeconds,lastWatchedPositionSeconds,addedAt,lastPlayedAt);

@override
String toString() {
  return 'Video(id: $id, youtubeId: $youtubeId, title: $title, channelName: $channelName, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds, lastWatchedPositionSeconds: $lastWatchedPositionSeconds, addedAt: $addedAt, lastPlayedAt: $lastPlayedAt)';
}


}

/// @nodoc
abstract mixin class _$VideoCopyWith<$Res> implements $VideoCopyWith<$Res> {
  factory _$VideoCopyWith(_Video value, $Res Function(_Video) _then) = __$VideoCopyWithImpl;
@override @useResult
$Res call({
 int id, String youtubeId, String title, String channelName, String thumbnailUrl, int durationSeconds, int lastWatchedPositionSeconds, DateTime addedAt, DateTime? lastPlayedAt
});




}
/// @nodoc
class __$VideoCopyWithImpl<$Res>
    implements _$VideoCopyWith<$Res> {
  __$VideoCopyWithImpl(this._self, this._then);

  final _Video _self;
  final $Res Function(_Video) _then;

/// Create a copy of Video
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? youtubeId = null,Object? title = null,Object? channelName = null,Object? thumbnailUrl = null,Object? durationSeconds = null,Object? lastWatchedPositionSeconds = null,Object? addedAt = null,Object? lastPlayedAt = freezed,}) {
  return _then(_Video(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,youtubeId: null == youtubeId ? _self.youtubeId : youtubeId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,channelName: null == channelName ? _self.channelName : channelName // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,durationSeconds: null == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int,lastWatchedPositionSeconds: null == lastWatchedPositionSeconds ? _self.lastWatchedPositionSeconds : lastWatchedPositionSeconds // ignore: cast_nullable_to_non_nullable
as int,addedAt: null == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastPlayedAt: freezed == lastPlayedAt ? _self.lastPlayedAt : lastPlayedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
