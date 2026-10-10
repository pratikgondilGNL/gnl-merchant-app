import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/qr_verification.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../di/providers.dart';

class ScanQrState {
  final bool isLoading;
  final String? error;
  final QrVerification? verification;

  const ScanQrState({
    this.isLoading = false,
    this.error,
    this.verification,
  });

  ScanQrState copyWith({
    bool? isLoading,
    String? error,
    QrVerification? verification,
    bool clearError = false,
  }) {
    return ScanQrState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      verification: verification ?? this.verification,
    );
  }
}

class ScanQrNotifier extends StateNotifier<ScanQrState> {
  final BookingRepository _bookingRepository;

  ScanQrNotifier(this._bookingRepository) : super(const ScanQrState());

  void setError(String message) {
    state = state.copyWith(isLoading: false, error: message);
  }

  Future<void> verify(String qrToken) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final verification = await _bookingRepository.verifyQR(qrToken);
      state = state.copyWith(
        isLoading: false,
        verification: verification,
      );
    } catch (e, stackTrace) {
      log('Verify QR failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: _errorMessage(e),
      );
    }
  }

  void reset() {
    state = const ScanQrState();
  }

  String _errorMessage(Object error) {
    if (error is FormatException) return error.message;

    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

final scanQrProvider =
    StateNotifierProvider<ScanQrNotifier, ScanQrState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return ScanQrNotifier(repository);
});
