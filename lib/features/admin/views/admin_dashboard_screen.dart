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
import '../../orders/views/order_history_screen.dart';

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
              label: 'Active',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
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
        return const AdminOrderView(onlyActive: true);
      case 1:
        return const AdminOrderView(onlyActive: false);
      case 2:
        return const AdminMenuView();
      case 3:
        return const AdminUserView();
      case 4:
        return const ProfileScreen(showHeader: false);
      default:
        return const AdminOrderView(onlyActive: true);
    }
  }
}

class AdminOrderView extends StatelessWidget {
  final bool onlyActive;
  const AdminOrderView({super.key, required this.onlyActive});

  @override
  Widget build(BuildContext context) {
    var orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    return StreamBuilder<List<OrderModel>>(
      stream: orderViewModel.getAllActiveOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = snapshot.data ?? [];
        if (onlyActive) {
          orders = orders
              .where((o) => o.status != 'completed' && o.status != 'cancelled')
              .toList();
        } else {
          orders = orders
              .where((o) => o.status == 'completed' || o.status == 'cancelled')
              .toList();
        }

        if (orders.isEmpty) {
          return Center(
            child: Text(onlyActive ? "No active orders" : "No past orders"),
          );
        }

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
                                    "Order #${order.tokenNumber} marked as $newValue",
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
                    const SizedBox(height: 4),
                    Text(
                      "Date: ${order.createdAt.toString().split('.')[0]}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
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
                  onPressed: () => _showItemDialog(context, menuModel),
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
                  leading: _buildImage(item.imageUrl),
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
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.info),
                        onPressed: () =>
                            _showItemDialog(context, menuModel, item: item),
                      ),
                      Switch(
                        value: item.isAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          menuModel.toggleAvailability(item.id, val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "${item.name} is now ${val ? 'Available' : 'Unavailable'}",
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () =>
                            _confirmDeleteItem(context, menuModel, item),
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

  Widget _buildImage(String url) {
    if (url.startsWith('local:')) {
      final assetName = url.replaceFirst('local:', '');
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          'assets/images/$assetName',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
        ),
      );
    }
    return const Icon(Icons.fastfood, color: AppColors.primary);
  }

  void _confirmDeleteItem(
    BuildContext context,
    MenuViewModel model,
    MenuItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Item?"),
        content: Text(
          "Are you sure you want to delete '${item.name}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              model.deleteMenuItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Successfully deleted '${item.name}'")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(
    BuildContext context,
    MenuViewModel model, {
    MenuItemModel? item,
  }) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(text: item?.price.toString() ?? '');
    final imgCtrl = TextEditingController(text: item?.imageUrl ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final tagCtrl = TextEditingController(text: item?.tag ?? '');
    final calCtrl = TextEditingController(
      text: item?.calories.toString() ?? '200',
    );
    final ratingCtrl = TextEditingController(
      text: item?.rating.toString() ?? '4.5',
    );

    String category = item?.category ?? 'food';
    bool isSpecial = item?.isSpecial ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(item == null ? "Add Menu Item" : "Update Menu Item"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Item Name"),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: "Price (Rs.)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: calCtrl,
                  decoration: const InputDecoration(labelText: "Calories"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ratingCtrl,
                  decoration: const InputDecoration(labelText: "Rating (0-5)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imgCtrl,
                  decoration: const InputDecoration(
                    labelText: "Image (local:name.jpg)",
                  ),
                ),
                TextField(
                  controller: tagCtrl,
                  decoration: const InputDecoration(
                    labelText: "Tag (e.g. healthy)",
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  items: ['food', 'drink']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => category = v!,
                  decoration: const InputDecoration(labelText: "Category"),
                ),
                SwitchListTile(
                  title: const Text("Today's Special Deal"),
                  value: isSpecial,
                  onChanged: (val) => setState(() => isSpecial = val),
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
                final newItem = MenuItemModel(
                  id: item?.id ?? '',
                  name: nameCtrl.text,
                  description: descCtrl.text,
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  imageUrl: imgCtrl.text,
                  category: category,
                  tag: tagCtrl.text,
                  isSpecial: isSpecial,
                  calories: double.tryParse(calCtrl.text) ?? 200.0,
                  rating: double.tryParse(ratingCtrl.text) ?? 4.5,
                  isAvailable: item?.isAvailable ?? true,
                );
                if (item == null) {
                  model.addMenuItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully added '${newItem.name}'"),
                    ),
                  );
                } else {
                  model.updateMenuItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully updated '${newItem.name}'"),
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(item == null ? "Add" : "Update"),
            ),
          ],
        ),
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
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final users = snapshot.data ?? [];
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.history_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderHistoryScreen(userId: user.uid),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.person_remove,
                        color: AppColors.error,
                      ),
                      onPressed: () =>
                          _confirmDeleteUser(context, authViewModel, user),
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

  void _confirmDeleteUser(
    BuildContext context,
    AuthViewModel auth,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove User?"),
        content: Text(
          "Are you sure you want to remove ${user.name}? This user will lose access to the system.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              auth.deleteUser(user.uid);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("User '${user.name}' has been removed")),
              );
            },
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
