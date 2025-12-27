import 'package:fdsmart/core/widgets/app_header.dart';
import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/menu/views/menu_item_card.dart';
import 'package:fdsmart/features/menu/views/menu_item_detail_screen.dart';
import 'package:fdsmart/features/auth/viewmodels/language_view_model.dart';
import 'package:fdsmart/features/auth/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langModel = Provider.of<LanguageViewModel>(context);
    final authModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: langModel.translate('search_hint'),
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.textTertiary.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textPrimary,
                                size: 16,
                              ),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (val) {
                    setState(() {}); // Update UI to show/hide clear button
                    Provider.of<MenuViewModel>(
                      context,
                      listen: false,
                    ).setSearchQuery(val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.restaurant_rounded, size: 20),
                    text: langModel.translate('food'),
                  ),
                  Tab(
                    icon: const Icon(Icons.local_cafe_rounded, size: 20),
                    text: langModel.translate('drink'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Consumer<MenuViewModel>(
                builder: (context, model, child) {
                  // Sync favorites
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    model.setUserFavorites(
                      authModel.currentUser?.favorites ?? [],
                    );
                  });

                  if (model.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (model.errorMessage != null && model.items.isEmpty) {
                    return Center(
                      child: Text(
                        model.errorMessage!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMenuGrid(context, model.foodItems),
                      _buildMenuGrid(context, model.drinkItems),
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

  Widget _buildMenuGrid(BuildContext context, List items) {
    if (items.isEmpty) {
      return const Center(child: Text("No items available"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemCard(
          item: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MenuItemDetailScreen(item: item),
              ),
            );
          },
        );
      },
    );
  }
}
