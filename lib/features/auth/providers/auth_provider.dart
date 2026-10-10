import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/token_storage.dart';
import '../../../domain/models/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../di/providers.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final User? user;
  final String? email;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.user,
    this.email,
    this.accessToken,
    this.refreshToken,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    User? user,
    String? email,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final AppStorage _appStorage;

  AuthNotifier(this._authRepository, this._appStorage)
      : super(const AuthState());

  Future<bool> login({
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.login(email: email);
      state = state.copyWith(isLoading: false, email: email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signUp(user);
      state = state.copyWith(isLoading: false, email: user.email);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tokenData = await _authRepository.verifyOtp(
        email: state.email ?? '',
        otp: otp,
      );
      await _appStorage.saveTokens(
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        accessToken: tokenData.accessToken,
        refreshToken: tokenData.refreshToken,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _appStorage.getAccessToken();
    if (token != null) {
      state = state.copyWith(
        isAuthenticated: true,
        accessToken: token,
        refreshToken: await _appStorage.getRefreshToken(),
      );
    }
  }

  Future<void> logout() async {
    await _appStorage.clearAll();
    state = const AuthState();
  }

  Future<bool> resendOtp() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.resendOtp(email: state.email ?? '');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthNotifier(repository, tokenStorage);
});
