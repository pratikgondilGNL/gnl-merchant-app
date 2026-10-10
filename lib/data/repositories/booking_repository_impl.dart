import 'package:dio/dio.dart';

import '../../domain/models/booking.dart';
import '../../domain/models/qr_verification.dart';
import '../../domain/repositories/booking_repository.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class BookingRepositoryImpl implements BookingRepository {
  final ApiClient _apiClient;

  BookingRepositoryImpl(this._apiClient);

  @override
  Future<QrVerification> verifyQR(String qrToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyQR,
        data: {'qr_token': qrToken},
      );
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Invalid QR verification response format',
        );
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'QR verification failed',
        );
      }

      Map<String, dynamic>? resultJson;
      final result = data['result'];
      if (result is Map<String, dynamic>) {
        resultJson = result;
      } else if (result is List && result.isNotEmpty) {
        final first = result.first;
        if (first is Map<String, dynamic>) resultJson = first;
      } else {
        resultJson = data;
      }

      if (resultJson == null || resultJson.isEmpty) {
        throw const FormatException('QR verification result not found');
      }

      return QrVerification.fromJson(resultJson);
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to verify QR: $e');
    }
  }

  @override
  Future<List<Booking>> getBookings(String clubId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bookings(clubId));
      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid bookings response format');
      }

      final status = data['status'];
      if (status is bool && !status) {
        throw FormatException(
          data['message']?.toString() ?? 'Bookings request failed',
        );
      }

      final result = data['result'];
      if (result is! List) {
        throw const FormatException('Bookings result not found');
      }

      return result
          .whereType<Map<String, dynamic>>()
          .map(Booking.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e));
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('Unable to fetch bookings: $e');
    }
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
