import 'dart:developer';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api/api_endpoints.dart';
import '../../../di/providers.dart';
import '../../../domain/models/club.dart';
import '../../../domain/models/club_gallery_request.dart';
import '../../../domain/models/location.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/global_app_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../club/providers/club_provider.dart';

class ClubInfoScreen extends ConsumerStatefulWidget {
  const ClubInfoScreen({super.key});

  @override
  ConsumerState<ClubInfoScreen> createState() => _ClubInfoScreenState();
}

class _ClubInfoScreenState extends ConsumerState<ClubInfoScreen> {
  Club? _originalClub;

  final _clubNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _zipController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _websiteController = TextEditingController();
  final _dressCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _aboutUsDescController = TextEditingController();
  final _aboutUsPointsController = TextEditingController();

  File? _logoFile;
  File? _coverImageFile;
  final List<File> _newClubImages = [];

  LocationCountry? _selectedCountry;
  LocationCity? _selectedCity;
  LocationArea? _selectedArea;

  bool _is18Plus = false;
  bool _hasDanceFloor = false;
  bool _servesAlcohol = false;

  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const Map<String, List<String>> _defaultTimes = {
    'Monday': ['18:00', '03:00'],
    'Tuesday': ['18:00', '03:00'],
    'Wednesday': ['18:00', '03:00'],
    'Thursday': ['18:00', '03:00'],
    'Friday': ['20:00', '04:00'],
    'Saturday': ['20:00', '04:00'],
    'Sunday': ['18:00', '02:00'],
  };

  final Map<String, List<TextEditingController>> _timeControllers = {};
  final Map<String, bool> _isClosed = {};

  bool _isEditing = false;
  bool _isSaving = false;
  bool _initialized = false;
  bool _locationAttempted = false;

  bool get _fieldsEnabled => _isEditing;

