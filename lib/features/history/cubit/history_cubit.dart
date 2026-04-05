import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/storage_service.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final StorageService _storage;

  HistoryCubit(this._storage) : super(HistoryState.initial());

  void load() {
    emit(HistoryState(sessions: _storage.getSessions()));
  }

  Future<void> delete(String id) async {
    await _storage.deleteSession(id);
    load();
  }
}
