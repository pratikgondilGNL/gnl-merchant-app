import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/models/club.dart';
import '../../domain/models/club_gallery_request.dart';
import '../../domain/models/location.dart';
import '../../domain/repositories/club_repository.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class ClubRepositoryImpl implements ClubRepository {
  final ApiClient _apiClient;

  ClubRepositoryImpl(this._apiClient);

  @override
  Future<String> createClub(Club club) async {
    final formData = await _clubFormData(club);
    final response = await _apiClient.post(
      ApiEndpoints.createClub,
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
    final data = response.data as Map<String, dynamic>;
    return _createdClubId(data);
  }

  @override
  Future<Club?> getClub(String id) async {
    final response = await _apiClient.get(ApiEndpoints.club(id));
    if (response.data == null) return null;
    return Club.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<Club>> getMyClubs() async {
    final response = await _apiClient.get(ApiEndpoints.clubs);
    final data = response.data;
    final list =
        data is Map<String, dynamic> ? data['result'] as List? : data as List?;
    if (list == null) return [];
    debugPrint('RAW CLUB JSON: $data');

    return list.map((e) => Club.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<LocationCountry>> getLocations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.locations);
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid locations response format');
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'Locations request failed',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw const FormatException('Locations result not found');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(LocationCountry.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to fetch locations: $e');
    }
  }

  @override
  Future<void> updateClub(String clubId, Club club) async {
    final formData = await _clubFormData(club);
    await _apiClient.put(
      ApiEndpoints.club(clubId),
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  @override
  Future<void> updateClubFields(
      String clubId,
      Map<String, dynamic> fields, {
        Club? club,
      }) async {
    final formData = await _fieldsFormData(fields, club);
    await _apiClient.put(
      ApiEndpoints.club(clubId),
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<FormData> _fieldsFormData(
      Map<String, dynamic> fields,
      Club? club,
      ) async {
    final data = Map<String, dynamic>.from(fields);

    final aboutUsPoints = data.remove('about_us_points');
    final operatingHours = data.remove('operating_hours');
    final logoPath = data.remove('logo');
    final coverPath = data.remove('cover_image');

    final formData = FormData.fromMap(data);

    if (aboutUsPoints is List) {
      for (var i = 0; i < aboutUsPoints.length; i++) {
        formData.fields.add(
          MapEntry('about_us_points[$i]', aboutUsPoints[i].toString()),
        );
      }
    }

    if (operatingHours is List && operatingHours.isNotEmpty) {
      formData.fields.add(
        MapEntry('operating_hours', jsonEncode(operatingHours)),
      );
    }

    if (logoPath != null) {
      await _addFileIfExists(formData, 'logo', logoPath.toString());
    }
    if (coverPath != null) {
      await _addFileIfExists(formData, 'cover_image', coverPath.toString());
    }

    return formData;
  }

  @override
  Future<void> createGallery(String clubId, ClubGalleryRequest request) async {
    final formData = await _galleryFormData(request);
    await _apiClient.post(
      ApiEndpoints.clubGallery(clubId),
      data: formData,
      options: Options(contentType: Headers.multipartFormDataContentType),
    );
  }

  Future<FormData> _clubFormData(Club club) async {
    final data = Map<String, dynamic>.from(club.toJson())
      ..remove('logo')
      ..remove('cover_image')
      ..remove('operating_hours')
      ..remove('area')
      ..remove('subscription_plan');

    final areaId = int.tryParse(club.area?.trim() ?? '');
    if (areaId != null && areaId > 0) {
      data['area'] = areaId;
    }

    final formData = FormData.fromMap(data);
    _addOperatingHours(formData, club.operatingHoursToJson());
    await _addFileIfExists(formData, 'logo', club.logoUrl);
    await _addFileIfExists(formData, 'cover_image', club.coverUrl);

    return formData;
  }

  void _addOperatingHours(
    FormData formData,
    List<Map<String, dynamic>> operatingHours,
  ) {
    if (operatingHours.isEmpty) return;
    formData.fields.add(
      MapEntry('operating_hours', jsonEncode(operatingHours)),
    );
  }

  Future<FormData> _galleryFormData(ClubGalleryRequest request) async {
    final formData = FormData.fromMap({
      'review_points': request.reviewPoints,
      'is_primary': request.isPrimary,
    });

    for (final imagePath in request.images) {
      await _addFileIfExists(formData, 'images', imagePath);
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

  String _createdClubId(Map<String, dynamic> data) {
    final result = data['result'];
    if (result is Map<String, dynamic>) {
      final clubId = result['club_id'];
      if (clubId != null) return clubId.toString();

      final id = result['id'];
      if (id != null) return id.toString();
    }

    final id = data['id'];
    if (id != null) return id.toString();

    throw const FormatException('Created club id not found in response');
  }

  String _dioErrorMessage(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
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
