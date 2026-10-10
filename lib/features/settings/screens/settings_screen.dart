import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/club/providers/club_provider.dart';
import '../../../routing/app_routes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    _SettingsHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 24,
                        ),
        child: const Column(
          children: [
            _ProfileCard(),
            SizedBox(height: 24),
            _AccountSection(),
            SizedBox(height: 24),
            // _SubscriptionSection(),
            // SizedBox(height: 24),
            _SupportSection(),
                            SizedBox(height: 24),
                            _LogoutButton(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: _AppInfo(),
                            ),
                          ],
                        ),
                      ),
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
}

class _SettingsHeader extends StatelessWidget {
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
            'Settings',
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

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubProvider).clubs;
    final club = clubs.isNotEmpty ? clubs.first : null;

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
          const _Avatar(),
          const SizedBox(height: 16),
          Text(
            club?.name ?? 'Your Club',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            club?.email ?? 'merchant@club.com',
            style: const TextStyle(
              color: AppColors.hint,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          // _PlanBadge(),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark2,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.business,
        color: AppColors.textPrimary,
        size: 40,
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            color: AppColors.primaryDark,
            size: 19,
          ),
          SizedBox(width: 6),
          Text(
            'Professional Plan',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasClubs = ref.watch(clubProvider).clubs.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Account',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          children: [
            const _SettingsRow(
              icon: Icons.person_outline_rounded,
              label: 'Profile Settings',
              showChevron: true,
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: Icons.business,
              label: 'Club Information',
              showChevron: true,
              enabled: hasClubs,
              onTap: hasClubs ? () => context.pushNamed(AppRoutes.clubInfo) : null,
            ),
            // _SettingsDivider(),
            // _SettingsRow(
            //   icon: Icons.notifications_none_rounded,
            //   label: 'Notifications',
            //   badge: '3',
            //   showChevron: true,
            // ),
          ],
        ),
      ],
    );
  }
}

class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Subscription',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          children: [
            _SettingsRow(
              icon: Icons.workspace_premium,
              label: 'Current Plan',
              badge: 'Pro',
              badgeColor: true,
              showChevron: true,
              onTap: () => context.pushNamed(AppRoutes.accountSuspended),
            ),
            const _SettingsDivider(),
            const _SettingsRow(
              icon: Icons.credit_card,
              label: 'Payment Methods',
              showChevron: true,
            ),
            const _SettingsDivider(),
            const _SettingsRow(
              icon: Icons.calendar_month,
              label: 'Billing History',
              showChevron: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            'Support',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SettingsCard(
          children: [
            _SettingsRow(
              icon: Icons.help_outline,
              label: 'Help Center',
              showChevron: true,
              onTap: () => _launchUrl(
                context,
                'https://globalnightlife.club/help-center.html',
              ),
            ),
            const _SettingsDivider(),
            _SettingsRow(
              icon: Icons.shield_outlined,
              label: 'Privacy Policy',
              showChevron: true,
              onTap: () => _launchUrl(
                context,
                'https://globalnightlife.club/refund-policy.html',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link')),
      );
    }
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool badgeColor;
  final bool showChevron;
  final bool enabled;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor = false,
    this.showChevron = true,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: enabled ? AppColors.primaryDark : AppColors.hint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: enabled ? AppColors.textPrimary : AppColors.hint,
                    fontSize: 16.5,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor
                        ? AppColors.primaryDark
                        : AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.hint,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.border,
      margin: const EdgeInsets.only(left: 15, right: 15),
    );
  }
}

class _AppInfo extends StatelessWidget {
  const _AppInfo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'GNL Merchant App',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.hint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.hint, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.hint, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.goNamed(AppRoutes.login);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
