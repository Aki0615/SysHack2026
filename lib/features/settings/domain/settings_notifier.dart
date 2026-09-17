import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool isPocketModeEnabled;

  const SettingsState({
    this.isPocketModeEnabled = true,
  });

  SettingsState copyWith({
    bool? isPocketModeEnabled,
  }) {
    return SettingsState(
      isPocketModeEnabled: isPocketModeEnabled ?? this.isPocketModeEnabled,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  static const _pocketModeKey = 'isPocketModeEnabled';

  @override
  Future<SettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isPocketModeEnabled = prefs.getBool(_pocketModeKey) ?? true; // デフォルトはON
    return SettingsState(isPocketModeEnabled: isPocketModeEnabled);
  }

  Future<void> setPocketModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pocketModeKey, value);
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(isPocketModeEnabled: value));
    } else {
      state = AsyncData(SettingsState(isPocketModeEnabled: value));
    }
  }
}

final settingsNotifierProvider = AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
