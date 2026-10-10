import '../models/booking.dart';
import '../models/qr_verification.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings(String clubId);
  Future<QrVerification> verifyQR(String qrToken);
}
