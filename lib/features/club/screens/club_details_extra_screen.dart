import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../di/providers.dart';
import '../../../domain/models/club.dart';
import '../../../domain/models/club_gallery_request.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/global_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/club_draft_provider.dart';
import '../providers/club_provider.dart';

class ClubDetailsExtraScreen extends ConsumerStatefulWidget {
  const ClubDetailsExtraScreen({super.key});

  @override
  ConsumerState<ClubDetailsExtraScreen> createState() =>
      _ClubDetailsExtraScreenState();
}

class _ClubDetailsExtraScreenState
    extends ConsumerState<ClubDetailsExtraScreen> {
  final _dressCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _aboutUsDescController = TextEditingController();
  final _aboutUsPointsController = TextEditingController();

  final List<File> _clubImages = [];

  bool _is18Plus = false;
  bool _hasDanceFloor = false;
  bool _servesAlcohol = false;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, List<TextEditingController>> _timeControllers = {};
  final Map<String, bool> _isClosed = {};

  @override
  void initState() {
    super.initState();

    final defaultTimes = {
      'Monday': ['18:00', '03:00'],
      'Tuesday': ['18:00', '03:00'],
      'Wednesday': ['18:00', '03:00'],
      'Thursday': ['18:00', '03:00'],
      'Friday': ['20:00', '04:00'],
      'Saturday': ['20:00', '04:00'],
      'Sunday': ['18:00', '02:00'],
    };

    for (final day in _days) {
      final times = defaultTimes[day]!;
      _timeControllers[day] = [
        TextEditingController(text: times[0]),
        TextEditingController(text: times[1]),
      ];
      _isClosed[day] = false;
    }
  }

  @override
  void dispose() {
    _dressCodeController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _aboutUsDescController.dispose();
    _aboutUsPointsController.dispose();
    for (final controllers in _timeControllers.values) {
      for (final c in controllers) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        controller.text =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  static const _imageTypes = XTypeGroup(
    label: 'Images',
    extensions: ['jpg', 'jpeg', 'png'],
  );

  Future<void> _pickClubImage() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file != null) {
      setState(() {
        _clubImages.add(File(file.path));
      });
    }
  }

  void _removeClubImage(int index) {
    setState(() {
      _clubImages.removeAt(index);
    });
  }

  Future<void> _handleCreateClub() async {
    final draft = ref.read(clubDraftProvider);
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing basic club details. Please go back.')),
      );
      return;
    }

    if (_clubImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 3 club images.')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description is required.')),
      );
      return;
    }

    final Map<String, OpeningHours> openingHours = {};
    for (final day in _days) {
      openingHours[day] = OpeningHours(
        open: _timeControllers[day]![0].text,
        close: _timeControllers[day]![1].text,
        isClosed: _isClosed[day] ?? false,
      );
    }

    final club = draft.copyWith(
      dressCode: _dressCodeController.text,
      description: _descriptionController.text,
      shortDescription: _shortDescriptionController.text,
      aboutUsDesc: _aboutUsDescController.text,
      aboutUsHighlights: _aboutUsPointsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      is18Plus: _is18Plus,
      hasDanceFloor: _hasDanceFloor,
      servesAlcohol: _servesAlcohol,
      openingHours: openingHours,
    );

    final notifier = ref.read(clubProvider.notifier);

    final clubId = await notifier.createClub(club);
    if (clubId == null) {
      final state = ref.read(clubProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error ?? 'Failed to create club')),
        );
      }
      return;
    }

    await ref.read(tokenStorageProvider).saveClubId(clubId);

    for (final file in _clubImages) {
      final success = await notifier.createGallery(
        clubId,
        ClubGalleryRequest(
          images: [file.path],
          reviewPoints: 'ambience',
          isPrimary: file == _clubImages.first,
        ),
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: ${file.path}')),
        );
      }
    }

    if (mounted) {
      ref.read(clubDraftProvider.notifier).state = null;
      context.pushReplacementNamed(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const GlobalAppBar(title: 'List My Club'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildSectionTitle(
                      'Club Details',
                      'Complete your club profile',
                    ),
                    const SizedBox(height: 24),
                    _buildLabeledField(
                      label: 'Dress Code',
                      controller: _dressCodeController,
                      hint: 'e.g. Smart Casual, Formal, etc.',
                      icon: Icons.checkroom_outlined,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Club Images* (Min 3)',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildImageGrid(),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload up to 6 images',
                            style: TextStyle(
                              color: AppColors.hint,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Opening Hours*',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._days.map(_buildDayRow),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabeledField(
                      label: 'Description*',
                      controller: _descriptionController,
                      hint:
                          'Describe your club, ambiance, music genre, special features...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'Short Description',
                      controller: _shortDescriptionController,
                      hint: 'A brief one-liner about your club',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    _buildSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amenities',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchRow(
                            label: '18+ Only',
                            value: _is18Plus,
                            onChanged: (v) => setState(() => _is18Plus = v),
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchRow(
                            label: 'Dance Floor',
                            value: _hasDanceFloor,
                            onChanged: (v) =>
                                setState(() => _hasDanceFloor = v),
                          ),
                          const SizedBox(height: 12),
                          _buildSwitchRow(
                            label: 'Serves Alcohol',
                            value: _servesAlcohol,
                            onChanged: (v) =>
                                setState(() => _servesAlcohol = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildLabeledField(
                      label: 'About Us',
                      controller: _aboutUsDescController,
                      hint: 'Tell us about your club...',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    _buildLabeledField(
                      label: 'About Us Highlights',
                      controller: _aboutUsPointsController,
                      hint: 'Key highlights, one per line...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(clubState.isLoading),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _buildSwitchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.textPrimary,
          activeTrackColor: AppColors.primaryDark,
          inactiveTrackColor: AppColors.surfaceAlt,
        ),
      ],
    );
  }

  Widget _buildLabeledField({
    String? label,
    required TextEditingController controller,
    String? hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
        CustomTextField(
          controller: controller,
          hintText: hint ?? '',
          prefixIcon: icon,
          keyboardType: keyboardType,
          maxLines: maxLines,
          filledColor: AppColors.card,
          borderRadius: 12,
          showBorder: true,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          hintColor: AppColors.hint,
          textColor: AppColors.textPrimary,
          prefixIconColor: AppColors.hint,
          contentPadding: EdgeInsets.only(
            left: icon != null ? 48 : 16,
            right: 16,
            top: 14,
            bottom: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    final totalSlots = _clubImages.length + 1;
    final itemCount = totalSlots > 6 ? 6 : totalSlots;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: List.generate(itemCount, (index) {
        if (index == _clubImages.length && _clubImages.length < 6) {
          return GestureDetector(
            onTap: _pickClubImage,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.hint,
                size: 24,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _removeClubImage(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.border,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _clubImages[index],
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayRow(String day) {
    final controllers = _timeControllers[day]!;
    final closed = _isClosed[day] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              day,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    controller: controllers[0],
                    enabled: !closed,
                    onTap: closed ? null : () => _pickTime(controllers[0]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '-',
                    style: TextStyle(
                      color: closed ? AppColors.hint : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTimeField(
                    controller: controllers[1],
                    enabled: !closed,
                    onTap: closed ? null : () => _pickTime(controllers[1]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isClosed[day] = !closed;
              });
            },
            child: Text(
              closed ? 'Open' : 'Close',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          controller.text,
          style: TextStyle(
            color: enabled ? AppColors.textPrimary : AppColors.hint,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomButton(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 48,
              child: PrimaryButton1(
                text: 'Create Club',
                isLoading: isLoading,
                onPressed: isLoading ? null : _handleCreateClub,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
