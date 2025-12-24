import 'package:flutter/material.dart';
import 'package:fdsmart/core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
            ),
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              // color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'FDSmart',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
