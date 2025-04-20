// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecu_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ECUErrorImpl _$$ECUErrorImplFromJson(Map<String, dynamic> json) =>
    _$ECUErrorImpl(
      code: json['code'] as String,
      description: json['description'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      solution: json['solution'] as String?,
    );

Map<String, dynamic> _$$ECUErrorImplToJson(_$ECUErrorImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'severity': instance.severity,
      'timestamp': instance.timestamp.toIso8601String(),
      'solution': instance.solution,
    };
