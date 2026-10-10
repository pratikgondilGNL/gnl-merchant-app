import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../di/providers.dart';
import '../../../domain/models/event.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/feature_tile.dart';
import '../../club/providers/club_provider.dart';
import '../../event/providers/event_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubProvider.notifier).loadClubs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubProvider);
    log(clubState.clubs.length.toString());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            color: AppColors.surface,
            child: clubState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryDark,
                    ),
                  )
                : clubState.clubs.isNotEmpty
                    ? const _ClubDashboard()
                    : const _NoClubDashboard(),
          ),
        ),
      ),
    );
  }
}

// ─── No Club ──────────────────────────────────────────────────
class _NoClubDashboard extends StatelessWidget {
  const _NoClubDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DashboardHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeNoClub(),
                SizedBox(height: 24),
                _NoClubCard(),
                SizedBox(height: 24),
                _WhatYouGetSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeNoClub extends StatelessWidget {
  const _WelcomeNoClub();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to GNL!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'List your club to start managing bookings',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _NoClubCard extends StatelessWidget {
  const _NoClubCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.store,
              color: AppColors.primaryDark,
              size: 45,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Club Listed Yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
            child: Text(
              'List your nightclub to start accepting table bookings and managing your business',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.hint,
                fontSize: 16,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                context.pushNamed(AppRoutes.clubList);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'List My Club',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatYouGetSection extends StatelessWidget {
  const _WhatYouGetSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What you'll get:",
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 16),
        FeatureTile(
          icon: Icons.people_outline,
          title: 'Manage Bookings',
          subtitle: 'Track all table reservations',
        ),
        SizedBox(height: 16),
        FeatureTile(
          icon: Icons.trending_up,
          title: 'Analytics & Insights',
          subtitle: 'View performance metrics',
        ),
        SizedBox(height: 16),
        FeatureTile(
          icon: Icons.calendar_month,
          title: 'Event Management',
          subtitle: 'Create and update events',
        ),
      ],
    );
  }
}

// ─── Club Dashboard ───────────────────────────────────────────
class _ClubDashboard extends ConsumerStatefulWidget {
  const _ClubDashboard();

  @override
  ConsumerState<_ClubDashboard> createState() => _ClubDashboardState();
}

class _ClubDashboardState extends ConsumerState<_ClubDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    final clubId = await ref.read(tokenStorageProvider).getClubId();
    if (!mounted) return;
    if (clubId == null || clubId.isEmpty) {
      ref.read(eventProvider.notifier).setEventsError(
            'Club id not found. Please contact support.',
          );
      return;
    }
    ref.read(eventProvider.notifier).loadAllEvents(clubId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DashboardHeader(showNotification: true),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const _WelcomeClub(),
                const SizedBox(height: 24),
                const _ActionButtons(),
                const SizedBox(height: 24),
                _EventsSection(onRetry: _loadEvents),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeClub extends ConsumerWidget {
  const _WelcomeClub();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubProvider).clubs;
    final clubName = clubs.isNotEmpty ? clubs.first.name : 'Your Club';

    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Welcome back! 👋🏻',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            clubName,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: _ScanQrButton()),
            SizedBox(width: 12),
            Expanded(child: _BookingsButton()),
          ],
        ),
        SizedBox(height: 16),
        _AddEventButton(),
      ],
    );
  }
}

class _ScanQrButton extends StatelessWidget {
  const _ScanQrButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.scanQr),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Scan QR',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEventButton extends StatelessWidget {
  const _AddEventButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.addEvent),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Event',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingsButton extends StatelessWidget {
  const _BookingsButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.bookings),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, color: AppColors.textPrimary, size: 20),
            SizedBox(width: 8),
            Text(
              'Bookings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsSection extends ConsumerWidget {
  final VoidCallback onRetry;

  const _EventsSection({required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventProvider);
    final events = state.events;

    ref.listen<EventState>(eventProvider, (prev, next) {
      if (next.isSuccess && prev?.isSuccess != true) {
        onRetry();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Events',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (state.isEventsLoading && events.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            ),
          )
        else if (state.eventsError != null)
          _EventsError(message: state.eventsError!, onRetry: onRetry)
        else if (events.isEmpty)
          const _EmptyEventsCard()
        else
          for (final event in events)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventCard(event: event),
            ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;

  const _EventCard({required this.event});

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.pushNamed(
                  AppRoutes.updateEvent,
                  queryParameters: {'id': event.id ?? ''},
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.hint,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(event.date),
                style: const TextStyle(
                  color: AppColors.hint,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                color: AppColors.hint,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
                  style: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  const _EmptyEventsCard();

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
        children: [
          const Icon(
            Icons.event_available,
            color: AppColors.hint,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'No events yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add your first event to get started',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.addEvent),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Add Event',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EventsError({required this.message, required this.onRetry});

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
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.hint,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
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
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _formatTime(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return time;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1];
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:$minute $period';
}

class _DashboardHeader extends StatelessWidget {
  final bool showNotification;

  const _DashboardHeader({this.showNotification = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text(
            'GNL Merchant',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.settings),
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceAlt,
              child: Icon(Icons.person_outline, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
