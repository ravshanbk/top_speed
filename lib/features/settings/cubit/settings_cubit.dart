import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/lang.dart';
import '../../../core/services/storage_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageService _storage;

  SettingsCubit(this._storage)
      : super(SettingsState(
          isKmh: _storage.isKmh,
          lang: _storage.savedLang,
          alertThresholdMs: _storage.savedAlertThresholdMs,
        ));

  void toggleUnit() {
    final isKmh = !state.isKmh;
    _storage.saveUnit(isKmh);
    emit(state.copyWith(isKmh: isKmh));
  }

  void setLang(AppLang lang) {
    if (state.lang == lang) return;
    _storage.saveLang(lang);
    emit(state.copyWith(lang: lang));
  }

  void setAlertFromDisplay(double? displayValue) {
    double? ms;
    if (displayValue != null && displayValue > 0) {
      ms = state.isKmh ? displayValue / 3.6 : displayValue / 2.23694;
    }
    _storage.saveAlertThresholdMs(ms);
    emit(state.copyWith(alertThresholdMs: ms));
  }
}
