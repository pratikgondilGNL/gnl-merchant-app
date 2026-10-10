import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/token_storage.dart';
import '../data/api/api_client.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../data/repositories/club_repository_impl.dart';
import '../data/repositories/event_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/club_repository.dart';
import '../domain/repositories/event_repository.dart';

// API Client
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(storage);
});

// Services
final tokenStorageProvider = Provider<AppStorage>((ref) => AppStorage());

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ClubRepositoryImpl(apiClient);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventRepositoryImpl(apiClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepositoryImpl(apiClient);
});
