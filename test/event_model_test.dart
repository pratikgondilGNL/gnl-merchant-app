import 'package:flutter_test/flutter_test.dart';

import 'package:merchant_project/domain/models/event.dart';

void main() {
  group('Event.fromJson', () {
    test('parses the allEvents API response item', () {
      final json = <String, dynamic>{
        'id': 13,
        'title': 'Luxe Saturdays: Midnight Affair',
        'description': 'Premium nightlife, pulsating beats.',
        'banner': '/media/events/images_jwpf5e9.jpg',
        'date': '2026-08-14',
        'start_time': '20:00:00',
        'end_time': '02:00:00',
        'dj_name': 'DJ Aaryan',
        'latitude': '18.536200',
        'longitude': '73.893900',
        'entry_fee': '1499.00',
        'min_spend': '3000.00',
        'couple_entry_fee': '2499.00',
        'male_entry_fee': '1499.00',
        'female_entry_fee': '999.00',
        'music_genre': 'edm',
        'event_status': 'upcoming',
        'special_instructions': 'Dress code required.',
        'discount_percentage': 10,
        'discount_type': 'flat',
        'is_active': true,
        'is_top': true,
        'updated_at': '2026-08-09T12:35:10.082855Z',
        'total_capacity': 600,
        'booked_capacity': 0,
        'category': 5,
        'area': 8,
      };

      final event = Event.fromJson(json);

      expect(event.id, '13');
      expect(event.name, 'Luxe Saturdays: Midnight Affair');
      expect(event.date, DateTime(2026, 8, 14));
      expect(event.startTime, '20:00:00');
      expect(event.endTime, '02:00:00');
      expect(event.djArtist, 'DJ Aaryan');
      expect(event.entryFee, 1499.0);
      expect(event.minSpend, 3000.0);
      expect(event.coupleEntryFee, 2499.0);
      expect(event.maleEntryFee, 1499.0);
      expect(event.femaleEntryFee, 999.0);
      expect(event.musicGenre, 'edm');
      expect(event.status, EventStatus.upcoming);
      expect(event.discountPercentage, 10);
      expect(event.discountType, 'flat');
      expect(event.isActive, isTrue);
      expect(event.isTop, isTrue);
      expect(event.totalCapacity, 600);
      expect(event.bookedCapacity, 0);
      expect(event.category, 5);
      expect(event.area, 8);
      expect(event.bannerUrl, '/media/events/images_jwpf5e9.jpg');
    });

    test('tolerates missing optional fields', () {
      final event = Event.fromJson(const {
        'id': 5,
        'title': 'Minimal Event',
        'date': '2026-08-01',
        'start_time': '21:00:00',
        'end_time': '01:00:00',
        'description': 'Short description',
        'event_status': 'live',
      });

      expect(event.id, '5');
      expect(event.entryFee, isNull);
      expect(event.djArtist, isNull);
      expect(event.discountType, isNull);
      expect(event.isActive, isTrue);
      expect(event.isTop, isFalse);
      expect(event.status, EventStatus.live);
    });

    test('throws FormatException when date is missing', () {
      expect(
        () => Event.fromJson(const {
          'title': 'No Date',
          'start_time': '21:00:00',
          'end_time': '01:00:00',
          'description': 'x',
        }),
        throwsFormatException,
      );
    });
  });
}
