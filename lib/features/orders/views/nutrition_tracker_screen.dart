import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NutritionTrackerScreen extends StatelessWidget {
  const NutritionTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthViewModel>(context).currentUser?.uid;
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Nutrition Tracker",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: userId == null
                  ? const Center(child: Text("Please login to see stats"))
                  : StreamBuilder<List<OrderModel>>(
                      stream: orderViewModel.getMyOrdersStream(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final orders = snapshot.data ?? [];
                        if (orders.isEmpty) {
                          return const Center(
                            child: Text(
                              "No data yet. Place an order to start tracking!",
                            ),
                          );
                        }

                        // Calculate total calories (simulated calculation)
                        double totalCalories = 0;
                        for (var order in orders) {
                          for (var item in order.items) {
                            // Since OrderItemModel might not have calories, we'll use a fixed multiplier for demo
                            totalCalories += (item.quantity * 250.0);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCalorieCard(totalCalories, orders.length),
                              const SizedBox(height: 24),
                              const Text(
                                "Daily Breakdown (Recent)",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: orders.length > 5
                                      ? 5
                                      : orders.length,
                                  itemBuilder: (context, index) {
                                    final order = orders[index];
                                    double orderCals = 0;
                                    for (var item in order.items)
                                      orderCals += item.quantity * 250;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        title: Text(
                                          "Order #${order.tokenNumber}",
                                        ),
                                        subtitle: Text(
                                          "${order.items.length} items",
                                        ),
                                        trailing: Text(
                                          "${orderCals.toInt()} kcal",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(double calories, int orderCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            "Total Calories Consumed",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "${calories.toInt()} kcal",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Over $orderCount orders",
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
