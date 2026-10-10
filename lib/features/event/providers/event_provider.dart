import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/event.dart';
import '../../../domain/models/event_category.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../di/providers.dart';

class EventState {
  final bool isLoading;
  final String? error;
  final Event? event;
  final bool isSuccess;
  final bool isCategoriesLoading;
  final String? categoriesError;
  final List<EventCategory> categories;
  final bool isEventsLoading;
  final String? eventsError;
  final List<Event> events;

  const EventState({
    this.isLoading = false,
    this.error,
    this.event,
    this.isSuccess = false,
    this.isCategoriesLoading = false,
    this.categoriesError,
    this.categories = const [],
    this.isEventsLoading = false,
    this.eventsError,
    this.events = const [],
  });

  EventState copyWith({
    bool? isLoading,
    String? error,
    Event? event,
    bool? isSuccess,
    bool? isCategoriesLoading,
    String? categoriesError,
    List<EventCategory>? categories,
    bool clearCategoriesError = false,
    bool? isEventsLoading,
    String? eventsError,
    List<Event>? events,
    bool clearEventsError = false,
  }) {
    return EventState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      event: event ?? this.event,
      isSuccess: isSuccess ?? this.isSuccess,
      isCategoriesLoading: isCategoriesLoading ?? this.isCategoriesLoading,
      categoriesError:
          clearCategoriesError ? null : categoriesError ?? this.categoriesError,
      categories: categories ?? this.categories,
      isEventsLoading: isEventsLoading ?? this.isEventsLoading,
      eventsError:
          clearEventsError ? null : eventsError ?? this.eventsError,
      events: events ?? this.events,
    );
  }
}

class EventNotifier extends StateNotifier<EventState> {
  final EventRepository _eventRepository;

  EventNotifier(this._eventRepository) : super(const EventState());

  void setEvent(Event event) {
    state = state.copyWith(event: event);
  }

  void setEventsError(String message) {
    state = state.copyWith(isEventsLoading: false, eventsError: message);
  }

  Future<void> loadEvent(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final event = await _eventRepository.getEvent(id);
      state = state.copyWith(isLoading: false, event: event);
    } catch (e, stackTrace) {
      log('Load event failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> createEvent(Event event, String clubId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _eventRepository.createEvent(event, clubId);
      state = state.copyWith(
        isLoading: false,
        event: event,
        isSuccess: true,
      );
    } catch (e, stackTrace) {
      log('Create event failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> updateEvent(Event event, String clubId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      await _eventRepository.updateEvent(event, clubId);
      final events = [...state.events];
      final index = events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        events[index] = event;
      }
      state = state.copyWith(
        isLoading: false,
        event: event,
        events: events,
        isSuccess: true,
      );
    } catch (e, stackTrace) {
      log('Update event failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(isLoading: false, error: _errorMessage(e));
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(
      isCategoriesLoading: true,
      clearCategoriesError: true,
    );
    try {
      final categories = await _eventRepository.getCategories();
      state = state.copyWith(
        isCategoriesLoading: false,
        categories: categories,
      );
    } catch (e, stackTrace) {
      log('Load categories failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isCategoriesLoading: false,
        categoriesError: _errorMessage(e),
      );
    }
  }

  Future<void> loadAllEvents(String clubId) async {
    state = state.copyWith(
      isEventsLoading: true,
      clearEventsError: true,
    );
    try {
      final events = await _eventRepository.getAllEvents(clubId);
      state = state.copyWith(
        isEventsLoading: false,
        events: events,
      );
    } catch (e, stackTrace) {
      log('Load all events failed', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isEventsLoading: false,
        eventsError: _errorMessage(e),
      );
    }
  }

  void reset() {
    state = const EventState();
  }

  String _errorMessage(Object error) {
    if (error is FormatException) return error.message;

    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

final eventProvider =
    StateNotifierProvider<EventNotifier, EventState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventNotifier(repository);
});
