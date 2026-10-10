import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/club.dart';
import '../../../domain/models/club_gallery_request.dart';
import '../../../domain/models/location.dart';
import '../../../domain/repositories/club_repository.dart';
import '../../../di/providers.dart';

class ClubState {
  final bool isLoading;
  final bool isLocationsLoading;
  final String? error;
  final String? locationsError;
  final List<Club> clubs;
  final List<LocationCountry> locations;
  final String? createdClubId;

  const ClubState({
    this.isLoading = false,
    this.isLocationsLoading = false,
    this.error,
    this.locationsError,
    this.clubs = const [],
    this.locations = const [],
    this.createdClubId,
  });

  ClubState copyWith({
    bool? isLoading,
    bool? isLocationsLoading,
    String? error,
    String? locationsError,
    List<Club>? clubs,
    List<LocationCountry>? locations,
    String? createdClubId,
    bool clearError = false,
    bool clearLocationsError = false,
  }) {
    return ClubState(
      isLoading: isLoading ?? this.isLoading,
      isLocationsLoading: isLocationsLoading ?? this.isLocationsLoading,
      error: clearError ? null : error ?? this.error,
      locationsError:
          clearLocationsError ? null : locationsError ?? this.locationsError,
      clubs: clubs ?? this.clubs,
      locations: locations ?? this.locations,
      createdClubId: createdClubId ?? this.createdClubId,
    );
  }
}

class ClubNotifier extends StateNotifier<ClubState> {
  final ClubRepository _clubRepository;

  ClubNotifier(this._clubRepository) : super(const ClubState());

  Future<String?> createClub(Club club) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      log(club.toJson().toString());
      final clubId = await _clubRepository.createClub(club);
      state = state.copyWith(
        isLoading: false,
        createdClubId: clubId,
        clubs: [club, ...state.clubs],
      );
      return clubId;
    } catch (e, stackTrace) {
      log('Create club failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
      return null;
    }
  }

  Future<bool> createGallery(String clubId, ClubGalleryRequest request) async {
    try {
      await _clubRepository.createGallery(clubId, request);
      return true;
    } catch (e, stackTrace) {
      log('Gallery upload failed', error: e, stackTrace: stackTrace);
      state =
          state.copyWith(error: 'Gallery upload failed: ${_errorMessage(e)}');
      return false;
    }
  }

  Future<bool> updateClub(String clubId, Club club, {Club? original}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final payload =
      original != null ? club.diffJson(original) : club.toJson();

      if (payload.isEmpty) {
        state = state.copyWith(isLoading: false);
        return true;
      }

      await _clubRepository.updateClubFields(clubId, payload, club: club);

      final clubs = [...state.clubs];
      if (clubs.isNotEmpty) {
        clubs[0] = club;
      }
      state = state.copyWith(isLoading: false, clubs: clubs);
      return true;
    } catch (e, stackTrace) {
      log('Update club failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
      return false;
    }
  }

  Future<List<Club>> loadClubs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final clubs = await _clubRepository.getMyClubs();
      // log('RAW CLUB JSON: $clubs');
      state = state.copyWith(isLoading: false, clubs: clubs);
      return clubs;
    } catch (e, stackTrace) {
      log('Load clubs failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
      return const [];
    }
  }

  Future<void> loadLocations() async {
    state = state.copyWith(
      isLocationsLoading: true,
      clearLocationsError: true,
    );
    try {
      final locations = await _clubRepository.getLocations();
      state = state.copyWith(
        isLocationsLoading: false,
        locations: locations,
      );
    } catch (e, stackTrace) {
      log('Load locations failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLocationsLoading: false,
        locationsError: _errorMessage(e),
      );
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

final clubProvider = StateNotifierProvider<ClubNotifier, ClubState>((ref) {
  final repository = ref.watch(clubRepositoryProvider);
  return ClubNotifier(repository);
});
