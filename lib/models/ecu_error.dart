import 'package:freezed_annotation/freezed_annotation.dart';

part 'ecu_error.freezed.dart';
part 'ecu_error.g.dart';

@freezed
class ECUError with _$ECUError {
  const factory ECUError({
    required String code,
    required String description,
    required String severity,
    required DateTime timestamp,
    String? solution,
  }) = _ECUError;

  factory ECUError.fromJson(Map<String, dynamic> json) => 
      _$ECUErrorFromJson(json);
}