import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/auth/viewmodels/language_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final langModel = Provider.of<LanguageViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                langModel.translate('settings'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionHeader("Preferences"),
                  _buildSwitchTile(
                    icon: Icons.notifications_active_rounded,
                    title: "Enable Notifications",
                    value: _notificationsEnabled,
                    onChanged: (val) =>
                        setState(() => _notificationsEnabled = val),
                  ),
                  _buildListTile(
                    icon: Icons.language_rounded,
                    title: langModel.translate('language'),
                    trailing: langModel.currentLanguage.name.toUpperCase(),
                    onTap: () => _showLanguagePicker(context, langModel),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Account Security"),
                  _buildListTile(
                    icon: Icons.lock_rounded,
                    title: langModel.translate('change_password'),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _buildListTile(
                    icon: Icons.privacy_tip_rounded,
                    title: "Privacy Policy",
                    onTap: () {
                      // Open privacy link
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("About"),
                  _buildListTile(
                    icon: Icons.info_rounded,
                    title: "App Version",
                    trailing: "1.0.0",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, LanguageViewModel langModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Language / භාෂාව තෝරන්න / மொழியைத் தேர்ந்தெடுக்கவும்",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _langTile(context, "English", Language.english, langModel),
            _langTile(context, "සිංහල", Language.sinhala, langModel),
            _langTile(context, "தமிழ்", Language.tamil, langModel),
          ],
        ),
      ),
    );
  }

  Widget _langTile(
    BuildContext context,
    String label,
    Language lang,
    LanguageViewModel model,
  ) {
    final isSelected = model.currentLanguage == lang;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () {
        model.setLanguage(lang);
        Navigator.pop(context);
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    final authModel = Provider.of<AuthViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          "Change Password",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: passwordCtrl,
          obscureText: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            labelText: "New Password",
            labelStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordCtrl.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Password must be at least 6 characters"),
                  ),
                );
                return;
              }
              final success = await authModel.changePassword(passwordCtrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Password updated!"
                          : (authModel.errorMessage ?? "Failed"),
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.error,
                  ),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary.withOpacity(0.8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          if (onTap != null)
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
