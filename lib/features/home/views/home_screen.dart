import 'dart:async';
import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/offline_banner.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/auth/viewmodels/language_view_model.dart';
import 'package:fdsmart/features/auth/views/profile_screen.dart';
import 'package:fdsmart/features/home/views/notification_screen.dart';
import 'package:fdsmart/features/home/widgets/category_card.dart';
import 'package:fdsmart/features/home/widgets/special_offer_card.dart';
import 'package:fdsmart/features/menu/views/menu_screen.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/orders/views/order_history_screen.dart';
import 'package:fdsmart/features/orders/views/order_placement_screen.dart';
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:fdsmart/features/orders/views/nutrition_tracker_screen.dart';
import 'package:fdsmart/features/orders/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription? _orderSubscription;
  final Set<String> _notifiedOrders = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListener();
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    final orderModel = Provider.of<OrderViewModel>(context, listen: false);
    final userId = auth.currentUser?.uid;

    if (userId != null) {
      _orderSubscription = orderModel.getMyOrdersStream(userId).listen((
        orders,
      ) {
        for (var order in orders) {
          final key = "${order.id}_${order.status}";
          if ((order.status == 'ready' || order.status == 'completed') &&
              !_notifiedOrders.contains(key)) {
            _notifiedOrders.add(key);
            _showNotification(order);
          }
        }
      });
    }
  }

  void _showNotification(OrderModel order) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Order #${order.tokenNumber} is ${order.status.toUpperCase()}!",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: order.status == 'ready'
            ? AppColors.success
            : AppColors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "HISTORY",
          textColor: Colors.white,
          onPressed: () => setState(() => _currentIndex = 2),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildNavIcon(IconData icon, int index, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: active ? [
          BoxShadow(
            color: AppColors.primaryShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Icon(
        icon,
        size: 24,
        color: active ? Colors.white : AppColors.textTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;
    final String userName;
    if (user != null) {
      userName = (user.name != null && user.name!.isNotEmpty)
          ? user.name!
          : (user.email.split('@')[0]);
    } else {
      userName = 'User';
    }
    final langModel = Provider.of<LanguageViewModel>(context);

    final List<Widget> pages = [
      _buildDashboard(userName, langModel),
      const MenuScreen(),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      floatingActionButton: Consumer<OrderViewModel>(
        builder: (context, orderModel, child) {
          final user = Provider.of<AuthViewModel>(
            context,
            listen: false,
          ).currentUser;
          if (orderModel.cartItems.isEmpty || user?.role == 'admin')
            return const SizedBox.shrink();
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryShadow,
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
              label: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      "${orderModel.cartItems.length} Items",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderPlacementScreen()),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textTertiary,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.home_outlined, 0),
                activeIcon: _buildNavIcon(Icons.home_rounded, 0, active: true),
                label: langModel.translate('home'),
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.restaurant_menu_outlined, 1),
                activeIcon: _buildNavIcon(Icons.restaurant_menu_rounded, 1, active: true),
                label: langModel.translate('menu'),
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.receipt_long_outlined, 2),
                activeIcon: _buildNavIcon(Icons.receipt_long_rounded, 2, active: true),
                label: langModel.translate('orders'),
              ),
              BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_outline_rounded, 3),
                activeIcon: _buildNavIcon(Icons.person_rounded, 3, active: true),
                label: langModel.translate('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(String userName, LanguageViewModel langModel) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.accent,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              "What would you like to eat today?",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider, width: 1),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  langModel.translate('todays_specials'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<MenuViewModel>(
                      context,
                      listen: false,
                    ).setSearchQuery("");
                    setState(() => _currentIndex = 1);
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Consumer<MenuViewModel>(
                builder: (context, menuModel, child) {
                  final specials = menuModel.specialItems;
                  if (menuModel.isLoading && specials.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (specials.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text("Coming soon: Exclusive deals!"),
                      ),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: specials.length,
                    separatorBuilder: (c, i) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final item = specials[index];
                      return SpecialOfferCard(
                        item: item,
                        discount: index % 2 == 0 ? "20% OFF" : "SALE",
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Innovative Features",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                CategoryCard(
                  title: langModel.translate('healthy_picks'),
                  icon: Icons.eco_rounded,
                  color: Colors.green,
                  onTap: () {
                    Provider.of<MenuViewModel>(
                      context,
                      listen: false,
                    ).setSearchQuery("healthy");
                    setState(() => _currentIndex = 1);
                  },
                ),
                CategoryCard(
                  title: langModel.translate('order_tracker'),
                  icon: Icons.track_changes_rounded,
                  color: Colors.orange,
                  onTap: () {
                    setState(() => _currentIndex = 2);
                  },
                ),
                CategoryCard(
                  title: langModel.translate('nutrition_info'),
                  icon: Icons.fitness_center_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NutritionTrackerScreen(),
                      ),
                    );
                  },
                ),
                CategoryCard(
                  title: langModel.translate('favourites'),
                  icon: Icons.favorite_rounded,
                  color: Colors.red,
                  onTap: () {
                    Provider.of<MenuViewModel>(
                      context,
                      listen: false,
                    ).setSearchQuery("fav:only");
                    setState(() => _currentIndex = 1);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
