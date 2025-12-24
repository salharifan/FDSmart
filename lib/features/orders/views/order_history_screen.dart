import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:fdsmart/features/orders/views/add_review_screen.dart';
import 'package:fdsmart/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:fdsmart/core/widgets/app_header.dart';

class OrderHistoryScreen extends StatelessWidget {
  final String? userId;
  const OrderHistoryScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final effectiveUserId =
        userId ?? Provider.of<AuthViewModel>(context).currentUser?.uid;
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                userId != null ? "User Order History" : "My Orders",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: effectiveUserId == null
                  ? const Center(child: Text("Please login to view orders"))
                  : StreamBuilder<List<OrderModel>>(
                      stream: orderViewModel.getMyOrdersStream(effectiveUserId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return const Center(
                            child: Text("Error loading orders"),
                          );
                        }

                        final orders = snapshot.data ?? [];

                        if (orders.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 64,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "No past orders yet",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: 200,
                                  child: CustomButton(
                                    text: "ORDER NOW",
                                    onPressed: () {
                                      // Ideally switch to menu tab.
                                      // This might be tricky from here, but we can pop or navigate.
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/home',
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          separatorBuilder: (c, i) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return _buildOrderCard(context, order);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    switch (order.statusEnum) {
      case OrderStatus.preparing:
        statusColor = Colors.orange;
        break;
      case OrderStatus.ready:
        statusColor = Colors.green;
        break;
      case OrderStatus.completed:
        statusColor = Colors.grey;
        break;
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Token: #${order.tokenNumber}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, hh:mm a').format(order.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${item.quantity}x ${item.name}",
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  Text(
                    "Rs. ${(item.price * item.quantity).toStringAsFixed(0)}",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Rs. ${order.totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (order.statusEnum == OrderStatus.completed) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: "LEAVE A REVIEW",
              isSecondary: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddReviewScreen(orderId: order.id),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
