import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../di/providers.dart';
import '../../../domain/models/booking.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  BookingStatus? _selectedFilter;

  static const _filters = <String, BookingStatus?>{
    'All': null,
    'Confirmed': BookingStatus.confirmed,
    'Pending': BookingStatus.pending,
    'Completed': BookingStatus.completed,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBookings());
  }

  Future<void> _loadBookings() async {
    final clubId = await ref.read(tokenStorageProvider).getClubId();
    if (!mounted) return;
    if (clubId == null || clubId.isEmpty) {
      ref.read(bookingProvider.notifier).setError(
            'Club id not found. Please contact support.',
          );
      return;
    }
    ref.read(bookingProvider.notifier).loadBookings(clubId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingProvider);
    final all = state.bookings;

    final filtered = _selectedFilter == null
        ? all
        : all.where((b) => b.status == _selectedFilter).toList();
    final confirmedCount =
        all.where((b) => b.status == BookingStatus.confirmed).length;
    final pendingCount =
        all.where((b) => b.status == BookingStatus.pending).length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            color: AppColors.surface,
            child: Stack(
              children: [
                Column(
                  children: [
                    const _BookingsHeader(),
                    _StatsRow(
                      totalToday: all.length,
                      confirmed: confirmedCount,
                      pending: pendingCount,
                    ),
                    _FilterBar(
                      filters: _filters.keys.toList(),
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = _filters[filter]);
                      },
                    ),
                    Expanded(
                      child: _buildList(state, filtered),
                    ),
                  ],
                ),
                const Positioned(
                  bottom: 16,
                  right: 16,
                  child: _NavPanelButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BookingState state, List<Booking> bookings) {
    if (state.isLoading && bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryDark),
      );
    }

    if (state.error != null && bookings.isEmpty) {
      return _BookingsError(message: state.error!, onRetry: _loadBookings);
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_note_outlined, color: AppColors.hint, size: 48),
              SizedBox(height: 16),
              Text(
                'No bookings found',
                style: TextStyle(color: AppColors.hint, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 80),
      itemCount: bookings.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _BookingCard(booking: bookings[i]),
      ),
    );
  }
}

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Bookings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalToday;
  final int confirmed;
  final int pending;

  const _StatsRow({
    required this.totalToday,
    required this.confirmed,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(value: totalToday.toString(), label: 'Total')),
          Expanded(child: _StatItem(value: confirmed.toString(), label: 'Confirmed')),
          Expanded(child: _StatItem(value: pending.toString(), label: 'Pending')),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.hint,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  final List<String> filters;
  final BookingStatus? selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = (filter == 'All' && selectedFilter == null) ||
              (filter == 'Confirmed' &&
                  selectedFilter == BookingStatus.confirmed) ||
              (filter == 'Pending' &&
                  selectedFilter == BookingStatus.pending) ||
              (filter == 'Completed' &&
                  selectedFilter == BookingStatus.completed);
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryDark : AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.hint,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  Color _statusBgColor() {
    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
        return AppColors.primaryDark;
      case BookingStatus.pending:
        return AppColors.hint;
      case BookingStatus.completed:
        return AppColors.border;
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return AppColors.error;
      case BookingStatus.other:
        return AppColors.border;
    }
  }

  Color _statusTextColor() {
    switch (booking.status) {
      case BookingStatus.confirmed:
      case BookingStatus.checkedIn:
      case BookingStatus.pending:
        return AppColors.textPrimary;
      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
      case BookingStatus.other:
        return AppColors.textPrimary;
    }
  }

  String _statusLabel() {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.other:
        return booking.status.name;
    }
  }

  String get _displayTime {
    final parts = booking.eventTime.split(':');
    if (parts.length == 3) return '${parts[0]}:${parts[1]}';
    return booking.eventTime;
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.userName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.eventTitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(),
                  style: TextStyle(
                    color: _statusTextColor(),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BookingInfoRow(
            icon: Icons.people_outline,
            text: '${booking.peopleCount} guests',
          ),
          if (booking.eventDate.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BookingInfoRow(
              icon: Icons.calendar_today_outlined,
              text: booking.eventDate,
            ),
          ],
          if (_displayTime.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BookingInfoRow(
              icon: Icons.access_time_rounded,
              text: _displayTime,
            ),
          ],
          if (booking.totalAmount.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BookingInfoRow(
              icon: Icons.currency_rupee,
              text: booking.totalAmount,
            ),
          ],
          if (booking.userEmail.isNotEmpty) ...[
            const SizedBox(height: 8),
            _BookingInfoRow(
              icon: Icons.mail_outline,
              text: booking.userEmail,
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BookingInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.hint, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 14.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BookingsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.hint, size: 48),
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

class _NavPanelButton extends StatelessWidget {
  const _NavPanelButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(
        Icons.chevron_left,
        color: AppColors.hint,
        size: 20,
      ),
    );
  }
}
