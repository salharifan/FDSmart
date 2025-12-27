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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: const AppHeader(),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded, size: 24),
                activeIcon: Icon(Icons.dashboard_rounded, size: 26),
                label: 'Active',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded, size: 24),
                activeIcon: Icon(Icons.history_rounded, size: 26),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded, size: 24),
                activeIcon: Icon(Icons.menu_book_rounded, size: 26),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_rounded, size: 24),
                activeIcon: Icon(Icons.people_rounded, size: 26),
                label: 'Users',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 24),
                activeIcon: Icon(Icons.person_rounded, size: 26),
                label: 'Profile',
              ),
            ],
          ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'preparing':
        return AppColors.warning;
      case 'ready':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'preparing':
        return Icons.restaurant_rounded;
      case 'ready':
        return Icons.shopping_bag_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.pending_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    var orderViewModel = Provider.of<OrderViewModel>(context, listen: false);

    return StreamBuilder<List<OrderModel>>(
      stream: orderViewModel.getAllActiveOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading orders...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    onlyActive ? Icons.inbox_rounded : Icons.history_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  onlyActive ? "No Active Orders" : "No Order History",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  onlyActive
                      ? "All orders are completed or cancelled"
                      : "No completed or cancelled orders yet",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Section Header with Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        onlyActive ? 'Active Orders' : 'Order History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          onlyActive
                              ? Icons.pending_actions_rounded
                              : Icons.archive_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          orders.length.toString(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Orders List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final statusColor = _getStatusColor(order.status);
                  final statusIcon = _getStatusIcon(order.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          // Order Header with Token & Status Badge
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.surfaceLight,
                                  AppColors.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Token Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryShadow,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.confirmation_number_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "#${order.tokenNumber}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Status Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: DropdownButton<String>(
                                    value: order.status,
                                    underline: const SizedBox(),
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: statusColor,
                                    ),
                                    dropdownColor: AppColors.surfaceHighlight,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    items: [
                                      'preparing',
                                      'ready',
                                      'completed',
                                      'cancelled',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getStatusIcon(value),
                                              size: 16,
                                              color: _getStatusColor(value),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              value.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getStatusColor(value),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        orderViewModel.updateOrderStatus(
                                          order.id,
                                          newValue,
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    "Order #${order.tokenNumber} marked as $newValue",
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor:
                                                _getStatusColor(newValue),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Order Items
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_basket_rounded,
                                      size: 16,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Order Items',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...order.items.map(
                                  (i) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${i.quantity}x',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            i.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.textPrimary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  height: 1,
                                  color: AppColors.divider,
                                ),
                                const SizedBox(height: 16),
                                // Order Footer
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule_rounded,
                                              size: 14,
                                              color: AppColors.textTertiary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              order.createdAt
                                                  .toString()
                                                  .split('.')[0]
                                                  .substring(0, 16),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textTertiary,
                                                    fontSize: 11,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.success.withOpacity(0.2),
                                            AppColors.success.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color:
                                              AppColors.success.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'Rs. ',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            order.totalPrice.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.success,
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
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        return Column(
          children: [
            // Section Header with Add Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${menuModel.items.length} ${menuModel.items.length == 1 ? 'item' : 'items'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _showItemDialog(context, menuModel),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text("Add Item"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Menu Items Grid
            Expanded(
              child: menuModel.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 64,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "No Menu Items",
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start by adding your first menu item",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: menuModel.items.length,
                      itemBuilder: (context, index) {
                        final item = menuModel.items[index];
                        return Dismissible(
                          key: Key(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  side: BorderSide(color: AppColors.divider, width: 1),
                                ),
                                title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.error.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.delete_rounded,
                                        color: AppColors.error,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Delete Item?",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  "Are you sure you want to delete '${item.name}'? This action cannot be undone.",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.error.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                            ) ?? false;
                          },
                          onDismissed: (direction) {
                            menuModel.deleteMenuItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Successfully deleted '${item.name}'",
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              children: [
                                // Item Header
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.surfaceLight,
                                        AppColors.surface,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Item Image
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.divider,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: _buildImage(item.imageUrl),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Item Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ),
                                                if (item.isSpecial)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondary
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                        color: AppColors
                                                            .secondary
                                                            .withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star_rounded,
                                                          size: 12,
                                                          color: AppColors
                                                              .secondary,
                                                        ),
                                                        const SizedBox(width: 2),
                                                        Text(
                                                          'Special',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColors
                                                                .secondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        AppColors.success
                                                            .withOpacity(0.2),
                                                        AppColors.success
                                                            .withOpacity(0.1),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                    border: Border.all(
                                                      color: AppColors.success
                                                          .withOpacity(0.3),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        'Rs. ',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              AppColors.success,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        item.price.toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color:
                                                              AppColors.success,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.info
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star_rounded,
                                                        size: 12,
                                                        color: AppColors.info,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        item.rating.toString(),
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColors.info,
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
                                    ],
                                  ),
                                ),
                                // Item Actions
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Category Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.category == 'food'
                                              ? AppColors.foodYellow
                                                  .withOpacity(0.15)
                                              : AppColors.info.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              item.category == 'food'
                                                  ? Icons.restaurant_rounded
                                                  : Icons.local_cafe_rounded,
                                              size: 14,
                                              color: item.category == 'food'
                                                  ? AppColors.foodYellow
                                                  : AppColors.info,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.category.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: item.category == 'food'
                                                    ? AppColors.foodYellow
                                                    : AppColors.info,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      // Availability Toggle
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: item.isAvailable
                                              ? AppColors.success
                                                  .withOpacity(0.15)
                                              : AppColors.error.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              item.isAvailable
                                                  ? Icons.check_circle_rounded
                                                  : Icons.cancel_rounded,
                                              size: 14,
                                              color: item.isAvailable
                                                  ? AppColors.success
                                                  : AppColors.error,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                item.isAvailable
                                                    ? 'Available'
                                                    : 'Unavailable',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: item.isAvailable
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Switch(
                                              value: item.isAvailable,
                                              activeColor: AppColors.success,
                                              inactiveTrackColor: AppColors.error
                                                  .withOpacity(0.3),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              onChanged: (val) {
                                                menuModel.toggleAvailability(
                                                    item.id, val);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(
                                                          val
                                                              ? Icons
                                                                  .check_circle_rounded
                                                              : Icons
                                                                  .cancel_rounded,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 12),
                                                        Expanded(
                                                          child: Text(
                                                            "${item.name} is now ${val ? 'Available' : 'Unavailable'}",
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: val
                                                        ? AppColors.success
                                                        : AppColors.error,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Edit Button
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.info.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit_rounded,
                                            color: AppColors.info,
                                            size: 20,
                                          ),
                                          onPressed: () => _showItemDialog(
                                              context, menuModel,
                                              item: item),
                                          tooltip: 'Edit',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
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
      return Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.surfaceLight,
            child: Icon(
              Icons.fastfood_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          );
        },
      );
    }
    return Container(
      color: AppColors.surfaceLight,
      child: Icon(
        Icons.fastfood_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  void _confirmDeleteItem(
    BuildContext context,
    MenuViewModel model,
    MenuItemModel item,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Delete Item?",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete '${item.name}'? This action cannot be undone.",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                model.deleteMenuItem(item.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Successfully deleted '${item.name}'",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.divider, width: 1),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item == null ? Icons.add_rounded : Icons.edit_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                item == null ? "Add Menu Item" : "Update Menu Item",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Item Name",
                    prefixIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Description",
                    prefixIcon: Icon(Icons.description_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Price (Rs.)",
                          prefixIcon: Icon(Icons.attach_money_rounded, color: AppColors.success),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: "Calories",
                          prefixIcon: Icon(Icons.local_fire_department_rounded, color: AppColors.warning),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ratingCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Rating (0-5)",
                    prefixIcon: Icon(Icons.star_rounded, color: AppColors.secondary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imgCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Image (local:name.jpg)",
                    prefixIcon: Icon(Icons.image_rounded, color: AppColors.info),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    hintText: "local:burger.jpg",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagCtrl,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Tag (e.g. healthy)",
                    prefixIcon: Icon(Icons.label_rounded, color: AppColors.accent),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppColors.surfaceHighlight,
                  style: TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: "Category",
                    prefixIcon: Icon(
                      category == 'food' ? Icons.restaurant_rounded : Icons.local_cafe_rounded,
                      color: AppColors.primary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                  ),
                  items: ['food', 'drink'].map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Row(
                        children: [
                          Icon(
                            c == 'food' ? Icons.restaurant_rounded : Icons.local_cafe_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(c.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => category = v!);
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: SwitchListTile(
                    title: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Today's Special Deal",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: isSpecial,
                    activeColor: AppColors.secondary,
                    onChanged: (val) => setState(() => isSpecial = val),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
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
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Successfully added '${newItem.name}'",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else {
                    model.updateMenuItem(newItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Successfully updated '${newItem.name}'",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  item == null ? "Add Item" : "Update Item",
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminUserView extends StatelessWidget {
  const AdminUserView({super.key});

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primary;
      case 'user':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'user':
        return Icons.person_rounded;
      default:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    return StreamBuilder<List<UserModel>>(
      stream: authViewModel.getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading users...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "No Users Found",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "No registered users in the system",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Section Header with Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surface,
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Management',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${users.length} ${users.length == 1 ? 'user' : 'users'} registered',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.info.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          users.length.toString(),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Users List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final roleColor = _getRoleColor(user.role);
                  final roleIcon = _getRoleIcon(user.role);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.divider,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        children: [
                          // User Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.surfaceLight,
                                  AppColors.surface,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        roleColor.withOpacity(0.3),
                                        roleColor.withOpacity(0.15),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: roleColor.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: roleColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name ?? 'No Name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.email_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              user.email,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Role Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: roleColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: roleColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        roleIcon,
                                        size: 16,
                                        color: roleColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        user.role.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: roleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // User Actions
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // User ID Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.fingerprint_rounded,
                                        size: 14,
                                        color: AppColors.textTertiary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ID: ${user.uid.substring(0, 8)}...',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // View History Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.info.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.history_rounded,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderHistoryScreen(
                                          userId: user.uid,
                                        ),
                                      ),
                                    ),
                                    tooltip: 'View Order History',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Remove User Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.person_remove_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    onPressed: () => _confirmDeleteUser(
                                      context,
                                      authViewModel,
                                      user,
                                    ),
                                    tooltip: 'Remove User',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.divider, width: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_remove_rounded,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Remove User?",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to remove ${user.name}? This user will lose access to the system.",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                auth.deleteUser(user.uid);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "User '${user.name}' has been removed",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Remove", style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
