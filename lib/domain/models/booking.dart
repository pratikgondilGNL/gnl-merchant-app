enum BookingStatus {
  confirmed,
  pending,
  completed,
  checkedIn,
  cancelled,
  rejected,
  other,
}

class Booking {
  final String id;
  final String userName;
  final String userEmail;
  final String eventTitle;
  final String eventBanner;
  final String eventDate;
  final String eventTime;
  final String clubAddress;
  final String bookingType;
  final BookingStatus status;
  final int peopleCount;
  final String totalAmount;
  final String qrCode;
  final String createdAt;
  final int couplesCount;
  final int maleCount;
  final int femaleCount;

  const Booking({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.eventTitle,
    required this.eventBanner,
    required this.eventDate,
    required this.eventTime,
    required this.clubAddress,
    required this.bookingType,
    required this.status,
    required this.peopleCount,
    required this.totalAmount,
    required this.qrCode,
    required this.createdAt,
    required this.couplesCount,
    required this.maleCount,
    required this.femaleCount,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: _stringValue(json['id']),
      userName: _stringValue(json['user_name']),
      userEmail: _stringValue(json['user_email']),
      eventTitle: _stringValue(json['event_title']),
      eventBanner: _stringValue(json['event_banner']),
      eventDate: _stringValue(json['event_date']),
      eventTime: _stringValue(json['event_time']),
      clubAddress: _stringValue(json['club_address']),
      bookingType: _stringValue(json['booking_type']),
      status: _parseStatus(json['status']),
      peopleCount: _intValue(json['people_count']),
      totalAmount: _stringValue(json['total_amount']),
      qrCode: _stringValue(json['qr_code']),
      createdAt: _stringValue(json['created_at']),
      couplesCount: _intValue(json['couples_count']),
      maleCount: _intValue(json['male_count']),
      femaleCount: _intValue(json['female_count']),
    );
  }

  static String _stringValue(dynamic value) => value?.toString() ?? '';

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static BookingStatus _parseStatus(dynamic value) {
    switch (value?.toString().toLowerCase().replaceAll('-', '_')) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'completed':
        return BookingStatus.completed;
      case 'checked_in':
        return BookingStatus.checkedIn;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      case 'rejected':
        return BookingStatus.rejected;
      default:
        return BookingStatus.other;
    }
  }
}
