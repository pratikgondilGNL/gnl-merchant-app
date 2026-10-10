import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_project/domain/models/qr_verification.dart';

void main() {
  group('QrVerification.fromJson', () {
    test('parses the verify-qr API response item', () {
      final verification = QrVerification.fromJson({
        'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'booking_type': 'table',
        'people_count': 4,
        'status': 'initiated',
        'event_title': 'Friday Night Vibes',
        'event_date': '2026-08-12',
        'user_email': 'user@example.com',
        'guest_details': null,
      });

      expect(
        verification.id,
        '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      );
      expect(verification.bookingType, 'table');
      expect(verification.peopleCount, 4);
      expect(verification.status, 'initiated');
      expect(verification.eventTitle, 'Friday Night Vibes');
      expect(verification.eventDate, '2026-08-12');
      expect(verification.userEmail, 'user@example.com');
      expect(verification.guestDetails, isNull);
    });

    test('parses guest_details as structured breakdown for guest bookings',
        () {
      final verification = QrVerification.fromJson({
        'id': '2283b699-12f8-4354-a039-2898ccd6b6b3',
        'booking_type': 'guest',
        'people_count': 2,
        'status': 'checked_in',
        'event_title': 'Weekend Masti',
        'event_date': '2026-07-23',
        'user_email': 'flutterspace02@gmail.com',
        'guest_details': {
          'couples_count': 1,
          'male_count': 0,
          'female_count': 0,
          'total_people': 2,
        },
      });

      expect(verification.bookingType, 'guest');
      expect(verification.guestDetails, isNotNull);
      expect(verification.guestDetails!.couplesCount, 1);
      expect(verification.guestDetails!.maleCount, 0);
      expect(verification.guestDetails!.femaleCount, 0);
      expect(verification.guestDetails!.totalPeople, 2);
    });

    test('tolerates missing optional fields', () {
      final verification = QrVerification.fromJson({
        'id': 'x',
      });

      expect(verification.bookingType, '');
      expect(verification.peopleCount, 0);
      expect(verification.status, '');
      expect(verification.eventTitle, '');
      expect(verification.eventDate, '');
      expect(verification.userEmail, '');
      expect(verification.guestDetails, isNull);
    });

    test('coerces numeric string fields', () {
      final verification = QrVerification.fromJson({
        'people_count': '8',
      });

      expect(verification.peopleCount, 8);
    });
  });
}
