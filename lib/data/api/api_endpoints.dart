class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://3.108.39.64';

  // Auth
  static const String login = '/auth/signup/';
  static const String signUp = '/auth/merchant/signup/';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String resendOtp = '/auth/resend-otp';

  // extra
  static const String locations = '/events/locations?include_areas=true&include_cities=true';
  static const String eventCategories = '/events/categories/';

  // Club
  static const String createClub = '/merchant/clubs/create';
  static const String clubs = '/merchant/clubs/';
  static String club(String id) => '/merchant/clubs/$id/edit';
  static String clubGallery(String id) => '/merchant/clubs/$id/gallery/create';

  // event
  static String addEvent(String id) => '/merchant/clubs/$id/events/create';
  static String allEvents(String id) => '/merchant/clubs/$id/events/';
  static String updateEvent(String clubId, String eventId) =>
      '/merchant/clubs/$clubId/events/$eventId/edit';

  // bookings
  static String bookings(String id) => '/bookings/my/?club_id=$id';
  static const String verifyQR = '/bookings/verify-qr/';
  static const String confirmBookings = '/bookings/confirm/';

  // Subscription
  static const String subscriptions = '/subscriptions';

  // Event
  static String event(String id) => '/events/$id';
}
