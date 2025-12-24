import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:fdsmart/features/menu/views/menu_item_detail_screen.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpecialOfferCard extends StatelessWidget {
  final MenuItemModel item;
  final String discount;

  const SpecialOfferCard({
    super.key,
    required this.item,
    required this.discount,
  });

  Widget _buildImage() {
    if (item.imageUrl.startsWith('local:')) {
      final assetName = item.imageUrl.replaceFirst('local:', '');
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (c, e, s) => Container(
          width: 100,
          height: 100,
          color: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.fastfood, color: AppColors.primary),
        ),
      );
    } else if (item.imageUrl.isNotEmpty) {
      return Image.network(
        item.imageUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (c, e, s) => Container(
          width: 100,
          height: 100,
          color: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.fastfood, color: AppColors.primary),
        ),
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        color: AppColors.primary.withOpacity(0.1),
        child: const Icon(Icons.fastfood, color: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuItemDetailScreen(item: item)),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImage(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Rs. ${item.price.toInt()}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "SPECIAL",
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Consumer<OrderViewModel>(
                              builder: (context, orderModel, child) {
                                return GestureDetector(
                                  onTap: () {
                                    orderModel.addToCart(
                                      OrderItemModel(
                                        menuItemId: item.id,
                                        name: item.name,
                                        price: item.price,
                                        quantity: 1,
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("${item.name} added!"),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            Positioned(
              top: 8,
              left: 8,
              child: Consumer<AuthViewModel>(
                builder: (context, authViewModel, child) {
                  final isFavorite =
                      authViewModel.currentUser?.favorites.contains(item.id) ??
                      false;
                  return GestureDetector(
                    onTap: () => authViewModel.toggleFavorite(item.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite
                            ? Colors.red
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            // Discount badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  discount,
                  style: const TextStyle(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
