import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/qr_verification.dart';
import '../../../routing/app_routes.dart';
import '../providers/scan_qr_provider.dart';

class ScanQRDetailsScreen extends ConsumerStatefulWidget {
  final String? qrToken;

  const ScanQRDetailsScreen({super.key, this.qrToken});

  @override
  ConsumerState<ScanQRDetailsScreen> createState() =>
      _ScanQRDetailsScreenState();
}

class _ScanQRDetailsScreenState extends ConsumerState<ScanQRDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verify();
    });
  }

  void _verify() {
    final token = widget.qrToken;
    if (token == null || token.isEmpty) {
      ref
          .read(scanQrProvider.notifier)
          .setError('QR token not found. Please scan again.');
      return;
    }
    ref.read(scanQrProvider.notifier).verify(token);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scanQrProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ScanQrState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      );
    }

    if (state.error != null) {
      return _ErrorSection(message: state.error!, onRetry: _verify);
    }

    final verification = state.verification;
    if (verification == null) {
      return _ErrorSection(
        message: 'Unable to verify booking. Please try again.',
        onRetry: _verify,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const _SuccessSection(),
          const SizedBox(height: 32),
          _BookingDetailsCard(verification: verification),
          const SizedBox(height: 32),
          const _ActionButtons(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
            'QR Scanner',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessSection extends StatelessWidget {
  const _SuccessSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryDark, Color(0xFFA81B20)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: AppColors.textPrimary,
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Valid Booking!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Booking verified successfully',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _BookingDetailsCard extends StatelessWidget {
  final QrVerification verification;

  const _BookingDetailsCard({required this.verification});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.tag,
            label: 'Booking ID',
            value: verification.id,
          ),
          if (verification.eventTitle.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.event_note_outlined,
              label: 'Event Title',
              value: verification.eventTitle,
            ),
          ],
          if (verification.bookingType.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.chair_outlined,
              label: 'Booking Type',
              value: verification.bookingType,
            ),
          ],
          if (verification.status.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: _capitalize(verification.status),
            ),
          ],
          if (verification.peopleCount > 0) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.people_outline,
              label: 'Number of Guests',
              value: '${verification.peopleCount} people',
            ),
          ],
          if (verification.eventDate.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.calendar_month,
              label: 'Event Date',
              value: formatDate(verification.eventDate),
            ),
          ],
          if (verification.userEmail.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.mail_outline,
              label: 'User Email',
              value: verification.userEmail,
            ),
          ],
          if (verification.guestDetails != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 16),
            const Text(
              'Guest Details',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.favorite_outline,
              label: 'Couples',
              value: verification.guestDetails!.couplesCount.toString(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DetailRow(
                    icon: Icons.male,
                    label: 'Male',
                    value: verification.guestDetails!.maleCount.toString(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _DetailRow(
                    icon: Icons.female,
                    label: 'Female',
                    value: verification.guestDetails!.femaleCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.people_outline,
              label: 'Total People',
              value: verification.guestDetails!.totalPeople.toString(),
            ),
          ],
        ],
      ),
    );
  }

  String formatDate(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;

    return DateFormat('dd MMM yyyy').format(parsed);
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDark, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       /* SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Confirm Entry',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),*/
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () =>
                context.pushReplacementNamed(AppRoutes.scanQr),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Scan Another',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.hint,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.hint, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Material(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
