import 'dart:io';
import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/auth/views/settings_screen.dart';
import 'package:fdsmart/features/orders/views/my_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.currentUser;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const AppHeader(),
                  const SizedBox(height: 32),

                  // Profile Avatar with Edit Icon
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage:
                            user?.profileImageUrl != null &&
                                user!.profileImageUrl!.isNotEmpty
                            ? (user.profileImageUrl!.startsWith('http')
                                  ? NetworkImage(user.profileImageUrl!)
                                  : FileImage(File(user.profileImageUrl!))
                                        as ImageProvider)
                            : null,
                        child:
                            user?.profileImageUrl == null ||
                                user!.profileImageUrl!.isEmpty
                            ? const Icon(
                                Icons.person_rounded,
                                size: 60,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(authViewModel),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (user?.phone != null)
                    Text(
                      user!.phone!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Wallet & Features Section
                  _buildProfileItem(
                    icon: Icons.history_rounded,
                    title: "Order History",
                    onTap: () {
                      // Handled by main navigation (tab index)
                    },
                  ),

                  _buildProfileItem(
                    icon: Icons.edit_rounded,
                    title: "Edit Profile",
                    onTap: () => _showEditProfileDialog(context, authViewModel),
                  ),

                  _buildProfileItem(
                    icon: Icons.rate_review_rounded,
                    title: "My Reviews",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyReviewsScreen(),
                      ),
                    ),
                  ),

                  _buildProfileItem(
                    icon: Icons.settings_rounded,
                    title: "Settings",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),

                  const SizedBox(height: 32),

                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      authViewModel.signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ],
              ),
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
        title: const Text("Edit Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _pickImage(model);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.image),
              label: const Text("Change Photo"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await model.updateProfile(
                name: nameCtrl.text,
                phone: phoneCtrl.text,
              );
              Navigator.pop(context);
            },
            child: const Text("Save"),
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
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing != null
            ? Text(
                trailing,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              )
            : const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
        onTap: onTap,
      ),
    );
  }
}
