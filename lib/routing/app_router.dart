import 'package:go_router/go_router.dart';

import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/club/screens/club_list_screen.dart';
import '../features/club/screens/club_details_extra_screen.dart';
import '../features/subscription/screens/subscription_screen.dart';
import '../features/scanqr/screens/scan_qr_details_screen.dart';
import '../features/scanqr/screens/scan_qr_screen.dart';
import '../features/booking/screens/booking_screen.dart';
import '../features/event/screens/update_event_screen.dart';
import '../features/settings/screens/account_suspended_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/club_info_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpPath,
        name: AppRoutes.otp,
        builder: (_, __) => const OTPScreen(),
      ),
      GoRoute(
        path: AppRoutes.signupPath,
        name: AppRoutes.signup,
        builder: (_, __) => SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboardPath,
        name: AppRoutes.dashboard,
        builder: (_, __) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.clubListPath,
        name: AppRoutes.clubList,
        builder: (_, __) => const ClubDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.clubDetailsExtraPath,
        name: AppRoutes.clubDetailsExtra,
        builder: (_, __) => const ClubDetailsExtraScreen(),
      ),
      GoRoute(
        path: AppRoutes.subscriptionPath,
        name: AppRoutes.subscription,
        builder: (_, __) => const SelectSubscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.clubInfoPath,
        name: AppRoutes.clubInfo,
        builder: (_, __) => const ClubInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountSuspendedPath,
        name: AppRoutes.accountSuspended,
        builder: (_, __) => const AccountSuspendedScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingsPath,
        name: AppRoutes.bookings,
        builder: (_, __) => const BookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanQrPath,
        name: AppRoutes.scanQr,
        builder: (_, __) => const ScanQRScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanQrDetailsPath,
        name: AppRoutes.scanQrDetails,
        builder: (_, state) => ScanQRDetailsScreen(
          qrToken: state.uri.queryParameters['qr'],
        ),
      ),
      GoRoute(
        path: AppRoutes.addEventPath,
        name: AppRoutes.addEvent,
        builder: (_, __) => const UpdateEventScreen(),
      ),
      GoRoute(
        path: AppRoutes.updateEventPath,
        name: AppRoutes.updateEvent,
        builder: (_, state) => UpdateEventScreen(
          eventId: state.uri.queryParameters['id'],
        ),
      ),
    ],
  );
}
