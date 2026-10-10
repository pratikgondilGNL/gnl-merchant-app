import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';

class OTPScreen extends ConsumerStatefulWidget {
  const OTPScreen({super.key});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  int _timerSeconds = 48;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _timerSeconds = 48;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
            _timerSeconds = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _timerSeconds--;
          });
        }
      }
    });
  }

  bool get _isComplete => _otpController.text.length == 6;

  Future<void> _verifyOtp() async {
    if (!_isComplete) return;
    final success = await ref.read(authProvider.notifier).verifyOtp(
          otp: _otpController.text,
        );

    if (success && mounted) {
      context.goNamed(AppRoutes.dashboard);
    }
  }

  void _resendOtp() {
    if (!_canResend) return;
    ref.read(authProvider.notifier).resendOtp();
    _startTimer();
    _otpController.clear();
    _otpFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      _buildShieldIcon(),
                      const SizedBox(height: 32),
                      const Text(
                        'Verification Code',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "We've sent a 4-digit code to",
                        style: TextStyle(
                          color: AppColors.hint,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref.watch(authProvider).email ?? 'your email',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildOtpFields(),
                      const SizedBox(height: 32),
                      _buildTimerText(),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Change Email?',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          const Text(
            'Verify OTP',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShieldIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2),
      ),
      child: const Icon(
        Icons.shield_outlined,
        color: AppColors.primaryDark,
        size: 40,
      ),
    );
  }

  Widget _buildOtpFields() {
    return Pinput(
      controller: _otpController,
      focusNode: _otpFocusNode,
      length: 6,
      keyboardType: TextInputType.number,
      onCompleted: (_) => _verifyOtp(),
      onChanged: (_) => setState(() {}),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      defaultPinTheme: PinTheme(
        width: 74,
        height: 64,
        margin: EdgeInsets.symmetric(horizontal: 2),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
      ),
      focusedPinTheme: PinTheme(
        width: 74,
        height: 64,
        margin: EdgeInsets.symmetric(horizontal: 2),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryDark, width: 2),
        ),
      ),
      submittedPinTheme: PinTheme(
        width: 74,
        height: 64,
        margin: EdgeInsets.symmetric(horizontal: 2),
        textStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildTimerText() {
    if (_canResend) {
      return GestureDetector(
        onTap: _resendOtp,
        child: const Text(
          'Resend OTP',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: AppColors.hint,
          fontSize: 14,
        ),
        children: [
          const TextSpan(text: 'Resend OTP in '),
          TextSpan(
            text: '${_timerSeconds}s',
            style: const TextStyle(color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final isLoading = ref.watch(authProvider).isLoading;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: (_isComplete && !isLoading) ? _verifyOtp : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor:
                AppColors.primaryDark.withValues(alpha: 0.5),
            foregroundColor: AppColors.textPrimary,
            disabledForegroundColor:
                AppColors.textPrimary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Text(
                  'Verify & Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
