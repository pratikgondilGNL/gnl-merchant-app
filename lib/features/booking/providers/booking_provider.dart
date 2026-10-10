import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../di/providers.dart';

class BookingState {
  final bool isLoading;
  final String? error;
  final List<Booking> bookings;

  const BookingState({
    this.isLoading = false,
    this.error,
    this.bookings = const [],
  });

  BookingState copyWith({
    bool? isLoading,
    String? error,
    List<Booking>? bookings,
    bool clearError = false,
  }) {
    return BookingState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      bookings: bookings ?? this.bookings,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final BookingRepository _bookingRepository;

  BookingNotifier(this._bookingRepository) : super(const BookingState());

  void setError(String message) {
    state = state.copyWith(isLoading: false, error: message);
  }

  Future<void> loadBookings(String clubId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _bookingRepository.getBookings(clubId);
      state = state.copyWith(isLoading: false, bookings: bookings);
    } catch (e, stackTrace) {
      log('Load bookings failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  String _errorMessage(Object error) {
    if (error is FormatException) return error.message;

    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final repository = ref.watch(bookingRepositoryProvider);
  return BookingNotifier(repository);
});
