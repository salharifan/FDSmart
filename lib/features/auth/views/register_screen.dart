import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:fdsmart/core/widgets/custom_text_field.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'user'; // 'user' or 'admin'

  void _handleRegister() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // Simple validation
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      }
      return;
    }

    bool success = await authViewModel.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _selectedRole,
    );

    if (success) {
      if (mounted) {
        if (_selectedRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authViewModel.errorMessage ?? 'Registration Failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Back button and logo
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const Spacer(),
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryShadow,
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.restaurant_menu_rounded,
                                color: AppColors.textInverse,
                                size: 28,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Title
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Join us for healthier food choices',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // Registration form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.divider.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone_rounded,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_rounded,
                        isPassword: true,
                      ),
                      const SizedBox(height: 28),
                      
                      // Role selection
                      const Text(
                        "Choose Account Type",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRoleCard(
                              title: "Customer",
                              icon: Icons.person_rounded,
                              role: "user",
                              isSelected: _selectedRole == 'user',
                              onTap: () => setState(() => _selectedRole = 'user'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildRoleCard(
                              title: "Admin",
                              icon: Icons.admin_panel_settings_rounded,
                              role: "admin",
                              isSelected: _selectedRole == 'admin',
                              onTap: () => setState(() => _selectedRole = 'admin'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Sign up button
                      Consumer<AuthViewModel>(
                        builder: (context, model, child) {
                          return CustomButton(
                            text: 'Create Account',
                            icon: Icons.arrow_forward_rounded,
                            isLoading: model.isLoading,
                            onPressed: _handleRegister,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Login link
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ShaderMask(
                          shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required String role,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primaryLight.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.divider.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.backgroundElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
