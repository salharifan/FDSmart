import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const MenuItemCard({super.key, required this.item, required this.onTap});

  Widget _buildImage() {
    if (item.imageUrl.startsWith('local:')) {
      final assetName = item.imageUrl.replaceFirst('local:', '');
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else if (item.imageUrl.isNotEmpty) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.fastfood, color: AppColors.textSecondary),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final isFavorite =
        authViewModel.currentUser?.favorites.contains(item.id) ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.surfaceLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.divider.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with modern overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: _buildImage(),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => authViewModel.toggleFavorite(item.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isFavorite 
                              ? Colors.red.withOpacity(0.15)
                              : AppColors.background.withOpacity(0.7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFavorite 
                                ? Colors.red.withOpacity(0.5)
                                : AppColors.divider.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 16,
                          color: isFavorite
                              ? Colors.red
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  // Calorie badge
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.divider.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${item.calories.toInt()}",
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Area with modern styling
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFB020), Color(0xFFFF8C00)],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.white,
                                      size: 11,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      item.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.currency_rupee_rounded,
                              color: AppColors.accent,
                              size: 14,
                            ),
                            Text(
                              "${item.price.toInt()}",
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryShadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
