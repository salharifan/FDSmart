import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fdsmart/core/widgets/app_header.dart';

class OrderPlacementScreen extends StatefulWidget {
  const OrderPlacementScreen({super.key});

  @override
  State<OrderPlacementScreen> createState() => _OrderPlacementScreenState();
}

class _OrderPlacementScreenState extends State<OrderPlacementScreen> {
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // Select all items by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderModel = Provider.of<OrderViewModel>(context, listen: false);
      setState(() {
        _selectedIndices.addAll(
          List.generate(orderModel.cartItems.length, (index) => index),
        );
      });
    });
  }

  double _calculateSelectedTotal(OrderViewModel orderModel) {
    double total = 0;
    for (int index in _selectedIndices) {
      if (index < orderModel.cartItems.length) {
        final item = orderModel.cartItems[index];
        total += item.price * item.quantity;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Consumer<OrderViewModel>(
                builder: (context, orderModel, child) {
                  if (orderModel.cartItems.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Your cart is empty",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: 200,
                            child: CustomButton(
                              text: "BROWSE MENU",
                              onPressed: () => Navigator.pop(
                                context,
                              ), // Assuming pushed from menu
                              isSecondary: true,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: orderModel.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = orderModel.cartItems[index];
                            final isSelected = _selectedIndices.contains(index);
                            return Card(
                              color: isSelected
                                  ? AppColors.surfaceLight
                                  : AppColors.surfaceLight.withOpacity(0.5),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedIndices.add(index);
                                      } else {
                                        _selectedIndices.remove(index);
                                      }
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                title: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                subtitle: Text(
                                  "${item.quantity} x Rs. ${item.price}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Rs. ${(item.price * item.quantity).toStringAsFixed(0)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Remove Item?"),
                                            content: Text(
                                              "Are you sure you want to remove '${item.name}' from your cart?",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text("CANCEL"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: TextButton.styleFrom(
                                                  foregroundColor:
                                                      AppColors.error,
                                                ),
                                                child: const Text("REMOVE"),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          setState(() {
                                            _selectedIndices.remove(index);
                                          });
                                          orderModel.removeFromCart(index);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "'${item.name}' removed from cart",
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Footer
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  "Rs. ${_calculateSelectedTotal(orderModel).toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedIndices.isNotEmpty &&
                                _selectedIndices.length <
                                    orderModel.cartItems.length)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  "${_selectedIndices.length} of ${orderModel.cartItems.length} items selected",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            CustomButton(
                              text: "CONFIRM ORDER",
                              isLoading: orderModel.isLoading,
                              onPressed: _selectedIndices.isEmpty
                                  ? null
                                  : () async {
                                      final authModel =
                                          Provider.of<AuthViewModel>(
                                            context,
                                            listen: false,
                                          );
                                      final userId = authModel.currentUser?.uid;

                                      if (userId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please login to place an order",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Create a list of only selected items
                                      List<OrderItemModel> selectedItems = [];
                                      for (int index in _selectedIndices) {
                                        if (index <
                                            orderModel.cartItems.length) {
                                          selectedItems.add(
                                            orderModel.cartItems[index],
                                          );
                                        }
                                      }

                                      if (selectedItems.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Please select at least one item",
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Temporarily replace cart with selected items
                                      final originalCart =
                                          List<OrderItemModel>.from(
                                            orderModel.cartItems,
                                          );
                                      orderModel.clearCart();
                                      for (var item in selectedItems) {
                                        orderModel.addToCart(item);
                                      }

                                      int? token = await orderModel.checkout(
                                        userId,
                                      );

                                      // Restore unselected items to cart
                                      for (
                                        int i = 0;
                                        i < originalCart.length;
                                        i++
                                      ) {
                                        if (!_selectedIndices.contains(i)) {
                                          orderModel.addToCart(originalCart[i]);
                                        }
                                      }

                                      if (token != null) {
                                        if (context.mounted) {
                                          setState(() {
                                            _selectedIndices.clear();
                                            // Re-select remaining items
                                            _selectedIndices.addAll(
                                              List.generate(
                                                orderModel.cartItems.length,
                                                (index) => index,
                                              ),
                                            );
                                          });
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: AppColors.success,
                                                    size: 80,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    "Payment Successful!",
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    "Your order has been placed.",
                                                    style: TextStyle(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const Divider(height: 32),
                                                  const Text(
                                                    "YOUR TOKEN NUMBER",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      letterSpacing: 1.2,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    "#$token",
                                                    style: const TextStyle(
                                                      fontSize: 48,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: CustomButton(
                                                      text: "TRACK ORDER",
                                                      onPressed: () {
                                                        Navigator.pop(
                                                          context,
                                                        ); // Close dialog
                                                        Navigator.pop(
                                                          context,
                                                        ); // Back to home
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Failed to place order. Try again.",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
