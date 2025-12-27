import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:fdsmart/core/widgets/custom_text_field.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  void _handleReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    bool success = await authViewModel.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Email Sent"),
            content: const Text(
              "A password reset link has been sent to your email address.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to login
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authViewModel.errorMessage ?? "Failed to send reset email",
            ),
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
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Icon with gradient background
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 56,
                          color: AppColors.textInverse,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "No worries! Enter your email address and we'll send you a link to reset your password.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Form card
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.divider.withOpacity(0.5),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              label: "Email Address",
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 28),
                            Consumer<AuthViewModel>(
                              builder: (context, model, child) {
                                return CustomButton(
                                  text: "Send Reset Link",
                                  icon: Icons.send_rounded,
                                  isLoading: model.isLoading,
                                  onPressed: _handleReset,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Back to login
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        label: const Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
