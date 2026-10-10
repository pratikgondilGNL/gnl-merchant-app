import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api/api_endpoints.dart';
import '../../../di/providers.dart';
import '../../../domain/models/event.dart';
import '../../../domain/models/event_category.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/global_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../club/providers/club_provider.dart';
import '../providers/event_provider.dart';

class UpdateEventScreen extends ConsumerStatefulWidget {
  final Event? event;
  final String? eventId;

  const UpdateEventScreen({super.key, this.event, this.eventId});

  @override
  ConsumerState<UpdateEventScreen> createState() => _UpdateEventScreenState();
}

class _UpdateEventScreenState extends ConsumerState<UpdateEventScreen> {
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _djArtistController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _minSpendController = TextEditingController();
  final _coupleEntryFeeController = TextEditingController();
  final _maleEntryFeeController = TextEditingController();
  final _femaleEntryFeeController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _totalCapacityController = TextEditingController();

  late final bool _isUpdate;
  String _musicGenre = 'edm';
  EventStatus _status = EventStatus.live;
  bool _isActive = true;
  bool _isTop = false;
  File? _bannerFile;
  EventCategory? _selectedCategory;
  int? _categoryId;
  Event? _sourceEvent;
  String? _loadedEventId;
  bool _eventLoadStarted = false;

  static const _imageTypes = XTypeGroup(
    label: 'Images',
    extensions: ['jpg', 'jpeg', 'png'],
  );

