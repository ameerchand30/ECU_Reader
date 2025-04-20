// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ecu_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ECUError _$ECUErrorFromJson(Map<String, dynamic> json) {
  return _ECUError.fromJson(json);
}

/// @nodoc
mixin _$ECUError {
  String get code => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get solution => throw _privateConstructorUsedError;

  /// Serializes this ECUError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ECUError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ECUErrorCopyWith<ECUError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ECUErrorCopyWith<$Res> {
  factory $ECUErrorCopyWith(ECUError value, $Res Function(ECUError) then) =
      _$ECUErrorCopyWithImpl<$Res, ECUError>;
  @useResult
  $Res call({
    String code,
    String description,
    String severity,
    DateTime timestamp,
    String? solution,
  });
}

/// @nodoc
class _$ECUErrorCopyWithImpl<$Res, $Val extends ECUError>
    implements $ECUErrorCopyWith<$Res> {
  _$ECUErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ECUError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = null,
    Object? severity = null,
    Object? timestamp = null,
    Object? solution = freezed,
  }) {
    return _then(
      _value.copyWith(
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            severity:
                null == severity
                    ? _value.severity
                    : severity // ignore: cast_nullable_to_non_nullable
                        as String,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            solution:
                freezed == solution
                    ? _value.solution
                    : solution // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ECUErrorImplCopyWith<$Res>
    implements $ECUErrorCopyWith<$Res> {
  factory _$$ECUErrorImplCopyWith(
    _$ECUErrorImpl value,
    $Res Function(_$ECUErrorImpl) then,
  ) = __$$ECUErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String code,
    String description,
    String severity,
    DateTime timestamp,
    String? solution,
  });
}

/// @nodoc
class __$$ECUErrorImplCopyWithImpl<$Res>
    extends _$ECUErrorCopyWithImpl<$Res, _$ECUErrorImpl>
    implements _$$ECUErrorImplCopyWith<$Res> {
  __$$ECUErrorImplCopyWithImpl(
    _$ECUErrorImpl _value,
    $Res Function(_$ECUErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ECUError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? description = null,
    Object? severity = null,
    Object? timestamp = null,
    Object? solution = freezed,
  }) {
    return _then(
      _$ECUErrorImpl(
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        severity:
            null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                    as String,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        solution:
            freezed == solution
                ? _value.solution
                : solution // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ECUErrorImpl implements _ECUError {
  const _$ECUErrorImpl({
    required this.code,
    required this.description,
    required this.severity,
    required this.timestamp,
    this.solution,
  });

  factory _$ECUErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ECUErrorImplFromJson(json);

  @override
  final String code;
  @override
  final String description;
  @override
  final String severity;
  @override
  final DateTime timestamp;
  @override
  final String? solution;

  @override
  String toString() {
    return 'ECUError(code: $code, description: $description, severity: $severity, timestamp: $timestamp, solution: $solution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ECUErrorImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.solution, solution) ||
                other.solution == solution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    code,
    description,
    severity,
    timestamp,
    solution,
  );

  /// Create a copy of ECUError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ECUErrorImplCopyWith<_$ECUErrorImpl> get copyWith =>
      __$$ECUErrorImplCopyWithImpl<_$ECUErrorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ECUErrorImplToJson(this);
  }
}

abstract class _ECUError implements ECUError {
  const factory _ECUError({
    required final String code,
    required final String description,
    required final String severity,
    required final DateTime timestamp,
    final String? solution,
  }) = _$ECUErrorImpl;

  factory _ECUError.fromJson(Map<String, dynamic> json) =
      _$ECUErrorImpl.fromJson;

  @override
  String get code;
  @override
  String get description;
  @override
  String get severity;
  @override
  DateTime get timestamp;
  @override
  String? get solution;

  /// Create a copy of ECUError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ECUErrorImplCopyWith<_$ECUErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
