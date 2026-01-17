import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../main.dart';

/// Onboarding Screen 7: Registration/Login
class AuthScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AuthScreen({Key? key, required this.onComplete}) : super(key: key);

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
        // Register using custom endpoint
        final user = await client.auth.register(
          _emailController.text.trim(),
          _nameController.text.trim(),
        );
        
        if (user != null) {
          // Success
          widget.onComplete();
        } else {
          _showError('Email already exists or registration failed.');
        }
      } else {
        // Login using custom endpoint
        final user = await client.auth.login(_emailController.text.trim());
        
        if (user != null) {
          // Success
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
        content: Text(message),
        backgroundColor: AppColors.accentError,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.containerPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Header
              Text(
                _isRegistering ? 'Create your Account' : 'Sign in to your Account',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _isRegistering 
                  ? 'Please fill in the details to create your account.' 
                  : 'Please enter your credentials to continue.',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Form Fields
              if (_isRegistering) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your name',
                  icon: Icons.person_outline,
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
                icon: Icons.lock_outline,
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
              PrimaryButton(
                text: _isRegistering ? 'Register' : 'Login',
                isLoading: _isLoading,
                onPressed: _handleAuth,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Social Auth
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.glassBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('Or login with', style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.glassBorder)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: _buildSocialButton('Apple', Icons.apple)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildSocialButton('Google', Icons.g_mobiledata_rounded)),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isRegistering ? 'Already have an account? ' : 'Don\'t have an account? ',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isRegistering = !_isRegistering),
                    child: Text(
                      _isRegistering ? 'Log in' : 'Register',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
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
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          borderRadius: AppBorderRadius.md,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
              border: InputBorder.none,
              icon: Icon(icon, color: AppColors.accentPrimary, size: 20),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'This field is required';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        border: Border.all(color: AppColors.glassBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.labelLg),
        ],
      ),
    );
  }
}
