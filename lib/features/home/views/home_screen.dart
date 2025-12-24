import 'package:fdsmart/core/widgets/app_header.dart';

import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/core/widgets/offline_banner.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:fdsmart/features/home/widgets/category_card.dart';
import 'package:fdsmart/features/home/widgets/special_offer_card.dart';
import 'package:fdsmart/features/menu/views/menu_screen.dart';
import 'package:fdsmart/features/orders/views/order_history_screen.dart';
import 'package:fdsmart/features/orders/views/order_placement_screen.dart'; // For Floating Action Button eventually
import 'package:fdsmart/features/orders/viewmodels/order_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;
    final userName = user?.name ?? 'Guest';

    final List<Widget> pages = [
      _buildDashboard(userName),
      const MenuScreen(),
      const OrderHistoryScreen(), // Linked OrderHistoryScreen
      const Center(
        child: Text("Profile Page Placeholder"),
      ), // Replace with ProfileScreen
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
          // We only show the cart button if items are in the cart.
          if (orderModel.cartItems.isEmpty) return const SizedBox.shrink();
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
          backgroundColor: Colors.transparent, // Handled by container
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
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

  Widget _buildDashboard(String userName) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  const Text(
                    'Search for food, drinks...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Today's Specials
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Specials",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "See All",
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: const [
                  SpecialOfferCard(
                    title: "Burger Combo",
                    price: "Tokens: 12",
                    imageColor: Colors.orange,
                    discount: "20% OFF",
                  ),
                  SizedBox(width: 16),
                  SpecialOfferCard(
                    title: "Cool Drinks",
                    price: "Tokens: 5",
                    imageColor: Colors.blue,
                    discount: "Buy 1 Get 1",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Categories / Quick Actions
            const Text(
              "Explore Menu",
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
                  title: "Food Menu",
                  icon: Icons.lunch_dining_rounded,
                  color: Colors.orange,
                  onTap: () {
                    // Navigate to Food Tab in Menu
                    setState(() => _currentIndex = 1);
                  },
                ),
                CategoryCard(
                  title: "Drinks",
                  icon: Icons.local_cafe_rounded,
                  color: Colors.brown,
                  onTap: () {
                    // Navigate to Drink Tab in Menu
                    setState(() => _currentIndex = 1);
                  },
                ),
                CategoryCard(
                  title: "Favourites",
                  icon: Icons.favorite_rounded,
                  color: Colors.red,
                  onTap: () {},
                ),
                CategoryCard(
                  title: "My Orders",
                  icon: Icons.history_edu_rounded,
                  color: Colors.teal,
                  onTap: () {
                    setState(() => _currentIndex = 2);
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
