import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  String? _emailError;

  @override
  void dispose() {
    emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  bool _validate() {
    final error = _validateEmail(emailController.text);
    setState(() => _emailError = error);
    return error == null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: _buildBody(authState),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AuthState authState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 48),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 24),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login to manage your nightclub',
                style: TextStyle(
                  color: AppColors.hint,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildEmailField(),
            const SizedBox(height: 24),
            _buildLoginButton(authState),
            const SizedBox(height: 24),
            _buildOrDivider(),
            const SizedBox(height: 24),
            _buildCreateAccountButton(),
            const SizedBox(height: 24),
            _buildTerms(),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLogo() {
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.wine_bar,
        color: AppColors.textPrimary,
        size: 40,
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: 'Email',
          labelStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          hintText: 'Enter your email',
          controller: emailController,
          focusNode: _emailFocusNode,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          hintColor: AppColors.hint,
          prefixIconColor: AppColors.hint,
          filledColor: AppColors.card,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryDark,
          errorBorderColor: AppColors.error,
          borderRadius: 12,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
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

  Widget _buildLoginButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: authState.isLoading
            ? null
            : () async {
                if (!_validate()) return;
                final success = await ref.read(authProvider.notifier).login(
                      email: emailController.text.trim(),
                    );
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
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'OR',
            style: TextStyle(
              color: AppColors.hint,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          context.pushNamed(AppRoutes.signup);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceAlt,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create New Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: const TextStyle(
          color: AppColors.hint,
          fontSize: 12,
        ),
        children: [
          const TextSpan(
            text: 'By continuing, you agree to our ',
          ),
          TextSpan(
            text: 'Terms',
            style: TextStyle(
              color: AppColors.primaryDark,
            ),
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}
