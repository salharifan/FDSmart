import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuItemDetailScreen extends StatefulWidget {
  final MenuItemModel item;

  const MenuItemDetailScreen({super.key, required this.item});

  @override
  State<MenuItemDetailScreen> createState() => _MenuItemDetailScreenState();
}

class _MenuItemDetailScreenState extends State<MenuItemDetailScreen> {
  int quantity = 1;

  Widget _buildImage() {
    if (widget.item.imageUrl.startsWith('local:')) {
      final assetName = widget.item.imageUrl.replaceFirst('local:', '');
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
        ),
      );
    } else if (widget.item.imageUrl.isNotEmpty) {
      return Image.network(
        widget.item.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 50),
        ),
      );
    } else {
      return Container(
        color: AppColors.surfaceLight,
        child: Icon(
          widget.item.category == 'food'
              ? Icons.lunch_dining
              : Icons.local_drink,
          size: 100,
          color: AppColors.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.glassBlack,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: _buildImage(),
          ),

          // Content Scrollable Sheet
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          "Rs. ${widget.item.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Rating and Calories
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.item.calories.toInt()} kcal",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.item.isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.item.isAvailable ? "Available" : "Stock Out",
                            style: TextStyle(
                              color: widget.item.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quantity Selector
                    Row(
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => setState(() => quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Cart Button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Consumer<OrderViewModel>(
              builder: (context, orderModel, child) {
                return CustomButton(
                  text:
                      "ADD TO ORDER  •  Rs. ${(widget.item.price * quantity).toStringAsFixed(0)}",
                  isLoading: orderModel.isLoading,
                  onPressed: () {
                    final orderItem = OrderItemModel(
                      menuItemId: widget.item.id,
                      name: widget.item.name,
                      price: widget.item.price,
                      quantity: quantity,
                    );
                    orderModel.addToCart(orderItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Added $quantity ${widget.item.name} to order!",
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
