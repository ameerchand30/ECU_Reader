part of 'ecu_bloc.dart';
@freezed
class ECUEvent with _$ECUEvent {
  const factory ECUEvent.readErrors() = _ReadErrors;
  const factory ECUEvent.clearErrors() = _ClearErrors;
}