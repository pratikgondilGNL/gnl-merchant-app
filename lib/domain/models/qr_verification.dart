class GuestDetails {
  final int couplesCount;
  final int maleCount;
  final int femaleCount;
  final int totalPeople;

  const GuestDetails({
    this.couplesCount = 0,
    this.maleCount = 0,
    this.femaleCount = 0,
    this.totalPeople = 0,
  });

  factory GuestDetails.fromJson(Map<String, dynamic> json) {
    return GuestDetails(
      couplesCount: _intValue(json['couples_count']),
      maleCount: _intValue(json['male_count']),
      femaleCount: _intValue(json['female_count']),
      totalPeople: _intValue(json['total_people']),
    );
  }

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class QrVerification {
  final String id;
  final String bookingType;
  final int peopleCount;
  final String status;
  final String eventTitle;
  final String eventDate;
  final String userEmail;
  final GuestDetails? guestDetails;

  const QrVerification({
    required this.id,
    required this.bookingType,
    required this.peopleCount,
    required this.status,
    required this.eventTitle,
    required this.eventDate,
    required this.userEmail,
    this.guestDetails,
  });

  factory QrVerification.fromJson(Map<String, dynamic> json) {
    return QrVerification(
      id: _stringValue(json['id']),
      bookingType: _stringValue(json['booking_type']),
      peopleCount: _intValue(json['people_count']),
      status: _stringValue(json['status']),
      eventTitle: _stringValue(json['event_title']),
      eventDate: _stringValue(json['event_date']),
      userEmail: _stringValue(json['user_email']),
      guestDetails: _guestDetails(json['guest_details']),
    );
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static GuestDetails? _guestDetails(dynamic value) {
    if (value is Map<String, dynamic>) return GuestDetails.fromJson(value);
    if (value is Map) {
      return GuestDetails.fromJson(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }
    return null;
  }
}
