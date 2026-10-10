import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardState {
  final bool isLoading;

  const DashboardState({this.isLoading = false});

  DashboardState copyWith({bool? isLoading}) {
    return DashboardState(isLoading: isLoading ?? this.isLoading);
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(const DashboardState());
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
