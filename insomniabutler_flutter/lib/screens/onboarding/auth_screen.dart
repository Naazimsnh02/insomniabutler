import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart';
import '../../services/user_service.dart';
import '../../widgets/glass_card.dart';

/// Onboarding Screen 7: Registration/Login
class AuthScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AuthScreen({super.key, required this.onComplete});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegistering = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isRegistering) {
        final user = await client.auth.register(
          _emailController.text.trim(),
          _nameController.text.trim(),
        );

        if (user != null) {
          await UserService.setCurrentUser(user);
          widget.onComplete();
        } else {
          _showError('Email already exists or registration failed.');
        }
      } else {
        final user = await client.auth.login(_emailController.text.trim());

        if (user != null) {
          await UserService.setCurrentUser(user);
          widget.onComplete();
        } else {
          _showError('Invalid email or user not found.');
        }
      }
    } catch (e) {
      _showError('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.accentError.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        color: const Color(0xFF080D20), // Fallback base color
        child: Stack(
          children: [
            // Deep Night Background - Linear Gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.bgMainGradient,
                ),
              ),
            ),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),

                      // Title Section
                      Text(
                        _isRegistering ? 'Create Account' : 'Welcome Back',
                        style: AppTextStyles.h2,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        _isRegistering
                            ? 'Join us for a better night\'s sleep.'
                            : 'Sign in to rescue your rest.',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // Form Fields
                      if (_isRegistering) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Your name',
                          icon: Icons.person_outline_rounded,
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'name@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),

                      if (!_isRegistering)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.xl),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: _isRegistering ? 'Register' : 'Login',
                          isLoading: _isLoading,
                          onPressed: _handleAuth,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // Toggle Auth Mode
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isRegistering
                                ? 'Joined us before? '
                                : 'New to the Butler? ',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                              () => _isRegistering = !_isRegistering,
                            ),
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(
                                _isRegistering ? 'Log in' : 'Register',
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 120,
                      ), // Extra space for dots and scroll
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          borderRadius: AppRadius.lg,
          color: AppColors.bgSecondary.withOpacity(0.4),
          border: Border.all(
            color: AppColors.accentPrimary.withOpacity(0.3),
            width: 1.5,
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySm.copyWith(
                color: AppColors.textTertiary.withOpacity(0.5),
              ),
              border: InputBorder.none,
              icon: Icon(
                icon,
                color: AppColors.accentPrimary.withOpacity(0.8),
                size: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelLg.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
