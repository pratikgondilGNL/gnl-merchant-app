import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool isLoading;

  const SettingsState({this.isLoading = false});

  SettingsState copyWith({bool? isLoading}) {
    return SettingsState(isLoading: isLoading ?? this.isLoading);
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
