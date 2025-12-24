import 'package:fdsmart/core/widgets/app_header.dart';

import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

// ...

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: Row(
                children: [
                  // Sidebar (Navigation Rail)
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: AppColors.surfaceLight,
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        onPressed: () {
                          Provider.of<AuthViewModel>(
                            context,
                            listen: false,
                          ).signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_rounded),
                        label: Text('Orders'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.menu_book_rounded),
                        label: Text('Menu'),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  // Content
                  Expanded(
                    child: _selectedIndex == 0
                        ? const AdminOrderView()
                        : const AdminMenuView(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminOrderView extends StatelessWidget {
  const AdminOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    var orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    return StreamBuilder<List<OrderModel>>(
      stream: orderViewModel.getAllActiveOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No active orders"));
        }

        final orders = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Token #${order.tokenNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<String>(
                          value: order.status,
                          items:
                              [
                                'preparing',
                                'ready',
                                'completed',
                                'cancelled',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value.toUpperCase()),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              orderViewModel.updateOrderStatus(
                                order.id,
                                newValue,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Total: ${order.totalPrice} Tokens"),
                    ...order.items.map(
                      (i) => Text("- ${i.quantity}x ${i.name}"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AdminMenuView extends StatelessWidget {
  const AdminMenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuViewModel>(
      builder: (context, menuModel, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Simulating adding an item for demo
                menuModel.addMenuItem(
                  MenuItemModel(
                    id: '',
                    name: 'New Item ${DateTime.now().second}',
                    description: 'Description',
                    price: 10,
                    imageUrl: '',
                    category: 'food',
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add New Item (Demo)"),
            ),
            const SizedBox(height: 16),
            ...menuModel.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(
                      item.category == 'food'
                          ? Icons.lunch_dining
                          : Icons.local_cafe,
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text("${item.price} Tokens"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isAvailable,
                        onChanged: (val) {
                          // Update availability
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () {
                          // Confirm delete
                          menuModel.deleteMenuItem(item.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