  String _bannerUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiEndpoints.baseUrl}$url';
  }

  @override
  void initState() {
    super.initState();
    _isUpdate = widget.event != null || widget.eventId != null;
    final event = widget.event;
    if (event != null) {
      _populateEvent(event);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(eventProvider.notifier);
      final state = ref.read(eventProvider);
      if (state.categories.isEmpty && !state.isCategoriesLoading) {
        notifier.loadCategories();
      }
      if (_isUpdate && widget.event == null) {
        _loadEventForUpdate();
      }
    });
  }

  Future<void> _loadEventForUpdate() async {
    if (!mounted) return;
    setState(() => _eventLoadStarted = true);
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

  void _populateEvent(Event event) {
    _sourceEvent = event;
    _nameController.text = event.name;
    _dateController.text =
        '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';
    _startTimeController.text = event.startTime;
    _endTimeController.text = event.endTime;
    _descriptionController.text = event.description;
    _djArtistController.text = event.djArtist ?? '';
    _entryFeeController.text = event.entryFee?.toStringAsFixed(0) ?? '';
    _minSpendController.text = event.minSpend?.toStringAsFixed(0) ?? '';
    _coupleEntryFeeController.text =
        event.coupleEntryFee?.toStringAsFixed(0) ?? '';
    _maleEntryFeeController.text =
        event.maleEntryFee?.toStringAsFixed(0) ?? '';
    _femaleEntryFeeController.text =
        event.femaleEntryFee?.toStringAsFixed(0) ?? '';
    _musicGenre = event.musicGenre ?? 'edm';
    _status = event.status;
    _specialInstructionsController.text = event.specialInstructions ?? '';
    _discountPercentageController.text =
        event.discountPercentage?.toString() ?? '0';
    _isActive = event.isActive;
    _isTop = event.isTop;
    _totalCapacityController.text = event.totalCapacity?.toString() ?? '';
    _categoryId = event.category;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    _djArtistController.dispose();
    _entryFeeController.dispose();
    _minSpendController.dispose();
    _coupleEntryFeeController.dispose();
    _maleEntryFeeController.dispose();
    _femaleEntryFeeController.dispose();
    _specialInstructionsController.dispose();
    _discountPercentageController.dispose();
    _totalCapacityController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file != null) {
      setState(() {
        _bannerFile = File(file.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
    if (date != null) {
      setState(() {
        _dateController.text =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.card,
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      _showMessage('Event name is required');
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      _showMessage('Date is required');
      return;
    }

    if (_startTimeController.text.trim().isEmpty) {
      _showMessage('Start time is required');
      return;
    }

    if (_endTimeController.text.trim().isEmpty) {
      _showMessage('End time is required');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Event description is required');
      return;
    }

    final clubId = await ref.read(tokenStorageProvider).getClubId();
    if (!mounted) return;
    if (clubId == null || clubId.isEmpty) {
      _showMessage('Club id not found. Please contact support.');
      return;
    }

    final clubState = ref.read(clubProvider);
    final club =
        clubState.clubs.isNotEmpty ? clubState.clubs.first : null;

    final sourceEvent = _sourceEvent ?? widget.event;

    final event = Event(
      id: sourceEvent?.id,
      bannerUrl: _bannerFile?.path ?? sourceEvent?.bannerUrl,
      name: _nameController.text.trim(),
      date: DateTime.parse(_dateController.text.trim()),
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      description: _descriptionController.text.trim(),
      djArtist: _djArtistController.text.trim().isEmpty
          ? null
          : _djArtistController.text.trim(),
      entryFee: _entryFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_entryFeeController.text.trim()),
      minSpend: _minSpendController.text.trim().isEmpty
          ? null
          : double.tryParse(_minSpendController.text.trim()),
      coupleEntryFee: _coupleEntryFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_coupleEntryFeeController.text.trim()),
      maleEntryFee: _maleEntryFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_maleEntryFeeController.text.trim()),
      femaleEntryFee: _femaleEntryFeeController.text.trim().isEmpty
          ? null
          : double.tryParse(_femaleEntryFeeController.text.trim()),
      musicGenre: _musicGenre,
      status: _status,
      specialInstructions: _specialInstructionsController.text.trim().isEmpty
          ? null
          : _specialInstructionsController.text.trim(),
      latitude: sourceEvent?.latitude ?? club?.latitude?.toString(),
      longitude: sourceEvent?.longitude ?? club?.longitude?.toString(),
      discountPercentage: _discountPercentageController.text.trim().isEmpty
          ? 0
          : int.tryParse(_discountPercentageController.text.trim()) ?? 0,
      discountType: 'flat',
      isActive: _isActive,
      isTop: _isTop,
      totalCapacity: _totalCapacityController.text.trim().isEmpty
          ? 0
          : int.tryParse(_totalCapacityController.text.trim()),
      bookedCapacity: sourceEvent?.bookedCapacity ?? 0,
      category: _selectedCategory?.id,
      area: sourceEvent?.area ?? int.tryParse(club?.area ?? ''),
    );

    final notifier = ref.read(eventProvider.notifier);
    if (!_isUpdate) {
      notifier.createEvent(event, clubId);
    } else {
      notifier.updateEvent(event, clubId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventProvider);

    if (state.categories.isNotEmpty &&
        _selectedCategory == null &&
        _categoryId != null) {
      EventCategory? match;
      for (final category in state.categories) {
        if (category.id == _categoryId) {
          match = category;
          break;
        }
      }
      if (match != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _selectedCategory = match);
          }
        });
      }
    }

    if (_isUpdate && widget.event == null && _loadedEventId == null) {
      Event? matchingEvent;
      for (final event in state.events) {
        if (event.id == widget.eventId) {
          matchingEvent = event;
          break;
        }
      }
      if (matchingEvent != null) {
        final event = matchingEvent;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _populateEvent(event);
            _loadedEventId = event.id;
          });
        });
      }
    }

    ref.listen<EventState>(eventProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUpdate
                  ? 'Event updated successfully'
                  : 'Event created successfully',
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.card,
          ),
        );
        context.pop();
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error!,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.card,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GlobalAppBar(
        title: _isUpdate ? 'Update Event' : 'Add Event',
      ),
      body: SafeArea(
        top: false,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(EventState state) {
    if (_isUpdate && widget.event == null) {
      if (!_eventLoadStarted || state.isEventsLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        );
      }

      if (state.eventsError != null) {
        return _buildEventLoadError(state.eventsError!);
      }

      if (_loadedEventId == null) {
        return _buildEventLoadError(
          'Event not found. Please try again.',
        );
      }
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildSectionTitle(),
                const SizedBox(height: 24),
                _buildBannerUploadCard(),
                const SizedBox(height: 20),
                _buildField(
                  label: 'Event Name*',
                  controller: _nameController,
                  hint: 'Friday Night Vibes',
                ),
                const SizedBox(height: 16),
                _buildDateField(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        label: 'Start Time*',
                        controller: _startTimeController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeField(
                        label: 'End Time*',
                        controller: _endTimeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildField(
                  label: 'DJ / Artist Name',
                  controller: _djArtistController,
                  hint: 'DJ Mark',
                ),
                const SizedBox(height: 20),
                _buildPricingSection(),
                const SizedBox(height: 16),
                _buildEntryFeesSection(),
                const SizedBox(height: 16),
                _buildDiscountSection(),
                const SizedBox(height: 16),
                _buildCapacitySection(),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                _buildStatusDropdown(),
                const SizedBox(height: 16),
                _buildField(
                  label: 'Special Instructions',
                  controller: _specialInstructionsController,
                  hint:
                      'Dress code, age restrictions, special requirements...',
                  maxLines: 3,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _buildBottomButtons(state.isLoading),
      ],
    );
  }

  Widget _buildEventLoadError(String message) {
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
            PrimaryButton1(
              text: 'Retry',
              onPressed: () => _loadEventForUpdate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isUpdate
              ? 'Update your current event information'
              : 'Add a new event to your club',
          style: const TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerUploadCard() {
    final resolvedExisting = _bannerUrl(_sourceEvent?.bannerUrl);
    final hasBanner = _bannerFile != null || resolvedExisting.isNotEmpty;

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
            children: [
              const Text(
                'Event Banner',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              if (_bannerFile != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _bannerFile = null;
                    });
                  },
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickBanner,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasBanner ? AppColors.primaryDark : AppColors.border,
                  width: hasBanner ? 1 : 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasBanner
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_bannerFile != null)
                          Image.file(
                            _bannerFile!,
                            fit: BoxFit.cover,
                          )
                        else
                          Image.network(
                            resolvedExisting,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.file_upload_outlined,
                                  color: AppColors.hint,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Upload event banner',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Recommended: 1920x1080px',
                                  style: TextStyle(
                                    color: AppColors.hint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.file_upload_outlined,
                          color: AppColors.hint,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Upload event banner',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Recommended: 1920x1080px',
                          style: TextStyle(
                            color: AppColors.hint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    String? label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
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
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          filledColor: AppColors.card,
          borderRadius: 12,
          showBorder: true,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          hintColor: AppColors.hint,
          textColor: AppColors.textPrimary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date*',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.hint,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _dateController.text.isEmpty
                      ? 'Select date'
                      : _dateController.text,
                  style: TextStyle(
                    color: _dateController.text.isEmpty
                        ? AppColors.hint
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickTime(controller),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: AppColors.hint,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  controller.text.isEmpty ? 'Select time' : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty
                        ? AppColors.hint
                        : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Description*',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _descriptionController,
          hintText:
              'Describe your event, DJ lineup, special performances...',
          maxLines: 4,
          filledColor: AppColors.card,
          borderRadius: 12,
          showBorder: true,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          hintColor: AppColors.hint,
          textColor: AppColors.textPrimary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Pricing',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildField(
                label: 'Entry Fee',
                controller: _entryFeeController,
                hint: '50',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildField(
                label: 'Min. Spend',
                controller: _minSpendController,
                hint: '200',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntryFeesSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Entry Fees by Category',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  label: 'Couple',
                  controller: _coupleEntryFeeController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Male',
                  controller: _maleEntryFeeController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  label: 'Female',
                  controller: _femaleEntryFeeController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discount',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildField(
                  label: 'Percentage',
                  controller: _discountPercentageController,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapacitySection() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Capacity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Total Capacity',
            controller: _totalCapacityController,
            hint: '0',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final state = ref.watch(eventProvider);
    final categories = state.categories;
    final isLoading = state.isCategoriesLoading;

    String hintText;
    if (isLoading) {
      hintText = 'Loading...';
    } else if (state.categoriesError != null) {
      hintText = state.categoriesError!;
    } else if (categories.isEmpty) {
      hintText = 'No categories available';
    } else {
      hintText = 'Select category';
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EventCategory>(
            key: ValueKey<EventCategory?>(_selectedCategory),
            initialValue: _selectedCategory,
            isExpanded: true,
            dropdownColor: AppColors.card,
            iconEnabledColor: AppColors.hint,
            iconDisabledColor: AppColors.hint,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.hint,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryDark),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: categories
                .map(
                  (category) => DropdownMenuItem<EventCategory>(
                    value: category,
                    child: Text(
                      category.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: isLoading || categories.isEmpty
                ? null
                : (category) {
                    setState(() => _selectedCategory = category);
                  },
          ),
          if (state.categoriesError != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.categoriesError!,
                    style: const TextStyle(
                      color: AppColors.hint,
                      fontSize: 12,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () =>
                          ref.read(eventProvider.notifier).loadCategories(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
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

  Widget _buildStatusDropdown() {
    const statuses = [
      ('Live', EventStatus.live),
      ('Draft', EventStatus.draft),
      ('Ended', EventStatus.ended),
      ('Upcoming', EventStatus.upcoming),
    ];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Status & Visibility',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          _buildSwitchRow(
            label: 'Active',
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
          ),
          const SizedBox(height: 12),
          _buildSwitchRow(
            label: 'Top Event',
            value: _isTop,
            onChanged: (v) => setState(() => _isTop = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EventStatus>(
            key: ValueKey<EventStatus>(_status),
            initialValue: _status,
            isExpanded: true,
            dropdownColor: AppColors.card,
            iconEnabledColor: AppColors.hint,
            iconDisabledColor: AppColors.hint,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryDark),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            items: statuses
                .map(
                  (status) => DropdownMenuItem<EventStatus>(
                    value: status.$2,
                    child: Text(
                      status.$1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _status = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton1(
            text: _isUpdate ? 'Save Changes' : 'Add Event',
            isLoading: isLoading,
            onPressed: isLoading ? null : _save,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: isLoading ? null : () => context.pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.hint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
