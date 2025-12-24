import 'package:flutter/material.dart';
import 'package:fdsmart/core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({super.key, this.showBack = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.surfaceLight),
      child: Row(
        children: [
          if (showBack || Navigator.canPop(context))
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: onBack ?? () => Navigator.pop(context),
              ),
            ),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'FDSmart',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Healthier Choices, Smarter Orders',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