  String _imageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '${ApiEndpoints.baseUrl}$url';
  }

  static const _imageTypes = XTypeGroup(
    label: 'Images',
    extensions: ['jpg', 'jpeg', 'png'],
  );

  List<LocationArea> get _availableAreas {
    if (_selectedCity != null) {
      return _selectedCity!.areas;
    }

    return _selectedCountry?.cities
            .expand((city) => city.areas)
            .toList(growable: false) ??
        const [];
  }

  @override
  void initState() {
    super.initState();
    for (final day in _days) {
      final times = _defaultTimes[day]!;
      _timeControllers[day] = [
        TextEditingController(text: times[0]),
        TextEditingController(text: times[1]),
      ];
      _isClosed[day] = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(clubProvider);
      if (state.clubs.isEmpty) {
        ref.read(clubProvider.notifier).loadClubs();
      }
      if (state.locations.isEmpty) {
        ref.read(clubProvider.notifier).loadLocations();
      }
    });
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _zipController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
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

  Future<void> _pickLogo() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file != null) {
      setState(() {
        _logoFile = File(file.path);
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _logoFile = null;
    });
  }

  Future<void> _pickCoverImage() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file != null) {
      setState(() {
        _coverImageFile = File(file.path);
      });
    }
  }

  void _removeCoverImage() {
    setState(() {
      _coverImageFile = null;
    });
  }

  Future<void> _pickClubImage() async {
    final file = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (file != null) {
      setState(() {
        _newClubImages.add(File(file.path));
      });
    }
  }

  void _removeClubImage(int index) {
    setState(() {
      _newClubImages.removeAt(index);
    });
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

  void _populateFromClub(Club club) {
    _clubNameController.text = club.name;
    _addressController.text = club.address;
    _cityController.text = club.city;
    _areaController.text = club.area ?? '';
    _zipController.text = club.zipCode;
    _latitudeController.text = club.latitude?.toString() ?? '';
    _longitudeController.text = club.longitude?.toString() ?? '';
    _phoneController.text = club.contactNumber;
    _emailController.text = club.email;
    _instagramController.text = club.instagram ?? '';
    _facebookController.text = club.facebook ?? '';
    _websiteController.text = club.website ?? '';
    _dressCodeController.text = club.dressCode ?? '';
    _descriptionController.text = club.description ?? '';
    _shortDescriptionController.text = club.shortDescription ?? '';
    _aboutUsDescController.text = club.aboutUsDesc ?? '';
    _aboutUsPointsController.text =
        club.aboutUsHighlights?.join(', ') ?? '';
    _is18Plus = club.is18Plus;
    _hasDanceFloor = club.hasDanceFloor;
    _servesAlcohol = club.servesAlcohol;

    for (final day in _days) {
      final hours = club.openingHours?[day];
      _timeControllers[day]![0].text =
          hours == null || hours.open.isEmpty ? '00:00' : hours.open;
      _timeControllers[day]![1].text =
          hours == null || hours.close.isEmpty ? '00:00' : hours.close;
      _isClosed[day] = hours?.isClosed ?? false;
    }

    _logoFile = null;
    _coverImageFile = null;
    _newClubImages.clear();
    _selectedCountry = null;
    _selectedCity = null;
    _selectedArea = null;
    _locationAttempted = false;
    _initialized = true;

    _originalClub = club;
  }

  void _matchLocation(Club club, List<LocationCountry> locations) {
    _locationAttempted = true;
    final areaId = int.tryParse(club.area ?? '');
    if (areaId == null) return;

    for (final country in locations) {
      for (final city in country.cities) {
        for (final area in city.areas) {
          if (area.id == areaId) {
            _selectedCountry = country;
            _selectedCity = city;
            _selectedArea = area;
            _cityController.text = city.name;
            _areaController.text = area.id.toString();
            return;
          }
        }
      }
    }
  }

  void _onCountryChanged(LocationCountry? country) {
    setState(() {
      _selectedCountry = country;
      _selectedCity = null;
      _selectedArea = null;
      _cityController.clear();
      _areaController.clear();
    });
  }

  void _onCityChanged(LocationCity? city) {
    setState(() {
      _selectedCity = city;
      _selectedArea = null;
      _cityController.text = city?.name ?? '';
      _areaController.clear();
    });
  }

  void _onAreaChanged(LocationArea? area) {
    setState(() {
      _selectedArea = area;
      _areaController.text = area?.id.toString() ?? '';
    });
  }

  void _onCancelPressed() {
    final club = ref.read(clubProvider).clubs.isNotEmpty
        ? ref.read(clubProvider).clubs.first
        : null;
    if (!_isEditing) {
      context.pop();
      return;
    }
    if (club == null) {
      context.pop();
      return;
    }
    setState(() {
      _isEditing = false;
      _populateFromClub(club);
    });
  }

  void _onPrimaryPressed() {
    if (_isEditing) {
      _handleUpdate();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (_clubNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Club name is required',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
      return;
    }

    final clubId = await ref.read(tokenStorageProvider).getClubId();
    if (!mounted) return;
    if (clubId == null || clubId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Club id not found. Please contact support.',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
      return;
    }

    final currentClub = ref.read(clubProvider).clubs.isNotEmpty
        ? ref.read(clubProvider).clubs.first
        : null;

    final openingHours = <String, OpeningHours>{};
    for (final day in _days) {
      openingHours[day] = OpeningHours(
        open: _timeControllers[day]![0].text,
        close: _timeControllers[day]![1].text,
        isClosed: _isClosed[day] ?? false,
      );
    }

    final club = Club(
      name: _clubNameController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      zipCode: _zipController.text.trim(),
      contactNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      area: _areaController.text.trim(),
      latitude: double.tryParse(_latitudeController.text.trim()),
      longitude: double.tryParse(_longitudeController.text.trim()),
      website: _websiteController.text.trim(),
      instagram: _instagramController.text.trim(),
      facebook: _facebookController.text.trim(),
      logoUrl: _logoFile?.path ?? currentClub?.logoUrl,
      coverUrl: _coverImageFile?.path ?? currentClub?.coverUrl,
      imageUrls: currentClub?.imageUrls,
      openingHours: openingHours,
      dressCode: _dressCodeController.text.trim(),
      description: _descriptionController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
      aboutUsDesc: _aboutUsDescController.text.trim(),
      aboutUsHighlights: _aboutUsPointsController.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      is18Plus: _is18Plus,
      hasDanceFloor: _hasDanceFloor,
      servesAlcohol: _servesAlcohol,
    );
    // log(club.aboutUsHighlights.toString());

    final notifier = ref.read(clubProvider.notifier);
    setState(() => _isSaving = true);

    final success = await notifier.updateClub(clubId, club, original: _originalClub);

    if (success) {
      for (final file in _newClubImages) {
        await notifier.createGallery(
          clubId,
          ClubGalleryRequest(
            images: [file.path],
            reviewPoints: 'ambience',
            isPrimary: false,
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Club updated successfully',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
      final freshClubs = await ref.read(clubProvider.notifier).loadClubs();
      if (!mounted) return;
      final freshClub =
          freshClubs.isNotEmpty ? freshClubs.first : club;
      setState(() {
        _isEditing = false;
        _populateFromClub(freshClub);
      });
    } else {
      final error = ref.read(clubProvider).error ?? 'Failed to update club';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.card,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubState = ref.watch(clubProvider);
    final club = clubState.clubs.isNotEmpty ? clubState.clubs.first : null;

    if (club != null && !_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _populateFromClub(club));
        }
      });
    }

    if (club != null &&
        _initialized &&
        !_locationAttempted &&
        club.area != null &&
        club.area!.isNotEmpty &&
        clubState.locations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _matchLocation(club, clubState.locations));
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: const GlobalAppBar(title: 'Club Info'),
      body: SafeArea(
        top: false,
        child: clubState.isLoading && club == null
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryDark,
                ),
              )
            : club == null
                ? const Center(
                    child: Text(
                      'No club information available',
                      style: TextStyle(
                        color: AppColors.hint,
                        fontSize: 16,
                      ),
                    ),
                  )
                : SingleChildScrollView(
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
                        _buildLogoUploadCard(club.logoUrl),
                        const SizedBox(height: 20),
                        _buildCoverImageUploadCard(club.coverUrl),
                        const SizedBox(height: 20),
                        _buildLabeledField(
                          label: 'Club Name*',
                          controller: _clubNameController,
                          hint: 'Enter club name',
                          icon: Icons.business_rounded,
                        ),
                        const SizedBox(height: 18),
                        _buildLabeledField(
                          label: 'Address*',
                          controller: _addressController,
                          hint: 'Full address',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLocationDropdown<LocationCountry>(
                                label: 'Country',
                                hint: clubState.isLocationsLoading
                                    ? 'Loading...'
                                    : 'Select country',
                                value: _selectedCountry,
                                items: clubState.locations,
                                itemLabel: (country) => country.name,
                                onChanged: _onCountryChanged,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLocationDropdown<LocationCity>(
                                label: 'City*',
                                hint: 'Select city',
                                value: _selectedCity,
                                items: _selectedCountry?.cities ?? const [],
                                itemLabel: (city) => city.name,
                                onChanged: _onCityChanged,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLocationDropdown<LocationArea>(
                                label: 'Area',
                                hint: 'Select area',
                                value: _selectedArea,
                                items: _availableAreas,
                                itemLabel: (area) => area.name,
                                onChanged: _onAreaChanged,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Zip Code',
                                controller: _zipController,
                                hint: '411001',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Latitude',
                                controller: _latitudeController,
                                hint: '28.6139',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLabeledField(
                                label: 'Longitude',
                                controller: _longitudeController,
                                hint: '77.2090',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _buildLabeledField(
                          label: 'Contact Number*',
                          controller: _phoneController,
                          hint: '+91 98765 43210',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 18),
                        _buildLabeledField(
                          label: 'Email*',
                          controller: _emailController,
                          hint: 'club@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Social Media',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabeledField(
                          controller: _instagramController,
                          hint: 'Instagram username',
                          icon: Icons.camera_alt_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildLabeledField(
                          controller: _facebookController,
                          hint: 'Facebook page',
                          icon: Icons.facebook,
                        ),
                        const SizedBox(height: 12),
                        _buildLabeledField(
                          label: 'Website',
                          controller: _websiteController,
                          hint: 'https://yourclub.com',
                          icon: Icons.language,
                          keyboardType: TextInputType.url,
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
                                'Opening Hours',
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
                                onChanged: (v) =>
                                    setState(() => _is18Plus = v),
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
      bottomNavigationBar: club == null ? null : _buildBottomBar(),
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
          enabled: _fieldsEnabled,
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

  Widget _buildLocationDropdown<T>({
    required String label,
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required ValueChanged<T?>? onChanged,
  }) {
    final T? selectedValue =
        value != null && items.contains(value) ? value : null;

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
        DropdownButtonFormField<T>(
          key: ValueKey<T?>(selectedValue),
          initialValue: selectedValue,
          isExpanded: true,
          dropdownColor: AppColors.card,
          iconEnabledColor: AppColors.hint,
          iconDisabledColor: AppColors.hint,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
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
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _fieldsEnabled ? onChanged : null,
        ),
      ],
    );
  }

  Widget _buildLogoUploadCard(String? logoUrl) {
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
                'Club Logo',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              if (_fieldsEnabled && _logoFile != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: _removeLogo,
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
          if (_fieldsEnabled)
            _buildImagePickerRow(
              pickedFile: _logoFile,
              existingUrl: logoUrl,
              onPick: _pickLogo,
              uploadLabel: 'Upload Logo',
            )
          else
            GestureDetector(
              onTap: null,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _logoThumbnail(logoUrl),
              ),
            ),
        ],
      ),
    );
  }

  Widget _logoThumbnail(String? logoUrl) {
    if (_logoFile != null) {
      return Image.file(_logoFile!, fit: BoxFit.cover);
    }
    final resolved = _imageUrl(logoUrl);
    if (resolved.isNotEmpty) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, color: AppColors.hint, size: 32),
            SizedBox(height: 8),
            Text(
              'Upload club logo',
              style: TextStyle(color: AppColors.hint, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'PNG, JPG (Max 5MB)',
              style: TextStyle(color: AppColors.hint, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.file_upload_outlined, color: AppColors.hint, size: 32),
        SizedBox(height: 8),
        Text(
          'Upload club logo',
          style: TextStyle(color: AppColors.hint, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'PNG, JPG (Max 5MB)',
          style: TextStyle(color: AppColors.hint, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCoverImageUploadCard(String? coverUrl) {
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
                'Cover Image',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              if (_fieldsEnabled && _coverImageFile != null) ...[
                const Spacer(),
                GestureDetector(
                  onTap: _removeCoverImage,
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
          if (_fieldsEnabled)
            _buildImagePickerRow(
              pickedFile: _coverImageFile,
              existingUrl: coverUrl,
              onPick: _pickCoverImage,
              uploadLabel: 'Upload Cover',
            )
          else
            GestureDetector(
              onTap: null,
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _coverThumbnail(coverUrl),
              ),
            ),
        ],
      ),
    );
  }

  Widget _coverThumbnail(String? coverUrl) {
    if (_coverImageFile != null) {
      return Image.file(_coverImageFile!, fit: BoxFit.cover);
    }
    final resolved = _imageUrl(coverUrl);
    if (resolved.isNotEmpty) {
      return Image.network(
        resolved,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_upload_outlined, color: AppColors.hint, size: 32),
            SizedBox(height: 8),
            Text(
              'Upload cover image',
              style: TextStyle(color: AppColors.hint, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'PNG, JPG (Max 10MB)',
              style: TextStyle(color: AppColors.hint, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.file_upload_outlined, color: AppColors.hint, size: 32),
        SizedBox(height: 8),
        Text(
          'Upload cover image',
          style: TextStyle(color: AppColors.hint, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'PNG, JPG (Max 10MB)',
          style: TextStyle(color: AppColors.hint, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildImagePickerRow({
    required File? pickedFile,
    required String? existingUrl,
    required VoidCallback onPick,
    required String uploadLabel,
  }) {
    final existingResolved = _imageUrl(existingUrl);
    final hasImage = pickedFile != null || existingResolved.isNotEmpty;

    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  pickedFile != null
                      ? Image.file(pickedFile, fit: BoxFit.cover)
                      : Image.network(
                          existingResolved,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceAlt,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.hint,
                              size: 24,
                            ),
                          ),
                        ),
                  Positioned(
                    right: 4,
                    bottom: 4,
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
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: AppColors.hint, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    uploadLabel,
                    style: const TextStyle(
                      color: AppColors.hint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImageGrid(List<String>? existingUrls) {
    final existing = existingUrls ?? const <String>[];
    final children = <Widget>[];

    for (final url in existing) {
      children.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            _imageUrl(url),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceAlt,
              child: const Icon(
                Icons.image_outlined,
                color: AppColors.hint,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }

    for (var i = 0; i < _newClubImages.length; i++) {
      children.add(
        Stack(
          fit: StackFit.expand,
          children: [
            Image.file(_newClubImages[i], fit: BoxFit.cover),
            if (_fieldsEnabled)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeClubImage(i),
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
              ),
          ],
        ),
      );
    }

    if (_fieldsEnabled && existing.length + _newClubImages.length < 6) {
      children.add(
        GestureDetector(
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
            child: const Icon(Icons.add, color: AppColors.hint, size: 24),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1,
      children: children,
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
          onChanged: _fieldsEnabled ? onChanged : null,
          activeThumbColor: AppColors.textPrimary,
          activeTrackColor: AppColors.primaryDark,
          inactiveTrackColor: AppColors.surfaceAlt,
        ),
      ],
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
            child: closed
                ? Center(
                  child: const Text(
                      'Closed',
                      style: TextStyle(
                        color: AppColors.hint,
                        fontSize: 14,
                      ),
                    ),
                )
                : Row(
                    children: [
                      Expanded(
                        child: _buildTimeField(
                          controller: controllers[0],
                          enabled: _fieldsEnabled,
                          onTap: _fieldsEnabled
                              ? () => _pickTime(controllers[0])
                              : null,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildTimeField(
                          controller: controllers[1],
                          enabled: _fieldsEnabled,
                          onTap: _fieldsEnabled
                              ? () => _pickTime(controllers[1])
                              : null,
                        ),
                      ),
                    ],
                  ),
          ),
          if (_fieldsEnabled) ...[
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

  Widget _buildBottomBar() {
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
              onPressed: _isSaving ? null : _onCancelPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
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
                text: _isEditing ? 'Update' : 'Edit',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _onPrimaryPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
