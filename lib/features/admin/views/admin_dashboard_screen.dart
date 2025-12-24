import 'package:fdsmart/core/widgets/app_header.dart';

import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/menu/models/menu_item_model.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/views/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const AdminOrderView();
      case 1:
        return const AdminMenuView();
      case 2:
        return const AdminUserView();
      case 3:
        return const ProfileScreen();
      default:
        return const AdminOrderView();
    }
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                            color: AppColors.primary,
                          ),
                        ),
                        DropdownButton<String>(
                          value: order.status,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          items:
                              [
                                'preparing',
                                'ready',
                                'completed',
                                'cancelled',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value.toUpperCase(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              orderViewModel.updateOrderStatus(
                                order.id,
                                newValue,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Order #${order.tokenNumber} updated to $newValue",
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    ...order.items.map(
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "${i.quantity}x ${i.name}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Total: Rs. ${order.totalPrice}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Manage Menu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show dialog to add item
                    _showAddItemDialog(context, menuModel);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...menuModel.items.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      item.imageUrl.isNotEmpty &&
                          item.imageUrl.startsWith('http')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            item.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(Icons.fastfood, color: AppColors.primary),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Rs. ${item.price}",
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          menuModel.toggleAvailability(item.id, val);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => menuModel.deleteMenuItem(item.id),
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

  void _showAddItemDialog(BuildContext context, MenuViewModel model) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    String category = 'food';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Menu Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Item Name"),
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(labelText: "Price (Rs.)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: imgCtrl,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: ['food', 'drink']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => category = v!,
                decoration: const InputDecoration(labelText: "Category"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              model.addMenuItem(
                MenuItemModel(
                  id: '',
                  name: nameCtrl.text,
                  description: 'Canteen Item',
                  price: double.tryParse(priceCtrl.text) ?? 10.0,
                  imageUrl: imgCtrl.text,
                  category: category,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class AdminUserView extends StatelessWidget {
  const AdminUserView({super.key});

  @override
  Widget build(BuildContext context) {
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    return StreamBuilder<List<UserModel>>(
      stream: authViewModel.getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        final users = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(
                  user.name ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${user.email} • ${user.role}"),
                trailing: IconButton(
                  icon: const Icon(Icons.person_remove, color: AppColors.error),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Remove User?"),
                        content: Text(
                          "Are you sure you want to remove ${user.name}?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              authViewModel.deleteUser(user.uid);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Remove",
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
