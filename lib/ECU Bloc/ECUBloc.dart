import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/ecu_repository.dart';
import '../../domain/ecu_error.dart';

part 'ecu_event.dart';
part 'ecu_state.dart';
part 'ecu_bloc.freezed.dart';

@injectable
class ECUBloc extends Bloc<ECUEvent, ECUState> {
  final ECURepository _repository;

  ECUBloc(this._repository) : super(const ECUState.initial()) {
    on<ECUEvent>((event, emit) async {
      await event.map(
        readErrors: (_) async {
          emit(const ECUState.loading());
          try {
            final errors = await _repository.readErrors();
            emit(ECUState.loaded(errors));
          } catch (e) {
            emit(ECUState.error(e.toString()));
          }
        },
        clearErrors: (_) async {
          emit(const ECUState.loading());
          try {
            await _repository.clearErrors();
            emit(const ECUState.cleared());
          } catch (e) {
            emit(ECUState.error(e.toString()));
          }
        },
      );
    });
  }
}