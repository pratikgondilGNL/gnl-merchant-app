import 'package:flutter_test/flutter_test.dart';

import 'package:merchant_project/domain/models/club.dart';

void main() {
  Club buildClub(Map<String, OpeningHours> openingHours) {
    return Club(
      name: 'Luxe Club',
      address: '1 Main St',
      city: 'Pune',
      zipCode: '411001',
      contactNumber: '1234567890',
      email: 'club@test.com',
      openingHours: openingHours,
    );
  }

  Map<String, OpeningHours> sevenDays() {
    return {
      'Saturday': const OpeningHours(open: '18:00', close: '03:00'),
      'Friday': const OpeningHours(open: '18:00', close: '03:00'),
      'Thursday': const OpeningHours(open: '18:00', close: '01:00'),
      'Wednesday': const OpeningHours(open: '18:00', close: '01:00'),
      'Tuesday': const OpeningHours(open: '18:00', close: '01:00'),
      'Monday': const OpeningHours(open: '18:00', close: '01:00'),
      'Sunday': const OpeningHours(
        open: '00:00',
        close: '00:00',
        isClosed: true,
      ),
    };
  }

  group('Club.operatingHoursToJson', () {
    test('emits the requested array format in canonical day order', () {
      final club = buildClub(sevenDays());

      final hours = club.operatingHoursToJson();

      expect(hours, hasLength(7));
      expect(
        hours.map((e) => e['day']).toList(),
        ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      );

      expect(hours.first, {
        'day': 'monday',
        'open': '18:00',
        'close': '01:00',
        'closed': false,
      });

      expect(hours.last, {
        'day': 'sunday',
        'open': null,
        'close': null,
        'closed': true,
      });
    });

    test('returns empty list when no opening hours set', () {
      final club = buildClub({});
      expect(club.operatingHoursToJson(), isEmpty);
    });

    test('toJson embeds the same array under operating_hours', () {
      final club = buildClub(sevenDays());
      final json = club.toJson();

      final hours = json['operating_hours'] as List;
      expect(hours, hasLength(7));
      expect(hours.first, isA<Map<String, dynamic>>());
    });
  });

  group('Club.fromJson', () {
    test('parses the merchant clubs API response item', () {
      final json = <String, dynamic>{
        'id': 15,
        'name': 'Luxe District',
        'description': 'Upscale nightlife destination',
        'short_description': 'Luxury nightclub',
        'address': 'Koregaon Park Plaza, Pune',
        'latitude': '18.536200',
        'longitude': '73.893900',
        'contact_email': 'info@luxedistrict.com',
        'contact_phone': '9876541200',
        'website': 'https://www.luxedistrict.com',
        'instagram_url': 'https://instagram.com/luxedistrict',
        'facebook_url': 'https://facebook.com/luxedistrict',
        'is_18_plus': true,
        'has_dance_floor': true,
        'serves_alcohol': true,
        'dress_code': 'Upscale Evening Wear',
        'logo': '/media/clubs/logos/photo-1.jpeg',
        'cover_image': '/media/clubs/covers/photo-2.jpeg',
        'rejection_reason': '',
        'about_us_desc': 'Elegant interiors',
        'about_us_points': [
          {'Celebrity DJ Nights': 'Top DJs every weekend'},
          'VIP Tables',
        ],
        'is_top': true,
        'area': 8,
        'subscription_plan': 1,
        'operating_hours': [
          {
            'day': 0,
            'day_name': 'Monday',
            'opening_time': '18:00:00',
            'closing_time': '01:00:00',
            'is_closed': false,
          },
          {
            'day': 6,
            'day_name': 'Sunday',
            'opening_time': null,
            'closing_time': null,
            'is_closed': true,
          },
        ],
      };

      final club = Club.fromJson(json);

      expect(club.id, '15');
      expect(club.name, 'Luxe District');
      expect(club.email, 'info@luxedistrict.com');
      expect(club.contactNumber, '9876541200');
      expect(club.latitude, 18.5362);
      expect(club.is18Plus, isTrue);
      expect(club.hasDanceFloor, isTrue);
      expect(club.servesAlcohol, isTrue);
      expect(club.area, '8');
      expect(club.aboutUsHighlights, ['Celebrity DJ Nights', 'VIP Tables']);

      expect(club.openingHours, isNotNull);
      expect(club.openingHours!.length, 2);
      final monday = club.openingHours!['Monday']!;
      expect(monday.open, '18:00');
      expect(monday.close, '01:00');
      expect(monday.isClosed, isFalse);
      final sunday = club.openingHours!['Sunday']!;
      expect(sunday.open, '');
      expect(sunday.isClosed, isTrue);
    });

    test('normalizes lowercase day_name keys', () {
      final club = Club.fromJson(const {
        'id': 9,
        'name': 'Loft',
        'description': 'x',
        'address': 'Lane 5',
        'contact_email': 'loft@test.com',
        'contact_phone': '555',
        'operating_hours': [
          {
            'day': 1,
            'day_name': 'tuesday',
            'opening_time': '19:30:00',
            'closing_time': '02:15:00',
            'is_closed': false,
          },
        ],
      });

      expect(club.openingHours, isNotNull);
      expect(club.openingHours!.containsKey('Tuesday'), isTrue);
      expect(club.openingHours!['Tuesday']!.open, '19:30');
      expect(club.openingHours!['Tuesday']!.close, '02:15');
    });

    test('tolerates missing operating_hours and subscription data', () {
      final club = Club.fromJson(const {
        'id': 5,
        'name': 'Club One',
        'description': 'x',
        'address': 'Downtown',
        'contact_email': 'a@b.c',
        'contact_phone': '123',
        'about_us_points': [],
      });

      expect(club.id, '5');
      expect(club.openingHours, isNull);
      expect(club.aboutUsHighlights, isNull);
      expect(club.servesAlcohol, isFalse);
    });
  });

  group('OpeningHours', () {
    test('fromJson tolerates null open/close for closed days', () {
      final hours = OpeningHours.fromJson(const {
        'day': 'sunday',
        'open': null,
        'close': null,
        'closed': true,
      });

      expect(hours.isClosed, isTrue);
      expect(hours.toJson()['closed'], isTrue);
      expect(hours.toJson()['open'], isNull);
      expect(hours.toJson()['close'], isNull);
    });
  });
}
