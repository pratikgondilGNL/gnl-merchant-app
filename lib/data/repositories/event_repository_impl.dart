import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/models/event.dart';
import '../../domain/models/event_category.dart';
import '../../domain/repositories/event_repository.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class EventRepositoryImpl implements EventRepository {
  final ApiClient _apiClient;

  EventRepositoryImpl(this._apiClient);

  @override
  Future<void> createEvent(Event event, String clubId) async {
    try {
      final formData = await _eventFormData(event);
      await _apiClient.post(
        ApiEndpoints.addEvent(clubId),
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to create event: $e');
    }
  }

  @override
  Future<void> updateEvent(Event event, String clubId) async {
    try {
      final formData = await _eventFormData(event);
      await _apiClient.put(
        ApiEndpoints.updateEvent(clubId, event.id ?? ''),
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to update event: $e');
    }
  }

  @override
  Future<Event?> getEvent(String id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.event(id));
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid event response format');
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'Event request failed',
        );
      }

      final result = data['result'];
      Map<String, dynamic>? eventJson;
      if (result is Map<String, dynamic>) {
        eventJson = result;
      } else if (result is List && result.isNotEmpty) {
        final first = result.first;
        if (first is Map<String, dynamic>) eventJson = first;
      } else {
        eventJson = data;
      }

      if (eventJson == null || eventJson.isEmpty) return null;
      return Event.fromJson(eventJson);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to fetch event: $e');
    }
  }

  @override
  Future<List<Event>> getAllEvents(String clubId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.allEvents(clubId));
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid events response format');
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'Events request failed',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw const FormatException('Events result not found');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(Event.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to fetch events: $e');
    }
  }

  @override
  Future<List<EventCategory>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.eventCategories);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid categories response format');
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'Categories request failed',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw const FormatException('Categories result not found');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(EventCategory.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to fetch categories: $e');
    }
  }

  Future<FormData> _eventFormData(Event event) async {
    final data = Map<String, dynamic>.from(event.toJson());
    final banner = data['banner']?.toString();

    final isLocalFile = banner != null &&
        banner.isNotEmpty &&
        !banner.startsWith('http://') &&
        !banner.startsWith('https://');

    if (isLocalFile) {
      data.remove('banner');
    }

    final formData = FormData.fromMap(data);

    if (isLocalFile) {
      await _addFileIfExists(formData, 'banner', banner);
    }

    return formData;
  }

  Future<void> _addFileIfExists(
    FormData formData,
    String fieldName,
    String? path,
  ) async {
    if (path == null || path.isEmpty) return;
    if (path.startsWith('http://') || path.startsWith('https://')) return;
    if (!File(path).existsSync()) return;

    formData.files.add(
      MapEntry(
        fieldName,
        await MultipartFile.fromFile(path, filename: _fileName(path)),
      ),
    );
  }

  String _fileName(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    return normalizedPath.split('/').last;
  }

  String _dioErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      final detail = responseData['detail'];
      if (detail != null && detail.toString().trim().isNotEmpty) {
        return detail.toString();
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.badResponse:
        return 'Server error ${error.response?.statusCode ?? ''}'.trim();
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server.';
      case DioExceptionType.badCertificate:
        return 'Unable to verify server certificate.';
      case DioExceptionType.unknown:
        return error.message ?? 'Something went wrong.';
    }
  }
}
