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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
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
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              "${orderModel.cartItems.length} Items",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderPlacementScreen()),
              );
            },
          );
        },
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
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: langModel.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: langModel.translate('menu'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_rounded),
              label: langModel.translate('orders'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: langModel.translate('profile'),
            ),
          ],
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_getGreeting()} $userName!",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "What would you like to eat today?",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 22,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    Provider.of<AuthViewModel>(
                      context,
                      listen: false,
                    ).signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: langModel.translate('search_hint'),
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<MenuViewModel>(
                              context,
                              listen: false,
                            ).setSearchQuery("");
                          },
                        )
                      : null,
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  setState(() {}); // Update UI to show/hide clear button
                  Provider.of<MenuViewModel>(
                    context,
                    listen: false,
                  ).setSearchQuery(val);
                },
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    // Navigate to Menu tab when user presses enter
                    setState(() => _currentIndex = 1);
                  }
                },
              ),
            ),
            // Show search results preview if searching
            if (_searchController.text.isNotEmpty)
              Consumer<MenuViewModel>(
                builder: (context, menuModel, child) {
                  final searchResults = menuModel.itemsWithFavorites(
                    Provider.of<AuthViewModel>(
                          context,
                        ).currentUser?.favorites ??
                        [],
                  );
                  if (searchResults.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "No items found for '${_searchController.text}'",
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Found ${searchResults.length} items",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _currentIndex = 1);
                              },
                              child: const Text(
                                "View All →",
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          itemCount: searchResults.length > 5
                              ? 5
                              : searchResults.length,
                          separatorBuilder: (c, i) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final item = searchResults[index];
                            return SpecialOfferCard(
                              item: item,
                              discount: "RESULT",
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            const SizedBox(height: 32),
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
