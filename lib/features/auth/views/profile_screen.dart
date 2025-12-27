import 'dart:io';
import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/auth/views/settings_screen.dart';
import 'package:fdsmart/features/orders/views/my_reviews_screen.dart';
import 'package:fdsmart/features/orders/views/order_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  final bool showHeader;
  const ProfileScreen({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.currentUser;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (showHeader) const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // Profile Avatar Section
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Profile Avatar with Edit Icon
                              Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.primaryGradient,
                                      border: Border.all(
                                        color: AppColors.primaryLight,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryShadow,
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: user?.profileImageUrl != null &&
                                              user!.profileImageUrl!.isNotEmpty
                                          ? (user.profileImageUrl!.startsWith('http')
                                                  ? Image.network(
                                                      user.profileImageUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: AppColors.surfaceLight,
                                                          child: Icon(
                                                            Icons.person_rounded,
                                                            size: 50,
                                                            color: AppColors.primary,
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Image.file(
                                                      File(user.profileImageUrl!),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: AppColors.surfaceLight,
                                                          child: Icon(
                                                            Icons.person_rounded,
                                                            size: 50,
                                                            color: AppColors.primary,
                                                          ),
                                                        );
                                                      },
                                                    ))
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.primary.withOpacity(0.2),
                                                    AppColors.primaryDark.withOpacity(0.1),
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person_rounded,
                                                size: 50,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () => _pickImage(authViewModel),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.surface,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryShadow,
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // User Name
                              Text(
                                user?.name ?? 'Guest User',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),

                              // User Email
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_rounded,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      user?.email ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Phone Number
                              if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      user.phone!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ],

                              // Role Badge
                              if (user?.role != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: user?.role == 'admin'
                                        ? const LinearGradient(
                                            colors: [Color(0xFFFF4757), Color(0xFFE84118)],
                                          )
                                        : AppColors.accentGradient,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (user?.role == 'admin'
                                                ? const Color(0xFFFF4757)
                                                : AppColors.accent)
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        user?.role == 'admin'
                                            ? Icons.admin_panel_settings_rounded
                                            : Icons.person_rounded,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (user?.role ?? 'user').toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Profile Actions Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.divider,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              if (user?.role != 'admin')
                                _buildProfileItem(
                                  context: context,
                                  icon: Icons.history_rounded,
                                  title: "Order History",
                                  subtitle: "View your past orders",
                                  iconColor: AppColors.info,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OrderHistoryScreen(),
                                    ),
                                  ),
                                ),

                              _buildProfileItem(
                                context: context,
                                icon: Icons.edit_rounded,
                                title: "Edit Profile",
                                subtitle: "Update your information",
                                iconColor: AppColors.primary,
                                onTap: () => _showEditProfileDialog(context, authViewModel),
                              ),

                              if (user?.role != 'admin')
                                _buildProfileItem(
                                  context: context,
                                  icon: Icons.rate_review_rounded,
                                  title: "My Reviews",
                                  subtitle: "Manage your reviews",
                                  iconColor: AppColors.secondary,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyReviewsScreen(),
                                    ),
                                  ),
                                ),

                              _buildProfileItem(
                                context: context,
                                icon: Icons.settings_rounded,
                                title: "Settings",
                                subtitle: "App preferences",
                                iconColor: AppColors.accent,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Logout Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                authViewModel.signOut();
                                Navigator.pushReplacementNamed(context, '/login');
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: AppColors.error,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Logout",
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Sign out from your account",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.error,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthViewModel model) {
    final nameCtrl = TextEditingController(text: model.currentUser?.name);
    final phoneCtrl = TextEditingController(text: model.currentUser?.phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Update Profile",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Update your information below to keep your profile current.",
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  hintText: "Enter your full name",
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.divider, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "e.g. +94 77 123 4567",
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.divider, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 1),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _pickImage(model),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.info.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: AppColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Change Profile Photo",
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Select from gallery",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await model.updateProfile(
                  name: nameCtrl.text,
                  phone: phoneCtrl.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Profile updated successfully",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text(
                "Save Changes",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(AuthViewModel model) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // For local demo, we store the path
      // Note: In real production, upload to Firebase Storage first
      await model.updateProfile(profileImageUrl: image.path);
    }
  }

  Widget _buildProfileItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      trailing,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
