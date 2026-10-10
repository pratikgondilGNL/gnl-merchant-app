import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_project/domain/models/booking.dart';

void main() {
  group('Booking.fromJson', () {
    test('parses the bookings API response item', () {
      final booking = Booking.fromJson({
        'id': '8b6e7b6c-a0d3-4f9e-9f6a-5a7c1e2f3a4b',
        'user_email': 'sahil@gmail.com',
        'user_name': 'Sahil',
        'event_title': 'Carnival',
        'event_banner': '/media/events/images_2.jpg',
        'event_date': '2026-07-23',
        'event_time': '07:00:00',
        'club_address': 'Noida',
        'booking_type': 'guest',
        'status': 'checked_in',
        'people_count': 5,
        'total_amount': '1700.00',
        'qr_code': '/media/bookings/qr/14.png',
        'created_at': '2026-07-23T17:41:47.386339+05:30',
        'couples_count': 0,
        'male_count': 3,
        'female_count': 2,
      });

      expect(booking.id, '8b6e7b6c-a0d3-4f9e-9f6a-5a7c1e2f3a4b');
      expect(booking.userName, 'Sahil');
      expect(booking.userEmail, 'sahil@gmail.com');
      expect(booking.eventTitle, 'Carnival');
      expect(booking.eventBanner, '/media/events/images_2.jpg');
      expect(booking.eventDate, '2026-07-23');
      expect(booking.eventTime, '07:00:00');
      expect(booking.clubAddress, 'Noida');
      expect(booking.bookingType, 'guest');
      expect(booking.status, BookingStatus.checkedIn);
      expect(booking.peopleCount, 5);
      expect(booking.totalAmount, '1700.00');
      expect(booking.qrCode, '/media/bookings/qr/14.png');
      expect(booking.createdAt, '2026-07-23T17:41:47.386339+05:30');
      expect(booking.couplesCount, 0);
      expect(booking.maleCount, 3);
      expect(booking.femaleCount, 2);
    });

    test('parses supported status strings', () {
      expect(
        Booking.fromJson({'status': 'confirmed'}).status,
        BookingStatus.confirmed,
      );
      expect(
        Booking.fromJson({'status': 'pending'}).status,
        BookingStatus.pending,
      );
      expect(
        Booking.fromJson({'status': 'completed'}).status,
        BookingStatus.completed,
      );
      expect(
        Booking.fromJson({'status': 'checked_in'}).status,
        BookingStatus.checkedIn,
      );
      expect(
        Booking.fromJson({'status': 'cancelled'}).status,
        BookingStatus.cancelled,
      );
      expect(
        Booking.fromJson({'status': 'rejected'}).status,
        BookingStatus.rejected,
      );
    });

    test('tolerates missing optional fields', () {
      final booking = Booking.fromJson({
        'id': 'x',
        'user_name': 'A',
        'status': 'unknown_status',
      });

      expect(booking.userName, 'A');
      expect(booking.userEmail, '');
      expect(booking.eventTitle, '');
      expect(booking.eventDate, '');
      expect(booking.status, BookingStatus.other);
      expect(booking.peopleCount, 0);
      expect(booking.totalAmount, '');
    });

    test('coerces numeric string fields', () {
      final booking = Booking.fromJson({
        'people_count': '8',
        'couples_count': '1',
        'male_count': '4',
        'female_count': '3',
      });

      expect(booking.peopleCount, 8);
      expect(booking.couplesCount, 1);
      expect(booking.maleCount, 4);
      expect(booking.femaleCount, 3);
    });
  });
}
