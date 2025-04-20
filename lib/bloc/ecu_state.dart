part of 'ecu_bloc.dart';
@freezed
class ECUState with _$ECUState {
  const factory ECUState.initial() = _Initial;
  const factory ECUState.loading() = _Loading;
  const factory ECUState.loaded(List<ECUError> errors) = _Loaded;
  const factory ECUState.cleared() = _Cleared;
  const factory ECUState.error(String message) = _Error;
}