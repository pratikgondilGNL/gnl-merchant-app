import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../di/providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    final storage = ref.read(tokenStorageProvider);
    // await storage.saveClubId("10");
    // await storage.saveTokens(
    //     accessToken:
    //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzg3MDU0MjgyLCJpYXQiOjE3ODY0NDk0ODIsImp0aSI6ImQ4MTQ3ZjBhZGJjMDRiNzRhNjI0MjQzNjg0ZjliMjlkIiwidXNlcl9pZCI6IjUifQ.UKIpPOU6o18WP0_IKBH-WQY0nv4bKGw1JUQ9sqeN8ok");

    final token = await storage.getAccessToken();

    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    if (token != null) {
      ref.read(authProvider.notifier).checkAuthStatus();
      context.goNamed(AppRoutes.dashboard);
    } else {
      context.goNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final value = (_controller.value + delay) % 1;
        final offset = -8 * (value < 0.5 ? value : 1 - value);

        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                width: 130,
                height: 130,
              ),
            ),
            const SizedBox(height: 16),
            Text("GNL", style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Merchant",
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(0.0),
                    const SizedBox(width: 6),
                    _dot(0.2),
                    const SizedBox(width: 6),
                    _dot(0.4),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text("Premium Nightlife Experience", style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
