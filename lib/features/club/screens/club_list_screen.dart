import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/club.dart';
import '../../../domain/models/location.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/global_app_bar.dart';
import '../providers/club_draft_provider.dart';
import '../providers/club_provider.dart';

class ClubDetailsScreen extends ConsumerStatefulWidget {
  const ClubDetailsScreen({super.key});

  @override
  ConsumerState<ClubDetailsScreen> createState() => _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends ConsumerState<ClubDetailsScreen> {
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

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(cleaned)) {
      return 'Enter a valid contact number (7-15 digits)';
    }
    return null;
  }

  File? _logoFile;
  File? _coverImageFile;
  LocationCountry? _selectedCountry;
  LocationCity? _selectedCity;
  LocationArea? _selectedArea;

  static const _imageTypes = XTypeGroup(
    label: 'Images',
    extensions: ['jpg', 'jpeg', 'png'],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clubProvider.notifier).loadLocations();
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

  List<LocationArea> get _availableAreas {
    if (_selectedCity != null) {
      return _selectedCity!.areas;
    }

    return _selectedCountry?.cities
            .expand((city) => city.areas)
            .toList(growable: false) ??
        const [];
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
                        'Club Details', 'Complete your club profile'),
                    const SizedBox(height: 24),
                    _buildLogoUploadCard(),
                    const SizedBox(height: 20),
                    _buildCoverImageUploadCard(),
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
                            onChanged: clubState.locations.isEmpty
                                ? null
                                : _onCountryChanged,
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
                            onChanged: _selectedCountry == null
                                ? null
                                : _onCityChanged,
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
                            onChanged: _selectedCountry == null ||
                                    _availableAreas.isEmpty
                                ? null
                                : _onAreaChanged,
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
                      validator: _validatePhone,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
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
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
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
    String? Function(String?)? validator,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
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
          validator: validator,
          autoValidateMode: autoValidateMode,
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
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLogoUploadCard() {
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
                'Club Logo*',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              if (_logoFile != null) ...[
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
          Row(
            children: [
              GestureDetector(
                onTap: _pickLogo,
                child: Container(
                  width: 80,
                  height: 80,
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
                  child: _logoFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _logoFile!,
                              fit: BoxFit.cover,
                            ),
                          ],
                        )
                      : const Icon(
                          Icons.file_upload_outlined,
                          color: AppColors.hint,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _logoFile != null ? 'Logo uploaded' : 'Upload club logo',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PNG, JPG (Max 5MB)',
                    style: TextStyle(
                      color: AppColors.hint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoverImageUploadCard() {
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
              if (_coverImageFile != null) ...[
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
          GestureDetector(
            onTap: _pickCoverImage,
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
              child: _coverImageFile != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _coverImageFile!,
                          fit: BoxFit.cover,
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
                          'Upload cover image',
                          style: TextStyle(
                            color: AppColors.hint,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'PNG, JPG (Max 10MB)',
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

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            if (_validatePhone(_phoneController.text) != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Please enter a valid contact number',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.card,
                ),
              );
              return;
            }

            if (_clubNameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Club name is required',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: AppColors.card,
                ),
              );
              return;
            }

            // Store draft data
            ref.read(clubDraftProvider.notifier).state = Club(
              name: _clubNameController.text,
              address: _addressController.text,
              city: _cityController.text,
              zipCode: _zipController.text,
              contactNumber: _phoneController.text,
              email: _emailController.text,
              area: _areaController.text,
              latitude: double.tryParse(_latitudeController.text),
              longitude: double.tryParse(_longitudeController.text),
              instagram: _instagramController.text,
              facebook: _facebookController.text,
              website: _websiteController.text,
              logoUrl: _logoFile
                  ?.path, // For now, passing path. Repo should handle upload.
              coverUrl: _coverImageFile?.path,
            );

            context.pushNamed(AppRoutes.clubDetailsExtra);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Next',
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
