import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/user.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final phoneController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  String _selectedCountryCode = '+91';

  String? _phoneError;
  String? _nameError;
  String? _emailError;
  String? _cityError;

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    cityController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) return 'Enter a valid phone number';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.trim().isEmpty) return 'City is required';
    if (value.trim().length < 2) return 'Enter a valid city';
    return null;
  }

  bool _validate() {
    final phoneErr = _validatePhone(phoneController.text);
    final nameErr = _validateName(nameController.text);
    final emailErr = _validateEmail(emailController.text);
    final cityErr = _validateCity(cityController.text);

    setState(() {
      _phoneError = phoneErr;
      _nameError = nameErr;
      _emailError = emailErr;
      _cityError = cityErr;
    });

    return phoneErr == null &&
        nameErr == null &&
        emailErr == null &&
        cityErr == null;
  }

  void _clearFieldError(String field) {
    setState(() {
      switch (field) {
        case 'phone':
          if (_phoneError != null) _phoneError = null;
          break;
        case 'name':
          if (_nameError != null) _nameError = null;
          break;
        case 'email':
          if (_emailError != null) _emailError = null;
          break;
        case 'city':
          if (_cityError != null) _cityError = null;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitleSection(),
                    const SizedBox(height: 24),
                    _buildPhoneField(),
                    const SizedBox(height: 16),
                    _buildNameField(),
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildCityField(),
                    const SizedBox(height: 16),
                    _buildNoteBox(),
                  ],
                ),
              ),
            ),
            _buildBottomButton(authState),
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
            'Sign Up',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Fill in your details to get started',
          style: TextStyle(
            color: AppColors.hint,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number*',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountryCodeDropdown(),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                hintText: '234 567 8900',
                controller: phoneController,
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                filledColor: AppColors.card,
                enabledBorderColor: AppColors.border,
                focusedBorderColor: AppColors.primaryDark,
                errorBorderColor: AppColors.error,
                hintColor: AppColors.hint,
                prefixIconColor: AppColors.hint,
                borderRadius: 12,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                onChanged: (_) => _clearFieldError('phone'),
              ),
            ),
          ],
        ),
        if (_phoneError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _phoneError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCountryCodeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountryCode,
          isDense: true,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
          items: const [
            DropdownMenuItem(value: '+971', child: Text('\u{1F1E6}\u{1F1EA} +971')),
            DropdownMenuItem(value: '+91', child: Text('\u{1F1EE}\u{1F1F3} +91')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCountryCode = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: 'Full Name*',
          hintText: 'Enter your full name',
          controller: nameController,
          prefixIcon: Icons.person,
          filledColor: AppColors.card,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          errorBorderColor: AppColors.error,
          hintColor: AppColors.hint,
          prefixIconColor: AppColors.hint,
          borderRadius: 12,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          onChanged: (_) => _clearFieldError('name'),
        ),
        if (_nameError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _nameError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: 'Email*',
          hintText: 'your@email.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          filledColor: AppColors.card,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          errorBorderColor: AppColors.error,
          hintColor: AppColors.hint,
          borderRadius: 12,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          onChanged: (_) => _clearFieldError('email'),
        ),
        if (_emailError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _emailError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: 'City*',
          hintText: 'Enter your city',
          controller: cityController,
          prefixIcon: Icons.location_on,
          filledColor: AppColors.card,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          errorBorderColor: AppColors.error,
          hintColor: AppColors.hint,
          prefixIconColor: AppColors.hint,
          borderRadius: 12,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          onChanged: (_) => _clearFieldError('city'),
        ),
        if (_cityError != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              _cityError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoteBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        '* Required fields. You\'ll receive an OTP on your email for verification.',
        style: TextStyle(
          color: AppColors.hint,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBottomButton(AuthState authState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: authState.isLoading
              ? null
              : () async {
                  if (!_validate()) return;
                  final phone = '$_selectedCountryCode ${phoneController.text.trim()}';
                  final user = User(
                    phone: phone,
                    fullName: nameController.text.trim(),
                    email: emailController.text.trim(),
                    city: cityController.text.trim(),
                  );
                  final success = await ref.read(authProvider.notifier).signUp(user);
                  if (success && mounted) {
                    context.pushNamed(AppRoutes.otp);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
            foregroundColor: AppColors.textPrimary,
            disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: authState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Text(
                  'Generate OTP',
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
