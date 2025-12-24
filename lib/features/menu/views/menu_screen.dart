import 'package:fdsmart/core/theme/app_colors.dart';
import 'package:fdsmart/features/menu/viewmodels/menu_view_model.dart';
import 'package:fdsmart/features/menu/views/menu_item_card.dart';
import 'package:fdsmart/features/menu/views/menu_item_detail_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Our Menu'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: "Food"),
              Tab(text: "Drinks"),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
          ],
        ),
        body: Consumer<MenuViewModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (model.errorMessage != null) {
              // Show error but still might show data if we have fallback logic in viewmodel
              // For now, if items empty and error exists
              if (model.items.isEmpty) {
                return Center(
                  child: Text(
                    model.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }
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
