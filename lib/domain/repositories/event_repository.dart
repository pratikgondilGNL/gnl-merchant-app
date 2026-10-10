import '../models/event.dart';
import '../models/event_category.dart';

abstract class EventRepository {
  Future<void> createEvent(Event event, String clubId);
  Future<void> updateEvent(Event event, String clubId);
  Future<Event?> getEvent(String id);
  Future<List<Event>> getAllEvents(String clubId);
  Future<List<EventCategory>> getCategories();
}
